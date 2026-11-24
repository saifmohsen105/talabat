#!/usr/bin/env bash
set -euo pipefail

command -v supabase >/dev/null || {
  echo "Supabase CLI is required: https://supabase.com/docs/guides/cli" >&2
  exit 1
}
read -rp "Enter your Supabase project ref: " PROJECT_REF
[[ -n "$PROJECT_REF" ]] || { echo "Project ref is required." >&2; exit 1; }

supabase login
supabase link --project-ref "$PROJECT_REF"
supabase db push
echo "Hosted database migrations applied."
echo "Run supabase/seed.sql in Supabase Dashboard > SQL Editor to seed hosted data."
echo "For local development, run: supabase start && supabase db reset"
