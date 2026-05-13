
CREATE OR REPLACE FUNCTION "public"."log_eko_activity"("p_new_post_id" bigint, "p_ekoed_post_id" bigint, "p_author_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql"
    SET "search_path" TO ''
    AS $$
DECLARE
  v_ekoed_author_uid uuid;
BEGIN
  IF p_ekoed_post_id IS NULL THEN
    RETURN;
  END IF;

  SELECT author_uid INTO v_ekoed_author_uid
  FROM public.posts
  WHERE id = p_ekoed_post_id;

  IF v_ekoed_author_uid IS NULL OR v_ekoed_author_uid = p_author_id THEN
    RETURN;
  END IF;

  INSERT INTO public.activity (post_id, source_uid, target_uid, type)
  VALUES (p_new_post_id, p_author_id, v_ekoed_author_uid, 'eko'::public."ACTIVITY_TYPE");
END;
$$;


ALTER FUNCTION "public"."log_eko_activity"("p_new_post_id" bigint, "p_ekoed_post_id" bigint, "p_author_id" "uuid") OWNER TO "postgres";


GRANT ALL ON FUNCTION "public"."log_eko_activity"("p_new_post_id" bigint, "p_ekoed_post_id" bigint, "p_author_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."log_eko_activity"("p_new_post_id" bigint, "p_ekoed_post_id" bigint, "p_author_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."log_eko_activity"("p_new_post_id" bigint, "p_ekoed_post_id" bigint, "p_author_id" "uuid") TO "service_role";


CREATE OR REPLACE FUNCTION "public"."insert_post"("p_created_at" timestamp with time zone, "p_body" "text", "p_title" "text", "p_gif" "text", "p_poll" "text"[], "p_author_uid" "uuid", "p_image_base64" "text", "p_ekoed_id" bigint, OUT "o_post_id" bigint, OUT "o_poll_data" "jsonb") RETURNS "record"
    LANGUAGE "plpgsql"
    SET "search_path" TO ''
    AS $$
  begin
    -- 1. Insert the main post
    insert into public.posts (
      created_at, body, title, gif, author_uid, image, ekoed_id
    ) values (
      p_created_at, p_body, p_title, p_gif, p_author_uid,
      case
        when p_image_base64 is not null
        then pg_catalog.decode(p_image_base64, 'base64')
        else null
      end,
      p_ekoed_id
    )
    returning id into o_post_id;

    -- 2. Insert poll options if the array is not empty
    if p_poll is not null and pg_catalog.array_length(p_poll, 1) > 0 then
      insert into public.poll_options (post_id, value)
      select o_post_id, pg_catalog.unnest(p_poll);

      -- 3. Fetch the JSON representation using your existing function
      -- Note: You must qualify get_poll_from_id with its schema (public)
      o_poll_data := public.get_post_poll_results_json(o_post_id);
    else
      o_poll_data := null;
    end if;

    perform public.log_post_activity(o_post_id, p_author_uid, ARRAY[p_body, p_title]);
    perform public.log_eko_activity(o_post_id, p_ekoed_id, p_author_uid);
  end;
  $$;


ALTER FUNCTION "public"."insert_post"("p_created_at" timestamp with time zone, "p_body" "text", "p_title" "text", "p_gif" "text", "p_poll" "text"[], "p_author_uid" "uuid", "p_image_base64" "text", "p_ekoed_id" bigint, OUT "o_post_id" bigint, OUT "o_poll_data" "jsonb") OWNER TO "postgres";
