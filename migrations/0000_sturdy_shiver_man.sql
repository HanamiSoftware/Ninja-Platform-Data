CREATE TABLE "identity_users" (
	"id" uuid PRIMARY KEY NOT NULL,
	"authgear_user_id" varchar(128) NOT NULL,
	"email" varchar(255) NOT NULL,
	"username" varchar(50),
	"display_name" varchar(120),
	"avatar_url" varchar(500),
	"locale" varchar(10) DEFAULT 'it',
	"timezone" varchar(50) DEFAULT 'Europe/Rome',
	"onboarding_completed" boolean DEFAULT false NOT NULL,
	"metadata" jsonb DEFAULT '{}'::jsonb,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	"deleted_at" timestamp with time zone
);
--> statement-breakpoint
CREATE UNIQUE INDEX "ux_identity_users_authgear" ON "identity_users" USING btree ("authgear_user_id");--> statement-breakpoint
CREATE UNIQUE INDEX "ux_identity_users_email" ON "identity_users" USING btree ("email");--> statement-breakpoint
CREATE UNIQUE INDEX "ux_identity_users_username" ON "identity_users" USING btree ("username");--> statement-breakpoint
CREATE INDEX "ix_identity_users_created" ON "identity_users" USING btree ("created_at");