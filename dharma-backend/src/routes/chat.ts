import { Router, Request, Response } from "express";
import OpenAI from "openai";

const SYSTEM_PROMPT = `You are a warm, compassionate spiritual guide deeply versed in Buddhism and Hinduism. Your purpose is to support seekers on their spiritual journey with wisdom drawn from these traditions.

Guidelines:
- Draw from Buddhist teachings (Dhammapada, Four Noble Truths, Eightfold Path, Zen, Theravada, Mahayana) and Hindu scriptures (Bhagavad Gita, Upanishads, Vedanta, Yoga Sutras)
- Be warm, gentle, and encouraging — like a wise teacher speaking to a student
- Offer practical guidance: meditation techniques, mantras, breathing exercises, daily practices
- When quoting scripture, cite the source (e.g., "As the Bhagavad Gita teaches in Chapter 2, Verse 47...")
- Keep responses concise but meaningful — aim for depth over length
- Respect all paths and traditions; never be dogmatic
- If asked about topics outside spirituality, gently guide the conversation back to spiritual practice and inner growth
- Use simple, accessible language — avoid unnecessary jargon
- Do not return markdown formatting!! Meaning no ** in the messages please!`;

interface ChatMessage {
    role: "user" | "assistant" | "system";
    content: string;
}

interface ChatRequestBody {
    messages: ChatMessage[];
}

export function createChatRouter(openai: OpenAI) {
    const router = Router();

    router.post("/", async (req: Request, res: Response): Promise<void> => {
        try {
            const { messages } = req.body as ChatRequestBody;

            if (!messages || !Array.isArray(messages) || messages.length === 0) {
                res.status(400).json({ error: "messages array is required" });
                return;
            }

            // Prepend system prompt to conversation
            const fullMessages: ChatMessage[] = [
                { role: "system", content: SYSTEM_PROMPT },
                ...messages,
            ];

            const completion = await openai.chat.completions.create({
                model: "gpt-4o-mini",
                messages: fullMessages,
                temperature: 0.7,
                max_tokens: 1024,
            });

            const reply = completion.choices[0]?.message?.content || "";

            if (process.env.NODE_ENV !== "production") {
                console.log("--- Chat Debug ---");
                console.log("User:", messages[messages.length - 1]?.content);
                console.log("AI:", reply.substring(0, 50) + (reply.length > 50 ? "..." : ""));
                console.log("------------------");
            }

            res.json({ reply });
        } catch (error: any) {
            console.error("Chat API error:", error?.message || error);

            if (error?.status === 401) {
                res.status(500).json({ error: "Invalid OpenAI API key" });
                return;
            }

            res.status(500).json({ error: "Failed to get response from AI" });
        }
    });

    return router;
}
