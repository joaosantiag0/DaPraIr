-- CreateTable
CREATE TABLE "forum_categories" (
    "id" UUID NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "slug" VARCHAR(100) NOT NULL,
    "description" TEXT NOT NULL,
    "icon_name" VARCHAR(50) NOT NULL,
    "display_order" INTEGER NOT NULL DEFAULT 0,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "topics_count" INTEGER NOT NULL DEFAULT 0,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "forum_categories_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "forum_topics" (
    "id" UUID NOT NULL,
    "category_id" UUID NOT NULL,
    "author_id" UUID NOT NULL,
    "title" VARCHAR(200) NOT NULL,
    "content" TEXT NOT NULL,
    "visibility" VARCHAR(20) NOT NULL DEFAULT 'PUBLIC',
    "status" VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    "is_edited" BOOLEAN NOT NULL DEFAULT false,
    "edited_at" TIMESTAMPTZ,
    "likes_count" INTEGER NOT NULL DEFAULT 0,
    "comments_count" INTEGER NOT NULL DEFAULT 0,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "forum_topics_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "forum_comments" (
    "id" UUID NOT NULL,
    "topic_id" UUID NOT NULL,
    "parent_id" UUID,
    "author_id" UUID NOT NULL,
    "reply_to_user_id" UUID,
    "content" TEXT NOT NULL,
    "depth" SMALLINT NOT NULL DEFAULT 1,
    "visibility" VARCHAR(20) NOT NULL DEFAULT 'PUBLIC',
    "status" VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    "is_edited" BOOLEAN NOT NULL DEFAULT false,
    "edited_at" TIMESTAMPTZ,
    "likes_count" INTEGER NOT NULL DEFAULT 0,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "forum_comments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "forum_topic_likes" (
    "id" UUID NOT NULL,
    "topic_id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "forum_topic_likes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "forum_comment_likes" (
    "id" UUID NOT NULL,
    "comment_id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "forum_comment_likes_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "forum_categories_name_key" ON "forum_categories"("name");

-- CreateIndex
CREATE UNIQUE INDEX "forum_categories_slug_key" ON "forum_categories"("slug");

-- CreateIndex
CREATE INDEX "forum_categories_is_active_display_order_idx" ON "forum_categories"("is_active", "display_order");

-- CreateIndex
CREATE INDEX "forum_topics_category_id_status_created_at_idx" ON "forum_topics"("category_id", "status", "created_at" DESC);

-- CreateIndex
CREATE INDEX "forum_topics_author_id_status_idx" ON "forum_topics"("author_id", "status");

-- CreateIndex
CREATE INDEX "forum_topics_visibility_status_idx" ON "forum_topics"("visibility", "status");

-- CreateIndex
CREATE INDEX "forum_topics_likes_count_idx" ON "forum_topics"("likes_count" DESC);

-- CreateIndex
CREATE INDEX "forum_comments_topic_id_created_at_idx" ON "forum_comments"("topic_id", "created_at" ASC);

-- CreateIndex
CREATE INDEX "forum_comments_parent_id_idx" ON "forum_comments"("parent_id");

-- CreateIndex
CREATE INDEX "forum_comments_author_id_idx" ON "forum_comments"("author_id");

-- CreateIndex
CREATE INDEX "forum_topic_likes_topic_id_idx" ON "forum_topic_likes"("topic_id");

-- CreateIndex
CREATE UNIQUE INDEX "forum_topic_likes_user_id_topic_id_key" ON "forum_topic_likes"("user_id", "topic_id");

-- CreateIndex
CREATE INDEX "forum_comment_likes_comment_id_idx" ON "forum_comment_likes"("comment_id");

-- CreateIndex
CREATE UNIQUE INDEX "forum_comment_likes_user_id_comment_id_key" ON "forum_comment_likes"("user_id", "comment_id");

-- AddForeignKey
ALTER TABLE "forum_topics" ADD CONSTRAINT "forum_topics_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "forum_categories"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "forum_topics" ADD CONSTRAINT "forum_topics_author_id_fkey" FOREIGN KEY ("author_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "forum_comments" ADD CONSTRAINT "forum_comments_topic_id_fkey" FOREIGN KEY ("topic_id") REFERENCES "forum_topics"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "forum_comments" ADD CONSTRAINT "forum_comments_parent_id_fkey" FOREIGN KEY ("parent_id") REFERENCES "forum_comments"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "forum_comments" ADD CONSTRAINT "forum_comments_author_id_fkey" FOREIGN KEY ("author_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "forum_comments" ADD CONSTRAINT "forum_comments_reply_to_user_id_fkey" FOREIGN KEY ("reply_to_user_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "forum_topic_likes" ADD CONSTRAINT "forum_topic_likes_topic_id_fkey" FOREIGN KEY ("topic_id") REFERENCES "forum_topics"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "forum_topic_likes" ADD CONSTRAINT "forum_topic_likes_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "forum_comment_likes" ADD CONSTRAINT "forum_comment_likes_comment_id_fkey" FOREIGN KEY ("comment_id") REFERENCES "forum_comments"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "forum_comment_likes" ADD CONSTRAINT "forum_comment_likes_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
