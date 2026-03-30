import { Request, Response, Router } from "express";
import { SupabaseClient } from "@supabase/supabase-js";

function extractAccessToken(req: Request): string | null {
    const authorizationHeader = req.header("Authorization");

    if (!authorizationHeader?.startsWith("Bearer ")) {
        return null;
    }

    const accessToken = authorizationHeader.slice("Bearer ".length).trim();
    return accessToken.length > 0 ? accessToken : null;
}

export function createAccountRouter(supabaseAdmin: SupabaseClient) {
    const router = Router();

    router.delete("/", async (req: Request, res: Response): Promise<void> => {
        try {
            const accessToken = extractAccessToken(req);

            if (!accessToken) {
                res.status(401).json({ error: "Missing bearer token" });
                return;
            }

            const {
                data: { user },
                error: getUserError,
            } = await supabaseAdmin.auth.getUser(accessToken);

            if (getUserError || !user) {
                res.status(401).json({ error: "Invalid or expired session" });
                return;
            }

            // Deleting the auth user cascades through public.users and all user-owned tables.
            const { error: deleteUserError } = await supabaseAdmin.auth.admin.deleteUser(user.id);

            if (deleteUserError) {
                throw deleteUserError;
            }

            res.status(204).send();
        } catch (error: any) {
            console.error("Account deletion API error:", error?.message || error);
            res.status(500).json({ error: "Failed to delete account" });
        }
    });

    return router;
}