// identity schema placeholder
// identity_users
// identity_sessions
// identity_providers
import {
    pgTable,
    uuid,
    varchar,
    timestamp,
    boolean,
    jsonb,
    index,
    uniqueIndex,
} from "drizzle-orm/pg-core";

export const identityUsers = pgTable(
    "identity_users",
    {
        id: uuid("id").primaryKey(),

        authgearUserId: varchar("authgear_user_id", { length: 128 }).notNull(),

        email: varchar("email", { length: 255 }).notNull(),

        username: varchar("username", { length: 50 }),

        displayName: varchar("display_name", { length: 120 }),

        avatarUrl: varchar("avatar_url", { length: 500 }),

        locale: varchar("locale", { length: 10 }).default("it"),

        timezone: varchar("timezone", { length: 50 }).default("Europe/Rome"),

        onboardingCompleted: boolean("onboarding_completed").default(false).notNull(),

        metadata: jsonb("metadata").$type<Record<string, unknown>>().default({}),

        createdAt: timestamp("created_at", {
            withTimezone: true,
        })
            .defaultNow()
            .notNull(),

        updatedAt: timestamp("updated_at", {
            withTimezone: true,
        })
            .defaultNow()
            .notNull(),

        deletedAt: timestamp("deleted_at", {
            withTimezone: true,
        }),
    },
    (table) => ({
        authgearUserIdIdx: uniqueIndex("ux_identity_users_authgear").on(table.authgearUserId),

        emailIdx: uniqueIndex("ux_identity_users_email").on(table.email),

        usernameIdx: uniqueIndex("ux_identity_users_username").on(table.username),

        createdAtIdx: index("ix_identity_users_created").on(table.createdAt),
    }),
);
