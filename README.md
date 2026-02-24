# Supabase CLI Commands Reference

A **practical Supabase CLI cheat sheet**, focused on commands you'll actually use, with brief, accurate descriptions.

---

## 1. Project Setup

### `supabase init`

* Initializes Supabase in your repository.
* Creates the `supabase/` folder with config, migrations, and functions.

### `supabase link`

* Connects your local project to a **hosted Supabase project**.
* Stores project reference and links CLI actions to the backend.

---

## 2. Database & Migrations

### `supabase migration new <name>`

* Creates a new timestamped SQL migration file.
* Use for tables, RLS, RPCs, triggers, indexes.

### `supabase db push`

* Applies all pending migrations to the **hosted database**.

### `supabase db pull`

* Pulls the current remote database schema into a migration file.
* Useful when adopting an existing project.

### `supabase db reset`

* Drops and recreates the local database, then reapplies migrations.
* Use only with local Supabase.

### `supabase db diff`

* Shows SQL differences between two database states.
* Helps generate migrations safely.

---

## 3. Local Development (Optional)

### `supabase start`

* Starts a full local Supabase stack via Docker.
* Includes Postgres, Auth, Storage, Realtime.

### `supabase stop`

* Stops local Supabase services.

### `supabase status`

* Shows running services, ports, and local URLs.

---

## 4. Edge Functions

### `supabase functions new <name>`

* Creates a new Edge Function scaffold.
* Generates `supabase/functions/<name>/index.ts`.

### `supabase functions deploy <name>`

* Deploys an Edge Function to **hosted Supabase**.
* Available at `/functions/v1/<name>`.

### `supabase functions serve`

* Runs Edge Functions locally for testing.
* Requires local Supabase running.

### `supabase functions delete <name>`

* Deletes a deployed Edge Function from Supabase.

---

## 5. Secrets & Environment Variables

### `supabase secrets set KEY=value`

* Sets environment variables for Edge Functions (e.g., API keys).

### `supabase secrets list`

* Lists all configured secrets.

### `supabase secrets unset KEY`

* Removes a previously set secret.

---

## 6. Authentication Helpers

### `supabase gen types typescript`

* Example: `npx supabase gen types typescript --project-id xbrjymsimswevrifeeiz > database.types.ts`
* Generates TypeScript types from your database schema.
* Enables type-safe frontend development.

---

## 7. Admin & Utility

### `supabase login`

* Authenticates CLI with your Supabase account.

### `supabase projects list`

* Lists all Supabase projects under your account.

### `supabase help`

* Displays all available commands and options.

---

## 8. Frequently Used Commands

**Daily Workflow:**

```bash
supabase migration new add_budget_tables
supabase db push
supabase functions deploy budget-summary
```

**Occasional:**

```bash
supabase gen types typescript
supabase secrets set OPENAI_API_KEY=...
```

**Optional Local:**

```bash
supabase start
supabase db reset
```

---

## 9. What You Do NOT Need

* Custom server
* ORM migrations
* Separate backend deployment
* Manual dashboard schema edits

---

## One-Sentence Summary

Supabase CLI lets you manage **database schema, RPCs, triggers, Edge Functions, and secrets** as versioned code and deploy them safely to hosted Supabase.

---

## Next Steps / Extras

* Printable cheat sheet
* Feature-to-command mapping
* Example CI pipeline using these commands
* Common mistakes and safe practices
