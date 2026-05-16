CREATE OR REPLACE FUNCTION "public"."paginated_user_posts_popular" (
  "p_limit" integer,
  "p_user_uid" "uuid",
  "p_last_likes" bigint DEFAULT NULL::bigint,
  "p_last_id" bigint DEFAULT NULL::bigint
) RETURNS TABLE (
  "id" bigint,
  "author_uid" "uuid",
  "created_at" timestamp with time zone,
  "title" "text",
  "body" "text",
  "gif" "text",
  "image" "text",
  "ekoed_id" bigint,
  "like_count" bigint,
  "dislike_count" bigint,
  "comment_count" bigint,
  "is_liked" boolean,
  "is_disliked" boolean,
  "poll" "jsonb",
  "vote" bigint
) LANGUAGE "sql" STABLE
SET
  "search_path" TO '' AS $$
  SELECT *
  FROM public.full_post_info AS p
  WHERE p.author_uid = p_user_uid
    AND (
      p_last_likes IS NULL
      OR (p.like_count + p.dislike_count, p.id) < (p_last_likes, p_last_id)
    )
  ORDER BY p.like_count + p.dislike_count DESC, p.id DESC
  LIMIT p_limit;
$$;

ALTER FUNCTION "public"."paginated_user_posts_popular" (
  "p_limit" integer,
  "p_user_uid" "uuid",
  "p_last_likes" bigint,
  "p_last_id" bigint
) OWNER TO "postgres";

GRANT ALL ON FUNCTION "public"."paginated_user_posts_popular" (
  "p_limit" integer,
  "p_user_uid" "uuid",
  "p_last_likes" bigint,
  "p_last_id" bigint
) TO "anon";

GRANT ALL ON FUNCTION "public"."paginated_user_posts_popular" (
  "p_limit" integer,
  "p_user_uid" "uuid",
  "p_last_likes" bigint,
  "p_last_id" bigint
) TO "authenticated";

GRANT ALL ON FUNCTION "public"."paginated_user_posts_popular" (
  "p_limit" integer,
  "p_user_uid" "uuid",
  "p_last_likes" bigint,
  "p_last_id" bigint
) TO "service_role";

