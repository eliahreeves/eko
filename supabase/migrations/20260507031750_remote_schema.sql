drop policy "Enable insert for users based on user_id" on "public"."comments";


  create policy "Enable insert for users based on user_id"
  on "public"."comments"
  as permissive
  for insert
  to authenticated
with check ((( SELECT (auth.uid() = comments.author_uid)) AND ((NULLIF(body, ''::text) IS NOT NULL) OR (NULLIF(body, ''::text) IS NOT NULL))));



