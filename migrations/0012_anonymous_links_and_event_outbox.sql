-- PostgreSQL becomes the authority for anonymous identities, links and domain events.
-- Existing registered links remain owned by their current users.

CREATE TABLE "anonymous_identities" (
  "id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
  "key_hash" char(64) NOT NULL,
  "key_prefix" varchar(16) NOT NULL,
  "type" varchar(1) DEFAULT 'R' NOT NULL,
  "plan" varchar(30) DEFAULT 'anonimo' NOT NULL,
  "rate_limit" integer NOT NULL,
  "created_at" timestamp with time zone DEFAULT now() NOT NULL,
  "last_link_created_at" timestamp with time zone NOT NULL,
  "expires_at" timestamp with time zone NOT NULL,
  "revoked_at" timestamp with time zone,
  CONSTRAINT "uq_anonymous_identities_key_hash" UNIQUE ("key_hash"),
  CONSTRAINT "chk_anonymous_identities_type" CHECK (type = 'R'),
  CONSTRAINT "chk_anonymous_identities_plan" CHECK (plan = 'anonimo'),
  CONSTRAINT "chk_anonymous_identities_rate_limit" CHECK (rate_limit > 0)
);
--> statement-breakpoint
CREATE INDEX "idx_anonymous_identities_expires_at"
  ON "anonymous_identities" USING btree ("expires_at")
  WHERE revoked_at IS NULL;
--> statement-breakpoint
ALTER TABLE "links" ALTER COLUMN "user_id" DROP NOT NULL;
--> statement-breakpoint
ALTER TABLE "links" ADD COLUMN "anonymous_identity_id" uuid;
--> statement-breakpoint
ALTER TABLE "links" ADD CONSTRAINT "links_anonymous_identity_id_fkey"
  FOREIGN KEY ("anonymous_identity_id") REFERENCES "anonymous_identities"("id")
  ON DELETE RESTRICT ON UPDATE NO ACTION;
--> statement-breakpoint
ALTER TABLE "links" ADD CONSTRAINT "chk_links_exactly_one_owner" CHECK (
  (user_id IS NOT NULL AND anonymous_identity_id IS NULL)
  OR
  (user_id IS NULL AND anonymous_identity_id IS NOT NULL)
);
--> statement-breakpoint
ALTER TABLE "links" ADD CONSTRAINT "chk_links_anonymous_expiry" CHECK (
  anonymous_identity_id IS NULL OR expires_at IS NOT NULL
);
--> statement-breakpoint
CREATE INDEX "idx_links_anonymous_identity_created_at"
  ON "links" USING btree ("anonymous_identity_id", "created_at")
  WHERE anonymous_identity_id IS NOT NULL;
--> statement-breakpoint
CREATE TABLE "event_outbox" (
  "id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
  "event_id" uuid NOT NULL,
  "event_type" varchar(100) NOT NULL,
  "event_version" integer NOT NULL,
  "aggregate_type" varchar(50) NOT NULL,
  "aggregate_id" varchar(64) NOT NULL,
  "payload" jsonb NOT NULL,
  "occurred_at" timestamp with time zone NOT NULL,
  "available_at" timestamp with time zone DEFAULT now() NOT NULL,
  "published_at" timestamp with time zone,
  "attempts" integer DEFAULT 0 NOT NULL,
  "last_error" text,
  "created_at" timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT "uq_event_outbox_event_id" UNIQUE ("event_id"),
  CONSTRAINT "chk_event_outbox_attempts" CHECK (attempts >= 0),
  CONSTRAINT "chk_event_outbox_version" CHECK (event_version > 0)
);
--> statement-breakpoint
CREATE INDEX "idx_event_outbox_pending"
  ON "event_outbox" USING btree ("available_at", "created_at")
  WHERE published_at IS NULL;
--> statement-breakpoint
CREATE INDEX "idx_event_outbox_aggregate"
  ON "event_outbox" USING btree ("aggregate_type", "aggregate_id");
