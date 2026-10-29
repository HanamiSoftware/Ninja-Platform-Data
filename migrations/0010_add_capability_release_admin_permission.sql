-- Grant the existing admin role permission to publish/unpublish catalog features.
INSERT INTO "auth_capabilities" ("product_id", "code", "scope", "description")
SELECT product."id", 'admin.capabilities.release', 'admin',
       'Publish or unpublish product capabilities'
FROM "products" AS product
WHERE product."code" = 'ninjaurl'
ON CONFLICT ("product_id", "code") DO NOTHING;
--> statement-breakpoint
INSERT INTO "role_capabilities" ("product_id", "role_id", "capability_id")
SELECT role."product_id", role."id", capability."id"
FROM "roles" AS role
JOIN "products" AS product
  ON product."id" = role."product_id"
JOIN "auth_capabilities" AS capability
  ON capability."product_id" = product."id"
 AND capability."code" = 'admin.capabilities.release'
 AND capability."scope" = 'admin'
WHERE product."code" = 'ninjaurl'
  AND role."code" = 'admin'
ON CONFLICT ("role_id", "capability_id") DO NOTHING;
