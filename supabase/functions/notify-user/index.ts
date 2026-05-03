import { supabaseAdmin } from "../_shared/supabaseAdmin.ts";
import { importPKCS8, SignJWT } from "jose";
import webpush from "web-push";
import "@supabase/functions-js/edge-runtime.d.ts";

interface ApnsConfig {
  teamId: string;
  keyId: string;
  privateKeyP8: string;
  bundleId: string;
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
};

async function sendWebPush(subscription: unknown, payload: unknown) {
  try {
    const pubKey = Deno.env.get("VAPID_PUBLIC_KEY") || "";
    const privKey = Deno.env.get("VAPID_PRIVATE_KEY") || "";

    if (!pubKey || !privKey) {
      console.error("WebPush Error: Missing VAPID keys.");
      return false;
    }

    // FIXME what should be here?
    webpush.setVapidDetails(
      "mailto:admin@example.com",
      pubKey,
      privKey,
    );

    const sub = typeof subscription === "string"
      ? JSON.parse(subscription)
      : subscription;
    await webpush.sendNotification(sub, JSON.stringify(payload));
    return true;
  } catch (error) {
    console.error("WebPush Error:", error);
    return false;
  }
}

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
) {
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
          title: "New Activity",
          body: "You have new activity.",
        },
      },
      data: payload,
    };

    // Use sandbox endpoint if APNS_USE_SANDBOX is true
    const isSandbox = Deno.env.get("APNS_USE_SANDBOX") === "true";
    const apnsHost = isSandbox
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

Deno.serve(async (req) => {
  const { record } = await req.json();
  const targetUid = record.target_uid;

  // Fetch all active devices for the target user
  const { data: devices, error } = await supabaseAdmin
    .from("notifications")
    .select("*")
    .eq("user_uid", targetUid)
    .eq("active", true);

  if (error) {
    console.error("Query Error:", error);
  }

  if (error || !devices || devices.length === 0) {
    return new Response("No devices found", { status: 200 });
  }

  const notifications = devices.map((device: Device) => {
    if (device.notification_type === "apns") {
      return sendAPNS(device.token, record, apnsConfig);
    } else if (device.notification_type === "web_push") {
      return sendWebPush(device.token, record);
    }
  });

  await Promise.all(notifications);

  return new Response(JSON.stringify({ sent: devices.length }), {
    headers: { "Content-Type": "application/json" },
  });
});
