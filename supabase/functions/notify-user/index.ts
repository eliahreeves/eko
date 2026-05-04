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

async function sendWebPush(
  subscription: unknown,
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

    const sub = typeof subscription === "string"
      ? JSON.parse(subscription)
      : subscription;
    await webpush.sendNotification(
      sub,
      JSON.stringify({ title, body, data: payload }),
    );
    return true;
  } catch (error) {
    console.error("WebPush Error:", error);
    return false;
  }
}

// FIXME should be stored in DB, probably won't persist across edge func invocations
let cachedApnsToken: string | null = null;
let tokenGeneratedAt = 0;

async function getApnsToken(config: ApnsConfig) {
  const now = Date.now();
  // Reuse the token if it's less than 30 minutes old (1800,000 milliseconds)
  // https://developer.apple.com/documentation/usernotifications/establishing-a-token-based-connection-to-apns#Refresh-your-token-regularly
  if (cachedApnsToken && (now - tokenGeneratedAt < 1800000)) {
    return cachedApnsToken;
  }

  const { teamId, keyId, privateKeyP8 } = config;
  const ecPrivateKey = await importPKCS8(privateKeyP8, "ES256");
  const jwt = await new SignJWT({})
    .setProtectedHeader({ alg: "ES256", kid: keyId })
    .setIssuedAt()
    .setIssuer(teamId)
    .sign(ecPrivateKey);

  cachedApnsToken = jwt;
  tokenGeneratedAt = now;
  return jwt;
}

async function sendAPNS(
  deviceToken: string,
  payload: unknown,
  config: ApnsConfig,
  title: string,
  body: string,
) {
  // https://developer.apple.com/documentation/usernotifications/sending-notification-requests-to-apns
  const { privateKeyP8, bundleId } = config;

  if (!privateKeyP8) {
    console.error("APNS Error: Missing private key.");
    return false;
  }

  try {
    const jwt = await getApnsToken(config);

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
      `https://${apnsHost}/3/device/${deviceToken}`,
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

    if (!res.ok) {
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
  const userData = await getUser(record.source_uid || record.author_uid);
  const sourceName = userData?.name || "Someone";

  if (record.table === "activity") {
    if (record.type === "comment") {
      const commentData = await getComment(record.comment_id);
      title = `${sourceName} commented on your post!`;
      body = commentData?.body || body;
    } else if (record.type === "eko") {
      title = `${sourceName} eko'ed your post!`;
    } else if (record.type === "follow") {
      title = `${sourceName} followed you!`;
    } else if (record.type === "comment_tag") {
      title = `${sourceName} tagged you in a comment!`;
      const commentData = await getComment(record.comment_id);
      body = commentData?.body || body;
    } else if (record.type === "post_tag") {
      title = `${sourceName} tagged you in a post!`;
      const postData = await getPost(record.post_id);
      body = postData?.title || postData?.body || body;
    } else if (record.type === "post") {
      title = `New post from ${sourceName}!`;
      const postData = await getPost(record.post_id);
      body = postData?.title || postData?.body || body;
    }
  } else if (record.table == "posts") {
    title = `New post from ${sourceName}!`;
    body = record.title || record.body || body;
  }
  return { title, body };
}

Deno.serve(async (req) => {
  const { record } = await req.json();

  const allowedTables = ["activity", "posts"];
  if (!allowedTables.includes(record.table)) {
    return new Response("Unsupported table", { status: 400 });
  }

  const { title, body } = await getNotificationPayload(record);
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
      sendAPNS(device.token, record, apnsConfig, title, body)
    ),
    ...webPushDevices.map((device: Device) =>
      sendWebPush(device.token, record, title, body)
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
