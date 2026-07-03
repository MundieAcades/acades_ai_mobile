import { serve } from "https://deno.land/std@0.201.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.30.0";

interface RequestBody {
  farm_id?: string | number;
  user_id?: string;
  user_question?: string;
  match_count?: number;
}

const SUPABASE_URL = Deno.env.get("SUPABASE_URL") || "";
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") || "";
const GEMINI_API_KEY = Deno.env.get("GEMINI_API_KEY") || "";
const GEMINI_MODEL = Deno.env.get("GEMINI_MODEL") || "gemini-2.5-flash";
const GEMINI_EMBEDDING_MODEL = Deno.env.get("GEMINI_EMBEDDING_MODEL") || "text-embedding-004";

if (!SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY) {
  console.error("Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY");
}

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

async function getEmbedding(text: string): Promise<number[]> {
  if (!GEMINI_API_KEY) throw new Error("GEMINI_API_KEY is required for embeddings");
  const resp = await fetch(`https://generativelanguage.googleapis.com/v1beta/models/${GEMINI_EMBEDDING_MODEL}:embedContent?key=${GEMINI_API_KEY}`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      model: `models/${GEMINI_EMBEDDING_MODEL}`,
      content: { parts: [{ text }] },
    }),
  });
  const data = await resp.json();
  if (!resp.ok) throw new Error(data.error?.message || "Embedding error");
  return data.embedding?.values ?? [];
}

async function fetchContext(farm_id?: string | number) {
  if (!farm_id) return null;
  const { data, error } = await supabase
    .from("farm_records")
    .select("id, crop_type, planting_date")
    .eq("id", farm_id)
    .maybeSingle();
  if (error) throw error;
  return data;
}

async function similaritySearch(queryEmbedding: number[], matchCount = 5) {
  // Requires a Postgres RPC function `match_documents(query_embedding vector, match_count int)`
  // which returns rows from `messages` ordered by similarity using the <-> operator.
  const { data, error } = await supabase.rpc("match_documents", {
    query_embedding: queryEmbedding,
    match_count: matchCount,
  });
  if (error) throw error;
  return data || [];
}

async function callCompletion(prompt: string) {
  if (!GEMINI_API_KEY) throw new Error("GEMINI_API_KEY is required for completions");
  const resp = await fetch(`https://generativelanguage.googleapis.com/v1beta/models/${GEMINI_MODEL}:generateContent?key=${GEMINI_API_KEY}`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      contents: [{ role: "user", parts: [{ text: prompt }] }],
      generationConfig: { temperature: 0.2, maxOutputTokens: 500 },
    }),
  });
  const data = await resp.json();
  if (!resp.ok) throw new Error(data.error?.message || "Completion error");
  return data.candidates?.[0]?.content?.parts?.[0]?.text ?? "";
}

async function saveConversation(userId: string | undefined, answer: string, question: string, qEmbedding: number[]) {
  if (!userId) return;

  const { data: session, error: sessionError } = await supabase
    .from("chat_sessions")
    .insert([
      {
        user_id: userId,
        title: "AI chat",
        topic: "Agriculture",
        created_at: new Date().toISOString(),
      },
    ])
    .select("id")
    .single();

  if (sessionError || !session?.id) return;

  await supabase.from("chat_messages").insert([
    {
      session_id: session.id,
      user_id: userId,
      role: "user",
      content: question,
      embedding: qEmbedding,
      created_at: new Date().toISOString(),
    },
    {
      session_id: session.id,
      user_id: userId,
      role: "assistant",
      content: answer,
      created_at: new Date().toISOString(),
    },
  ]);
}

serve(async (req: Request) => {
  const headers = { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" };
  if (req.method === "OPTIONS") return new Response("ok", { headers });

  try {
    const body: RequestBody = await req.json().catch(() => ({}));
    if (!body.user_question) return new Response(JSON.stringify({ error: "user_question required" }), { status: 400, headers });

    const farm = await fetchContext(body.farm_id);

    // Get embedding for the user question
    const qEmbedding = await getEmbedding(body.user_question);

    // Get similar chat history
    const matches = await similaritySearch(qEmbedding, body.match_count ?? 5);

    // Build prompt using persona + relevant history
    const system = `You are a friendly local farming mentor. Answer concisely and kindly.`;

    let historyContext = "";
    if (Array.isArray(matches) && matches.length) {
      historyContext = matches.map((m: any) => `User: ${m.content}\nAssistant: ${m.content ?? ''}`).join("\n\n");
    }

    const farmContext = farm ? `Farm: crop=${farm.crop_type ?? 'unknown'}, planted=${farm.planting_date ?? 'unknown'}` : "";

    const prompt = `${system}\n${farmContext ? '\n' + farmContext : ''}\n\nRelevant chat history:\n${historyContext}\n\nUser question: ${body.user_question}\n\nRespond as a Malawian farming mentor in simple English.`;

    const answer = await callCompletion(prompt);

    await saveConversation(body.user_id, answer, body.user_question, qEmbedding);

    return new Response(JSON.stringify({ answer }), { headers });
  } catch (err) {
    console.error(err);
    const message = err instanceof Error ? err.message : String(err);
    return new Response(JSON.stringify({ error: message }), { status: 500, headers });
  }
});
