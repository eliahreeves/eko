import { supabaseAdmin } from "../_shared/supabaseAdmin.ts";
import { importPKCS8, SignJWT } from "jose";
import webpush from "web-push";
import "@supabase/functions-js/edge-runtime.d.ts";

interface ApnsConfig {
  teamId: string;
  keyId: string;
  privateKeyP8: string;
  bundleId: string;
  sandbox: boolean;
}

interface Device {
  user_uid: string;
  device_id: string;
  token: string;
  notification_type: "apns" | "web_push" | string;
  [key: string]: unknown;
}

const apnsConfig: ApnsConfig = {
  teamId: Deno.env.get("APNS_TEAM_ID") || "",
  keyId: Deno.env.get("APNS_KEY_ID") || "",
  privateKeyP8: Deno.env.get("APNS_PRIVATE_KEY") || "",
  bundleId: Deno.env.get("APNS_BUNDLE_ID") || "",
  sandbox: Deno.env.get("APNS_USE_SANDBOX") === "true" || false,
};

type WebPushSubscriptionInput = {
  endpoint: string;
  keys?: { p256dh?: string; auth?: string };
};

function parseWebPushSubscription(
  subscription: unknown,
): WebPushSubscriptionInput | null {
  if (
    subscription &&
    typeof subscription === "object" &&
    "endpoint" in subscription
  ) {
    const o = subscription as WebPushSubscriptionInput;
    return typeof o.endpoint === "string" && o.endpoint.length > 0 ? o : null;
  }
  if (typeof subscription !== "string") return null;
  const s = subscription.trim();
  if (!s) return null;
  if (s.startsWith("http://") || s.startsWith("https://")) {
    console.error(
      "WebPush Error: token is a bare URL; store JSON with endpoint and keys (UnifiedPush pubKeySet).",
    );
    return null;
  }
  try {
    const parsed = JSON.parse(s) as WebPushSubscriptionInput;
    if (!parsed?.endpoint || typeof parsed.endpoint !== "string") return null;
    return parsed;
  } catch {
    console.error("WebPush Error: token is not valid subscription JSON.");
    return null;
  }
}

async function deactivateDevice(device: Device) {
  const { error } = await supabaseAdmin
    .from("notifications")
    .update({ active: false })
    .eq("user_uid", device.user_uid)
    .eq("device_id", device.device_id);
  if (error) {
    console.error(`Failed to deactivate device ${device.device_id}:`, error);
  } else {
    console.log(
      `Deactivated expired device ${device.device_id} for user ${device.user_uid}`,
    );
  }
}

async function sendWebPush(
  device: Device,
  payload: unknown,
  title: string,
  body: string,
) {
  try {
    const pubKey = Deno.env.get("VAPID_PUBLIC_KEY") || "";
    const privKey = Deno.env.get("VAPID_PRIVATE_KEY") || "";

    if (!pubKey || !privKey) {
      console.error("WebPush Error: Missing VAPID keys.");
      return false;
    }

    webpush.setVapidDetails(
      "mailto:support@eko-app.com",
      pubKey,
      privKey,
    );

    const sub = parseWebPushSubscription(device.token);
    if (!sub) return false;
    const k = sub.keys;
    if (!k?.p256dh || !k?.auth) {
      console.error(
        "WebPush Error: subscription missing keys; client must re-register and upload full subscription JSON.",
      );
      return false;
    }
    await webpush.sendNotification(
      sub as { endpoint: string; keys: { p256dh: string; auth: string } },
      JSON.stringify({ title, body, data: payload }),
    );
    return true;
  } catch (error: unknown) {
    const webPushError = error as { statusCode?: number };
    if (webPushError?.statusCode === 410) {
      console.warn(
        `WebPush: subscription expired for device ${device.device_id}, deactivating`,
      );
      await deactivateDevice(device);
    } else {
      console.error("WebPush Error:", error);
    }
    return false;
  }
}

async function getApnsToken(config: ApnsConfig) {
  const cacheKey = "apns_token";
  const now = new Date().toISOString();

  // check for valid cached token
  const { data: cached, error: cacheError } = await supabaseAdmin
    .from("functions_cache")
    .select("data, expires_at")
    .eq("cache_key", cacheKey)
    .gt("expires_at", now)
    .maybeSingle();
  if (cacheError) {
    console.error("Error fetching cached APNS token:", cacheError);
  } else if (cached?.data?.token && typeof cached.data.token === "string") {
    return cached.data.token as string;
  }

  // generate new token if no valid cache
  const { teamId, keyId, privateKeyP8 } = config;
  if (!privateKeyP8) {
    console.error("APNS Error: Missing private key for token generation.");
    return null;
  }
  try {
    const ecPrivateKey = await importPKCS8(privateKeyP8, "ES256");
    const jwt = await new SignJWT({})
      .setProtectedHeader({ alg: "ES256", kid: keyId })
      .setIssuedAt()
      .setIssuer(teamId)
      .sign(ecPrivateKey);

    // cache the new token with 30 minute expiry
    const expiresAt = new Date(Date.now() + 30 * 60 * 1000).toISOString();
    const { error: upsertError } = await supabaseAdmin
      .from("functions_cache")
      .upsert(
        {
          cache_key: cacheKey,
          data: { token: jwt },
          expires_at: expiresAt,
          updated_at: now,
        },
        { onConflict: "cache_key" },
      );
    if (upsertError) {
      console.error("Failed to cache new APNS token:", upsertError);
    }
    return jwt;
  } catch (error) {
    console.error("Error generating APNS token:", error);
    return null;
  }
}

async function sendAPNS(
  device: Device,
  payload: unknown,
  config: ApnsConfig,
  title: string,
  body: string,
  isRetry = false, // will retry once if 403 (cert/auth token error) is returned
) {
  // https://developer.apple.com/documentation/usernotifications/sending-notification-requests-to-apns
  const { privateKeyP8, bundleId } = config;

  if (!privateKeyP8) {
    console.error("APNS Error: Missing private key.");
    return false;
  }

  try {
    const jwt = await getApnsToken(config);
    if (!jwt) {
      console.error("APNS Error: No valid APNS token available or generated.");
      return false;
    }

    const apnsPayload = {
      aps: {
        alert: {
          title: title,
          body: body,
        },
      },
      data: payload,
    };

    const apnsHost = config.sandbox
      ? "api.sandbox.push.apple.com"
      : "api.push.apple.com";

    const res = await fetch(
      `https://${apnsHost}/3/device/${device.token}`,
      {
        method: "POST",
        headers: {
          "authorization": `bearer ${jwt}`,
          "apns-topic": bundleId,
          "apns-push-type": "alert",
        },
        body: JSON.stringify(apnsPayload),
      },
    );

    if (res.status === 403) {
      console.warn("APNS token invalid or expired, clearing cache");
      await supabaseAdmin
        .from("functions_cache")
        .delete()
        .eq("cache_key", "apns_token");
      // retry once
      if (!isRetry) {
        console.log("Retrying APNS send with new token...");
        return sendAPNS(device, payload, config, title, body, true);
      } else {
        console.error("APNS send failed after one retry attempt");
        return false;
      }
    } else if (res.status === 410) {
      console.warn(
        `APNS: token expired for device ${device.device_id}, deactivating`,
      );
      await deactivateDevice(device);
    } else if (!res.ok) {
      const errorText = await res.text();
      console.error(`APNS Delivery Failed (${res.status}):`, errorText);
    }

    return res.ok;
  } catch (error) {
    console.error("APNS Error:", error);
    return false;
  }
}

async function getPost(postId: string) {
  const { data, error } = await supabaseAdmin
    .from("posts")
    .select("id, title, body")
    .eq("id", postId)
    .single();

  if (error) {
    console.error(`Error fetching post ${postId}:`, error);
  }
  return data;
}

async function getComment(commentId: string) {
  const { data, error } = await supabaseAdmin
    .from("comments")
    .select("id, body")
    .eq("id", commentId)
    .single();

  if (error) {
    console.error(`Error fetching comment ${commentId}:`, error);
  }
  return data;
}

// TODO we might want to think about doing queries in the notify_user_on_insert() db func instead of here.
async function getUser(userId: string) {
  const { data, error } = await supabaseAdmin
    .from("users")
    .select("name")
    .eq("id", userId)
    .single();

  if (error) {
    console.error(`Error fetching user ${userId}:`, error);
  }
  return data;
}

async function getPostTargets(author_uid: string) {
  const { data, error } = await supabaseAdmin.from("following").select(
    "source_uid",
  ).eq("target_uid", author_uid);
  if (error) {
    console.error(`Error fetching followers for ${author_uid};`, error);
    return [];
  }
  return data?.map((row) => row.source_uid) || [];
}

async function getTargets(record: any) {
  if (record.table === "activity") {
    return [record.target_uid];
  } else if (record.table == "posts") {
    return await getPostTargets(record.author_uid);
  }
  return [];
}

async function getNotificationPayload(record: any) {
  let title = "New Activity";
  let body = "Click to see";
  let payloadData: { type?: string; path?: string } = {};

  const userData = await getUser(record.source_uid || record.author_uid);
  const sourceName = userData?.name || "Someone";

  if (record.table === "activity") {
    if (record.type === "comment") {
      const commentData = await getComment(record.comment_id);
      title = `${sourceName} commented on your post!`;
      body = commentData?.body || body;
      payloadData = { type: "comment", path: record.post_id };
    } else if (record.type === "eko") {
      title = `${sourceName} eko'ed your post!`;
      payloadData = { type: "post", path: record.post_id };
    } else if (record.type === "follow") {
      title = `${sourceName} followed you!`;
      payloadData = { type: "follow", path: record.source_uid };
    } else if (record.type === "comment_tag") {
      title = `${sourceName} tagged you in a comment!`;
      const commentData = await getComment(record.comment_id);
      body = commentData?.body || body;
      payloadData = { type: "tag", path: record.post_id };
    } else if (record.type === "post_tag") {
      title = `${sourceName} tagged you in a post!`;
      const postData = await getPost(record.post_id);
      body = postData?.title || postData?.body || body;
      payloadData = { type: "tag", path: record.post_id };
    } else if (record.type === "post") {
      title = `New post from ${sourceName}!`;
      const postData = await getPost(record.post_id);
      body = postData?.title || postData?.body || body;
      payloadData = { type: "post", path: record.post_id };
    }
  } else if (record.table == "posts") {
    title = `New post from ${sourceName}!`;
    body = record.title || record.body || body;
    payloadData = { type: "post", path: record.id };
  }
  return { title, body, payloadData };
}

Deno.serve(async (req) => {
  const { record } = await req.json();

  const allowedTables = ["activity", "posts"];
  if (!allowedTables.includes(record.table)) {
    return new Response("Unsupported table", { status: 400 });
  }

  const { title, body, payloadData } = await getNotificationPayload(record);
  const targetUids = await getTargets(record);

  if (!targetUids || targetUids.length === 0) {
    return new Response("No targets found", { status: 200 });
  }

  // Fetch all active devices for the target user
  const { data: devices, error } = await supabaseAdmin
    .from("notifications")
    .select("*")
    .in("user_uid", targetUids)
    .eq("active", true);

  if (error) {
    console.error("Query Error:", error);
    return new Response("Error fetching devices", { status: 500 });
  }
  if (!devices || devices.length === 0) {
    return new Response("No devices found", { status: 200 });
  }

  const apnsDevices = devices.filter((d) => d.notification_type === "apns");
  const webPushDevices = devices.filter((d) =>
    d.notification_type === "web_push"
  );

  const notifications = [
    ...apnsDevices.map((device: Device) =>
      sendAPNS(device, payloadData, apnsConfig, title, body)
    ),
    ...webPushDevices.map((device: Device) =>
      sendWebPush(device, payloadData, title, body)
    ),
  ];

  await Promise.all(notifications);

  return new Response(
    JSON.stringify({
      sent: devices.length,
      apns: apnsDevices.length,
      webpush: webPushDevices.length,
    }),
    {
      headers: { "Content-Type": "application/json" },
    },
  );
});
