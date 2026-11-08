-- NinjaURL dashboard fixtures.
-- This is intentionally isolated from the production migration journal.
-- It creates three synthetic accounts (FREE, PRO, PRO+) and one owned link
-- for each account. It does not create credentials, API keys, or auth sessions.

DO $$
BEGIN
  IF current_setting('ninjaurl.allow_test_fixtures', true) IS DISTINCT FROM 'true' THEN
    RAISE EXCEPTION
      'Refusing to seed NinjaURL test fixtures. Set the connection startup option ninjaurl.allow_test_fixtures=true and use a disposable/test database.';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM products WHERE code = 'ninjaurl') THEN
    RAISE EXCEPTION 'NinjaURL product seed is missing; apply the platform migrations first.';
  END IF;

  IF (
    SELECT count(*)
    FROM plans
    WHERE product_id = (SELECT id FROM products WHERE code = 'ninjaurl')
      AND code IN ('free', 'pro', 'pro_plus')
  ) <> 3 THEN
    RAISE EXCEPTION 'NinjaURL FREE, PRO and PRO+ plans must exist before applying test fixtures.';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM domains
    WHERE hostname = 'n2l.ink' AND is_default = true AND status = 'active'
  ) THEN
    RAISE EXCEPTION 'The active default n2l.ink domain is missing.';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM roles
    WHERE product_id = (SELECT id FROM products WHERE code = 'ninjaurl')
      AND code = 'user'
  ) THEN
    RAISE EXCEPTION 'The NinjaURL user role is missing.';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM users AS existing
    JOIN (
      VALUES
        ('a1111111-1111-4111-8111-111111111101', 'ninjaurl-fixture:free'),
        ('a1111111-1111-4111-8111-111111111102', 'ninjaurl-fixture:pro'),
        ('a1111111-1111-4111-8111-111111111103', 'ninjaurl-fixture:pro-plus')
    ) AS fixture(user_id, auth_subject)
      ON existing.id = fixture.user_id::uuid
    WHERE existing.auth_provider <> 'ninjaurl-test-fixture'
       OR existing.auth_subject <> fixture.auth_subject
  ) OR EXISTS (
    SELECT 1
    FROM users AS existing
    JOIN (
      VALUES
        ('a1111111-1111-4111-8111-111111111101', 'ninjaurl-fixture:free'),
        ('a1111111-1111-4111-8111-111111111102', 'ninjaurl-fixture:pro'),
        ('a1111111-1111-4111-8111-111111111103', 'ninjaurl-fixture:pro-plus')
    ) AS fixture(user_id, auth_subject)
      ON existing.auth_subject = fixture.auth_subject
    WHERE existing.id <> fixture.user_id::uuid
       OR existing.auth_provider <> 'ninjaurl-test-fixture'
  ) THEN
    RAISE EXCEPTION 'A NinjaURL fixture identity conflicts with an existing user. No fixture rows were changed.';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM links AS existing
    JOIN (
      VALUES
        ('b1111111-1111-4111-8111-111111111101', 'a1111111-1111-4111-8111-111111111101', 'test-free', 'https://example.com/ninjaurl-fixture/free'),
        ('b1111111-1111-4111-8111-111111111102', 'a1111111-1111-4111-8111-111111111102', 'test-pro', 'https://example.com/ninjaurl-fixture/pro'),
        ('b1111111-1111-4111-8111-111111111103', 'a1111111-1111-4111-8111-111111111103', 'test-proplus', 'https://example.com/ninjaurl-fixture/pro-plus')
    ) AS fixture(link_id, user_id, slug, target)
      ON existing.id = fixture.link_id
    WHERE existing.user_id <> fixture.user_id::uuid
       OR existing.slug <> fixture.slug
       OR existing.target <> fixture.target
  ) THEN
    RAISE EXCEPTION 'A NinjaURL fixture link ID conflicts with existing link data.';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM links AS existing
    JOIN domains AS domain
      ON domain.id = existing.domain_id
     AND domain.hostname = 'n2l.ink'
     AND domain.is_default = true
    JOIN (
      VALUES
        ('b1111111-1111-4111-8111-111111111101', 'test-free'),
        ('b1111111-1111-4111-8111-111111111102', 'test-pro'),
        ('b1111111-1111-4111-8111-111111111103', 'test-proplus')
    ) AS fixture(link_id, slug)
      ON existing.slug = fixture.slug
    WHERE existing.id <> fixture.link_id
  ) THEN
    RAISE EXCEPTION 'A NinjaURL fixture slug already exists on the default domain.';
  END IF;
END
$$;
--> statement-breakpoint
INSERT INTO users (
  id,
  auth_provider,
  auth_subject,
  email,
  name
)
VALUES
  (
    'a1111111-1111-4111-8111-111111111101',
    'ninjaurl-test-fixture',
    'ninjaurl-fixture:free',
    'ninjaurl.fixture+free@example.invalid',
    'NinjaURL Fixture FREE'
  ),
  (
    'a1111111-1111-4111-8111-111111111102',
    'ninjaurl-test-fixture',
    'ninjaurl-fixture:pro',
    'ninjaurl.fixture+pro@example.invalid',
    'NinjaURL Fixture PRO'
  ),
  (
    'a1111111-1111-4111-8111-111111111103',
    'ninjaurl-test-fixture',
    'ninjaurl-fixture:pro-plus',
    'ninjaurl.fixture+pro-plus@example.invalid',
    'NinjaURL Fixture PRO+'
  )
ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO user_roles (user_id, product_id, role_id)
SELECT
  fixture.user_id,
  product.id,
  role.id
FROM users AS fixture
JOIN products AS product
  ON product.code = 'ninjaurl'
JOIN roles AS role
  ON role.product_id = product.id
 AND role.code = 'user'
WHERE fixture.auth_provider = 'ninjaurl-test-fixture'
  AND fixture.auth_subject IN (
    'ninjaurl-fixture:free',
    'ninjaurl-fixture:pro',
    'ninjaurl-fixture:pro-plus'
  )
ON CONFLICT (user_id, product_id) DO NOTHING;
--> statement-breakpoint
INSERT INTO subscriptions (
  id,
  user_id,
  product_id,
  plan_id,
  status,
  current_period_start,
  current_period_end
)
SELECT
  fixture.subscription_id::uuid,
  account.id,
  product.id,
  plan.id,
  'active',
  now(),
  now() + interval '1 year'
FROM (
  VALUES
    ('c1111111-1111-4111-8111-111111111101', 'ninjaurl-fixture:free', 'free'),
    ('c1111111-1111-4111-8111-111111111102', 'ninjaurl-fixture:pro', 'pro'),
    ('c1111111-1111-4111-8111-111111111103', 'ninjaurl-fixture:pro-plus', 'pro_plus')
) AS fixture(subscription_id, auth_subject, plan_code)
JOIN users AS account
  ON account.auth_provider = 'ninjaurl-test-fixture'
 AND account.auth_subject = fixture.auth_subject
JOIN products AS product
  ON product.code = 'ninjaurl'
JOIN plans AS plan
  ON plan.product_id = product.id
 AND plan.code = fixture.plan_code
WHERE NOT EXISTS (
  SELECT 1
  FROM subscriptions AS existing
  WHERE existing.user_id = account.id
    AND existing.product_id = product.id
    AND existing.status IN ('trialing', 'active', 'past_due')
)
ON CONFLICT (id) DO NOTHING;
--> statement-breakpoint
INSERT INTO links (
  id,
  domain_id,
  slug,
  target,
  user_id,
  created_at,
  updated_at
)
SELECT
  fixture.link_id,
  domain.id,
  fixture.slug,
  fixture.target,
  account.id,
  now(),
  now()
FROM (
  VALUES
    ('b1111111-1111-4111-8111-111111111101', 'ninjaurl-fixture:free', 'test-free', 'https://example.com/ninjaurl-fixture/free'),
    ('b1111111-1111-4111-8111-111111111102', 'ninjaurl-fixture:pro', 'test-pro', 'https://example.com/ninjaurl-fixture/pro'),
    ('b1111111-1111-4111-8111-111111111103', 'ninjaurl-fixture:pro-plus', 'test-proplus', 'https://example.com/ninjaurl-fixture/pro-plus')
) AS fixture(link_id, auth_subject, slug, target)
JOIN users AS account
  ON account.auth_provider = 'ninjaurl-test-fixture'
 AND account.auth_subject = fixture.auth_subject
JOIN domains AS domain
  ON domain.hostname = 'n2l.ink'
 AND domain.is_default = true
 AND domain.status = 'active'
ON CONFLICT (id) DO NOTHING;
