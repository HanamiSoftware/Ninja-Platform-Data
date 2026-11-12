# Ninja Platform Data — Project Status

**Reviewed:** 12 November 2026  
**Repository:** `HanamiSoftware/Ninja-Platform-Data`  
**Branch:** `docs/alignment-2026-11-12` (created from `main`)  
**Package version in package.json:** `0.1.7`

## 1. Repository responsibility

This repository owns the shared PostgreSQL schema, Drizzle relations, database construction and migration artifacts consumed by Ninja ecosystem services.

It does not own application API behavior, browser UI, authentication SDK behavior or the identity broker.

## 2. Current source snapshot

| Item | Observed state |
|---|---|
| Package | `@hanami-software/platform-data` |
| Version | `0.1.7` |
| Module format | ESM |
| Build output | `dist/index.js`, declarations in `dist/index.d.ts` |
| Package file allowlist | `dist`, `migrations`, `README.md` |
| Database connection | `DATABASE_URL` from environment configuration |
| Normal migration output | `migrations/` |
| Test-fixture migration output | `test-fixtures/migrations/` |
| Fixture migration table | `__drizzle_test_fixtures_migrations` |

The package metadata includes `README.md` in its file allowlist. This branch adds the missing root README so the package metadata and repository contents agree.

## 3. Migration and test-fixture boundaries

- `drizzle.config.ts` generates the normal migration sequence in `migrations/`.
- `drizzle.test.config.ts` uses a separate output directory and migration table for test fixtures.
- Fixture migrations must not be mixed into the normal application migration sequence.
- Prefer disposable test databases for fixture setup and migration validation.
- Never run test-fixture migrations against production or a shared database.

The presence of a migration file is not proof that it has been applied to a target database. Record target environment, commit, migration identifiers and result when validating migration state.

## 4. Credential exposure follow-up

A test database connection string was committed in an earlier Git revision and the file was later removed from the current main branch. The file's removal does not erase historical Git objects.

Francesco reports that Neon suspended the affected test databases pending password rotation. At the time of this review, the new password had not yet been set.

Required closure steps are tracked in the NinjaURL [Project Control Room](https://github.com/HanamiSoftware/NinjaURL-URL-Shortener/blob/dev/docs/PROJECT-CONTROL-ROOM.md):
1. Rotate the test database password in Neon.
2. Update the shared repository/environment secret consumed by the Workers.
3. Verify every intended consumer.
4. Confirm the local credential file is ignored and absent from future commits.
5. Consider Git history cleanup only as a separate coordinated operation with explicit approval.

No credential value is reproduced here.

### .gitignore finding

The current `.gitignore` ignores `.env`, but does not contain a rule for the specific local file name `staging database.txt`. This is a preventive configuration gap.

**Pending decision:** add a narrowly scoped ignore rule for that exact local filename and verify it with `git check-ignore`. This documentation branch does not modify `.gitignore`.

## 5. Dependency and release discipline

- Consuming Workers must use an explicit published package version.
- Review the package tarball contents after build; do not infer package correctness from source files alone.
- Review Drizzle Kit compatibility before changing its major/minor version or migration tooling.
- Update package metadata, lockfiles and migration documentation together.
- No database migration, package publish, merge or deployment is included in this documentation task.

## 6. Current documentation task

This branch adds:
- a root README describing package purpose, scripts, migration separation and security rules;
- this status document recording the package snapshot and outstanding credential hygiene.

No schema, migration, runtime source or database was changed.
