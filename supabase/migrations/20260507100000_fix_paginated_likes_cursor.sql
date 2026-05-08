CREATE OR REPLACE FUNCTION "public"."paginated_post_likes" (
  "p_limit" integer,
  "p_id" bigint,
  "p_last_uid" "uuid",
  "p_dislikes" boolean
) RETURNS TABLE (
  "id" "uuid",
  "username" "text",
  "name" "text",
  "profile_picture" "text",
  "bio" "text",
  "is_verified" boolean,
  "is_following" boolean,
  "is_follower" boolean
) LANGUAGE "plpgsql"
SET
  "search_path" TO '' AS $$
BEGIN
    RETURN QUERY
    SELECT u.id, u.username, u.name, u.profile_picture, u.bio, u.is_verified, u.is_following, u.is_follower
    FROM public.post_likes l
    JOIN public.full_user_info u on u.id = l.user_uid
    WHERE
    l.is_dislike = p_dislikes AND
    l.post_id = p_id AND
    (p_last_uid is NULL or (u.id < p_last_uid))
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

CREATE OR REPLACE FUNCTION "public"."paginated_comment_likes" (
  "p_limit" integer,
  "p_id" bigint,
  "p_last_uid" "uuid",
  "p_dislikes" boolean
) RETURNS TABLE (
  "id" "uuid",
  "username" "text",
  "name" "text",
  "profile_picture" "text",
  "bio" "text",
  "is_verified" boolean,
  "is_following" boolean,
  "is_follower" boolean
) LANGUAGE "plpgsql"
SET
  "search_path" TO '' AS $$
BEGIN
    RETURN QUERY
    SELECT u.id, u.username, u.name, u.profile_picture, u.bio, u.is_verified, u.is_following, u.is_follower
    FROM public.comment_likes l
    JOIN public.full_user_info u on u.id = l.user_uid
    WHERE
    l.is_dislike = p_dislikes AND
    l.comment_id = p_id AND
    (p_last_uid is NULL or (u.id < p_last_uid))
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

CREATE OR REPLACE FUNCTION "public"."paginated_user_followers" (
  "p_limit" integer,
  "p_uid" "uuid",
  "p_last_uid" "uuid"
) RETURNS TABLE (
  "id" "uuid",
  "username" "text",
  "name" "text",
  "profile_picture" "text",
  "bio" "text",
  "is_verified" boolean
) LANGUAGE "plpgsql"
SET
  "search_path" TO '' AS $$
BEGIN
  RETURN QUERY
  SELECT u.id, u.username, u.name, u.profile_picture, u.bio, u.is_verified
  FROM public.following f
  JOIN public.users u ON u.id = f.source_uid
  WHERE
    f.target_uid = p_uid
    AND (p_last_uid IS NULL OR u.id < p_last_uid)
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

CREATE OR REPLACE FUNCTION "public"."paginated_user_following" (
  "p_limit" integer,
  "p_uid" "uuid",
  "p_last_uid" "uuid"
) RETURNS TABLE (
  "id" "uuid",
  "username" "text",
  "name" "text",
  "profile_picture" "text",
  "bio" "text",
  "is_verified" boolean
) LANGUAGE "plpgsql"
SET
  "search_path" TO '' AS $$
BEGIN
  RETURN QUERY
  SELECT u.id, u.username, u.name, u.profile_picture, u.bio, u.is_verified
  FROM public.following f
  JOIN public.users u ON u.id = f.target_uid
  WHERE
    f.source_uid = p_uid
    AND (p_last_uid IS NULL OR u.id < p_last_uid)
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
