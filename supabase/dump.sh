#!/usr/bin/env bash
supabase db dump --db-url postgresql://postgres.nkwizistugahxfwdwtwg:"$SUPABASE_PASSWORD"@aws-1-us-east-1.pooler.supabase.com:5432/postgres -f ./schema.sql
