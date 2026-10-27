import "dotenv/config";
import postgres from "postgres";

async function main(): Promise<void> {
  const databaseUrl = process.env.DATABASE_URL;

  if (!databaseUrl) {
    throw new Error("DATABASE_URL is required for the database connectivity check.");
  }

  const sql = postgres(databaseUrl, {
    ssl: "require",
    connect_timeout: 10,
    max: 1,
  });

  try {
    console.log("Connecting to the configured PostgreSQL database...");

    const version = await sql`SELECT version();`;
    console.log("PostgreSQL version:", version[0]?.version ?? "unknown");

    const database = await sql`SELECT current_database() AS database;`;
    console.log("Connected database:", database[0]?.database ?? "unknown");

    console.log("Database connectivity check passed.");
  } finally {
    await sql.end({ timeout: 5 });
  }
}

main().catch((error: unknown) => {
  const message = error instanceof Error ? error.message : "Unknown database connection error";
  console.error("Database connectivity check failed:", message);
  process.exitCode = 1;
});
