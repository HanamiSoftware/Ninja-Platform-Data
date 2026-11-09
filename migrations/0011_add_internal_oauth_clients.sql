-- Internal first-party OAuth client registry for Ninja Connect.
-- One row per exact redirect URI; multiple callbacks may be registered per client.
-- client_id is public and browser clients must use Authorization Code + PKCE.

CREATE TABLE "oauth_clients_internal" (
  "id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
  "client_id" varchar(255) NOT NULL,
  "redirect_uri" text NOT NULL,
  "is_active" boolean DEFAULT true NOT NULL,
  "created_at" timestamp with time zone DEFAULT now() NOT NULL,
  "updated_at" timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT "uq_oauth_clients_internal_client_redirect"
    UNIQUE ("client_id", "redirect_uri"),
  CONSTRAINT "chk_oauth_clients_internal_client_id_nonempty"
    CHECK (length(btrim("client_id")) > 0),
  CONSTRAINT "chk_oauth_clients_internal_redirect_uri_nonempty"
    CHECK (length(btrim("redirect_uri")) > 0)
);
--> statement-breakpoint
CREATE INDEX "idx_oauth_clients_internal_client_id"
  ON "oauth_clients_internal" USING btree ("client_id");
