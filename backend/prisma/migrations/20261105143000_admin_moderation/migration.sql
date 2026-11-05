-- AlterTable
ALTER TABLE "users" ADD COLUMN "session_invalidated_at" TIMESTAMPTZ;

-- CreateTable
CREATE TABLE "user_penalties" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "moderator_id" UUID NOT NULL,
    "penalty_type" VARCHAR(30) NOT NULL,
    "reason" TEXT NOT NULL,
    "starts_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "ends_at" TIMESTAMPTZ,
    "status" VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    "revoked_by" UUID,
    "revocation_reason" TEXT,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "user_penalties_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "moderation_actions" (
    "id" UUID NOT NULL,
    "moderator_id" UUID NOT NULL,
    "action_type" VARCHAR(40) NOT NULL,
    "target_type" VARCHAR(30) NOT NULL,
    "target_id" UUID NOT NULL,
    "reason" TEXT NOT NULL,
    "metadata" JSONB,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "moderation_actions_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "user_penalties_user_id_status_idx" ON "user_penalties"("user_id", "status");
CREATE INDEX "user_penalties_status_ends_at_idx" ON "user_penalties"("status", "ends_at");

-- CreateIndex
CREATE INDEX "moderation_actions_target_type_target_id_idx" ON "moderation_actions"("target_type", "target_id");
CREATE INDEX "moderation_actions_moderator_id_created_at_idx" ON "moderation_actions"("moderator_id", "created_at" DESC);
CREATE INDEX "moderation_actions_action_type_created_at_idx" ON "moderation_actions"("action_type", "created_at" DESC);

-- AddForeignKey
ALTER TABLE "user_penalties" ADD CONSTRAINT "user_penalties_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "user_penalties" ADD CONSTRAINT "user_penalties_moderator_id_fkey" FOREIGN KEY ("moderator_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "user_penalties" ADD CONSTRAINT "user_penalties_revoked_by_fkey" FOREIGN KEY ("revoked_by") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "moderation_actions" ADD CONSTRAINT "moderation_actions_moderator_id_fkey" FOREIGN KEY ("moderator_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
