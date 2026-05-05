#!/usr/bin/env bash
cd "$(dirname "$0")" || exit
SCRIPT_DIR="$PWD"
set -a
source .env.local
set +a
supabase db dump --db-url postgresql://postgres.nkwizistugahxfwdwtwg:"$SUPABASE_PASSWORD"@aws-1-us-east-1.pooler.supabase.com:5432/postgres -f "$SCRIPT_DIR/schema.sql"
