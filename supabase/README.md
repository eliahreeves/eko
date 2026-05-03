### Testing functions
Set the env variables

You have to start the supabase project locally. If you want to use the production db for testing, set the MY_SUPABASE_URL and MY_SUPABASE_SERVICE_ROLE_KEY to the prod db.
```
supabase start
```

Then run edge func locally
```
supabase functions serve notify-user --env-file .env.local
```

Then you can curl the function with whatever the trigger should be in order to run it. For example:
```
curl -i --location --request POST 'http://127.0.0.1:54321/functions/v1/notify-user' \
  --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0' \
  --header 'Content-Type: application/json' \
  --data '{
    "type": "INSERT",
    "table": "activity",
    "record": {
      "target_uid": "991c0692-0485-4860-8659-a79beba4209c",
      "source_uid": "a2412328-2eed-4b00-b941-1534cd6e4908",
      "type": "post_tag",
      "post_id": "15885"
    }
  }'
```
