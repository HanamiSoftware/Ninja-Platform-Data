CREATE TABLE "capabilities" (
  "id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
  "product_id" uuid NOT NULL,
  "code" varchar(100) NOT NULL,
  "scope" varchar(30) NOT NULL,
  "description" text NOT NULL,
  "created_at" timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT "uq_capabilities_product_code" UNIQUE ("product_id", "code"),
  CONSTRAINT "uq_capabilities_product_id_pair" UNIQUE ("product_id", "id"),
  CONSTRAINT "capabilities_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "products"("id") ON DELETE RESTRICT ON UPDATE NO ACTION,
  CONSTRAINT "chk_capabilities_scope" CHECK ("scope" IN ('account', 'link_entitlement'))
);
--> statement-breakpoint
CREATE TABLE "plan_capabilities" (
  "id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
  "product_id" uuid NOT NULL,
  "plan_id" uuid NOT NULL,
  "capability_id" uuid NOT NULL,
  "enabled" boolean DEFAULT false NOT NULL,
  "limits" jsonb DEFAULT '{}'::jsonb NOT NULL,
  "created_at" timestamp with time zone DEFAULT now() NOT NULL,
  "updated_at" timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT "uq_plan_capabilities_plan_capability" UNIQUE ("plan_id", "capability_id"),
  CONSTRAINT "plan_capabilities_plan_product_fkey" FOREIGN KEY ("product_id", "plan_id") REFERENCES "plans"("product_id", "id") ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT "plan_capabilities_capability_product_fkey" FOREIGN KEY ("product_id", "capability_id") REFERENCES "capabilities"("product_id", "id") ON DELETE CASCADE ON UPDATE NO ACTION
);
--> statement-breakpoint
CREATE INDEX "idx_plan_capabilities_product" ON "plan_capabilities" USING btree ("product_id");
--> statement-breakpoint
CREATE TABLE "link_entitlements" (
  "id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
  "link_id" varchar(64) NOT NULL,
  "capability_id" uuid NOT NULL,
  "source_type" varchar(30) NOT NULL,
  "source_ref" varchar(255),
  "granted_at" timestamp with time zone DEFAULT now() NOT NULL,
  "expires_at" timestamp with time zone,
  "revoked_at" timestamp with time zone,
  CONSTRAINT "link_entitlements_link_id_fkey" FOREIGN KEY ("link_id") REFERENCES "links"("id") ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT "link_entitlements_capability_id_fkey" FOREIGN KEY ("capability_id") REFERENCES "capabilities"("id") ON DELETE RESTRICT ON UPDATE NO ACTION,
  CONSTRAINT "chk_link_entitlements_source_type" CHECK ("source_type" IN ('shuriken', 'admin_grant'))
);
--> statement-breakpoint
CREATE INDEX "idx_capabilities_product_scope" ON "capabilities" USING btree ("product_id", "scope");
--> statement-breakpoint
CREATE INDEX "idx_link_entitlements_link" ON "link_entitlements" USING btree ("link_id");
--> statement-breakpoint
CREATE UNIQUE INDEX "uq_active_link_entitlement" ON "link_entitlements" USING btree ("link_id", "capability_id") WHERE revoked_at IS NULL;
--> statement-breakpoint
INSERT INTO "capabilities" ("product_id", "code", "scope", "description")
SELECT product.id, seed.code, seed.scope, seed.description
FROM "products" AS product
CROSS JOIN (
  VALUES
    ('link.create', 'account', 'Create NinjaLinks'),
    ('link.customSlug', 'account', 'Choose a custom NinjaLink slug'),
    ('link.customDomain', 'account', 'Use account-owned custom domains'),
    ('link.smart', 'account', 'Use smart link behavior'),
    ('link.password', 'account', 'Protect a NinjaLink with a password'),
    ('link.expiring', 'account', 'Set a NinjaLink expiry'),
    ('link.oneTime', 'account', 'Use single-use NinjaLinks'),
    ('analytics.basic', 'account', 'View basic click analytics'),
    ('analytics.history', 'account', 'Access analytics history'),
    ('analytics.advanced', 'account', 'View advanced analytics breakdowns'),
    ('intelligence.metadata', 'account', 'Read destination metadata'),
    ('intelligence.screenshot', 'account', 'View destination screenshots'),
    ('intelligence.security', 'account', 'Use destination security intelligence'),
    ('intelligence.ai', 'account', 'Use AI-powered link intelligence'),
    ('qr.generate', 'account', 'Generate standard QR codes'),
    ('link.qr.customize', 'link_entitlement', 'Customize a QR code for an individual NinjaLink'),
    ('link.deeplink', 'link_entitlement', 'Unlock deep-link behavior for an individual NinjaLink')
) AS seed(code, scope, description)
WHERE product.code = 'ninjaurl'
ON CONFLICT ("product_id", "code") DO UPDATE
SET "scope" = EXCLUDED."scope",
    "description" = EXCLUDED."description";
--> statement-breakpoint
INSERT INTO "plan_capabilities" ("product_id", "plan_id", "capability_id", "enabled", "limits")
SELECT
  product.id,
  plan.id,
  capability.id,
  CASE
    WHEN capability.code IN ('link.create', 'link.customSlug', 'analytics.basic', 'analytics.history', 'qr.generate') THEN true
    WHEN capability.code = 'link.customDomain' THEN plan.code IN ('pro', 'pro_plus')
    ELSE false
  END,
  CASE
    WHEN capability.code = 'analytics.history' AND plan.code = 'free'
      THEN '{"window":{"unit":"day","value":3}}'::jsonb
    WHEN capability.code = 'analytics.history' AND plan.code IN ('pro', 'pro_plus')
      THEN '{"window":{"unit":"all"}}'::jsonb
    ELSE '{}'::jsonb
  END
FROM "products" AS product
JOIN "plans" AS plan ON plan.product_id = product.id
JOIN "capabilities" AS capability ON capability.product_id = product.id
WHERE product.code = 'ninjaurl'
  AND plan.code IN ('free', 'pro', 'pro_plus')
  AND capability.scope = 'account'
ON CONFLICT ("plan_id", "capability_id") DO UPDATE
SET "enabled" = EXCLUDED."enabled",
    "limits" = EXCLUDED."limits",
    "updated_at" = now();
