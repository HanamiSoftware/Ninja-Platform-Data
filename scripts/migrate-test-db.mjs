import "dotenv/config";

import { createHash } from "node:crypto";
import { readFile } from "node:fs/promises";
import { spawnSync } from "node:child_process";
import postgres from "postgres";

const expectedDatabase = process.env.EXPECTED_TEST_DATABASE;
if (process.env.ALLOW_TEST_DB_MIGRATION !== "YES" || !expectedDatabase) {
    throw new Error(
        "Safety check: set ALLOW_TEST_DB_MIGRATION=YES and EXPECTED_TEST_DATABASE to the exact test database name.",
    );
}

if (!process.env.DATABASE_URL) {
    throw new Error("DATABASE_URL is missing. Configure it for the test database first.");
}

const sql = postgres(process.env.DATABASE_URL, { ssl: "require", max: 1 });
let shouldRunMigrations = false;

try {
    const [connection] = await sql`
        SELECT current_database() AS database, current_user AS role
    `;

    console.log(`Database target: ${connection.database} (role: ${connection.role})`);

    if (connection.database !== expectedDatabase) {
        throw new Error(
            `Refusing to migrate: expected database "${expectedDatabase}", connected to "${connection.database}".`,
        );
    }

    const tableRows = await sql`
        SELECT table_name
        FROM information_schema.tables
        WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
    `;
    const tables = new Set(tableRows.map((row) => row.table_name));
    const requiredTables = [
        "api_keys",
        "auth_sessions",
        "links",
        "plans",
        "products",
        "subscriptions",
        "users",
    ];
    const missingTables = requiredTables.filter((table) => !tables.has(table));

    if (missingTables.length > 0) {
        throw new Error(`Refusing to baseline unexpected schema. Missing tables: ${missingTables.join(", ")}.`);
    }

    if (tables.has("domains") || tables.has("link_sync_jobs")) {
        throw new Error(
            "The database already contains domain migration tables. Inspect its migration history instead of baselining it.",
        );
    }

    const linkColumns = await sql`
        SELECT column_name
        FROM information_schema.columns
        WHERE table_schema = 'public' AND table_name = 'links'
    `;
    if (linkColumns.some((row) => row.column_name === "domain_id")) {
        throw new Error("links.domain_id already exists. Refusing to baseline a partially migrated schema.");
    }

    const [{ count: linkCount }] = await sql`SELECT COUNT(*)::int AS count FROM public.links`;
    if (Number(linkCount) !== 0) {
        throw new Error(`Expected an empty test links table, found ${linkCount} rows. No migration was run.`);
    }

    const [defaultProduct] = await sql`
        SELECT id FROM public.products WHERE code = 'ninjaurl' LIMIT 1
    `;
    if (!defaultProduct) {
        throw new Error("Expected the existing ninjaurl product seed before baselining migration 0000.");
    }

    const linkConstraints = await sql`
        SELECT conname
        FROM pg_constraint
        WHERE conrelid = 'public.links'::regclass
    `;
    if (!linkConstraints.some((row) => row.conname === "uq_links_slug")) {
        throw new Error("Expected baseline constraint uq_links_slug was not found on public.links.");
    }

    const migrationPath = "migrations/0000_bored_goblin_queen.sql";
    const journalPath = "migrations/meta/_journal.json";
    const migrationSql = await readFile(migrationPath, "utf8");
    const journal = JSON.parse(await readFile(journalPath, "utf8"));
    const baseline = journal.entries?.[0];

    if (!baseline || baseline.tag !== "0000_bored_goblin_queen") {
        throw new Error("Could not identify the expected baseline migration in the Drizzle journal.");
    }

    const baselineHash = createHash("sha256").update(migrationSql).digest("hex");
    const [tracker] = await sql`
        SELECT to_regclass('drizzle.__drizzle_migrations') AS tracker
    `;

    if (tracker.tracker) {
        const rows = await sql`
            SELECT hash, created_at
            FROM drizzle.__drizzle_migrations
            ORDER BY created_at
        `;

        if (rows.length > 1 || (rows.length === 1 && Number(rows[0].created_at) !== baseline.when)) {
            throw new Error(
                "Drizzle already has migration history that does not match the expected pre-0001 test schema. No changes made.",
            );
        }

        if (rows.length === 1 && Number(rows[0].created_at) === baseline.when) {
            console.log("Baseline migration 0000 is already recorded; resuming pending migrations.");
        } else {
            await sql`
                INSERT INTO drizzle.__drizzle_migrations (hash, created_at)
                VALUES (${baselineHash}, ${baseline.when})
            `;
            console.log("Recorded existing base schema as migration 0000.");
        }
    } else {
        await sql`CREATE SCHEMA IF NOT EXISTS drizzle`;
        await sql`
            CREATE TABLE drizzle.__drizzle_migrations (
                id SERIAL PRIMARY KEY,
                hash text NOT NULL,
                created_at bigint
            )
        `;
        await sql`
            INSERT INTO drizzle.__drizzle_migrations (hash, created_at)
            VALUES (${baselineHash}, ${baseline.when})
        `;
        console.log("Created Drizzle migration tracking and recorded existing base schema as migration 0000.");
    }

    shouldRunMigrations = true;
} finally {
    await sql.end();
}

if (shouldRunMigrations) {
    console.log("Applying migrations 0001 and later...");
    const command = process.platform === "win32" ? "npm.cmd" : "npm";
    const result = spawnSync(command, ["run", "migrate"], {
        stdio: "inherit",
        env: process.env,
        shell: process.platform === "win32",
    });

    if (result.error) throw result.error;
    if (result.status !== 0) {
        process.exitCode = result.status ?? 1;
    }
}
