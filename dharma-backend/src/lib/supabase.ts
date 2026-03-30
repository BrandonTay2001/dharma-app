import { createClient, SupabaseClient } from "@supabase/supabase-js";

export function createSupabaseClient(): SupabaseClient {
    const supabaseUrl = process.env.SUPABASE_URL;
    const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.SUPABASE_ANON_KEY;

    if (!supabaseUrl) {
        throw new Error("SUPABASE_URL is not set in environment variables");
    }

    if (!supabaseKey) {
        throw new Error(
            "Set SUPABASE_SERVICE_ROLE_KEY or SUPABASE_ANON_KEY in environment variables",
        );
    }

    return createClient(supabaseUrl, supabaseKey, {
        auth: {
            autoRefreshToken: false,
            persistSession: false,
        },
    });
}

export function createSupabaseAdminClient(): SupabaseClient {
    const supabaseUrl = process.env.SUPABASE_URL;
    const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

    if (!supabaseUrl) {
        throw new Error("SUPABASE_URL is not set in environment variables");
    }

    if (!serviceRoleKey) {
        throw new Error("SUPABASE_SERVICE_ROLE_KEY is required for admin operations");
    }

    return createClient(supabaseUrl, serviceRoleKey, {
        auth: {
            autoRefreshToken: false,
            persistSession: false,
        },
    });
}