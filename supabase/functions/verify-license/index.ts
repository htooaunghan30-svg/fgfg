// Supabase Edge Function: verify-license
// Deploy: supabase functions deploy verify-license --no-verify-jwt
// Required secrets:
// - SUPABASE_URL
// - SUPABASE_SERVICE_ROLE_KEY (or SERVICE_ROLE_KEY)
// - LICENSE_PEPPER
// - LICENSE_SIGN_PRIVATE_KEY_B64
// - LICENSE_SIGN_KID
// - HF_CLIENT_HEADER_VALUE

import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { encodeBase64, decodeBase64 } from "https://deno.land/std@0.224.0/encoding/base64.ts";

function sortJson(value: unknown): unknown {
  if (Array.isArray(value)) return value.map(sortJson);
  if (value && typeof value === "object") {
    const obj = value as Record<string, unknown>;
    return Object.keys(obj)
      .sort()
      .reduce<Record<string, unknown>>((acc, key) => {
        acc[key] = sortJson(obj[key]);
        return acc;
      }, {});
  }
  return value;
}

function canonicalJson(payload: Record<string, unknown>): string {
  return JSON.stringify(sortJson(payload));
}

function toHex(bytes: Uint8Array): string {
  return Array.from(bytes).map((b) => b.toString(16).padStart(2, "0")).join("");
}

async function hmacSha256Hex(message: string, secret: string): Promise<string> {
  const key = await crypto.subtle.importKey(
    "raw",
    new TextEncoder().encode(secret),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const sig = await crypto.subtle.sign("HMAC", key, new TextEncoder().encode(message));
  return toHex(new Uint8Array(sig));
}

async function signPayload(payload: Record<string, unknown>): Promise<string> {
  const privateKeyB64 = Deno.env.get("LICENSE_SIGN_PRIVATE_KEY_B64") ?? "";
  if (!privateKeyB64) throw new Error("missing signing private key");

  const privateKey = decodeBase64(privateKeyB64);
  const data = new TextEncoder().encode(canonicalJson(payload));

  const key = await crypto.subtle.importKey(
    "pkcs8",
    privateKey,
    { name: "Ed25519" },
    false,
    ["sign"],
  );
  const sig = await crypto.subtle.sign("Ed25519", key, data);
  return encodeBase64(new Uint8Array(sig));
}

function json(status: number, body: Record<string, unknown>): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}

const DEFAULT_KID = "license-ed25519-2026-01";

async function signed(status: number, payload: Record<string, unknown>): Promise<Response> {
  const envelope = {
    kid: Deno.env.get("LICENSE_SIGN_KID") ?? DEFAULT_KID,
    alg: "Ed25519",
    payload,
    signature: await signPayload(payload),
  };
  return json(status, envelope);
}

async function signedError(
  status: number,
  code: string,
  extra: Record<string, unknown> = {},
): Promise<Response> {
  const payload: Record<string, unknown> = {
    ok: false,
    code,
    error: code,
    issuedAt: new Date().toISOString(),
    nonce: crypto.randomUUID(),
    ...extra,
  };
  return signed(status, payload);
}

async function callRpcWithArgs(
  supabaseUrl: string,
  apiKey: string,
  args: Record<string, unknown>,
): Promise<unknown> {
  const rpcUrl = `${supabaseUrl}/rest/v1/rpc/verify_and_claim_license`;
  const res = await fetch(rpcUrl, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "apikey": apiKey,
      "Authorization": `Bearer ${apiKey}`,
      "Prefer": "params=single-object",
    },
    body: JSON.stringify(args),
  });

  const text = await res.text();
  let parsed: unknown = null;
  if (text.trim().length > 0) {
    try {
      parsed = JSON.parse(text);
    } catch {
      parsed = null;
    }
  }

  if (!res.ok) {
    throw new Error(
      `RPC_HTTP_${res.status}:${typeof parsed === "object" ? JSON.stringify(parsed) : text}`,
    );
  }
  return parsed;
}

async function callVerifyAndClaimLicense(
  licenseHash: string,
  deviceHash: string,
  appVersion: string,
  platform: string,
  ip: string | null,
  userAgent: string | null,
): Promise<Record<string, unknown>> {
  const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
  const serviceRole =
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ??
    Deno.env.get("SERVICE_ROLE_KEY") ??
    "";

  if (!supabaseUrl || !serviceRole) {
    return { ok: false, code: "CONFIG_MISSING_SUPABASE_SERVICE_ROLE" };
  }

  const args6 = {
    p_license_key_hash: licenseHash,
    p_device_hash: deviceHash,
    p_app_version: appVersion,
    p_platform: platform,
    p_ip: ip,
    p_user_agent: userAgent,
  };

  try {
    const r6 = await callRpcWithArgs(supabaseUrl, serviceRole, args6);
    if (r6 && typeof r6 === "object" && !Array.isArray(r6)) {
      return r6 as Record<string, unknown>;
    }
  } catch {
    // Backward compatibility fallback.
  }

  const args4 = {
    p_license_hash: licenseHash,
    p_device_id: deviceHash,
    p_app_version: appVersion,
    p_platform: platform,
  };
  const r4 = await callRpcWithArgs(supabaseUrl, serviceRole, args4);
  const row = Array.isArray(r4) ? r4[0] : r4;
  if (!row || typeof row !== "object") return { ok: false, code: "SERVER_ERROR" };

  const m = row as Record<string, unknown>;
  return {
    ok: Boolean(m.ok),
    code: String(m.code ?? "SERVER_ERROR"),
    license_id: m.license_id ?? null,
    expires_at: m.expires_at ?? null,
    remaining_activations: m.remaining_activations ?? 0,
    plan_code: m.plan_code ?? null,
    allowed_features: m.allowed_features ?? [],
  };
}

serve(async (req) => {
  try {
    if (req.method !== "POST") {
      return json(405, { ok: false, error: "METHOD_NOT_ALLOWED" });
    }

    const expectedClient = Deno.env.get("HF_CLIENT_HEADER_VALUE") ?? "";
    const gotClient = req.headers.get("x-hf-client") ?? "";
    if (!expectedClient || gotClient !== expectedClient) {
      return await signedError(401, "UNAUTHORIZED_CLIENT");
    }

    const body = await req.json().catch(() => null) as Record<string, unknown> | null;
    const licenseKey = String(body?.licenseKey ?? body?.license_key ?? "").trim().toUpperCase();
    const deviceId = String(body?.deviceId ?? body?.device_hash ?? body?.deviceHash ?? "").trim();
    const appVersion = String(body?.appVersion ?? body?.app_version ?? "").trim();
    const platform = String(body?.platform ?? "").trim();

    if (!licenseKey || !deviceId || !appVersion || !platform) {
      return await signedError(400, "INVALID_REQUEST");
    }

    const pepper = Deno.env.get("LICENSE_PEPPER") ?? "";
    if (!pepper) {
      return await signedError(500, "CONFIG_MISSING_LICENSE_PEPPER");
    }

    const licenseHashHex = await hmacSha256Hex(licenseKey, pepper);

    const ip =
      req.headers.get("cf-connecting-ip") ??
      req.headers.get("x-forwarded-for")?.split(",")[0]?.trim() ??
      null;
    const userAgent = req.headers.get("user-agent");

    const rpc = await callVerifyAndClaimLicense(
      licenseHashHex,
      deviceId,
      appVersion,
      platform,
      ip,
      userAgent,
    );

    const payload = {
      ok: rpc.ok === true,
      code: String(rpc.code ?? "SERVER_ERROR").toUpperCase(),
      licenseId: (rpc.license_id as string | null | undefined) ?? null,
      expiresAt: (rpc.expires_at as string | null | undefined) ?? null,
      remainingActivations: Number(rpc.remaining_activations ?? 0),
      planCode: (rpc.plan_code as string | null | undefined) ?? null,
      allowedFeatures: Array.isArray(rpc.allowed_features)
        ? (rpc.allowed_features as unknown[]).map((x) => String(x))
        : [],
      issuedAt: new Date().toISOString(),
      nonce: crypto.randomUUID(),
    };

    const statusCode = payload.ok ? 200 : 400;
    // Record only the outcome code. Never log the license key or device ID.
    console.info("verify-license outcome", {
      statusCode,
      ok: payload.ok,
      code: payload.code,
    });
    return await signed(statusCode, payload);
  } catch (err) {
    console.error("verify-license error", err);
    return json(500, {
      ok: false,
      code: "INTERNAL_SERVER_ERROR",
      error: "INTERNAL_SERVER_ERROR",
    });
  }
});
