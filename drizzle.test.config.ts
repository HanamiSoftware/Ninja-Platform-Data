import "dotenv/config";

import { defineConfig } from "drizzle-kit";

// Deliberately separate from drizzle.config.ts so test fixtures are never
// included in the normal application migration sequence.
export default defineConfig({
  dialect: "postgresql",
  schema: "./src/schema/**/*.ts",
  out: "./test-fixtures/migrations",
  dbCredentials: {
    url: process.env.DATABASE_URL!,
  },
  migrations: {
    schema: "public",
    table: "__drizzle_test_fixtures_migrations",
  },
});
