# Capability release state — NinjaURL

**Updated:** 2026-11-04  
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


## Integration status — 2026-11-04

- PR #14 is merged into `main` at `251152c24db20fadacf7296793968be23c45beeb`.
- The current `main` source and the `v0.1.6` tag both declare `@hanami/platform-data` version `0.1.6`.
- The `v0.1.6` tagged schema contains `capabilities.released` as a non-null boolean with default `false`.
- All five NinjaURL Workers (`auth-worker`, `create-worker`, `event-worker`, `redirect-worker`, and `admin-worker`) and `Workers/package-lock.json` reference the GitHub release tarball URL for `v0.1.6`. The previous source/package mismatch documented for `v0.1.5` is resolved in the repository references.
- The release asset itself was not downloaded or independently verified in this audit. No CI result tied specifically to the `v0.1.6` tag was verified.
- Migration files `0009_add_capability_release_state.sql` and `0010_add_capability_release_admin_permission.sql`, their snapshots, and the journal entries are present on `main`.
- Platform Data CI run [#30](https://github.com/HanamiSoftware/Ninja-Platform-Data/actions/runs/40944535614) passed source typecheck, Drizzle generation, and generated-migration artifact verification for the earlier merged PR. Its database-connectivity job was skipped; it does not prove that migrations were applied to any database.
- Migration history, initial release flags, and the `admin.capabilities.release` grant in the intended test database remain unverified.
- No database migration, release toggle, merge, or deployment was performed by this audit.

## Next verification steps

1. Verify that the `v0.1.6` release asset URL is downloadable and that its generated declarations include the `released` field.
2. Run or inspect Workers CI for a commit that consumes the `v0.1.6` tarball across all five Workers.
3. Check the migration journal and seed values in the intended test database; do not apply migrations or toggle release state without explicit authorization.
4. Validate account capabilities, public roadmap, and admin release endpoints end-to-end against that database and the deployed Worker configuration.
