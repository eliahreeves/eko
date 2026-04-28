#!/usr/bin/env bash

FLUTTER_COMMAND="flutter run \
--dart-define=\"KLIPY_API_KEY=$KLIPY_API_KEY\" \
--dart-define=\"SUPABASE_URL=$SUPABASE_URL\" \
--dart-define=\"SUPABASE_KEY=$SUPABASE_KEY\""

if [ "$1" == "web" ]; then
  FLUTTER_COMMAND="$FLUTTER_COMMAND -d web-server --web-hostname localhost --web-port 3000"
fi

eval "$FLUTTER_COMMAND"
