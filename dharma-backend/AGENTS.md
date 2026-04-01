# Dharma Backend

Express + TypeScript API server for the Dharma spirituality app.

## Structure

```
dharma-backend/
├── src/
│   ├── index.ts           # Express app entry point
│   └── routes/
│       └── chat.ts        # POST /api/chat – OpenAI proxy
├── tsconfig.json
├── package.json
├── .env                   # Local secrets (not committed)
└── .env.example           # Template for env vars
```

## API Endpoints

| Method | Path          | Description                    |
|--------|---------------|--------------------------------|
| GET    | /api/articles | Fetch all learn articles       |
| DELETE | /api/account  | Delete the authenticated user  |
| POST   | /api/chat     | Send messages, get AI response |
| GET    | /api/health   | Health check                   |

### GET /api/articles

Fetches all learn articles from the database ordered by creation date and title.

**Response:**
```json
{
  "articles": [
    {
      "id": "uuid",
      "title": "Understanding Dharma",
      "subtitle": "A foundational guide",
      "image_url": "https://...",
      "tags": ["dharma", "buddhism"],
      "estimated_read_mins": 5,
      "content": "Article content here...",
      "created_at": "2025-03-29T12:00:00Z"
    }
  ]
}
```

### POST /api/chat

Sends a message to the AI spiritual guide and receives a compassionate response based on Buddhist and Hindu teachings.

**Request:**
```json
{
  "messages": [
    { "role": "user", "content": "What is karma?" }
  ]
}
```

**Response:**
```json
{
  "reply": "Karma, from the Sanskrit word meaning 'action'..."
}
```

### DELETE /api/account

Deletes the authenticated user's account and all associated data.

**Auth:** Requires an `Authorization: Bearer <access-token>` header for the currently signed-in user.

**Response:** 204 No Content

Deletes the Supabase auth user. Because `public.users` now cascades from `auth.users`, this also removes the user's profile row and all dependent app data.

## Running

1. Copy `.env.example` to `.env` and add your `OPENAI_API_KEY`, `SUPABASE_URL`, `SUPABASE_ANON_KEY`, and `SUPABASE_SERVICE_ROLE_KEY`
2. `npm install`
3. `npm run dev` — starts with hot reload on port 3000

## Key Patterns

### Dependency Injection for OpenAI

The OpenAI client is **never instantiated at module load time**. Instead:

1. `src/index.ts` calls `dotenv.config()` as the very first step
2. `createOpenAIClient()` in `src/lib/openai.ts` is called next — reads `OPENAI_API_KEY` from the now-loaded env
3. The client is passed into route factories: `createChatRouter(openai)`

This ensures env vars are loaded before any SDK client is constructed and makes routes easy to test (pass a mock client).

```
dotenv.config()
  → createOpenAIClient()          // src/lib/openai.ts
    → createChatRouter(openai)    // src/routes/chat.ts
```

**Do not** create `new OpenAI()` at the top level of any module — always receive it as a parameter.

## Scripts

- `npm run dev` — Development server (nodemon + ts-node)
- `npm run build` — Compile TypeScript to `dist/`
- `npm start` — Run compiled output

## Key Patterns

- System prompt in `routes/chat.ts` guides AI tone (warm, compassionate, Buddhist/Hindu focus)
- Message rate limiting (5/day) is enforced client-side in the iOS `ChatViewModel`
- Uses `gpt-4o-mini` model for cost efficiency
