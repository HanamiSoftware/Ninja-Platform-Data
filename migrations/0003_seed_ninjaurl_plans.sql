-- Idempotent seed for NinjaURL's canonical product and plan codes.
-- This file only defines the migration; it must be applied to a database
-- only after the target environment has been explicitly verified.

INSERT INTO "products" ("code", "name")
VALUES ('ninjaurl', 'NinjaURL')
ON CONFLICT ("code") DO UPDATE
SET "name" = EXCLUDED."name";
--> statement-breakpoint
INSERT INTO "plans" ("product_id", "code", "name")
SELECT product.id, seed.code, seed.name
FROM "products" AS product
CROSS JOIN (
    VALUES
        ('free', 'Free'),
        ('pro', 'Pro'),
        ('pro_plus', 'Pro+')
) AS seed(code, name)
WHERE product.code = 'ninjaurl'
ON CONFLICT ("product_id", "code") DO UPDATE
SET "name" = EXCLUDED."name";
