-- Add an explicit capability for assigning the NinjaURL admin role to an existing user.
-- This is an application-RBAC permission, separate from commercial capabilities.

INSERT INTO "auth_capabilities" ("product_id", "code", "scope", "description")
SELECT product."id", 'admin.users.roles.assign', 'admin',
       'Assign the NinjaURL admin role to an existing user'
FROM "products" AS product
WHERE product."code" = 'ninjaurl'
ON CONFLICT ("product_id", "code") DO NOTHING;
--> statement-breakpoint
-- The default admin role receives this capability explicitly. Deployments may
-- remove this grant from the role if role assignment should be restricted further.
INSERT INTO "role_capabilities" ("product_id", "role_id", "capability_id")
SELECT role."product_id", role."id", capability."id"
FROM "roles" AS role
JOIN "auth_capabilities" AS capability
  ON capability."product_id" = role."product_id"
 AND capability."code" = 'admin.users.roles.assign'
WHERE role."code" = 'admin'
  AND role."product_id" = (SELECT "id" FROM "products" WHERE "code" = 'ninjaurl')
ON CONFLICT ("role_id", "capability_id") DO NOTHING;
