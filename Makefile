.PHONY: get analyze run supabase-link db-push db-reset

get:
	flutter pub get

analyze:
	flutter analyze

run:
	flutter run

supabase-link:
	@read -p "Supabase project ref: " ref; supabase link --tifoduyhndfooxywuvjw $$ref

db-push:
	supabase db push

db-reset:
	supabase db reset
