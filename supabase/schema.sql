


SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE EXTENSION IF NOT EXISTS "pg_net" WITH SCHEMA "public";






CREATE EXTENSION IF NOT EXISTS "hypopg" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "index_advisor" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pg_trgm" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";






CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";






CREATE TYPE "public"."ACTIVITY_TYPE" AS ENUM (
    'comment',
    'eko',
    'follow',
    'comment_tag',
    'post_tag',
    'post'
);


ALTER TYPE "public"."ACTIVITY_TYPE" OWNER TO "postgres";


CREATE TYPE "public"."DEVICE_TYPE" AS ENUM (
    'ios',
    'android',
    'linux',
    'browser'
);


ALTER TYPE "public"."DEVICE_TYPE" OWNER TO "postgres";


CREATE TYPE "public"."NOTIFICATION_TYPE" AS ENUM (
    'apns',
    'web_push'
);


ALTER TYPE "public"."NOTIFICATION_TYPE" OWNER TO "postgres";


COMMENT ON TYPE "public"."NOTIFICATION_TYPE" IS 'can delete when we make the relay';



CREATE OR REPLACE FUNCTION "public"."change_comment_likes"("p_id" bigint, "p_is_liking" boolean, "p_is_dislike" boolean) RETURNS "void"
    LANGUAGE "plpgsql"
    SET "search_path" TO ''
    AS $$
DECLARE
  v_uid UUID := auth.uid();
BEGIN
  IF p_is_liking THEN
    -- Try to update the row
INSERT INTO public.comment_likes (user_uid, comment_id, is_dislike)
    VALUES (v_uid, p_id, p_is_dislike)
    ON CONFLICT (user_uid, comment_id)
    DO UPDATE SET is_dislike = EXCLUDED.is_dislike;
  ELSE
    -- Delete the like if unliking
    DELETE FROM public.comment_likes AS p
    WHERE p.comment_id = p_id AND p.user_uid = v_uid;
  END IF;
END;
$$;


ALTER FUNCTION "public"."change_comment_likes"("p_id" bigint, "p_is_liking" boolean, "p_is_dislike" boolean) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."change_follow_state"("p_uid" "uuid", "p_is_follow" boolean) RETURNS "void"
    LANGUAGE "plpgsql"
    SET "search_path" TO ''
    AS $$DECLARE
  v_uid UUID := auth.uid();
BEGIN
  -- Ensure the user is actually authenticated
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'Not authorized';
  END IF;

  IF p_is_follow THEN
    -- Insert into following table
    INSERT INTO public.following (source_uid, target_uid)
    VALUES (v_uid, p_uid) 
    ON CONFLICT DO NOTHING;

    PERFORM public.log_follow_activity(v_uid, p_uid, 'follow'::public."ACTIVITY_TYPE");

  ELSE
    -- Unfollow logic
    DELETE FROM public.following
    WHERE source_uid = v_uid AND target_uid = p_uid;
  END IF;
END;$$;


ALTER FUNCTION "public"."change_follow_state"("p_uid" "uuid", "p_is_follow" boolean) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."change_post_likes"("p_id" bigint, "p_is_liking" boolean, "p_is_dislike" boolean) RETURNS "void"
    LANGUAGE "plpgsql"
    SET "search_path" TO ''
    AS $$
DECLARE
  v_uid UUID := auth.uid();
BEGIN
  IF p_is_liking THEN
    -- Try to update the row
INSERT INTO public.post_likes (user_uid, post_id, is_dislike)
    VALUES (v_uid, p_id, p_is_dislike)
    ON CONFLICT (user_uid, post_id)
    DO UPDATE SET is_dislike = EXCLUDED.is_dislike;
  ELSE
    -- Delete the like if unliking
    DELETE FROM public.post_likes AS p
    WHERE p.post_id = p_id AND p.user_uid = v_uid;
  END IF;
END;
$$;


ALTER FUNCTION "public"."change_post_likes"("p_id" bigint, "p_is_liking" boolean, "p_is_dislike" boolean) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."create_google_profile"("p_username" "text", "p_name" "text", "p_birthday" "date", "p_profile_picture" "text" DEFAULT NULL::"text") RETURNS TABLE("success" boolean, "error_message" "text")
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
  DECLARE
    v_uid UUID := auth.uid();
    v_pic TEXT;
  BEGIN
    IF v_uid IS NULL THEN
      RETURN QUERY SELECT false, 'not_authenticated'::text;
      RETURN;
    END IF;
    IF EXISTS (SELECT 1 FROM public.users WHERE id = v_uid) THEN
      RETURN QUERY SELECT false, 'profile_already_exists'::text;
      RETURN;
    END IF;
    IF EXISTS (SELECT 1 FROM public.usernames WHERE username = p_username) THEN
      RETURN QUERY SELECT false, 'username_taken'::text;
      RETURN;
    END IF;
    v_pic := NULLIF(BTRIM(p_profile_picture), '');
    BEGIN
      INSERT INTO public.users (id, username, name, birthday, bio, is_verified, profile_picture)
      VALUES (v_uid, p_username, p_name, p_birthday, '', false, v_pic);
    EXCEPTION
      WHEN unique_violation THEN
        RETURN QUERY SELECT false, 'username_taken'::text;
        RETURN;
      WHEN OTHERS THEN
        RETURN QUERY SELECT false, SQLERRM::text;
        RETURN;
    END;
    RETURN QUERY SELECT true, NULL::text;
  END;
  $$;


ALTER FUNCTION "public"."create_google_profile"("p_username" "text", "p_name" "text", "p_birthday" "date", "p_profile_picture" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."delete_user"() RETURNS "void"
    LANGUAGE "sql" SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
	delete from auth.users where id = auth.uid();
$$;


ALTER FUNCTION "public"."delete_user"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_comment_by_id"("p_id" bigint) RETURNS TABLE("id" bigint, "author_uid" "uuid", "created_at" timestamp with time zone, "body" "text", "gif" "text", "like_count" bigint, "dislike_count" bigint, "parent_post_id" bigint, "is_liked" boolean, "is_disliked" boolean)
    LANGUAGE "plpgsql"
    SET "search_path" TO ''
    AS $$
BEGIN
    RETURN QUERY
    SELECT *
    FROM public.full_comment_info as p
    WHERE p.id = p_id
    LIMIT 1;
END;
$$;


ALTER FUNCTION "public"."get_comment_by_id"("p_id" bigint) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_follow_info"("p_uid" "uuid") RETURNS TABLE("following" bigint, "followers" bigint)
    LANGUAGE "plpgsql"
    SET "search_path" TO ''
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        (SELECT COUNT(*) FROM public.following f WHERE f.source_uid = p_uid) AS following,
        (SELECT COUNT(*) FROM public.following f WHERE f.target_uid = p_uid) AS followers;
END;
$$;


ALTER FUNCTION "public"."get_follow_info"("p_uid" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_logo_of_the_day"() RETURNS "text"
    LANGUAGE "plpgsql" STABLE
    SET "search_path" TO ''
    AS $$
DECLARE
    total_logos INT;
    day_index INT;
    selected_svg TEXT;
BEGIN
    SELECT COUNT(*) INTO total_logos FROM public.logos;
    IF total_logos = 0 THEN
        RETURN NULL;
    END IF;
    day_index := (EXTRACT(EPOCH FROM CURRENT_DATE) / 86400)::INT;
    WITH IndexedLogos AS (
        SELECT svg, ROW_NUMBER() OVER (ORDER BY id) - 1 as idx
        FROM public.logos
    )
    SELECT svg INTO selected_svg
    FROM IndexedLogos
    WHERE idx = (day_index % total_logos);

    RETURN selected_svg;
END;
$$;


ALTER FUNCTION "public"."get_logo_of_the_day"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_min_version"("p_platform" "text") RETURNS "text"
    LANGUAGE "sql" STABLE
    SET "search_path" TO ''
    AS $_$
    SELECT minimum_version
    FROM public.utilities 
    WHERE platform = $1; 
  $_$;


ALTER FUNCTION "public"."get_min_version"("p_platform" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_post_by_id"("p_id" bigint) RETURNS TABLE("id" bigint, "author_uid" "uuid", "created_at" timestamp with time zone, "title" "text", "body" "text", "gif" "text", "image" "text", "ekoed_id" bigint, "like_count" bigint, "dislike_count" bigint, "comment_count" bigint, "is_liked" boolean, "is_disliked" boolean, "poll" "jsonb", "vote" bigint)
    LANGUAGE "sql" STABLE
    SET "search_path" TO ''
    AS $$

    SELECT *
    FROM public.full_post_info as p
    WHERE p.id = p_id
    
    LIMIT 1;
$$;


ALTER FUNCTION "public"."get_post_by_id"("p_id" bigint) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_post_poll_results_json"("p_post_id" bigint) RETURNS "jsonb"
    LANGUAGE "sql" STABLE
    SET "search_path" TO ''
    AS $$
  WITH option_counts AS (
    SELECT
      po.id AS option_id,
      po.value,
      COUNT(pv.user_uid)::bigint AS vote_count
    FROM public.poll_options po
    LEFT JOIN public.poll_votes pv
      ON pv.option_id = po.id
     AND pv.post_id = po.post_id
    WHERE po.post_id = p_post_id
    GROUP BY po.id, po.value
  )
  SELECT jsonb_agg(
    jsonb_build_object(
      'option_id', oc.option_id,
      'value', oc.value,
      'vote_count', oc.vote_count
    )
    ORDER BY oc.option_id
  )
  FROM option_counts oc;
  $$;


ALTER FUNCTION "public"."get_post_poll_results_json"("p_post_id" bigint) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_user_by_id"("p_uid" "uuid") RETURNS TABLE("id" "uuid", "username" "text", "name" "text", "profile_picture" "text", "bio" "text", "is_verified" boolean, "is_following" boolean, "is_follower" boolean)
    LANGUAGE "plpgsql"
    SET "search_path" TO ''
    AS $$
BEGIN
    RETURN QUERY
    SELECT *
    FROM public.full_user_info u
    WHERE u.id = p_uid 
    AND NOT EXISTS (
            SELECT 1 FROM public.blocked b
            WHERE 
                (b.source_uid = (SELECT auth.uid()) AND b.target_uid = u.id) OR
                (b.source_uid = u.id AND b.target_uid = (SELECT auth.uid()))
        )
    LIMIT 1;
END;
$$;


ALTER FUNCTION "public"."get_user_by_id"("p_uid" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_uuids_from_mentions"("input_texts" "text"[]) RETURNS TABLE("user_uuid" "uuid")
    LANGUAGE "plpgsql" STABLE
    SET "search_path" TO ''
    AS $$
BEGIN
    RETURN QUERY
    WITH extracted_usernames AS (
        SELECT DISTINCT lower(substring(m[1] from 2)) AS clean_username
        FROM (
            SELECT unnest(input_texts) AS original_string
        ) AS s,
        LATERAL regexp_matches(s.original_string, '(@[a-z0-9_]{3,24})', 'g') AS m
    )
    SELECT u.id
    FROM public.users u
    JOIN extracted_usernames e ON u.username = e.clean_username;
END;
$$;


ALTER FUNCTION "public"."get_uuids_from_mentions"("input_texts" "text"[]) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_new_public_user"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
begin
  insert into public.usernames (user_uid, username)
  values (new.id, new.username);
  return new;
end;
$$;


ALTER FUNCTION "public"."handle_new_public_user"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_new_user"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
  begin
    -- OAuth users (e.g. Google) have no username in metadata; skip the insert
    -- and let the client call create_google_profile after the user chooses one.
    IF new.raw_user_meta_data ->> 'username' IS NULL THEN
      RETURN new;
    END IF;
    insert into public.users (id, username, created_at, profile_picture, birthday, name, firebase_uid, bio, is_verified)
    values (new.id, new.raw_user_meta_data ->> 'username', COALESCE(NEW.raw_user_meta_data ->> 'created_at', now()::text)::timestamp, NEW.raw_user_meta_data ->>
  'profile_picture', (NEW.raw_user_meta_data ->> 'birthday')::date, NEW.raw_user_meta_data ->> 'name', NEW.raw_user_meta_data ->> 'firebase_uid', NEW.raw_user_meta_data
  ->> 'bio', (NEW.raw_user_meta_data ->> 'is_verified')::boolean);
    return new;
  end;
  $$;


ALTER FUNCTION "public"."handle_new_user"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."insert_comment"("p_created_at" timestamp with time zone, "p_body" "text", "p_gif" "text", "p_author_uid" "uuid", "p_parent_post_id" bigint) RETURNS bigint
    LANGUAGE "plpgsql"
    SET "search_path" TO ''
    AS $$
  declare
    new_comment_id bigint;
  begin
  insert into public.comments (
        created_at,
        body,
        gif,
        author_uid,
        parent_post_id
      ) values (
        p_created_at,
        p_body,
        p_gif,
        p_author_uid,
        p_parent_post_id
      )
      returning id into new_comment_id;
      perform public.log_comment_activity(new_comment_id, p_parent_post_id, p_author_uid, p_body);
      return new_comment_id;
  end;
$$;


ALTER FUNCTION "public"."insert_comment"("p_created_at" timestamp with time zone, "p_body" "text", "p_gif" "text", "p_author_uid" "uuid", "p_parent_post_id" bigint) OWNER TO "postgres";


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
PERFORM public.log_post_activity(o_post_id, p_author_uid, ARRAY[p_body, p_title]);
  end;
  $$;


ALTER FUNCTION "public"."insert_post"("p_created_at" timestamp with time zone, "p_body" "text", "p_title" "text", "p_gif" "text", "p_poll" "text"[], "p_author_uid" "uuid", "p_image_base64" "text", "p_ekoed_id" bigint, OUT "o_post_id" bigint, OUT "o_poll_data" "jsonb") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."insert_post"("p_created_at" timestamp with time zone, "p_firebase_uid" "text", "p_body" "text", "p_title" "text", "p_gif" "text", "p_poll" "text"[], "p_author_uid" "uuid", "p_image_base64" "text", "p_ekoed_id" bigint, OUT "o_post_id" bigint, OUT "o_poll_data" "jsonb") RETURNS "record"
    LANGUAGE "plpgsql"
    SET "search_path" TO ''
    AS $$
  begin
    -- 1. Insert the main post
    insert into public.posts (
      created_at, firebase_uid, body, title, gif, author_uid, image, ekoed_id
    ) values (
      p_created_at, p_firebase_uid, p_body, p_title, p_gif, p_author_uid,
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

  end;
  $$;


ALTER FUNCTION "public"."insert_post"("p_created_at" timestamp with time zone, "p_firebase_uid" "text", "p_body" "text", "p_title" "text", "p_gif" "text", "p_poll" "text"[], "p_author_uid" "uuid", "p_image_base64" "text", "p_ekoed_id" bigint, OUT "o_post_id" bigint, OUT "o_poll_data" "jsonb") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."is_username_available"("p_username" "text") RETURNS boolean
    LANGUAGE "plpgsql" STABLE
    SET "search_path" TO ''
    AS $$
BEGIN
  -- If there is no such username, it is available
  RETURN NOT EXISTS (
    SELECT 1
    FROM public.usernames
    WHERE username = p_username
  );
END;
$$;


ALTER FUNCTION "public"."is_username_available"("p_username" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."log_comment_activity"("p_comment_id" bigint, "p_post_id" bigint, "p_author_id" "uuid", "p_text" "text") RETURNS "void"
    LANGUAGE "plpgsql"
    SET "search_path" TO ''
    AS $$
DECLARE
    v_post_author_id uuid;
BEGIN
    -- 1. Get the post author once to save resources
    SELECT author_uid INTO v_post_author_id 
    FROM public.posts 
    WHERE id = p_post_id;

    -- 2. Log the top-level comment activity
    if p_author_id != v_post_author_id then
    INSERT INTO public.activity (post_id, comment_id, source_uid, target_uid, type) 
    VALUES (p_post_id, p_comment_id, p_author_id, v_post_author_id, 'comment'::public."ACTIVITY_TYPE");
    end if;

    -- 3. Log mention activities
    INSERT INTO public.activity (post_id, comment_id, source_uid, target_uid, type)
    SELECT 
        p_post_id,
        p_comment_id,
        p_author_id,
        m.user_uuid,
        'comment_tag'::public."ACTIVITY_TYPE"
    FROM public.get_uuids_from_mentions(ARRAY[p_text]) AS m
    WHERE m.user_uuid != p_author_id             -- Don't notify the commenter if they tag themselves
      AND m.user_uuid != v_post_author_id;      -- Don't notify the post author twice (they already got the 'comment' activity)
END;
$$;


ALTER FUNCTION "public"."log_comment_activity"("p_comment_id" bigint, "p_post_id" bigint, "p_author_id" "uuid", "p_text" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."log_follow_activity"("p_source_uid" "uuid", "p_target_uid" "uuid", "p_type" "public"."ACTIVITY_TYPE") RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  -- Check for existing activity within the last 8 hours to prevent spamming
  IF NOT EXISTS (
    SELECT 1 
    FROM public.activity 
    WHERE type = p_type 
      AND source_uid = p_source_uid 
      AND target_uid = p_target_uid 
      AND created_at > (now() - interval '8 hours')
  ) THEN
    INSERT INTO public.activity (source_uid, target_uid, type) 
    VALUES (p_source_uid, p_target_uid, p_type);
  END IF;
END;
$$;


ALTER FUNCTION "public"."log_follow_activity"("p_source_uid" "uuid", "p_target_uid" "uuid", "p_type" "public"."ACTIVITY_TYPE") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."log_post_activity"("p_post_id" bigint, "p_author_id" "uuid", "p_text" "text"[]) RETURNS "void"
    LANGUAGE "plpgsql"
    SET "search_path" TO ''
    AS $$
BEGIN

   INSERT INTO public.activity (post_id, source_uid, target_uid, type)
    SELECT 
        p_post_id,
        p_author_id,
        m.user_uuid,
        'post_tag'::public."ACTIVITY_TYPE"
    FROM public.get_uuids_from_mentions(p_text) AS m
    WHERE m.user_uuid != p_author_id;
END;
$$;


ALTER FUNCTION "public"."log_post_activity"("p_post_id" bigint, "p_author_id" "uuid", "p_text" "text"[]) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."notify_user_on_insert"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
DECLARE
  payload jsonb;
  edge_function_url text;
  request_id bigint;
BEGIN
  IF TG_TABLE_NAME = 'posts' THEN
    payload = jsonb_build_object(
      'record', jsonb_build_object(
        'table', 'posts',
        'id', NEW.id,
        'title', NEW.title,
        'body', NEW.body,
        'author_uid', NEW.author_uid
      )
    );
  ELSIF TG_TABLE_NAME = 'activity' THEN
    payload = jsonb_build_object(
      'record', jsonb_build_object(
        'table', 'activity',
        'id', NEW.id,
        'type', NEW.type,
        'source_uid', NEW.source_uid,
        'target_uid', NEW.target_uid,
        'post_id', NEW.post_id,
        'comment_id', NEW.comment_id
      )
    );
  END IF;
  edge_function_url = 'https://' || current_setting('supabase_functions_endpoint', true) || '/functions/v1/notify-user';
  SELECT net.http_post(
    url := edge_function_url,
    body := payload,
    headers := '{"Content-Type": "application/json"}'::jsonb
  ) INTO request_id;
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."notify_user_on_insert"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."paginated_activities"("p_limit" integer, "p_last_time" timestamp with time zone DEFAULT NULL::timestamp with time zone, "p_last_id" bigint DEFAULT NULL::bigint) RETURNS TABLE("id" bigint, "created_at" timestamp with time zone, "source_uid" "uuid", "post_id" bigint, "comment_id" bigint, "type" "text")
    LANGUAGE "sql" STABLE
    SET "search_path" TO ''
    AS $$
  SELECT id, created_at, source_uid, post_id, comment_id, type
  FROM public.activity as p
  WHERE (p_last_time IS NULL OR (p.created_at, p.id) < (p_last_time, p_last_id)) AND ((SELECT auth.uid()) = p.target_uid)
  ORDER BY p.created_at DESC, p.id DESC
  LIMIT p_limit;
$$;


ALTER FUNCTION "public"."paginated_activities"("p_limit" integer, "p_last_time" timestamp with time zone, "p_last_id" bigint) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."paginated_comment_likes"("p_limit" integer, "p_id" bigint, "p_last_uid" "uuid") RETURNS TABLE("id" "uuid", "username" "text", "name" "text", "profile_picture" "text", "bio" "text", "is_verified" boolean)
    LANGUAGE "plpgsql"
    SET "search_path" TO ''
    AS $$
BEGIN
    RETURN QUERY
    SELECT u.id, u.username, u.name, u.profile_picture, u.bio, u.is_verified
    FROM public.comment_likes l
    JOIN public.users u on u.id = l.user_uid
    WHERE
    l.comment_id = p_id AND
    --paging
    (p_last_uid is NULL or (p_last_uid < u.id))
    -- blocking
    AND NOT EXISTS (
            SELECT 1 FROM public.blocked b
            WHERE 
                (b.source_uid = (SELECT auth.uid()) AND b.target_uid = u.id) OR
                (b.source_uid = u.id AND b.target_uid = (SELECT auth.uid()))
    )
    ORDER BY u.id DESC
    LIMIT p_limit;
END;
$$;


ALTER FUNCTION "public"."paginated_comment_likes"("p_limit" integer, "p_id" bigint, "p_last_uid" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."paginated_comments"("p_limit" integer, "p_parent_post_id" bigint, "p_last_time" timestamp with time zone DEFAULT NULL::timestamp with time zone, "p_last_id" bigint DEFAULT NULL::bigint) RETURNS TABLE("id" bigint, "author_uid" "uuid", "created_at" timestamp with time zone, "body" "text", "gif" "text", "like_count" bigint, "dislike_count" bigint, "parent_post_id" bigint, "is_liked" boolean, "is_disliked" boolean)
    LANGUAGE "plpgsql"
    SET "search_path" TO ''
    AS $$
BEGIN
    RETURN QUERY
    SELECT *
    FROM public.full_comment_info as p
    WHERE
        p.parent_post_id = p_parent_post_id
    --paging
        AND (p_last_time IS NULL OR (p.created_at, p.id) > (p_last_time, p_last_id))
    ORDER BY p.created_at ASC, p.id ASC
    LIMIT p_limit;
END;
$$;


ALTER FUNCTION "public"."paginated_comments"("p_limit" integer, "p_parent_post_id" bigint, "p_last_time" timestamp with time zone, "p_last_id" bigint) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."paginated_following_posts"("p_limit" integer, "p_last_time" timestamp with time zone DEFAULT NULL::timestamp with time zone, "p_last_id" bigint DEFAULT NULL::bigint) RETURNS TABLE("id" bigint, "author_uid" "uuid", "created_at" timestamp with time zone, "title" "text", "body" "text", "gif" "text", "image" "text", "ekoed_id" bigint, "like_count" bigint, "dislike_count" bigint, "comment_count" bigint, "is_liked" boolean, "is_disliked" boolean, "poll" "jsonb", "vote" bigint)
    LANGUAGE "sql" STABLE
    SET "search_path" TO ''
    AS $$
  SELECT p.* FROM public.full_post_info p
  WHERE p.author_uid IN (
    SELECT target_uid 
    FROM public.following 
    WHERE source_uid = auth.uid()
  )
  AND (p_last_time IS NULL OR (p.created_at, p.id) < (p_last_time, p_last_id))
  ORDER BY p.created_at DESC, p.id DESC
  LIMIT p_limit;
$$;


ALTER FUNCTION "public"."paginated_following_posts"("p_limit" integer, "p_last_time" timestamp with time zone, "p_last_id" bigint) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."paginated_new_posts"("p_limit" integer, "p_last_time" timestamp with time zone DEFAULT NULL::timestamp with time zone, "p_last_id" bigint DEFAULT NULL::bigint) RETURNS TABLE("id" bigint, "author_uid" "uuid", "created_at" timestamp with time zone, "title" "text", "body" "text", "gif" "text", "image" "text", "ekoed_id" bigint, "like_count" bigint, "dislike_count" bigint, "comment_count" bigint, "is_liked" boolean, "is_disliked" boolean, "poll" "jsonb", "vote" bigint)
    LANGUAGE "sql" STABLE
    SET "search_path" TO ''
    AS $$
  SELECT *
  FROM public.full_post_info as p
  WHERE (p_last_time IS NULL OR (p.created_at, p.id) < (p_last_time, p_last_id))
  ORDER BY p.created_at DESC, p.id DESC
  LIMIT p_limit;
$$;


ALTER FUNCTION "public"."paginated_new_posts"("p_limit" integer, "p_last_time" timestamp with time zone, "p_last_id" bigint) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."paginated_popular_posts"("p_limit" integer, "p_last_likes" bigint DEFAULT NULL::bigint, "p_last_id" bigint DEFAULT NULL::bigint) RETURNS TABLE("id" bigint, "author_uid" "uuid", "created_at" timestamp with time zone, "title" "text", "body" "text", "gif" "text", "image" "text", "ekoed_id" bigint, "like_count" bigint, "dislike_count" bigint, "comment_count" bigint, "is_liked" boolean, "is_disliked" boolean, "poll" "jsonb", "vote" bigint)
    LANGUAGE "sql" STABLE
    SET "search_path" TO ''
    AS $$

    SELECT *
    FROM public.full_post_info as p
    WHERE (p_last_likes IS NULL OR (p.like_count + p.dislike_count, p.id) < (p_last_likes, p_last_id))
    ORDER BY p.like_count + p.dislike_count DESC, p.id DESC
    LIMIT p_limit;

$$;


ALTER FUNCTION "public"."paginated_popular_posts"("p_limit" integer, "p_last_likes" bigint, "p_last_id" bigint) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."paginated_post_likes"("p_limit" integer, "p_id" bigint, "p_last_uid" "uuid", "p_dislikes" boolean) RETURNS TABLE("id" "uuid", "username" "text", "name" "text", "profile_picture" "text", "bio" "text", "is_verified" boolean, "is_following" boolean, "is_follower" boolean)
    LANGUAGE "plpgsql"
    SET "search_path" TO ''
    AS $$
BEGIN
    RETURN QUERY
    SELECT u.id, u.username, u.name, u.profile_picture, u.bio, u.is_verified, u.is_following, u.is_follower
    FROM public.post_likes l
    JOIN public.full_user_info u on u.id = l.user_uid
    WHERE
    l.is_dislike = p_dislikes AND
    l.post_id = p_id AND
    --paging
    (p_last_uid is NULL or (p_last_uid < u.id))
    -- blocking
    AND NOT EXISTS (
            SELECT 1 FROM public.blocked b
            WHERE 
                (b.source_uid = (SELECT auth.uid()) AND b.target_uid = u.id) OR
                (b.source_uid = u.id AND b.target_uid = (SELECT auth.uid()))
    )
    ORDER BY u.id DESC
    LIMIT p_limit;
END;
$$;


ALTER FUNCTION "public"."paginated_post_likes"("p_limit" integer, "p_id" bigint, "p_last_uid" "uuid", "p_dislikes" boolean) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."paginated_user_followers"("p_limit" integer, "p_uid" "uuid", "p_last_uid" "uuid") RETURNS TABLE("id" "uuid", "username" "text", "name" "text", "profile_picture" "text", "bio" "text", "is_verified" boolean)
    LANGUAGE "plpgsql"
    SET "search_path" TO ''
    AS $$
  BEGIN
    RETURN QUERY
    SELECT u.id, u.username, u.name, u.profile_picture, u.bio, u.is_verified
    FROM public.following f
    JOIN public.users u ON u.id = f.source_uid
    WHERE
      f.target_uid = p_uid
      AND (p_last_uid IS NULL OR p_last_uid < u.id)
      AND NOT EXISTS (
        SELECT 1
        FROM public.blocked b
        WHERE
          (b.source_uid = auth.uid() AND b.target_uid = u.id)
          OR (b.source_uid = u.id AND b.target_uid = auth.uid())
      )
    ORDER BY u.id DESC
    LIMIT p_limit;
  END;
  $$;


ALTER FUNCTION "public"."paginated_user_followers"("p_limit" integer, "p_uid" "uuid", "p_last_uid" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."paginated_user_following"("p_limit" integer, "p_uid" "uuid", "p_last_uid" "uuid") RETURNS TABLE("id" "uuid", "username" "text", "name" "text", "profile_picture" "text", "bio" "text", "is_verified" boolean)
    LANGUAGE "plpgsql"
    SET "search_path" TO ''
    AS $$
  BEGIN
    RETURN QUERY
    SELECT u.id, u.username, u.name, u.profile_picture, u.bio, u.is_verified
    FROM public.following f
    JOIN public.users u ON u.id = f.target_uid
    WHERE
      f.source_uid = p_uid
      AND (p_last_uid IS NULL OR p_last_uid < u.id)
      AND NOT EXISTS (
        SELECT 1
        FROM public.blocked b
        WHERE
          (b.source_uid = auth.uid() AND b.target_uid = u.id)
          OR (b.source_uid = u.id AND b.target_uid = auth.uid())
      )
    ORDER BY u.id DESC
    LIMIT p_limit;
  END;
  $$;


ALTER FUNCTION "public"."paginated_user_following"("p_limit" integer, "p_uid" "uuid", "p_last_uid" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."paginated_user_posts"("p_limit" integer, "p_user_uid" "uuid", "p_last_time" timestamp with time zone DEFAULT NULL::timestamp with time zone, "p_last_id" bigint DEFAULT NULL::bigint) RETURNS TABLE("id" bigint, "author_uid" "uuid", "created_at" timestamp with time zone, "title" "text", "body" "text", "gif" "text", "image" "text", "ekoed_id" bigint, "like_count" bigint, "dislike_count" bigint, "comment_count" bigint, "is_liked" boolean, "is_disliked" boolean, "poll" "jsonb", "vote" bigint)
    LANGUAGE "sql" STABLE
    SET "search_path" TO ''
    AS $$
 
    SELECT *
    FROM public.full_post_info AS p
    WHERE p_user_uid = p.author_uid
      AND (p_last_time IS NULL OR (p.created_at, p.id) < (p_last_time, p_last_id))
    ORDER BY p.created_at DESC, p.id DESC
    LIMIT p_limit;

  $$;


ALTER FUNCTION "public"."paginated_user_posts"("p_limit" integer, "p_user_uid" "uuid", "p_last_time" timestamp with time zone, "p_last_id" bigint) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."poll_vote"("p_post_id" bigint, "p_option_id" bigint) RETURNS "void"
    LANGUAGE "sql"
    SET "search_path" TO ''
    AS $$
insert into public.poll_votes (option_id, post_id, user_uid) VALUES
 (p_option_id, p_post_id, (select auth.uid())) on conflict (post_id, user_uid) do update set option_id = p_option_id;
$$;


ALTER FUNCTION "public"."poll_vote"("p_post_id" bigint, "p_option_id" bigint) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."remove_poll_vote"("p_post_id" bigint) RETURNS "void"
    LANGUAGE "sql"
    SET "search_path" TO ''
    AS $$
delete from public.poll_votes where post_id = p_post_id AND user_uid = (select auth.uid())$$;


ALTER FUNCTION "public"."remove_poll_vote"("p_post_id" bigint) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."report"("p_post_id" bigint, "p_message" "text") RETURNS "void"
    LANGUAGE "sql"
    SET "search_path" TO ''
    AS $$
  INSERT INTO public.reports (post_id, message) VALUES (p_post_id, p_message);
$$;


ALTER FUNCTION "public"."report"("p_post_id" bigint, "p_message" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."search_users"("p_search" "text", "p_last_similarity" real, "p_last_uid" "uuid", "p_limit" integer, "p_exclude_current_user" boolean) RETURNS TABLE("id" "uuid", "username" "text", "name" "text", "profile_picture" "text", "bio" "text", "is_verified" boolean, "is_following" boolean, "is_follower" boolean, "similarity" real)
    LANGUAGE "plpgsql"
    SET "search_path" TO ''
    AS $$
BEGIN
    RETURN QUERY
    SELECT u.id, u.username, u.name, u.profile_picture, u.bio, u.is_verified, u.is_following, u.is_follower, GREATEST(extensions.similarity(u.username, p_search), extensions.similarity(u.name, p_search)) AS similarity
    FROM public.full_user_info u
    WHERE 
    --paging
    (p_last_similarity is NULL or (GREATEST(extensions.similarity(u.username, p_search), extensions.similarity(u.name, p_search)), u.id) < (p_last_similarity, p_last_uid))

    --exclusion
    AND (NOT p_exclude_current_user OR u.id <> auth.uid())
    -- blocking
    AND NOT EXISTS (
            SELECT 1 FROM public.blocked b
            WHERE 
                (b.source_uid = (SELECT auth.uid()) AND b.target_uid = u.id) OR
                (b.source_uid = u.id AND b.target_uid = (SELECT auth.uid()))
        )
    ORDER BY GREATEST(extensions.similarity(u.username ,p_search), extensions.similarity(u.name, p_search)) DESC, u.id DESC

    LIMIT p_limit;
END;
$$;


ALTER FUNCTION "public"."search_users"("p_search" "text", "p_last_similarity" real, "p_last_uid" "uuid", "p_limit" integer, "p_exclude_current_user" boolean) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_notifications"("p_device_id" "uuid", "p_token" "text", "p_active" boolean, "p_device_type" "public"."DEVICE_TYPE", "p_notification_type" "public"."NOTIFICATION_TYPE") RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
  v_uid UUID := auth.uid();
BEGIN
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'Not authorized';
  END IF;

  INSERT INTO public.notifications (
    device_id,
    user_uid, 
    token,
    active,
    device_type, 
    notification_type, 
    updated_at
  )
  VALUES (
    p_device_id,
    v_uid, 
    p_token, 
    p_active,
    p_device_type, 
    p_notification_type, 
    now()
  )
  ON CONFLICT (user_uid, device_id) 
  DO UPDATE SET
    token = EXCLUDED.token,
    active = EXCLUDED.active,
    device_type = EXCLUDED.device_type,
    notification_type = EXCLUDED.notification_type,
    updated_at = now();
END;
$$;


ALTER FUNCTION "public"."update_notifications"("p_device_id" "uuid", "p_token" "text", "p_active" boolean, "p_device_type" "public"."DEVICE_TYPE", "p_notification_type" "public"."NOTIFICATION_TYPE") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_profile"("p_name" "text" DEFAULT NULL::"text", "p_bio" "text" DEFAULT NULL::"text", "p_username" "text" DEFAULT NULL::"text", "p_profile_picture" "text" DEFAULT NULL::"text") RETURNS TABLE("success" boolean, "error_message" "text", "id" "uuid", "username" "text", "name" "text", "profile_picture" "text", "bio" "text", "is_verified" boolean, "is_following" boolean, "is_follower" boolean)
    LANGUAGE "plpgsql"
    SET "search_path" TO ''
    AS $$
DECLARE
  v_uid UUID := auth.uid();
  v_current_username TEXT;
  v_next_username TEXT;
BEGIN
  IF v_uid IS NULL THEN
    RETURN QUERY SELECT false, 'not_authenticated'::text, NULL::uuid, NULL::text, NULL::text, NULL::text, NULL::text, NULL::boolean, NULL::boolean, NULL::boolean;
    RETURN;
  END IF;

  SELECT u.username
  INTO v_current_username
  FROM public.users u
  WHERE u.id = v_uid;

  IF v_current_username IS NULL THEN
    RETURN QUERY SELECT false, 'user_not_found'::text, NULL::uuid, NULL::text, NULL::text, NULL::text, NULL::text, NULL::boolean, NULL::boolean, NULL::boolean;
    RETURN;
  END IF;

  v_next_username := NULLIF(BTRIM(p_username), '');

  IF v_next_username IS NOT NULL AND v_next_username <> v_current_username THEN
    IF EXISTS (
      SELECT 1
      FROM public.usernames un
      WHERE un.username = v_next_username
        AND un.user_uid <> v_uid
    ) THEN
      RETURN QUERY SELECT false, 'username_taken'::text, NULL::uuid, NULL::text, NULL::text, NULL::text, NULL::text, NULL::boolean, NULL::boolean, NULL::boolean;
      RETURN;
    END IF;
  ELSE
    v_next_username := v_current_username;
  END IF;

  BEGIN
    IF v_next_username <> v_current_username THEN
      UPDATE public.users AS u
      SET username = v_next_username
      WHERE u.id = v_uid;

      UPDATE public.usernames AS un
      SET username = v_next_username
      WHERE un.user_uid = v_uid;
    END IF;

    UPDATE public.users AS u
    SET
      name = COALESCE(p_name, u.name),
      bio = COALESCE(p_bio, u.bio),
      profile_picture = COALESCE(p_profile_picture, u.profile_picture)
    WHERE u.id = v_uid;
  EXCEPTION
    WHEN unique_violation THEN
      RETURN QUERY SELECT false, 'username_taken'::text, NULL::uuid, NULL::text, NULL::text, NULL::text, NULL::text, NULL::boolean, NULL::boolean, NULL::boolean;
      RETURN;
    WHEN OTHERS THEN
      RETURN QUERY SELECT false, SQLERRM::text, NULL::uuid, NULL::text, NULL::text, NULL::text, NULL::text, NULL::boolean, NULL::boolean, NULL::boolean;
      RETURN;
  END;

  RETURN QUERY
  SELECT true, NULL::text, u.id, u.username, u.name, u.profile_picture, u.bio, u.is_verified, u.is_following, u.is_follower
  FROM public.full_user_info u
  WHERE u.id = v_uid
  LIMIT 1;
END;
$$;


ALTER FUNCTION "public"."update_profile"("p_name" "text", "p_bio" "text", "p_username" "text", "p_profile_picture" "text") OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."activity" (
    "id" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "source_uid" "uuid" DEFAULT "auth"."uid"(),
    "post_id" bigint,
    "type" "public"."ACTIVITY_TYPE" NOT NULL,
    "target_uid" "uuid" NOT NULL,
    "comment_id" bigint
);


ALTER TABLE "public"."activity" OWNER TO "postgres";


ALTER TABLE "public"."activity" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."activity_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."blocked" (
    "source_uid" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "target_uid" "uuid" DEFAULT "gen_random_uuid"() NOT NULL
);


ALTER TABLE "public"."blocked" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."comment_likes" (
    "user_uid" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "comment_id" bigint NOT NULL,
    "is_dislike" boolean DEFAULT false NOT NULL
);


ALTER TABLE "public"."comment_likes" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."comments" (
    "id" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "author_uid" "uuid" DEFAULT "auth"."uid"() NOT NULL,
    "body" "text",
    "gif" "text",
    "parent_post_id" bigint NOT NULL,
    "firebase_uid" "text"
);


ALTER TABLE "public"."comments" OWNER TO "postgres";


ALTER TABLE "public"."comments" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."comments_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."following" (
    "source_uid" "uuid" DEFAULT "auth"."uid"() NOT NULL,
    "target_uid" "uuid" DEFAULT "auth"."uid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."following" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."full_comment_info" WITH ("security_invoker"='on') AS
 SELECT "p"."id",
    "p"."author_uid",
    "p"."created_at",
    "p"."body",
    "p"."gif",
    ( SELECT "count"(*) AS "count"
           FROM "public"."comment_likes" "l"
          WHERE (("l"."comment_id" = "p"."id") AND ("l"."is_dislike" = false))) AS "like_count",
    ( SELECT "count"(*) AS "count"
           FROM "public"."comment_likes" "l"
          WHERE (("l"."comment_id" = "p"."id") AND ("l"."is_dislike" = true))) AS "dislike_count",
    "p"."parent_post_id",
    (EXISTS ( SELECT 1
           FROM "public"."comment_likes" "l"
          WHERE (("l"."comment_id" = "p"."id") AND ("l"."user_uid" = "u"."uid") AND ("l"."is_dislike" = false)))) AS "is_liked",
    (EXISTS ( SELECT 1
           FROM "public"."comment_likes" "l"
          WHERE (("l"."comment_id" = "p"."id") AND ("l"."user_uid" = "u"."uid") AND ("l"."is_dislike" = true)))) AS "is_disliked"
   FROM "public"."comments" "p",
    LATERAL ( SELECT "auth"."uid"() AS "uid") "u";


ALTER VIEW "public"."full_comment_info" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."poll_votes" (
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "option_id" bigint NOT NULL,
    "post_id" bigint NOT NULL,
    "user_uid" "uuid" DEFAULT "auth"."uid"() NOT NULL
);


ALTER TABLE "public"."poll_votes" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."post_likes" (
    "user_uid" "uuid" DEFAULT "auth"."uid"() NOT NULL,
    "post_id" bigint NOT NULL,
    "is_dislike" boolean DEFAULT false NOT NULL
);


ALTER TABLE "public"."post_likes" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."posts" (
    "id" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "author_uid" "uuid" DEFAULT "auth"."uid"() NOT NULL,
    "title" "text",
    "body" "text",
    "gif" "text",
    "image" "bytea",
    "ekoed_id" bigint,
    "firebase_uid" "text"
);


ALTER TABLE "public"."posts" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."full_post_info" WITH ("security_invoker"='on') AS
 SELECT "p"."id",
    "p"."author_uid",
    "p"."created_at",
    "p"."title",
    "p"."body",
    "p"."gif",
    "regexp_replace"("encode"("p"."image", 'base64'::"text"), '\n'::"text", ''::"text", 'g'::"text") AS "image",
    "p"."ekoed_id",
    ( SELECT "count"(*) AS "count"
           FROM "public"."post_likes" "l"
          WHERE (("l"."post_id" = "p"."id") AND ("l"."is_dislike" = false))) AS "like_count",
    ( SELECT "count"(*) AS "count"
           FROM "public"."post_likes" "l"
          WHERE (("l"."post_id" = "p"."id") AND ("l"."is_dislike" = true))) AS "dislike_count",
    ( SELECT "count"(*) AS "count"
           FROM "public"."comments" "c"
          WHERE ("c"."parent_post_id" = "p"."id")) AS "comment_count",
    (EXISTS ( SELECT 1
           FROM "public"."post_likes" "l"
          WHERE (("l"."post_id" = "p"."id") AND ("l"."user_uid" = "u"."uid") AND ("l"."is_dislike" = false)))) AS "is_liked",
    (EXISTS ( SELECT 1
           FROM "public"."post_likes" "l"
          WHERE (("l"."post_id" = "p"."id") AND ("l"."user_uid" = "u"."uid") AND ("l"."is_dislike" = true)))) AS "is_disliked",
    "poll"."results" AS "poll_results",
    ( SELECT "v"."option_id"
           FROM "public"."poll_votes" "v"
          WHERE (("v"."post_id" = "p"."id") AND ("v"."user_uid" = "u"."uid"))
         LIMIT 1) AS "vote"
   FROM "public"."posts" "p",
    LATERAL ( SELECT "auth"."uid"() AS "uid") "u",
    LATERAL ( SELECT "public"."get_post_poll_results_json"("p"."id") AS "results") "poll";


ALTER VIEW "public"."full_post_info" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."users" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "profile_picture" "text",
    "birthday" "date",
    "name" "text",
    "username" "text" NOT NULL,
    "firebase_uid" "text",
    "is_verified" boolean DEFAULT false,
    "bio" "text"
);


ALTER TABLE "public"."users" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."full_user_info" WITH ("security_invoker"='on') AS
 SELECT "id",
    "username",
    "name",
    "profile_picture",
    "bio",
    "is_verified",
    (EXISTS ( SELECT 1
           FROM "public"."following" "f"
          WHERE (("f"."target_uid" = "u"."id") AND ("f"."source_uid" = ( SELECT "auth"."uid"() AS "uid"))))) AS "is_following",
    (EXISTS ( SELECT 1
           FROM "public"."following" "f"
          WHERE (("f"."source_uid" = "u"."id") AND ("f"."target_uid" = ( SELECT "auth"."uid"() AS "uid"))))) AS "is_follower"
   FROM "public"."users" "u";


ALTER VIEW "public"."full_user_info" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."functions_cache" (
    "id" bigint NOT NULL,
    "data" "jsonb" NOT NULL,
    "cache_key" "text" NOT NULL,
    "expires_at" timestamp with time zone,
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."functions_cache" OWNER TO "postgres";


ALTER TABLE "public"."functions_cache" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."functions_cache_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."logos" (
    "id" smallint NOT NULL,
    "svg" "text" DEFAULT ''::"text" NOT NULL,
    "desc" "text"
);


ALTER TABLE "public"."logos" OWNER TO "postgres";


ALTER TABLE "public"."logos" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."logos_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."notifications" (
    "user_uid" "uuid" DEFAULT "auth"."uid"() NOT NULL,
    "token" "text" NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "device_type" "public"."DEVICE_TYPE",
    "notification_type" "public"."NOTIFICATION_TYPE" NOT NULL,
    "device_id" "uuid" NOT NULL,
    "active" boolean DEFAULT true NOT NULL
);


ALTER TABLE "public"."notifications" OWNER TO "postgres";


COMMENT ON COLUMN "public"."notifications"."notification_type" IS 'delete when we setup relay';



CREATE TABLE IF NOT EXISTS "public"."poll_options" (
    "id" bigint NOT NULL,
    "value" "text" DEFAULT ''::"text" NOT NULL,
    "post_id" bigint NOT NULL
);


ALTER TABLE "public"."poll_options" OWNER TO "postgres";


ALTER TABLE "public"."poll_options" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."poll_options_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



ALTER TABLE "public"."posts" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."posts_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."reports" (
    "id" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "source_uid" "uuid" DEFAULT "auth"."uid"(),
    "target_uid" "uuid",
    "post_id" bigint,
    "message" "text" NOT NULL
);


ALTER TABLE "public"."reports" OWNER TO "postgres";


ALTER TABLE "public"."reports" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."reports_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."usernames" (
    "user_uid" "uuid" DEFAULT "auth"."uid"() NOT NULL,
    "username" "text" NOT NULL
);


ALTER TABLE "public"."usernames" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."utilities" (
    "platform" "text" NOT NULL,
    "minimum_version" "text" NOT NULL
);


ALTER TABLE "public"."utilities" OWNER TO "postgres";


ALTER TABLE ONLY "public"."activity"
    ADD CONSTRAINT "activity_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."blocked"
    ADD CONSTRAINT "blocked_pkey" PRIMARY KEY ("source_uid", "target_uid");



ALTER TABLE ONLY "public"."comment_likes"
    ADD CONSTRAINT "comment_likes_pkey" PRIMARY KEY ("user_uid", "comment_id");



ALTER TABLE ONLY "public"."comments"
    ADD CONSTRAINT "comments_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."following"
    ADD CONSTRAINT "following_pkey" PRIMARY KEY ("source_uid", "target_uid");



ALTER TABLE ONLY "public"."functions_cache"
    ADD CONSTRAINT "functions_cache_cache_key_key" UNIQUE ("cache_key");



ALTER TABLE ONLY "public"."functions_cache"
    ADD CONSTRAINT "functions_cache_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."logos"
    ADD CONSTRAINT "logos_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."notifications"
    ADD CONSTRAINT "notifications_pkey" PRIMARY KEY ("user_uid", "device_id");



ALTER TABLE ONLY "public"."poll_options"
    ADD CONSTRAINT "poll_options_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."poll_votes"
    ADD CONSTRAINT "poll_votes_pkey" PRIMARY KEY ("post_id", "user_uid");



ALTER TABLE ONLY "public"."post_likes"
    ADD CONSTRAINT "post_likes_pkey" PRIMARY KEY ("user_uid", "post_id");



ALTER TABLE ONLY "public"."posts"
    ADD CONSTRAINT "posts_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."reports"
    ADD CONSTRAINT "reports_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."usernames"
    ADD CONSTRAINT "usernames_pkey" PRIMARY KEY ("user_uid");



ALTER TABLE ONLY "public"."usernames"
    ADD CONSTRAINT "usernames_username_key" UNIQUE ("username");



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_username_key" UNIQUE ("username");



ALTER TABLE ONLY "public"."utilities"
    ADD CONSTRAINT "utilities_pkey" PRIMARY KEY ("platform");



CREATE INDEX "posts_created_at_id_desc_idx" ON "public"."posts" USING "btree" ("created_at" DESC, "id" DESC);



CREATE INDEX "users_name_trgm_idx" ON "public"."users" USING "gin" ("name" "extensions"."gin_trgm_ops");



CREATE INDEX "users_username_trgm_idx" ON "public"."users" USING "gin" ("username" "extensions"."gin_trgm_ops");



CREATE OR REPLACE TRIGGER "on_activity_creation" AFTER INSERT ON "public"."activity" FOR EACH ROW EXECUTE FUNCTION "public"."notify_user_on_insert"();



CREATE OR REPLACE TRIGGER "on_post_creation" AFTER INSERT ON "public"."posts" FOR EACH ROW EXECUTE FUNCTION "public"."notify_user_on_insert"();



CREATE OR REPLACE TRIGGER "on_public_user_created" AFTER INSERT ON "public"."users" FOR EACH ROW EXECUTE FUNCTION "public"."handle_new_public_user"();



ALTER TABLE ONLY "public"."activity"
    ADD CONSTRAINT "activity_comment_id_fkey" FOREIGN KEY ("comment_id") REFERENCES "public"."comments"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."activity"
    ADD CONSTRAINT "activity_post_id_fkey" FOREIGN KEY ("post_id") REFERENCES "public"."posts"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."activity"
    ADD CONSTRAINT "activity_source_uid_fkey" FOREIGN KEY ("source_uid") REFERENCES "public"."users"("id") ON UPDATE CASCADE ON DELETE SET NULL;



ALTER TABLE ONLY "public"."activity"
    ADD CONSTRAINT "activity_target_uid_fkey" FOREIGN KEY ("target_uid") REFERENCES "public"."users"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."blocked"
    ADD CONSTRAINT "blocked_source_uid_fkey" FOREIGN KEY ("source_uid") REFERENCES "public"."users"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."blocked"
    ADD CONSTRAINT "blocked_target_uid_fkey" FOREIGN KEY ("target_uid") REFERENCES "public"."users"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."comment_likes"
    ADD CONSTRAINT "comment_likes_comment_fkey" FOREIGN KEY ("comment_id") REFERENCES "public"."comments"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."comment_likes"
    ADD CONSTRAINT "comment_likes_user_fkey" FOREIGN KEY ("user_uid") REFERENCES "public"."users"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."comments"
    ADD CONSTRAINT "comments_author_uid_fkey" FOREIGN KEY ("author_uid") REFERENCES "public"."users"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."comments"
    ADD CONSTRAINT "comments_parent_post_id_fkey" FOREIGN KEY ("parent_post_id") REFERENCES "public"."posts"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."following"
    ADD CONSTRAINT "following_source_uid_fkey" FOREIGN KEY ("source_uid") REFERENCES "public"."users"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."following"
    ADD CONSTRAINT "following_target_uid_fkey" FOREIGN KEY ("target_uid") REFERENCES "public"."users"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."notifications"
    ADD CONSTRAINT "notifications_user_uid_fkey" FOREIGN KEY ("user_uid") REFERENCES "public"."users"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."poll_options"
    ADD CONSTRAINT "poll_options_post_id_fkey" FOREIGN KEY ("post_id") REFERENCES "public"."posts"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."poll_votes"
    ADD CONSTRAINT "poll_votes_option_id_fkey" FOREIGN KEY ("option_id") REFERENCES "public"."poll_options"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."poll_votes"
    ADD CONSTRAINT "poll_votes_post_id_fkey" FOREIGN KEY ("post_id") REFERENCES "public"."posts"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."poll_votes"
    ADD CONSTRAINT "poll_votes_user_uid_fkey" FOREIGN KEY ("user_uid") REFERENCES "public"."users"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."post_likes"
    ADD CONSTRAINT "post_likes_post_fkey" FOREIGN KEY ("post_id") REFERENCES "public"."posts"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."post_likes"
    ADD CONSTRAINT "post_likes_user_fkey" FOREIGN KEY ("user_uid") REFERENCES "public"."users"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."posts"
    ADD CONSTRAINT "posts_author_fkey" FOREIGN KEY ("author_uid") REFERENCES "public"."users"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."posts"
    ADD CONSTRAINT "posts_ekoed_id_fkey" FOREIGN KEY ("ekoed_id") REFERENCES "public"."posts"("id") ON UPDATE CASCADE ON DELETE SET NULL;



ALTER TABLE ONLY "public"."reports"
    ADD CONSTRAINT "reports_post_id_fkey" FOREIGN KEY ("post_id") REFERENCES "public"."posts"("id") ON UPDATE CASCADE ON DELETE SET NULL;



ALTER TABLE ONLY "public"."reports"
    ADD CONSTRAINT "reports_source_uid_fkey" FOREIGN KEY ("source_uid") REFERENCES "public"."users"("id") ON UPDATE CASCADE ON DELETE SET NULL;



ALTER TABLE ONLY "public"."reports"
    ADD CONSTRAINT "reports_target_uid_fkey" FOREIGN KEY ("target_uid") REFERENCES "public"."users"("id") ON UPDATE CASCADE ON DELETE SET NULL;



ALTER TABLE ONLY "public"."usernames"
    ADD CONSTRAINT "usernames_user_uid_fkey" FOREIGN KEY ("user_uid") REFERENCES "public"."users"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."usernames"
    ADD CONSTRAINT "usernames_username_fkey" FOREIGN KEY ("username") REFERENCES "public"."users"("username") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_id_fkey" FOREIGN KEY ("id") REFERENCES "auth"."users"("id") ON UPDATE CASCADE ON DELETE CASCADE;



CREATE POLICY "Allow blocking users" ON "public"."blocked" FOR INSERT TO "authenticated" WITH CHECK ((( SELECT "auth"."uid"() AS "uid") = "source_uid"));



CREATE POLICY "Enable delete for users based on user_id" ON "public"."poll_votes" FOR DELETE USING ((( SELECT "auth"."uid"() AS "uid") = "user_uid"));



CREATE POLICY "Enable delete for users based on user_id" ON "public"."post_likes" FOR DELETE TO "authenticated" USING ((( SELECT "auth"."uid"() AS "uid") = "user_uid"));



CREATE POLICY "Enable delete for users based on user_id" ON "public"."posts" FOR DELETE USING (((( SELECT "auth"."uid"() AS "uid") = "author_uid") AND ("created_at" < ("now"() - '48:00:00'::interval))));



CREATE POLICY "Enable insert for users based on user_id" ON "public"."activity" FOR INSERT WITH CHECK ((( SELECT "auth"."uid"() AS "uid") = "source_uid"));



CREATE POLICY "Enable insert for users based on user_id" ON "public"."comments" FOR INSERT TO "authenticated" WITH CHECK ((( SELECT "auth"."uid"() AS "uid") = "author_uid"));



CREATE POLICY "Enable insert for users based on user_id" ON "public"."notifications" FOR INSERT TO "authenticated" WITH CHECK (("auth"."uid"() = "user_uid"));



CREATE POLICY "Enable insert for users based on user_id" ON "public"."poll_votes" FOR INSERT WITH CHECK ((( SELECT "auth"."uid"() AS "uid") = "user_uid"));



CREATE POLICY "Enable insert for users based on user_id" ON "public"."post_likes" FOR INSERT TO "authenticated" WITH CHECK ((( SELECT "auth"."uid"() AS "uid") = "user_uid"));



CREATE POLICY "Enable insert for users based on user_id" ON "public"."posts" FOR INSERT WITH CHECK ((( SELECT "auth"."uid"() AS "uid") = "author_uid"));



CREATE POLICY "Enable insert for users based on user_id" ON "public"."reports" FOR INSERT WITH CHECK ((( SELECT "auth"."uid"() AS "uid") = "source_uid"));



CREATE POLICY "Enable insert for users based on user_id" ON "public"."users" FOR UPDATE TO "authenticated" USING ((( SELECT "auth"."uid"() AS "uid") = "id")) WITH CHECK ((( SELECT "auth"."uid"() AS "uid") = "id"));



CREATE POLICY "Enable read access for all users" ON "public"."logos" FOR SELECT USING (true);



CREATE POLICY "Enable read access for all users" ON "public"."usernames" FOR SELECT USING (true);



CREATE POLICY "Enable read access for all users" ON "public"."users" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Enable read access for all users" ON "public"."utilities" FOR SELECT USING (true);



CREATE POLICY "Enable update for users based on uid" ON "public"."post_likes" FOR UPDATE USING ((( SELECT "auth"."uid"() AS "uid") = "user_uid")) WITH CHECK ((( SELECT "auth"."uid"() AS "uid") = "user_uid"));



CREATE POLICY "Enable users to view their own data only" ON "public"."activity" FOR SELECT TO "authenticated" USING ((( SELECT "auth"."uid"() AS "uid") = "target_uid"));



ALTER TABLE "public"."activity" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "allow ead comments if they can read post" ON "public"."comments" FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."posts" "p"
  WHERE ("p"."id" = "comments"."parent_post_id"))));



CREATE POLICY "block filter" ON "public"."following" FOR SELECT TO "authenticated" USING (((NOT (EXISTS ( SELECT 1
   FROM "public"."blocked" "b"
  WHERE (("b"."target_uid" = ( SELECT "auth"."uid"() AS "uid")) AND (("b"."source_uid" = "following"."source_uid") OR ("b"."source_uid" = "following"."target_uid")))))) AND (NOT (EXISTS ( SELECT 1
   FROM "public"."blocked" "b"
  WHERE (("b"."source_uid" = ( SELECT "auth"."uid"() AS "uid")) AND (("b"."target_uid" = "following"."source_uid") OR ("b"."target_uid" = "following"."target_uid"))))))));



ALTER TABLE "public"."blocked" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."comment_likes" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."comments" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "create poll" ON "public"."poll_options" FOR INSERT WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."posts"
  WHERE (("posts"."id" = "poll_options"."post_id") AND ("posts"."author_uid" = "auth"."uid"())))));



CREATE POLICY "delete based on uid" ON "public"."comment_likes" FOR DELETE TO "authenticated" USING (("user_uid" = ( SELECT "auth"."uid"() AS "uid")));



CREATE POLICY "delete old comments if owned" ON "public"."comments" FOR DELETE USING (((( SELECT "auth"."uid"() AS "uid") = "author_uid") AND ("created_at" < ("now"() - '48:00:00'::interval))));



ALTER TABLE "public"."following" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."functions_cache" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "insert comment likes" ON "public"."comment_likes" FOR INSERT TO "authenticated" WITH CHECK (("user_uid" = ( SELECT "auth"."uid"() AS "uid")));



CREATE POLICY "insert follows where you are source" ON "public"."following" FOR INSERT TO "authenticated" WITH CHECK ((( SELECT "auth"."uid"() AS "uid") = "source_uid"));



ALTER TABLE "public"."logos" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."notifications" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."poll_options" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."poll_votes" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."post_likes" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."posts" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "read comment likes if you can read comment" ON "public"."comment_likes" FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."comments" "c"
  WHERE ("c"."id" = "comment_likes"."comment_id"))));



CREATE POLICY "read if access to parent" ON "public"."poll_options" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."posts" "p"
  WHERE ("p"."id" = "poll_options"."post_id"))));



CREATE POLICY "read if access to parent" ON "public"."poll_votes" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."posts" "p"
  WHERE ("p"."id" = "poll_votes"."post_id"))));



CREATE POLICY "read if not blocked" ON "public"."posts" FOR SELECT USING ((NOT (EXISTS ( SELECT 1
   FROM "public"."blocked" "b"
  WHERE ((("b"."source_uid" = ( SELECT "auth"."uid"() AS "uid")) AND ("b"."target_uid" = "posts"."author_uid")) OR (("b"."source_uid" = "posts"."author_uid") AND ("b"."target_uid" = ( SELECT "auth"."uid"() AS "uid"))))))));



CREATE POLICY "removed anything related to you" ON "public"."following" FOR DELETE TO "authenticated" USING (((( SELECT "auth"."uid"() AS "uid") = "source_uid") OR (( SELECT "auth"."uid"() AS "uid") = "target_uid")));



ALTER TABLE "public"."reports" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "see who you have blocked" ON "public"."blocked" FOR SELECT TO "authenticated" USING ((( SELECT "auth"."uid"() AS "uid") = "source_uid"));



CREATE POLICY "select only user id" ON "public"."notifications" FOR SELECT TO "authenticated" USING (("auth"."uid"() = "user_uid"));



CREATE POLICY "unblock people" ON "public"."blocked" FOR DELETE TO "authenticated" USING ((( SELECT "auth"."uid"() AS "uid") = "source_uid"));



CREATE POLICY "update based on uid" ON "public"."comment_likes" FOR UPDATE TO "authenticated" USING (("user_uid" = ( SELECT "auth"."uid"() AS "uid"))) WITH CHECK (("user_uid" = ( SELECT "auth"."uid"() AS "uid")));



CREATE POLICY "update based on uid" ON "public"."notifications" FOR UPDATE TO "authenticated" USING (("auth"."uid"() = "user_uid")) WITH CHECK (("auth"."uid"() = "user_uid"));



CREATE POLICY "user can read like if they can read post" ON "public"."post_likes" FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."posts" "p"
  WHERE ("p"."id" = "post_likes"."post_id"))));



ALTER TABLE "public"."usernames" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."users" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."utilities" ENABLE ROW LEVEL SECURITY;




ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";


GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";


























































































































































































































































































GRANT ALL ON FUNCTION "public"."change_comment_likes"("p_id" bigint, "p_is_liking" boolean, "p_is_dislike" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."change_comment_likes"("p_id" bigint, "p_is_liking" boolean, "p_is_dislike" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."change_comment_likes"("p_id" bigint, "p_is_liking" boolean, "p_is_dislike" boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."change_follow_state"("p_uid" "uuid", "p_is_follow" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."change_follow_state"("p_uid" "uuid", "p_is_follow" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."change_follow_state"("p_uid" "uuid", "p_is_follow" boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."change_post_likes"("p_id" bigint, "p_is_liking" boolean, "p_is_dislike" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."change_post_likes"("p_id" bigint, "p_is_liking" boolean, "p_is_dislike" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."change_post_likes"("p_id" bigint, "p_is_liking" boolean, "p_is_dislike" boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."create_google_profile"("p_username" "text", "p_name" "text", "p_birthday" "date", "p_profile_picture" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."create_google_profile"("p_username" "text", "p_name" "text", "p_birthday" "date", "p_profile_picture" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_google_profile"("p_username" "text", "p_name" "text", "p_birthday" "date", "p_profile_picture" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."delete_user"() TO "anon";
GRANT ALL ON FUNCTION "public"."delete_user"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."delete_user"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_comment_by_id"("p_id" bigint) TO "anon";
GRANT ALL ON FUNCTION "public"."get_comment_by_id"("p_id" bigint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_comment_by_id"("p_id" bigint) TO "service_role";



GRANT ALL ON FUNCTION "public"."get_follow_info"("p_uid" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_follow_info"("p_uid" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_follow_info"("p_uid" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_logo_of_the_day"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_logo_of_the_day"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_logo_of_the_day"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_min_version"("p_platform" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_min_version"("p_platform" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_min_version"("p_platform" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_post_by_id"("p_id" bigint) TO "anon";
GRANT ALL ON FUNCTION "public"."get_post_by_id"("p_id" bigint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_post_by_id"("p_id" bigint) TO "service_role";



GRANT ALL ON FUNCTION "public"."get_post_poll_results_json"("p_post_id" bigint) TO "anon";
GRANT ALL ON FUNCTION "public"."get_post_poll_results_json"("p_post_id" bigint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_post_poll_results_json"("p_post_id" bigint) TO "service_role";



GRANT ALL ON FUNCTION "public"."get_user_by_id"("p_uid" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_user_by_id"("p_uid" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_user_by_id"("p_uid" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_uuids_from_mentions"("input_texts" "text"[]) TO "anon";
GRANT ALL ON FUNCTION "public"."get_uuids_from_mentions"("input_texts" "text"[]) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_uuids_from_mentions"("input_texts" "text"[]) TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_new_public_user"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_new_public_user"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_new_public_user"() TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "service_role";



GRANT ALL ON FUNCTION "public"."insert_comment"("p_created_at" timestamp with time zone, "p_body" "text", "p_gif" "text", "p_author_uid" "uuid", "p_parent_post_id" bigint) TO "anon";
GRANT ALL ON FUNCTION "public"."insert_comment"("p_created_at" timestamp with time zone, "p_body" "text", "p_gif" "text", "p_author_uid" "uuid", "p_parent_post_id" bigint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."insert_comment"("p_created_at" timestamp with time zone, "p_body" "text", "p_gif" "text", "p_author_uid" "uuid", "p_parent_post_id" bigint) TO "service_role";



GRANT ALL ON FUNCTION "public"."insert_post"("p_created_at" timestamp with time zone, "p_body" "text", "p_title" "text", "p_gif" "text", "p_poll" "text"[], "p_author_uid" "uuid", "p_image_base64" "text", "p_ekoed_id" bigint, OUT "o_post_id" bigint, OUT "o_poll_data" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."insert_post"("p_created_at" timestamp with time zone, "p_body" "text", "p_title" "text", "p_gif" "text", "p_poll" "text"[], "p_author_uid" "uuid", "p_image_base64" "text", "p_ekoed_id" bigint, OUT "o_post_id" bigint, OUT "o_poll_data" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."insert_post"("p_created_at" timestamp with time zone, "p_body" "text", "p_title" "text", "p_gif" "text", "p_poll" "text"[], "p_author_uid" "uuid", "p_image_base64" "text", "p_ekoed_id" bigint, OUT "o_post_id" bigint, OUT "o_poll_data" "jsonb") TO "service_role";



GRANT ALL ON FUNCTION "public"."insert_post"("p_created_at" timestamp with time zone, "p_firebase_uid" "text", "p_body" "text", "p_title" "text", "p_gif" "text", "p_poll" "text"[], "p_author_uid" "uuid", "p_image_base64" "text", "p_ekoed_id" bigint, OUT "o_post_id" bigint, OUT "o_poll_data" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."insert_post"("p_created_at" timestamp with time zone, "p_firebase_uid" "text", "p_body" "text", "p_title" "text", "p_gif" "text", "p_poll" "text"[], "p_author_uid" "uuid", "p_image_base64" "text", "p_ekoed_id" bigint, OUT "o_post_id" bigint, OUT "o_poll_data" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."insert_post"("p_created_at" timestamp with time zone, "p_firebase_uid" "text", "p_body" "text", "p_title" "text", "p_gif" "text", "p_poll" "text"[], "p_author_uid" "uuid", "p_image_base64" "text", "p_ekoed_id" bigint, OUT "o_post_id" bigint, OUT "o_poll_data" "jsonb") TO "service_role";



GRANT ALL ON FUNCTION "public"."is_username_available"("p_username" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."is_username_available"("p_username" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_username_available"("p_username" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."log_comment_activity"("p_comment_id" bigint, "p_post_id" bigint, "p_author_id" "uuid", "p_text" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."log_comment_activity"("p_comment_id" bigint, "p_post_id" bigint, "p_author_id" "uuid", "p_text" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."log_comment_activity"("p_comment_id" bigint, "p_post_id" bigint, "p_author_id" "uuid", "p_text" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."log_follow_activity"("p_source_uid" "uuid", "p_target_uid" "uuid", "p_type" "public"."ACTIVITY_TYPE") TO "anon";
GRANT ALL ON FUNCTION "public"."log_follow_activity"("p_source_uid" "uuid", "p_target_uid" "uuid", "p_type" "public"."ACTIVITY_TYPE") TO "authenticated";
GRANT ALL ON FUNCTION "public"."log_follow_activity"("p_source_uid" "uuid", "p_target_uid" "uuid", "p_type" "public"."ACTIVITY_TYPE") TO "service_role";



GRANT ALL ON FUNCTION "public"."log_post_activity"("p_post_id" bigint, "p_author_id" "uuid", "p_text" "text"[]) TO "anon";
GRANT ALL ON FUNCTION "public"."log_post_activity"("p_post_id" bigint, "p_author_id" "uuid", "p_text" "text"[]) TO "authenticated";
GRANT ALL ON FUNCTION "public"."log_post_activity"("p_post_id" bigint, "p_author_id" "uuid", "p_text" "text"[]) TO "service_role";



GRANT ALL ON FUNCTION "public"."notify_user_on_insert"() TO "anon";
GRANT ALL ON FUNCTION "public"."notify_user_on_insert"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."notify_user_on_insert"() TO "service_role";



GRANT ALL ON FUNCTION "public"."paginated_activities"("p_limit" integer, "p_last_time" timestamp with time zone, "p_last_id" bigint) TO "anon";
GRANT ALL ON FUNCTION "public"."paginated_activities"("p_limit" integer, "p_last_time" timestamp with time zone, "p_last_id" bigint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."paginated_activities"("p_limit" integer, "p_last_time" timestamp with time zone, "p_last_id" bigint) TO "service_role";



GRANT ALL ON FUNCTION "public"."paginated_comment_likes"("p_limit" integer, "p_id" bigint, "p_last_uid" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."paginated_comment_likes"("p_limit" integer, "p_id" bigint, "p_last_uid" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."paginated_comment_likes"("p_limit" integer, "p_id" bigint, "p_last_uid" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."paginated_comments"("p_limit" integer, "p_parent_post_id" bigint, "p_last_time" timestamp with time zone, "p_last_id" bigint) TO "anon";
GRANT ALL ON FUNCTION "public"."paginated_comments"("p_limit" integer, "p_parent_post_id" bigint, "p_last_time" timestamp with time zone, "p_last_id" bigint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."paginated_comments"("p_limit" integer, "p_parent_post_id" bigint, "p_last_time" timestamp with time zone, "p_last_id" bigint) TO "service_role";



GRANT ALL ON FUNCTION "public"."paginated_following_posts"("p_limit" integer, "p_last_time" timestamp with time zone, "p_last_id" bigint) TO "anon";
GRANT ALL ON FUNCTION "public"."paginated_following_posts"("p_limit" integer, "p_last_time" timestamp with time zone, "p_last_id" bigint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."paginated_following_posts"("p_limit" integer, "p_last_time" timestamp with time zone, "p_last_id" bigint) TO "service_role";



GRANT ALL ON FUNCTION "public"."paginated_new_posts"("p_limit" integer, "p_last_time" timestamp with time zone, "p_last_id" bigint) TO "anon";
GRANT ALL ON FUNCTION "public"."paginated_new_posts"("p_limit" integer, "p_last_time" timestamp with time zone, "p_last_id" bigint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."paginated_new_posts"("p_limit" integer, "p_last_time" timestamp with time zone, "p_last_id" bigint) TO "service_role";



GRANT ALL ON FUNCTION "public"."paginated_popular_posts"("p_limit" integer, "p_last_likes" bigint, "p_last_id" bigint) TO "anon";
GRANT ALL ON FUNCTION "public"."paginated_popular_posts"("p_limit" integer, "p_last_likes" bigint, "p_last_id" bigint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."paginated_popular_posts"("p_limit" integer, "p_last_likes" bigint, "p_last_id" bigint) TO "service_role";



GRANT ALL ON FUNCTION "public"."paginated_post_likes"("p_limit" integer, "p_id" bigint, "p_last_uid" "uuid", "p_dislikes" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."paginated_post_likes"("p_limit" integer, "p_id" bigint, "p_last_uid" "uuid", "p_dislikes" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."paginated_post_likes"("p_limit" integer, "p_id" bigint, "p_last_uid" "uuid", "p_dislikes" boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."paginated_user_followers"("p_limit" integer, "p_uid" "uuid", "p_last_uid" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."paginated_user_followers"("p_limit" integer, "p_uid" "uuid", "p_last_uid" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."paginated_user_followers"("p_limit" integer, "p_uid" "uuid", "p_last_uid" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."paginated_user_following"("p_limit" integer, "p_uid" "uuid", "p_last_uid" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."paginated_user_following"("p_limit" integer, "p_uid" "uuid", "p_last_uid" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."paginated_user_following"("p_limit" integer, "p_uid" "uuid", "p_last_uid" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."paginated_user_posts"("p_limit" integer, "p_user_uid" "uuid", "p_last_time" timestamp with time zone, "p_last_id" bigint) TO "anon";
GRANT ALL ON FUNCTION "public"."paginated_user_posts"("p_limit" integer, "p_user_uid" "uuid", "p_last_time" timestamp with time zone, "p_last_id" bigint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."paginated_user_posts"("p_limit" integer, "p_user_uid" "uuid", "p_last_time" timestamp with time zone, "p_last_id" bigint) TO "service_role";



GRANT ALL ON FUNCTION "public"."poll_vote"("p_post_id" bigint, "p_option_id" bigint) TO "anon";
GRANT ALL ON FUNCTION "public"."poll_vote"("p_post_id" bigint, "p_option_id" bigint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."poll_vote"("p_post_id" bigint, "p_option_id" bigint) TO "service_role";



GRANT ALL ON FUNCTION "public"."remove_poll_vote"("p_post_id" bigint) TO "anon";
GRANT ALL ON FUNCTION "public"."remove_poll_vote"("p_post_id" bigint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."remove_poll_vote"("p_post_id" bigint) TO "service_role";



GRANT ALL ON FUNCTION "public"."report"("p_post_id" bigint, "p_message" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."report"("p_post_id" bigint, "p_message" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."report"("p_post_id" bigint, "p_message" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."search_users"("p_search" "text", "p_last_similarity" real, "p_last_uid" "uuid", "p_limit" integer, "p_exclude_current_user" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."search_users"("p_search" "text", "p_last_similarity" real, "p_last_uid" "uuid", "p_limit" integer, "p_exclude_current_user" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."search_users"("p_search" "text", "p_last_similarity" real, "p_last_uid" "uuid", "p_limit" integer, "p_exclude_current_user" boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."update_notifications"("p_device_id" "uuid", "p_token" "text", "p_active" boolean, "p_device_type" "public"."DEVICE_TYPE", "p_notification_type" "public"."NOTIFICATION_TYPE") TO "anon";
GRANT ALL ON FUNCTION "public"."update_notifications"("p_device_id" "uuid", "p_token" "text", "p_active" boolean, "p_device_type" "public"."DEVICE_TYPE", "p_notification_type" "public"."NOTIFICATION_TYPE") TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_notifications"("p_device_id" "uuid", "p_token" "text", "p_active" boolean, "p_device_type" "public"."DEVICE_TYPE", "p_notification_type" "public"."NOTIFICATION_TYPE") TO "service_role";



GRANT ALL ON FUNCTION "public"."update_profile"("p_name" "text", "p_bio" "text", "p_username" "text", "p_profile_picture" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."update_profile"("p_name" "text", "p_bio" "text", "p_username" "text", "p_profile_picture" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_profile"("p_name" "text", "p_bio" "text", "p_username" "text", "p_profile_picture" "text") TO "service_role";



SET SESSION AUTHORIZATION "postgres";
RESET SESSION AUTHORIZATION;



SET SESSION AUTHORIZATION "postgres";
RESET SESSION AUTHORIZATION;



SET SESSION AUTHORIZATION "postgres";
RESET SESSION AUTHORIZATION;















GRANT ALL ON TABLE "public"."activity" TO "anon";
GRANT ALL ON TABLE "public"."activity" TO "authenticated";
GRANT ALL ON TABLE "public"."activity" TO "service_role";



GRANT ALL ON SEQUENCE "public"."activity_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."activity_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."activity_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."blocked" TO "anon";
GRANT ALL ON TABLE "public"."blocked" TO "authenticated";
GRANT ALL ON TABLE "public"."blocked" TO "service_role";



GRANT ALL ON TABLE "public"."comment_likes" TO "anon";
GRANT ALL ON TABLE "public"."comment_likes" TO "authenticated";
GRANT ALL ON TABLE "public"."comment_likes" TO "service_role";



GRANT ALL ON TABLE "public"."comments" TO "anon";
GRANT ALL ON TABLE "public"."comments" TO "authenticated";
GRANT ALL ON TABLE "public"."comments" TO "service_role";



GRANT ALL ON SEQUENCE "public"."comments_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."comments_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."comments_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."following" TO "anon";
GRANT ALL ON TABLE "public"."following" TO "authenticated";
GRANT ALL ON TABLE "public"."following" TO "service_role";



GRANT ALL ON TABLE "public"."full_comment_info" TO "anon";
GRANT ALL ON TABLE "public"."full_comment_info" TO "authenticated";
GRANT ALL ON TABLE "public"."full_comment_info" TO "service_role";



GRANT ALL ON TABLE "public"."poll_votes" TO "anon";
GRANT ALL ON TABLE "public"."poll_votes" TO "authenticated";
GRANT ALL ON TABLE "public"."poll_votes" TO "service_role";



GRANT ALL ON TABLE "public"."post_likes" TO "anon";
GRANT ALL ON TABLE "public"."post_likes" TO "authenticated";
GRANT ALL ON TABLE "public"."post_likes" TO "service_role";



GRANT ALL ON TABLE "public"."posts" TO "anon";
GRANT ALL ON TABLE "public"."posts" TO "authenticated";
GRANT ALL ON TABLE "public"."posts" TO "service_role";



GRANT ALL ON TABLE "public"."full_post_info" TO "anon";
GRANT ALL ON TABLE "public"."full_post_info" TO "authenticated";
GRANT ALL ON TABLE "public"."full_post_info" TO "service_role";



GRANT ALL ON TABLE "public"."users" TO "anon";
GRANT ALL ON TABLE "public"."users" TO "authenticated";
GRANT ALL ON TABLE "public"."users" TO "service_role";



GRANT ALL ON TABLE "public"."full_user_info" TO "anon";
GRANT ALL ON TABLE "public"."full_user_info" TO "authenticated";
GRANT ALL ON TABLE "public"."full_user_info" TO "service_role";



GRANT ALL ON TABLE "public"."functions_cache" TO "anon";
GRANT ALL ON TABLE "public"."functions_cache" TO "authenticated";
GRANT ALL ON TABLE "public"."functions_cache" TO "service_role";



GRANT ALL ON SEQUENCE "public"."functions_cache_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."functions_cache_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."functions_cache_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."logos" TO "anon";
GRANT ALL ON TABLE "public"."logos" TO "authenticated";
GRANT ALL ON TABLE "public"."logos" TO "service_role";



GRANT ALL ON SEQUENCE "public"."logos_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."logos_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."logos_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."notifications" TO "anon";
GRANT ALL ON TABLE "public"."notifications" TO "authenticated";
GRANT ALL ON TABLE "public"."notifications" TO "service_role";



GRANT ALL ON TABLE "public"."poll_options" TO "anon";
GRANT ALL ON TABLE "public"."poll_options" TO "authenticated";
GRANT ALL ON TABLE "public"."poll_options" TO "service_role";



GRANT ALL ON SEQUENCE "public"."poll_options_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."poll_options_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."poll_options_id_seq" TO "service_role";



GRANT ALL ON SEQUENCE "public"."posts_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."posts_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."posts_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."reports" TO "anon";
GRANT ALL ON TABLE "public"."reports" TO "authenticated";
GRANT ALL ON TABLE "public"."reports" TO "service_role";



GRANT ALL ON SEQUENCE "public"."reports_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."reports_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."reports_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."usernames" TO "anon";
GRANT ALL ON TABLE "public"."usernames" TO "authenticated";
GRANT ALL ON TABLE "public"."usernames" TO "service_role";



GRANT ALL ON TABLE "public"."utilities" TO "anon";
GRANT ALL ON TABLE "public"."utilities" TO "authenticated";
GRANT ALL ON TABLE "public"."utilities" TO "service_role";



SET SESSION AUTHORIZATION "postgres";
RESET SESSION AUTHORIZATION;



SET SESSION AUTHORIZATION "postgres";
RESET SESSION AUTHORIZATION;



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "service_role";































