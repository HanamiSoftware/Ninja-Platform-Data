# Ninja Platform Data

Shared PostgreSQL schema, relations and data-access primitives used by the Ninja ecosystem.

**Package:** `@hanami-software/platform-data`  
**Version recorded in this branch:** `0.1.7`  
**Package metadata:** `private: true`  
**Repository:** [HanamiSoftware/Ninja-Platform-Data](https://github.com/HanamiSoftware/Ninja-Platform-Data)

## Ownership

This repository owns:
- shared database schema definitions;
- Drizzle relations and database construction;
- application migration files;
- explicitly separate test-fixture migrations and test data tooling.

It does not own application-specific Worker routes, UI behavior, identity-broker behavior or deployment configuration in consuming repositories.

## Package contents

The current `package.json` declares these package files:
- `dist`
- `migrations`
- `README.md`

The README is included in the package allowlist. Keep it present and verify the generated tarball before distributing a new versioned package artifact.

## Development

Requirements: Node.js and npm.

```bash
npm install
npm run typecheck
npm run build
npm run generate
```

Useful scripts:

| Script | Purpose |
|---|---|
| `build` | Compile TypeScript into `dist` |
| `typecheck` | Type-check without emitting |
| `generate` | Generate Drizzle migrations from schema changes |
| `migrate` | Apply the normal migration sequence |
| `migrate:test-fixtures` | Apply the separate test-fixture migration sequence |
| `lint` | Run ESLint |
| `studio` | Open Drizzle Studio |

Database configuration is read from `DATABASE_URL` via environment configuration. Never commit a connection string, password, token or populated local environment file.

## Migration separation

- Normal application migrations are generated under `migrations/` by `drizzle.config.ts`.
- Test-fixture migrations are generated under `test-fixtures/migrations/` by `drizzle.test.config.ts`.
- The test config uses a separate migration table, `__drizzle_test_fixtures_migrations`, so fixture setup is not silently mixed into the normal application migration sequence.

Do not run migrations against a shared or production database unless the target, migration plan, backup/rollback strategy and authorization are explicit. Prefer disposable test databases for fixtures and destructive test setup.

## Security and local configuration

- Store database credentials in the approved secret manager or local environment configuration, never in tracked files.
- Confirm the exact file is ignored by Git; do not assume that ignoring `.env` ignores arbitrary text files containing connection strings.
- Before committing, inspect `git status --short` and the staged diff.
- If a credential is exposed, rotate it at the provider first, then update the consuming repository/environment secrets and verify all consumers.
- Removing a credential file from the latest commit does not remove it from Git history. Any history rewrite requires a coordinated plan and explicit approval.

The current `.gitignore` should be reviewed for the specific local test-credential filename; see [Project Status](docs/PROJECT-STATUS.md).

## Consuming repositories

- [NinjaURL Workers](https://github.com/HanamiSoftware/NinjaURL-URL-Shortener)
- [NinjaAuth SDK](https://github.com/HanamiSoftware/NinjaAuth-SDK)
- [NinjaURL Dashboard](https://github.com/HanamiSoftware/Ninja-URL-Dashboard)
- [NinjaURL Extension](https://github.com/HanamiSoftware/NinjaUrl-Extension)

Consumers must pin the intended versioned package artifact and update lockfiles intentionally. Do not assume that a local schema change is already present in a deployed Worker or database.
