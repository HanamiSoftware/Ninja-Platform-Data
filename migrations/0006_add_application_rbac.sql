-- Product-scoped application RBAC for NinjaURL.
-- Commercial capabilities and link entitlements remain unchanged.

CREATE TABLE "roles" (
  "id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
  "product_id" uuid NOT NULL,
  "code" varchar(50) NOT NULL,
  "name" varchar(100) NOT NULL,
  "description" text,
  "created_at" timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT "uq_roles_product_code" UNIQUE ("product_id", "code"),
  CONSTRAINT "uq_roles_product_id_pair" UNIQUE ("product_id", "id"),
  CONSTRAINT "roles_product_id_fkey" FOREIGN KEY ("product_id")
    REFERENCES "products" ("id") ON DELETE RESTRICT ON UPDATE NO ACTION
);
--> statement-breakpoint
CREATE INDEX "idx_roles_product" ON "roles" USING btree ("product_id");
--> statement-breakpoint
CREATE TABLE "auth_capabilities" (
  "id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
  "product_id" uuid NOT NULL,
  "code" varchar(100) NOT NULL,
  "scope" varchar(20) NOT NULL,
  "description" text NOT NULL,
  "created_at" timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT "uq_auth_capabilities_product_code" UNIQUE ("product_id", "code"),
  CONSTRAINT "uq_auth_capabilities_product_id_pair" UNIQUE ("product_id", "id"),
  CONSTRAINT "auth_capabilities_product_id_fkey" FOREIGN KEY ("product_id")
    REFERENCES "products" ("id") ON DELETE RESTRICT ON UPDATE NO ACTION,
  CONSTRAINT "chk_auth_capabilities_scope" CHECK ("scope" IN ('user', 'admin'))
);
--> statement-breakpoint
CREATE INDEX "idx_auth_capabilities_product_scope"
  ON "auth_capabilities" USING btree ("product_id", "scope");
--> statement-breakpoint
CREATE TABLE "role_capabilities" (
  "id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
  "product_id" uuid NOT NULL,
  "role_id" uuid NOT NULL,
  "capability_id" uuid NOT NULL,
  "created_at" timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT "uq_role_capabilities_role_capability" UNIQUE ("role_id", "capability_id"),
  CONSTRAINT "role_capabilities_role_product_fkey" FOREIGN KEY ("product_id", "role_id")
    REFERENCES "roles" ("product_id", "id") ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT "role_capabilities_capability_product_fkey" FOREIGN KEY ("product_id", "capability_id")
    REFERENCES "auth_capabilities" ("product_id", "id") ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT "role_capabilities_product_id_fkey" FOREIGN KEY ("product_id")
    REFERENCES "products" ("id") ON DELETE RESTRICT ON UPDATE NO ACTION
);
--> statement-breakpoint
CREATE INDEX "idx_role_capabilities_product_role"
  ON "role_capabilities" USING btree ("product_id", "role_id");
--> statement-breakpoint
CREATE TABLE "user_roles" (
  "id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
  "user_id" uuid NOT NULL,
  "product_id" uuid NOT NULL,
  "role_id" uuid NOT NULL,
  "created_at" timestamp with time zone DEFAULT now() NOT NULL,
  "updated_at" timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT "uq_user_roles_user_product" UNIQUE ("user_id", "product_id"),
  CONSTRAINT "user_roles_user_id_fkey" FOREIGN KEY ("user_id")
    REFERENCES "users" ("id") ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT "user_roles_product_id_fkey" FOREIGN KEY ("product_id")
    REFERENCES "products" ("id") ON DELETE RESTRICT ON UPDATE NO ACTION,
  CONSTRAINT "user_roles_role_product_fkey" FOREIGN KEY ("product_id", "role_id")
    REFERENCES "roles" ("product_id", "id") ON DELETE RESTRICT ON UPDATE NO ACTION
);
--> statement-breakpoint
CREATE INDEX "idx_user_roles_product_role"
  ON "user_roles" USING btree ("product_id", "role_id");
--> statement-breakpoint
-- Seed the two roles used by the initial RBAC implementation.
INSERT INTO "roles" ("product_id", "code", "name", "description")
SELECT product."id", seed."code", seed."name", seed."description"
FROM "products" AS product
CROSS JOIN (
  VALUES
    ('user', 'User', 'Standard NinjaURL user'),
    ('admin', 'Admin', 'NinjaURL administrator')
) AS seed("code", "name", "description")
WHERE product."code" = 'ninjaurl'
ON CONFLICT ("product_id", "code") DO NOTHING;
--> statement-breakpoint
-- Seed application authorization capabilities. These do not replace plan capabilities.
INSERT INTO "auth_capabilities" ("product_id", "code", "scope", "description")
SELECT product."id", seed."code", seed."scope", seed."description"
FROM "products" AS product
CROSS JOIN (
  VALUES
    ('link.create', 'user', 'Create links'),
    ('user.keys.create', 'user', 'Create registered API keys for the authenticated user'),
    ('link.read.own', 'user', 'Read links owned by the authenticated user'),
    ('link.delete.own', 'user', 'Delete links owned by the authenticated user'),
    ('admin.users.read', 'admin', 'Read user records for administration'),
    ('admin.users.update', 'admin', 'Update administrable user properties'),
    ('admin.keys.create', 'admin', 'Create registered or administrative API keys'),
    ('admin.keys.read', 'admin', 'List registered API keys'),
    ('admin.keys.revoke', 'admin', 'Revoke API keys'),
    ('admin.keys.rotate', 'admin', 'Rotate API keys'),
    ('admin.links.read', 'admin', 'Read links for administration')
) AS seed("code", "scope", "description")
WHERE product."code" = 'ninjaurl'
ON CONFLICT ("product_id", "code") DO NOTHING;
--> statement-breakpoint
-- Assign existing NIKO_A_ key owners the NinjaURL admin role before enabling role checks.
INSERT INTO "user_roles" ("user_id", "product_id", "role_id")
SELECT DISTINCT api_key."user_id", product."id", role."id"
FROM "api_keys" AS api_key
JOIN "products" AS product ON product."id" = api_key."product_id"
JOIN "roles" AS role ON role."product_id" = product."id" AND role."code" = 'admin'
WHERE product."code" = 'ninjaurl'
  AND left(api_key."key_prefix", 7) = 'NIKO_A_'
ON CONFLICT ("user_id", "product_id") DO NOTHING;
--> statement-breakpoint
-- Backfill users already associated with NinjaURL through registered keys, subscriptions or links.
-- Existing admin assignments win because this insert runs after the admin backfill.
INSERT INTO "user_roles" ("user_id", "product_id", "role_id")
SELECT DISTINCT source."user_id", product."id", role."id"
FROM "products" AS product
JOIN "roles" AS role ON role."product_id" = product."id" AND role."code" = 'user'
JOIN (
  SELECT key."user_id", key."product_id"
  FROM "api_keys" AS key
  WHERE left(key."key_prefix", 7) = 'NIKO_U_'
  UNION
  SELECT subscription."user_id", subscription."product_id"
  FROM "subscriptions" AS subscription
  UNION
  SELECT link."user_id", (SELECT "id" FROM "products" WHERE "code" = 'ninjaurl') AS product_id
  FROM "links" AS link
) AS source ON source."product_id" = product."id"
WHERE product."code" = 'ninjaurl'
ON CONFLICT ("user_id", "product_id") DO NOTHING;
--> statement-breakpoint
-- Grant the user role its initial user-scoped capabilities.
INSERT INTO "role_capabilities" ("product_id", "role_id", "capability_id")
SELECT role."product_id", role."id", capability."id"
FROM "roles" AS role
JOIN "auth_capabilities" AS capability ON capability."product_id" = role."product_id"
WHERE role."code" = 'user'
  AND capability."scope" = 'user'
  AND role."product_id" = (SELECT "id" FROM "products" WHERE "code" = 'ninjaurl')
ON CONFLICT ("role_id", "capability_id") DO NOTHING;
--> statement-breakpoint
-- Grant admin capabilities only to the NinjaURL admin role.
INSERT INTO "role_capabilities" ("product_id", "role_id", "capability_id")
SELECT role."product_id", role."id", capability."id"
FROM "roles" AS role
JOIN "auth_capabilities" AS capability ON capability."product_id" = role."product_id"
WHERE role."code" = 'admin'
  AND capability."scope" = 'admin'
  AND role."product_id" = (SELECT "id" FROM "products" WHERE "code" = 'ninjaurl')
ON CONFLICT ("role_id", "capability_id") DO NOTHING;
