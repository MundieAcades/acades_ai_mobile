-- Run this in Supabase SQL editor to create an RPC for pgvector similarity.
-- Assumes your chat_messages table has a column `embedding` of type `vector`.

create extension if not exists vector;

alter table public.chat_messages
add column if not exists embedding vector(1536);

create or replace function public.match_documents(query_embedding vector, match_count int)
returns setof public.chat_messages
language sql
stable
as $$
  select m.*
  from public.chat_messages m
  where m.embedding is not null
  order by m.embedding <-> query_embedding
  limit match_count;
$$;

-- After running this, you can call rpc('match_documents', { query_embedding: <vector>, match_count: 5 })
