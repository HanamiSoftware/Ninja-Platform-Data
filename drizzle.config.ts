import "dotenv/config";

import { defineConfig } from "drizzle-kit";


console.log(
    "DATABASE:",
    process.env.DATABASE_URL?.replace(/:[^:@]+@/, ":***@")
);
export default defineConfig({
    dialect: "postgresql",
    schema: "./src/schema/**/*.ts",
    out: "./migrations",
    dbCredentials: {
        url: process.env.DATABASE_URL!,
    },
});
