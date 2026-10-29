-- Add the missing user-owned key/link and administrative link capabilities for NinjaURL.
-- These are application-RBAC permissions, separate from commercial plan capabilities.

INSERT INTO "auth_capabilities" ("product_id", "code", "scope", "description")
SELECT product."id", seed."code", seed."scope", seed."description"
FROM "products" AS product
CROSS JOIN (
  VALUES
    ('link.update.own', 'user', 'Update links owned by the authenticated user'),
    ('user.keys.read.own', 'user', 'Read API keys owned by the authenticated user'),
    ('user.keys.revoke.own', 'user', 'Revoke API keys owned by the authenticated user'),
    ('user.keys.rotate.own', 'user', 'Rotate API keys owned by the authenticated user'),
    ('admin.links.create', 'admin', 'Create links for administration'),
    ('admin.links.update', 'admin', 'Update links for administration'),
    ('admin.links.delete', 'admin', 'Delete links for administration')
) AS seed("code", "scope", "description")
WHERE product."code" = 'ninjaurl'
ON CONFLICT ("product_id", "code") DO NOTHING;
--> statement-breakpoint
-- Keep role grants aligned with capability scope:
-- user gets all user-scoped capabilities; admin gets both user and admin capabilities.
INSERT INTO "role_capabilities" ("product_id", "role_id", "capability_id")
SELECT role."product_id", role."id", capability."id"
FROM "roles" AS role
JOIN "auth_capabilities" AS capability
  ON capability."product_id" = role."product_id"
WHERE role."code" = 'user'
  AND capability."scope" = 'user'
  AND role."product_id" = (SELECT "id" FROM "products" WHERE "code" = 'ninjaurl')
ON CONFLICT ("role_id", "capability_id") DO NOTHING;
--> statement-breakpoint
INSERT INTO "role_capabilities" ("product_id", "role_id", "capability_id")
SELECT role."product_id", role."id", capability."id"
FROM "roles" AS role
JOIN "auth_capabilities" AS capability
  ON capability."product_id" = role."product_id"
WHERE role."code" = 'admin'
  AND capability."scope" IN ('user', 'admin')
  AND role."product_id" = (SELECT "id" FROM "products" WHERE "code" = 'ninjaurl')
ON CONFLICT ("role_id", "capability_id") DO NOTHING;
