# Claude.md — Supabase Project Rules

## 🧠 Purpose
This repository uses **Supabase CLI–first development** for all database, function, and type management.  
Claude Code must **never** modify the database manually through SQL or the dashboard.

---

## ⚙️ Workflow

### 1. Create a migration
```bash
supabase migration new <descriptive_name>
Example:

bash
Copy code
supabase migration new add_user_profiles_table
2. Edit the migration file
Claude must write clean SQL inside /supabase/migrations/<timestamp>_<name>.sql.

Include primary keys, constraints, RLS enablement, and timestamps.

Use templates defined in supabase.md.

3. Apply locally
bash
Copy code
supabase db push
4. Generate TypeScript types
bash
Copy code
supabase gen types typescript --project-id $SUPABASE_PROJECT_REF > src/lib/supabase.types.ts
5. Test locally
bash
Copy code
supabase test db
6. Deploy
bash
Copy code
supabase link --project-ref $SUPABASE_PROJECT_REF
supabase db push
🧱 Naming Conventions
Migrations: descriptive kebab-case — create_user_table, add_last_login_to_user

Tables: singular lowercase nouns — user, order, profile

Functions: snake_case verbs — get_user_profile, update_order_status

Policies: clear and descriptive — "Users can view own data"

Type file: src/lib/supabase.types.ts

🧩 Local Setup
Claude Code should assume:

Local DB is running via supabase start

.env contains SUPABASE_PROJECT_REF

Helper script scripts/supa-migrate.sh handles the full flow:

bash
Copy code
./scripts/supa-migrate.sh <migration_name>
🔒 Security Rules
Enable RLS on all user-facing tables.

Always create both SELECT and INSERT/UPDATE policies.

Never expose secrets or service keys in code or migrations.

🧪 Testing
Use supabase test db when available.

Validate type generation after every schema change.

🚫 Anti-Patterns
Claude Code must never:

Run direct SQL commands against production.

Suggest dashboard edits.

Skip type generation.

Use vague migration names (update_db, fix_schema).

✅ Example Full Cycle
bash
Copy code
./scripts/supa-migrate.sh add_user_sessions_table
Claude then:

Generates migration SQL (with RLS)

Applies locally

Generates supabase.types.ts

Confirms success message

End result: fully synced Supabase schema + types.
