# Capability release state — NinjaURL

**Updated:** 2026-10-29  
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
