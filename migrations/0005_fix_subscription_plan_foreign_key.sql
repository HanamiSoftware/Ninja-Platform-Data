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
