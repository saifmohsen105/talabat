$ErrorActionPreference = "Stop"
supabase start
supabase db reset
Write-Host "Local database reset and seed data applied."
