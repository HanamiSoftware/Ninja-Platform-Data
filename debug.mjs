/*
 * --------------------------------------------------------------------------
 *
 * Author:      Francesco
 *
 * website: https://www.hanamisoftware.com
 * License:     MIT
 * Copyright (c) 2026 Hanami Software
 * --------------------------------------------------------------------------
 */




import "dotenv/config";
import postgres from "postgres";
import { drizzle } from "drizzle-orm/postgres-js";
import { migrate } from "drizzle-orm/postgres-js/migrator";

const connectionString = process.env.DATABASE_URL;

if (!connectionString) {
  throw new Error("DATABASE_URL non è definita");
}

const sql = postgres(connectionString, {
  max: 1,
  connect_timeout: 10,
});

try {
  const db = drizzle(sql);

  console.log("Avvio migrazione diagnostica...");

  await migrate(db, {
    migrationsFolder: "./migrations",
  });

  console.log("Migrazione completata.");
} catch (error) {
  console.error("MIGRAZIONE FALLITA:");
  console.error(error);
  console.error("Causa:", error?.cause);
  process.exitCode = 1;
} finally {
  await sql.end({ timeout: 5 });
}
