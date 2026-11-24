$ErrorActionPreference = "Stop"

if (-not (Get-Command supabase -ErrorAction SilentlyContinue)) {
  throw "Supabase CLI not found. Install it from https://supabase.com/docs/guides/cli"
}

$projectRef = Read-Host "Enter your Supabase project ref"
if ([string]::IsNullOrWhiteSpace($projectRef)) { throw "Project ref is required." }

supabase login
supabase link -- $projectRef
supabase db push
Write-Host "Hosted database migrations applied."
Write-Host "To seed the hosted project, open Supabase Dashboard > SQL Editor and run supabase/seed.sql."
Write-Host "For local development, run .\\scripts\\reset-local.ps1 (starts local Supabase and applies seed.sql)."
