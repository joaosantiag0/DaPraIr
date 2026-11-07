-- CreateTable
CREATE TABLE "gamification_levels" (
    "id" VARCHAR(50) NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "min_points" INTEGER NOT NULL,
    "level_order" INTEGER NOT NULL,
    "badge_icon_url" VARCHAR(512),
    "description" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "gamification_levels_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_gamification_profiles" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "points_total" INTEGER NOT NULL DEFAULT 0,
    "points_current" INTEGER NOT NULL DEFAULT 0,
    "current_level_id" VARCHAR(50) NOT NULL DEFAULT 'EXPLORER',
    "is_ranking_visible" BOOLEAN NOT NULL DEFAULT true,
    "use_anonymous_nickname" BOOLEAN NOT NULL DEFAULT false,
    "custom_nickname" VARCHAR(50),
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "user_gamification_profiles_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "gamification_transactions" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "action_type" VARCHAR(50) NOT NULL,
    "points" INTEGER NOT NULL,
    "source_id" UUID,
    "source_type" VARCHAR(50),
    "description" VARCHAR(255) NOT NULL,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "gamification_transactions_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "gamification_levels_min_points_key" ON "gamification_levels"("min_points");

-- CreateIndex
CREATE UNIQUE INDEX "gamification_levels_level_order_key" ON "gamification_levels"("level_order");

-- CreateIndex
CREATE UNIQUE INDEX "user_gamification_profiles_user_id_key" ON "user_gamification_profiles"("user_id");

-- CreateIndex
CREATE INDEX "user_gamification_profiles_is_ranking_visible_points_total_idx" ON "user_gamification_profiles"("is_ranking_visible", "points_total" DESC);

-- CreateIndex
CREATE UNIQUE INDEX "gamification_transactions_user_id_action_type_source_id_key" ON "gamification_transactions"("user_id", "action_type", "source_id");

-- CreateIndex
CREATE INDEX "gamification_transactions_user_id_created_at_idx" ON "gamification_transactions"("user_id", "created_at" DESC);

-- CreateIndex
CREATE INDEX "gamification_transactions_created_at_points_idx" ON "gamification_transactions"("created_at", "points");

-- AddForeignKey
ALTER TABLE "user_gamification_profiles" ADD CONSTRAINT "user_gamification_profiles_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_gamification_profiles" ADD CONSTRAINT "user_gamification_profiles_current_level_id_fkey" FOREIGN KEY ("current_level_id") REFERENCES "gamification_levels"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "gamification_transactions" ADD CONSTRAINT "gamification_transactions_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
