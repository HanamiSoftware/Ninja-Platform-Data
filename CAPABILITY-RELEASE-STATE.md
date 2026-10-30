# Capability release state — NinjaURL

**Updated:** 2026-10-30  
**Product code:** `ninjaurl`

## Meaning of `capabilities.released`

The boolean `capabilities.released` is the product-publication switch. It is separate from `plan_capabilities.enabled`, which controls whether a given plan is entitled to a capability.

- `released = false`: do not publish the capability in the account capability response; list it in the public roadmap.
- `released = true`: the capability may appear in the account capability response, with `enabled` still computed from plan entitlement and other server-side checks.
- A released capability is not proof by itself that the feature is fully implemented, tested, or enabled for every plan. The backend must fail closed when required implementation or policy data is missing.

## Schema and migrations

- `src/schema/schema.ts`: `capabilities.released` is a non-null boolean defaulting to `false`.
- `migrations/0009_add_capability_release_state.sql`: adds the field and marks these already-shipped NinjaURL account capabilities as released:
  - `link.create`
  - `link.customSlug`
  - `link.customDomain`
  - `qr.generate`
- `migrations/0010_add_capability_release_admin_permission.sql`: registers `admin.capabilities.release` and grants it to the existing NinjaURL admin role.

## Runtime contract

- The account endpoint includes released catalog entries and calculates plan `enabled` separately.
- `GET /v1/roadmap` lists unreleased NinjaURL catalog entries.
- `GET /v1/admin/capabilities` lists the administrative catalog.
- `POST /v1/admin/capabilities/release` changes the release flag and requires the dedicated admin authorization capability.
- Publishing a feature should not require a Worker code change; it requires a deliberate admin action after implementation and testing.

## Operational cautions

1. Confirm migration history and seed values in the target database before any migration or release operation.
2. Do not treat a green CI run as proof that a database migration has been applied to a particular environment.
3. Do not expose internal-only catalog descriptions on a public roadmap without reviewing them for public suitability.
4. Keep release state, plan entitlement, resource state, and implementation readiness as distinct concepts.
5. No production migration, database write, release toggle, merge, or deployment should occur without explicit authorization.


## Integration status — 2026-10-30

- PR #14 is merged into `main` at `251152c24db20fadacf7296793968be23c45beeb`.
- Platform Data CI run [#30](https://github.com/HanamiSoftware/Ninja-Platform-Data/actions/runs/40944535614) passed: source typecheck, Drizzle generation, and generated-migration artifact verification all succeeded. The database-connectivity job was skipped by its trusted-main condition; this run does not prove that migrations were applied to any database.
- Migration files `0009_add_capability_release_state.sql` and `0010_add_capability_release_admin_permission.sql`, their snapshots, and the journal entry are present on `main`.
- The current `main` schema contains `capabilities.released`. However, the `v0.1.5` tag's `src/schema/schema.ts` does not contain that property.
- All five NinjaURL Workers (`auth-worker`, `create-worker`, `event-worker`, `redirect-worker`, and `admin-worker`) currently reference the `v0.1.5` release tarball in their package manifests. This creates a real source/package schema mismatch even though the new capability handlers currently query the release state using raw SQL.
- Before relying on the shared Drizzle schema for the new field, prepare a new package release (proposed next version: `0.1.6`), build and verify its generated declarations, publish the release artifact, then update all five Worker manifests and the workspace lockfile and rerun Workers CI. Do not republish the existing `0.1.5` tag.
- No database migration was applied or verified in this session. Migration history, initial release flags, and the admin role grant must be checked in the intended test database before staging validation.
- No package release, database write, merge, or deployment was performed by this session.
