# NinjaURL test fixtures

These fixtures are deliberately kept outside the default `migrations/` journal.
They are intended for a disposable development or staging database only.

## Contents

The migration creates three synthetic NinjaURL accounts:

| Fixture | Plan | Email | Link slug |
|---|---|---|---|
| FREE | `free` | `ninjaurl.fixture+free@example.invalid` | `test-free` |
| PRO | `pro` | `ninjaurl.fixture+pro@example.invalid` | `test-pro` |
| PRO+ | `pro_plus` | `ninjaurl.fixture+pro-plus@example.invalid` | `test-proplus` |

Each account receives the NinjaURL `user` role, an active subscription for its plan,
and one link on the existing default `n2l.ink` domain.

No API keys, OAuth sessions, refresh tokens, passwords, or credentials are created.
The `auth_provider` is `ninjaurl-test-fixture`; these synthetic subjects do not match
AuthGear identities and therefore cannot sign in through the normal NinjaAuth OAuth flow.
Use real AuthGear test identities when end-to-end authentication is required.

The migration uses stable IDs and `ON CONFLICT DO NOTHING`; it does not update or delete
existing account, subscription, or link data. It also checks for identity and slug
collisions before inserting.

## Apply explicitly

The fixture migration has its own Drizzle config and migration table. It is not part
of `npm run migrate`.

Set the PostgreSQL startup option `ninjaurl.allow_test_fixtures=true` on the
`DATABASE_URL` connection used for the disposable/test database, then run:

```bash
npm run migrate:test-fixtures
```

For a URL without existing query parameters, the option can be supplied as:

```text
?options=-c%20ninjaurl.allow_test_fixtures%3Dtrue
```

If the option is absent, the migration fails closed before inserting any fixture data.


## Stato e utilizzo per la demo del 10 novembre 2026

Le fixture sono una possibile facilitazione per predisporre account FREE/PRO/PRO+ in un ambiente di test, ma **non sono un prerequisito per la demo** e non sono state validate su PostgreSQL nella documentazione di continuità dell'8 novembre.

Prima di qualsiasi applicazione:

1. Confrontare il SQL con schema effettivo, colonne, constraint, enum e journal Drizzle.
2. Eseguire la migrazione esclusivamente su un database disposable dedicato a test.
3. Verificare gli inserimenti con query di controllo e controllare che le foreign key usino `users.id`.
4. Per il login OAuth end-to-end, associare manualmente identità AuthGear di test ai record fixture soltanto dopo aver verificato formato di `auth_provider` e `auth_subject` e le collisioni. Non inserire subject reali in repository o documenti versionati.

La migrazione non crea credenziali né sessioni e non rende gli account sintetici autenticabili. Non puntare mai la fixture migration a database condivisi o di produzione. Nessuna migrazione è stata eseguita come parte della preparazione del piano demo.
