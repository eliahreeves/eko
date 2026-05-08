CREATE INDEX "comments_parent_post_created_id_idx" ON "public"."comments" USING "btree" ("parent_post_id", "created_at", "id");

CREATE INDEX "posts_author_created_id_desc_idx" ON "public"."posts" USING "btree" ("author_uid", "created_at" DESC, "id" DESC);

CREATE INDEX "following_target_source_idx" ON "public"."following" USING "btree" ("target_uid", "source_uid");

CREATE INDEX "post_likes_post_dislike_user_desc_idx" ON "public"."post_likes" USING "btree" ("post_id", "is_dislike", "user_uid" DESC);

CREATE INDEX "post_likes_post_user_is_dislike_idx" ON "public"."post_likes" USING "btree" ("post_id", "user_uid", "is_dislike");

CREATE INDEX "comment_likes_comment_dislike_user_desc_idx" ON "public"."comment_likes" USING "btree" ("comment_id", "is_dislike", "user_uid" DESC);

CREATE INDEX "comment_likes_comment_user_is_dislike_idx" ON "public"."comment_likes" USING "btree" ("comment_id", "user_uid", "is_dislike");

CREATE INDEX "blocked_target_source_idx" ON "public"."blocked" USING "btree" ("target_uid", "source_uid");

CREATE INDEX "activity_target_created_id_desc_idx" ON "public"."activity" USING "btree" ("target_uid", "created_at" DESC, "id" DESC);
