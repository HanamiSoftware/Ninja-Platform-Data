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


import { drizzle } from "drizzle-orm/postgres-js";
import postgres from "postgres";

import * as schema from "./schema/schema.js";
import * as relations from "./schema/relations.js";

const dbSchema = {
    ...schema,
    ...relations,
};

/**
 * Creates a Drizzle client using a connection string supplied by the consumer.
 * The caller is responsible for providing the connection configuration.
 */
export function createDb(connectionString: string) {
    const sql = postgres(connectionString, {
        max: 1,
        fetch_types: false,
    });

    return drizzle(sql, {
        schema: dbSchema,
    });
}
