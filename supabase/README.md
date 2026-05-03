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

Then you can curl the function with whatever the trigger should be in order to run it.
