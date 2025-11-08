# Xcode Productivity & Supabase CLI Workflow

## 🎯 Xcode Setup for Maximum Productivity

### Essential Xcode Settings
```
Preferences → Text Editing → Editing:
☑️ Automatically trim trailing whitespace
☑️ Including whitespace-only lines
☑️ Line numbers
☑️ Code folding ribbon

Preferences → Text Editing → Indentation:
☑️ Syntax-aware indenting
Tab width: 4 spaces
Indent width: 4 spaces

Preferences → Key Bindings:
⌘+Shift+O - Quick Open
⌘+Shift+F - Find in Project  
⌘+Shift+K - Clean Build Folder
⌘+R - Run
⌘+. - Stop
```

### Must-Have Xcode Extensions
1. **Swift Format** - Code formatting
2. **Copilot for Xcode** - AI assistance
3. **Sourcery** - Code generation
4. **SwiftLint** - Code quality

### Recommended Xcode Behaviors
```
Preferences → Behaviors → Build:
☑️ Show Navigator: Issue Navigator
☑️ Hide utilities

Preferences → Behaviors → Build Succeeds:
☑️ Show Navigator: Project Navigator

Preferences → Behaviors → Build Fails:  
☑️ Show Navigator: Issue Navigator
☑️ Show debugger with: Console View
```

## ⚡ Supabase CLI Workflow

### Installation
```bash
# Install Supabase CLI
brew install supabase/tap/supabase

# Login to your account
supabase login

# Link to your project
cd /your/project/directory
supabase link --project-ref your-project-ref
```

### Essential Commands
```bash
# Pull current schema from cloud
supabase db pull

# Apply local changes to cloud  
supabase db push

# Reset local database
supabase db reset

# Generate TypeScript types
supabase gen types typescript --local > types.ts

# Start local development
supabase start

# Apply migrations
supabase migration up
```

### Schema Management Workflow

#### 1. Create Migration Files
```bash
# Create new migration
supabase migration new add_authentication_fields

# This creates: supabase/migrations/20231020_add_authentication_fields.sql
```

#### 2. Write Migration
```sql
-- supabase/migrations/20231020_add_authentication_fields.sql
ALTER TABLE courses ADD COLUMN created_by uuid REFERENCES auth.users(id);
CREATE INDEX idx_courses_created_by ON courses(created_by);
```

#### 3. Test Locally
```bash
# Apply migration locally
supabase db reset

# Test your app locally
supabase start
```

#### 4. Deploy to Production
```bash
# Push migration to production
supabase db push
```

### AI-Assisted Schema Changes

To enable AI (like me) to make schema changes for you:

#### 1. Project Structure
```
your-project/
├── supabase/
│   ├── migrations/
│   │   └── 20231020_initial_schema.sql
│   └── config.toml
├── Database/
│   ├── schema_updates_sprint2.sql  (manual updates)
│   └── migration_templates/        (reusable patterns)
└── Documentation/
    └── Database-Schema.md          (current schema docs)
```

#### 2. Schema Documentation
Keep a current schema documentation that I can reference:

```markdown
# Current Database Schema

## Tables
- **courses**: Marathon course data
- **segments**: Elevation segments per course  
- **user_requests**: User-submitted course requests

## Key Relationships
- segments.course_id → courses.id
- courses.created_by → auth.users.id

## RLS Policies
- Public read on verified courses
- Authenticated insert on courses
```

#### 3. AI Workflow
1. **I create migration files** in `/Database/migrations/`
2. **You review and test** using `supabase db reset`
3. **You apply to production** using `supabase db push`
4. **I update documentation** to reflect changes

## 🛠️ Development Scripts

### Create these aliases in your `.zshrc`:
```bash
alias sp-start="supabase start"
alias sp-stop="supabase stop"  
alias sp-reset="supabase db reset"
alias sp-push="supabase db push"
alias sp-pull="supabase db pull"
alias sp-status="supabase status"

# Quick schema updates
alias sp-update="supabase db reset && echo '✅ Local DB updated'"
```

## 🚀 Recommended Workflow

### Daily Development
1. `supabase start` - Start local Supabase
2. Work on features in Xcode
3. Test schema changes locally with `supabase db reset`
4. Commit changes to git

### Schema Changes
1. Create migration file: `supabase migration new feature_name`
2. Write SQL in migration file
3. Test locally: `supabase db reset`
4. Deploy: `supabase db push`
5. Update documentation

### Production Deployment
1. Test everything locally first
2. `supabase db push` for schema changes
3. Deploy app updates
4. Monitor Supabase logs for issues

This workflow will make schema changes much faster and let me help you more effectively!