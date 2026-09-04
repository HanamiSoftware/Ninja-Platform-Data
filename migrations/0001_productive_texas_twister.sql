ALTER TABLE "users" DROP CONSTRAINT "uq_users_auth_identity";--> statement-breakpoint
DROP INDEX "idx_auth_sessions_active";--> statement-breakpoint
CREATE INDEX "idx_auth_sessions_active" ON "auth_sessions" USING btree ("user_id" uuid_ops,"expires_at" timestamptz_ops) WHERE (revoked_at IS NULL);--> statement-breakpoint
ALTER TABLE "users" ADD CONSTRAINT "uq_users_auth_identity" UNIQUE("auth_subject");