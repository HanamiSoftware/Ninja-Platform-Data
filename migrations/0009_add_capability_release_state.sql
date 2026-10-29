ALTER TABLE "capabilities"
  ADD COLUMN "released" boolean DEFAULT false NOT NULL;
--> statement-breakpoint
-- Keep the MVP's already-shipped account features available. All other
-- catalog entries remain unreleased until explicitly enabled by an admin.
UPDATE "capabilities" AS capability
SET "released" = true
FROM "products" AS product
WHERE product.id = capability.product_id
  AND product.code = 'ninjaurl'
  AND capability.code IN (
    'link.create',
    'link.customSlug',
    'link.customDomain',
    'qr.generate'
  );
