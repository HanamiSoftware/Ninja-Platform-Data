CREATE TABLE "domains" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"hostname" varchar(253) NOT NULL,
	"user_id" uuid,
	"is_default" boolean DEFAULT false NOT NULL,
	"status" varchar(20) DEFAULT 'pending' NOT NULL,
	"verification_token" varchar(255),
	"verified_at" timestamp with time zone,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "uq_domains_hostname" UNIQUE("hostname"),
	CONSTRAINT "chk_domains_status" CHECK (status IN ('pending', 'verified', 'active', 'disabled')),
	CONSTRAINT "chk_domains_owner" CHECK ((
        (is_default = true AND user_id IS NULL AND hostname = 'n2l.ink')
        OR
        (is_default = false AND user_id IS NOT NULL)
      )),
	CONSTRAINT "chk_domains_active_verified" CHECK (status <> 'active' OR verified_at IS NOT NULL)
);
INSERT INTO "domains" (
    "hostname",
    "user_id",
    "is_default",
    "status",
    "verified_at"
)
VALUES (
    'n2l.ink',
    NULL,
    TRUE,
    'active',
    now()
);
--> statement-breakpoint
--> statement-breakpoint
CREATE TABLE "link_sync_jobs" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"user_id" uuid NOT NULL,
	"anonymous_key_hash" char(64) NOT NULL,
	"status" varchar(20) DEFAULT 'pending' NOT NULL,
	"total_links" integer DEFAULT 0 NOT NULL,
	"processed_links" integer DEFAULT 0 NOT NULL,
	"checkpoint_index" integer DEFAULT 0 NOT NULL,
	"attempts" integer DEFAULT 0 NOT NULL,
	"retryable" boolean DEFAULT false NOT NULL,
	"error_code" varchar(100),
	"started_at" timestamp with time zone,
	"completed_at" timestamp with time zone,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "uq_link_sync_jobs_anonymous_key" UNIQUE("anonymous_key_hash"),
	CONSTRAINT "chk_link_sync_jobs_status" CHECK (status IN ('pending', 'in_progress', 'completed', 'failed')),
	CONSTRAINT "chk_link_sync_jobs_counts" CHECK (total_links >= 0
        AND processed_links >= 0
        AND checkpoint_index >= 0
        AND attempts >= 0),
	CONSTRAINT "chk_link_sync_jobs_processed" CHECK (processed_links <= total_links)
);
--> statement-breakpoint
ALTER TABLE "links" DROP CONSTRAINT "uq_links_slug";--> statement-breakpoint
ALTER TABLE "subscriptions" DROP CONSTRAINT "chk_subscription_status";--> statement-breakpoint
DROP INDEX "idx_auth_sessions_active";--> statement-breakpoint
DROP INDEX "idx_auth_sessions_user_id";--> statement-breakpoint
DROP INDEX "idx_subscriptions_user_product";--> statement-breakpoint
DROP INDEX "uq_active_subscription_per_product";--> statement-breakpoint
ALTER TABLE "links" ADD COLUMN "domain_id" uuid NOT NULL;--> statement-breakpoint
ALTER TABLE "domains" ADD CONSTRAINT "domains_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "link_sync_jobs" ADD CONSTRAINT "link_sync_jobs_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
CREATE INDEX "idx_domains_user_status" ON "domains" USING btree ("user_id","status");--> statement-breakpoint
CREATE UNIQUE INDEX "uq_domains_single_default" ON "domains" USING btree ("is_default") WHERE is_default = true;--> statement-breakpoint
CREATE INDEX "idx_link_sync_jobs_user_status" ON "link_sync_jobs" USING btree ("user_id","status");--> statement-breakpoint
ALTER TABLE "links" ADD CONSTRAINT "links_domain_id_fkey" FOREIGN KEY ("domain_id") REFERENCES "public"."domains"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
CREATE INDEX "idx_links_domain_id" ON "links" USING btree ("domain_id");--> statement-breakpoint
CREATE INDEX "idx_auth_sessions_active" ON "auth_sessions" USING btree ("user_id" uuid_ops,"expires_at" timestamptz_ops) WHERE revoked_at IS NULL;--> statement-breakpoint
CREATE INDEX "idx_auth_sessions_user_id" ON "auth_sessions" USING btree ("user_id");--> statement-breakpoint
CREATE INDEX "idx_subscriptions_user_product" ON "subscriptions" USING btree ("user_id","product_id");--> statement-breakpoint
CREATE UNIQUE INDEX "uq_active_subscription_per_product" ON "subscriptions" USING btree ("user_id","product_id") WHERE status IN ('trialing', 'active', 'past_due');--> statement-breakpoint
ALTER TABLE "links" ADD CONSTRAINT "uq_links_domain_slug" UNIQUE("domain_id","slug");--> statement-breakpoint
ALTER TABLE "subscriptions" ADD CONSTRAINT "chk_subscription_status" CHECK (status IN ('trialing', 'active', 'past_due', 'cancelled', 'expired'));