ALTER TABLE "users" DROP CONSTRAINT "uq_users_auth_identity";--> statement-breakpoint
ALTER TABLE "users" ADD CONSTRAINT "uq_users_auth_subject" UNIQUE("auth_subject");