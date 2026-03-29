import dotenv from "dotenv";

// Load env FIRST — before any other imports that may use process.env
dotenv.config();

import express from "express";
import cors from "cors";
import morgan from "morgan";
import { createOpenAIClient } from "./lib/openai";
import { createSupabaseClient } from "./lib/supabase";
import { createArticlesRouter } from "./routes/articles";
import { createChatRouter } from "./routes/chat";

const app = express();
const PORT = process.env.PORT || 3000;

// Init OpenAI client after dotenv has loaded
const openai = createOpenAIClient();
const supabase = createSupabaseClient();

// Middleware
app.use(morgan("dev")); // HTTP request logging
app.use((req, _res, next) => {
    console.log(`[${new Date().toISOString()}] ${req.method} ${req.url}`);
    next();
});
app.use(cors());
app.use(express.json());

// Routes
app.use("/api/chat", createChatRouter(openai));
app.use("/api/articles", createArticlesRouter(supabase));

// Health check
app.get("/api/health", (_req, res) => {
    res.json({ status: "ok" });
});

// Start server
app.listen(PORT, () => {
    console.log(`Dharma backend running on http://localhost:${PORT}`);
});
