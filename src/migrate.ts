import "dotenv/config";

import postgres from "postgres";
import { drizzle } from "drizzle-orm/postgres-js";
import { migrate } from "drizzle-orm/postgres-js/migrator";

async function main() {
	const connectionString = process.env.DATABASE_URL;

	if (!connectionString) {
		throw new Error("DATABASE_URL is not configured");
	}

	const client = postgres(connectionString, {
		max: 1,
		fetch_types: false,
	});

	try {
		const db = drizzle(client);

		await migrate(db, {
			migrationsFolder: "./migrations",
		});

		console.log("Database migrations completed successfully.");
	} finally {
		await client.end();
	}
}

main().catch((error) => {
	console.error("Database migration failed:", error);
	process.exitCode = 1;
});