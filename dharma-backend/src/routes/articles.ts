import { Router, Request, Response } from "express";
import { SupabaseClient } from "@supabase/supabase-js";

interface LearnArticle {
    id: string;
    title: string;
    subtitle: string | null;
    image_url: string | null;
    tags: string[];
    estimated_read_mins: number | null;
    content: string | null;
    created_at: string;
}

export function createArticlesRouter(supabase: SupabaseClient) {
    const router = Router();

    router.get("/", async (_req: Request, res: Response): Promise<void> => {
        try {
            const { data, error } = await supabase
                .from("learn_articles")
                .select("id, title, subtitle, image_url, tags, estimated_read_mins, content, created_at")
                .order("created_at", { ascending: true })
                .order("title", { ascending: true });

            if (error) {
                throw error;
            }

            res.json({ articles: (data ?? []) as LearnArticle[] });
        } catch (error: any) {
            console.error("Articles API error:", error?.message || error);
            res.status(500).json({ error: "Failed to load learn articles" });
        }
    });

    return router;
}