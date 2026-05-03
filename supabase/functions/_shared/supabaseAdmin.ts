import { createClient } from "@supabase/supabase-js";

// cant use SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY if testing locally, so use dummies
const supabaseUrl = Deno.env.get("MY_SUPABASE_URL") ??
  Deno.env.get("SUPABASE_URL") ?? "";
const supabaseKey = Deno.env.get("MY_SUPABASE_SERVICE_ROLE_KEY") ??
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";

export const supabaseAdmin = createClient(supabaseUrl, supabaseKey);
