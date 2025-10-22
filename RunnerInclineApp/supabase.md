## 🗂️ `supabase.md`
```md
# Supabase.md — Schema & RLS Standards

This document defines naming conventions, SQL templates, and security patterns Claude Code must follow for all schema work.

---

## 🧱 Table Standards

Every table must:
- Have a UUID primary key:
  ```sql
  id uuid PRIMARY KEY DEFAULT gen_random_uuid()
Include timestamps:

sql
Copy code
created_at timestamptz DEFAULT now(),
updated_at timestamptz DEFAULT now()
Use singular lowercase names.

Reference foreign keys with cascading deletes.

Enable RLS immediately after creation:

sql
Copy code
ALTER TABLE public.<table> ENABLE ROW LEVEL SECURITY;
📋 Example Table
sql
Copy code
CREATE TABLE public.user_profile (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name text,
  bio text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE public.user_profile ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile"
  ON public.user_profile
  FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can update own profile"
  ON public.user_profile
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);
🔒 RLS Policy Templates
Authenticated user owns row
sql
Copy code
ALTER TABLE public.<table> ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own rows"
  ON public.<table>
  FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);
Public read access
sql
Copy code
CREATE POLICY "Allow public read"
  ON public.<table>
  FOR SELECT
  USING (true);
Admin-only access
sql
Copy code
CREATE POLICY "Admins only"
  ON public.<table>
  FOR ALL
  TO authenticated
  USING (EXISTS (
    SELECT 1 FROM user_role WHERE user_id = auth.uid() AND role = 'admin'
  ));
🧩 Function Conventions
Functions are written in supabase/functions/<function_name>/index.ts.

Must include:

Clear error handling

CORS headers

Type-safe payloads

Example Deno function:

js
Copy code
import { serve } from "https://deno.land/std/http/server.ts";
import { supabase } from "../_shared/supabaseClient.ts";

serve(async (req) => {
  try {
    const { user_id } = await req.json();
    const { data, error } = await supabase
      .from("user_profile")
      .select("*")
      .eq("user_id", user_id)
      .single();

    if (error) throw error;
    return new Response(JSON.stringify(data), {
      headers: { "Content-Type": "application/json" },
    });
  } catch (err) {
    return new Response(JSON.stringify({ error: err.message }), { status: 400 });
  }
});
🧠 Type Generation Rule
After every schema change:

bash
Copy code
supabase gen types typescript --project-id $SUPABASE_PROJECT_REF > src/lib/supabase.types.ts
Types must be committed with the migration.

🚫 Schema Anti-Patterns
Don’t use serial or integer IDs.

Don’t skip RLS on public tables.

Don’t use plural table names.

Don’t store secrets in tables.

Don’t alter production schema manually.

✅ Good Example Migration
sql
Copy code
CREATE TABLE public.order (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES public.user(id) ON DELETE CASCADE,
  total numeric(10,2) NOT NULL,
  status text NOT NULL DEFAULT 'pending',
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE public.order ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own orders"
  ON public.order
  FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create own orders"
  ON public.order
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);
yaml
Copy code

---

## 🧩 Next Steps

1. Save both files to your **repo root** (`claude.md` and `supabase.md`).
2. Keep your helper script under `/scripts/supa-migrate.sh`.
3. Ensure `.env` has:
   ```bash
   SUPABASE_PROJECT_REF=your-project-ref
