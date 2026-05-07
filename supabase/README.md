### Testing functions

Set the env variables

You have to start the supabase project locally. If you want to use the production db for testing, set the MY_SUPABASE_URL and MY_SUPABASE_SERVICE_ROLE_KEY to the prod db.

```
supabase start
```

Then run edge func locally (secrets are loaded automatically into your shell by direnv)

```
supabase functions serve notify-user
```

Then you can curl the function with whatever the trigger should be in order to run it. For example:

```
curl -i --location --request POST 'http://127.0.0.1:54321/functions/v1/notify-user' \
  --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0' \
  --header 'Content-Type: application/json' \
  --data '{
    "type": "INSERT",
    "record": {
      "target_uid": "991c0692-0485-4860-8659-a79beba4209c",
      "source_uid": "a2412328-2eed-4b00-b941-1534cd6e4908",
      "type": "post_tag",
      "post_id": "15885"
      "table": "activity",
    }
  }'
```

```
curl -i --location --request POST 'http://127.0.0.1:54321/functions/v1/notify-user' \
  --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0' \
  --header 'Content-Type: application/json' \
  --data '{
    "type": "INSERT",
    "record": {
   "id": "12306",
      "author_uid": "a2412328-2eed-4b00-b941-1534cd6e4908",
   "title": "testing your mom post",
      "table": "posts"
    }
  }'
```

### Secrets

Secrets are managed with [sops](https://github.com/getsops/sops) + [age](https://github.com/FiloSottile/age) using SSH keys. The encrypted file lives at `supabase/.env` in the repo. On shell entry, direnv decrypts it and exports the variables directly into your shell.

**Add or remove access**

Add/remove public ssh key to `.sops.yaml`, run `sops updatekeys supabase/.env`, and push.

**Editing secrets:**

```bash
sops supabase/.env
```
