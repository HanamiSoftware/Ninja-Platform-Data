-- Correct the composite subscription-to-plan foreign key column order.
-- The original constraint referenced plans(id, product_id) instead of plans(product_id, id).
ALTER TABLE "subscriptions"
  DROP CONSTRAINT IF EXISTS "fk_subscription_plan_product";
--> statement-breakpoint
ALTER TABLE "subscriptions"
  ADD CONSTRAINT "fk_subscription_plan_product"
  FOREIGN KEY ("product_id", "plan_id")
  REFERENCES "plans" ("product_id", "id")
  ON DELETE RESTRICT
  ON UPDATE NO ACTION;
--> statement-breakpoint
-- Do not persist analytics as enabled until the corresponding endpoints ship.
UPDATE "plan_capabilities" AS pc
SET "enabled" = false,
    "updated_at" = now()
FROM "capabilities" AS c
JOIN "products" AS p ON p.id = c.product_id
WHERE pc.capability_id = c.id
  AND pc.product_id = p.id
  AND p.code = 'ninjaurl'
  AND c.code IN ('analytics.basic', 'analytics.history');
