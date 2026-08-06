import "dotenv/config";
import postgres from "postgres";

async function main() {
    const sql = postgres(process.env.DATABASE_URL!, {
        ssl: "require",
    });

    console.log("🚀 Connecting to Neon...");

    const version = await sql`SELECT version();`;
    console.log(version[0]);

    const databases = await sql`
        SELECT current_database() AS database;
    `;

    console.log(databases[0]);

    const tables = await sql`
        SELECT table_name
        FROM information_schema.tables
        WHERE table_schema = 'public'
        ORDER BY table_name;
    `;

    console.log("\nTables:");

    console.table(tables);

    await sql.end();

    console.log("\n✅ Everything works!");
}

main().catch(console.error);
