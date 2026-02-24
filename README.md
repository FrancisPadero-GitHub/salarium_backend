# SUPABASE CLI COMMANDS

Below is a **practical Supabase CLI command reference**, focused only on commands you will actually use in this architecture, with brief and accurate descriptions.

---

## 1. Project and Setup

### `supabase init`

Initializes Supabase in your repository.
Creates the `supabase/` folder with config, migrations, and functions.

---

### `supabase link`

Links your local project to a **hosted Supabase project**.
Stores the project reference and connects CLI actions to that backend.

---

## 2. Database and Migrations

### `supabase migration new <name>`

Creates a new timestamped SQL migration file.
Used for tables, RLS, RPCs, triggers, indexes.

---

### `supabase db push`

Executes all pending migrations on the **hosted Supabase database**.
This is how schema changes are applied.

---

### `supabase db pull`

Pulls the current remote database schema into a migration file.
Used when adopting an existing Supabase project.

---

### `supabase db reset`

Drops and recreates the local database, then reapplies migrations.
Used only with local Supabase.

---

### `supabase db diff`

Shows the SQL difference between two database states.
Useful for generating migrations safely.

---

## 3. Local Development (Optional)

### `supabase start`

Starts a full local Supabase stack using Docker.
Includes Postgres, Auth, Storage, Realtime.

---

### `supabase stop`

Stops the local Supabase services.

---

### `supabase status`

Shows running services, ports, and local URLs.

---

## 4. Edge Functions

### `supabase functions new <name>`

Creates a new Edge Function scaffold.
Generates `supabase/functions/<name>/index.ts`.

---

### `supabase functions deploy <name>`

Deploys an Edge Function to **hosted Supabase**.
Makes it available at `/functions/v1/<name>`.

---

### `supabase functions serve`

Runs Edge Functions locally for testing.
Requires local Supabase running.

---

### `supabase functions delete <name>`

Deletes a deployed Edge Function from Supabase.

---

## 5. Secrets and Environment Variables

### `supabase secrets set KEY=value`

Sets environment variables for Edge Functions.
Used for API keys and secrets.

---

### `supabase secrets list`

Lists all secrets configured for the project.

---

### `supabase secrets unset KEY`

Removes a previously set secret.

---

## 6. Authentication Helpers

### `supabase gen types typescript`

Sample actual command - npx supabase gen types typescript --project-id xbrjymsimswevrifeeiz > database.types.ts

Generates TypeScript types from your database schema.
Used for type safe frontend development.

---

## 7. Admin and Utility

### `supabase login`

Authenticates the CLI with your Supabase account.

---

### `supabase projects list`

Lists all Supabase projects under your account.

---

### `supabase help`

Shows all available commands and options.

---

## 8. Commands You Will Use Most Often

Daily workflow:

```bash
supabase migration new add_budget_tables
supabase db push
supabase functions deploy budget-summary
```

Occasional:

```bash
supabase gen types typescript
supabase secrets set OPENAI_API_KEY=...
```

Optional local:

```bash
supabase start
supabase db reset
```

---

## 9. What You Do NOT Need

- No custom server
- No ORM migrations
- No separate backend deployment
- No manual dashboard schema edits

---

## One Sentence Summary

Supabase CLI lets you manage **database schema, RPCs, triggers, Edge Functions, and secrets** as versioned code and deploy them safely to hosted Supabase.

---

If you want next:

- A printable cheat sheet
- Feature to command mapping
- Example CI pipeline using these commands
- Common mistakes and safe practices
