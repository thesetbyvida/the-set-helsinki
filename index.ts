import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const json = (payload: unknown, status = 200) =>
  new Response(JSON.stringify(payload), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const url = Deno.env.get("SUPABASE_URL");
    const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
    if (!url || !serviceKey) return json({ error: "Missing function secrets" }, 500);

    const admin = createClient(url, serviceKey);
    const callerClient = createClient(url, serviceKey, {
      global: { headers: { Authorization: req.headers.get("Authorization") || "" } },
    });

    const { data: authData } = await callerClient.auth.getUser();
    if (!authData.user) return json({ error: "Not authenticated" }, 401);

    const { data: profile } = await admin
      .from("profiles")
      .select("role,is_active")
      .eq("id", authData.user.id)
      .single();

    if (profile?.role !== "super_admin" || profile?.is_active === false) {
      return json({ error: "Only active super_admin can manage users" }, 403);
    }

    const body = await req.json();

    if (body.action === "create_user") {
      const email = String(body.email || "").trim().toLowerCase();
      const password = String(body.password || "");
      const full_name = String(body.full_name || "").trim();
      const role = String(body.role || "employee");
      const restaurant_ids = Array.isArray(body.restaurant_ids) ? body.restaurant_ids : [];

      if (!email || !password || !full_name) return json({ error: "Missing fields" }, 400);

      const { data: created, error: createError } = await admin.auth.admin.createUser({
        email, password, email_confirm: true, user_metadata: { full_name },
      });
      if (createError) return json({ error: createError.message }, 400);

      const userId = created.user.id;
      const { error: profileError } = await admin.from("profiles").upsert({
        id: userId, email, full_name, role, is_active: true,
      });
      if (profileError) return json({ error: profileError.message }, 400);

      if (restaurant_ids.length) {
        const { error: linkError } = await admin.from("user_restaurants").insert(
          restaurant_ids.map((restaurant_id: string) => ({ user_id: userId, restaurant_id }))
        );
        if (linkError) return json({ error: linkError.message }, 400);
      }

      return json({ success: true, user_id: userId });
    }

    if (body.action === "set_password") {
      const user_id = String(body.user_id || "");
      const password = String(body.password || "");
      if (!user_id || password.length < 6) return json({ error: "Invalid data" }, 400);
      const { error } = await admin.auth.admin.updateUserById(user_id, { password });
      if (error) return json({ error: error.message }, 400);
      return json({ success: true });
    }

    return json({ error: "Unknown action" }, 400);
  } catch (error) {
    return json({ error: String(error?.message || error) }, 500);
  }
});
