import { pgTable, unique, uuid, varchar, timestamp, text, index, foreignKey, char, uniqueIndex, check, integer } from "drizzle-orm/pg-core"
import { sql } from "drizzle-orm"



export const products = pgTable("products", {
	id: uuid().defaultRandom().primaryKey().notNull(),
	code: varchar({ length: 50 }).notNull(),
	name: varchar({ length: 100 }).notNull(),
	createdAt: timestamp("created_at", { withTimezone: true, mode: 'string' }).defaultNow().notNull(),
}, (table) => [
	unique("products_code_key").on(table.code),
]);

export const users = pgTable("users", {
	id: uuid().defaultRandom().primaryKey().notNull(),
	authProvider: varchar("auth_provider", { length: 50 }).notNull(),
	authSubject: varchar("auth_subject", { length: 255 }).notNull(),
	email: varchar({ length: 320 }),
	name: varchar({ length: 255 }),
	pictureUrl: text("picture_url"),
	createdAt: timestamp("created_at", { withTimezone: true, mode: 'string' }).defaultNow().notNull(),
	updatedAt: timestamp("updated_at", { withTimezone: true, mode: 'string' }).defaultNow().notNull(),
	lastLoginAt: timestamp("last_login_at", { withTimezone: true, mode: 'string' }),
}, (table) => [
	unique("uq_users_auth_subject").on(table.authSubject),
]);

export const authSessions = pgTable("auth_sessions", {
	id: uuid().defaultRandom().primaryKey().notNull(),
	userId: uuid("user_id").notNull(),
	clientId: varchar("client_id", { length: 255 }).notNull(), 
	sessionHash: char("session_hash", { length: 64 }).notNull(),
	refreshTokenEncrypted: text("refresh_token_encrypted").notNull(),
	createdAt: timestamp("created_at", { withTimezone: true, mode: 'string' }).defaultNow().notNull(),
	lastUsedAt: timestamp("last_used_at", { withTimezone: true, mode: 'string' }).defaultNow().notNull(),
	expiresAt: timestamp("expires_at", { withTimezone: true, mode: 'string' }).notNull(),
	absoluteExpiresAt: timestamp("absolute_expires_at", { withTimezone: true, mode: 'string' }).notNull(),
	revokedAt: timestamp("revoked_at", { withTimezone: true, mode: 'string' }),
}, (table) => [
	index("idx_auth_sessions_active").using("btree", table.userId.asc().nullsLast().op("uuid_ops"), table.expiresAt.asc().nullsLast().op("timestamptz_ops")).where(sql`(revoked_at IS NULL)`),
	index("idx_auth_sessions_user_id").using("btree", table.userId.asc().nullsLast().op("uuid_ops")),
	foreignKey({
			columns: [table.userId],
			foreignColumns: [users.id],
			name: "auth_sessions_user_id_fkey"
		}).onDelete("cascade"),
	unique("auth_sessions_session_hash_key").on(table.sessionHash),
]);

export const plans = pgTable("plans", {
	id: uuid().defaultRandom().primaryKey().notNull(),
	productId: uuid("product_id").notNull(),
	code: varchar({ length: 50 }).notNull(),
	name: varchar({ length: 100 }).notNull(),
	createdAt: timestamp("created_at", { withTimezone: true, mode: 'string' }).defaultNow().notNull(),
}, (table) => [
	foreignKey({
			columns: [table.productId],
			foreignColumns: [products.id],
			name: "plans_product_id_fkey"
		}).onDelete("restrict"),
	unique("uq_product_plan_code").on(table.productId, table.code),
	unique("uq_plan_product_pair").on(table.productId, table.id),
]);

export const subscriptions = pgTable("subscriptions", {
	id: uuid().defaultRandom().primaryKey().notNull(),
	userId: uuid("user_id").notNull(),
	productId: uuid("product_id").notNull(),
	planId: uuid("plan_id").notNull(),
	status: varchar({ length: 30 }).default('active').notNull(),
	currentPeriodStart: timestamp("current_period_start", { withTimezone: true, mode: 'string' }),
	currentPeriodEnd: timestamp("current_period_end", { withTimezone: true, mode: 'string' }),
	createdAt: timestamp("created_at", { withTimezone: true, mode: 'string' }).defaultNow().notNull(),
	updatedAt: timestamp("updated_at", { withTimezone: true, mode: 'string' }).defaultNow().notNull(),
}, (table) => [
	index("idx_subscriptions_user_product").using("btree", table.userId.asc().nullsLast().op("uuid_ops"), table.productId.asc().nullsLast().op("uuid_ops")),
	uniqueIndex("uq_active_subscription_per_product").using("btree", table.userId.asc().nullsLast().op("uuid_ops"), table.productId.asc().nullsLast().op("uuid_ops")).where(sql`((status)::text = ANY ((ARRAY['trialing'::character varying, 'active'::character varying, 'past_due'::character varying])::text[]))`),
	foreignKey({
			columns: [table.userId],
			foreignColumns: [users.id],
			name: "subscriptions_user_id_fkey"
		}).onDelete("cascade"),
	foreignKey({
			columns: [table.productId],
			foreignColumns: [products.id],
			name: "subscriptions_product_id_fkey"
		}).onDelete("restrict"),
	foreignKey({
			columns: [table.productId, table.planId],
			foreignColumns: [plans.id, plans.productId],
			name: "fk_subscription_plan_product"
		}).onDelete("restrict"),
	check("chk_subscription_status", sql`(status)::text = ANY ((ARRAY['trialing'::character varying, 'active'::character varying, 'past_due'::character varying, 'cancelled'::character varying, 'expired'::character varying])::text[])`),
]);


export const apiKeys = pgTable("api_keys", {
	id: uuid().defaultRandom().primaryKey().notNull(),

	userId: uuid("user_id").notNull(),
	productId: uuid("product_id").notNull(),

	// SHA-256 esadecimale della chiave: mai il segreto in chiaro.
	keyHash: char("key_hash", { length: 64 }).notNull(),
	keyPrefix: varchar("key_prefix", { length: 16 }).notNull(),

	name: varchar({ length: 100 }),

	// Limite applicato dal worker secondo la finestra
	// temporale prevista dal relativo algoritmo.
	rateLimit: integer("rate_limit").notNull(),

	createdAt: timestamp("created_at", {
		withTimezone: true,
		mode: "string",
	}).defaultNow().notNull(),

	lastUsedAt: timestamp("last_used_at", {
		withTimezone: true,
		mode: "string",
	}),

	expiresAt: timestamp("expires_at", {
		withTimezone: true,
		mode: "string",
	}),

	revokedAt: timestamp("revoked_at", {
		withTimezone: true,
		mode: "string",
	}),
}, (table) => [
	unique("uq_api_keys_hash").on(table.keyHash),

	index("idx_api_keys_user_product").on(
		table.userId,
		table.productId,
	),

	foreignKey({
		columns: [table.userId],
		foreignColumns: [users.id],
		name: "api_keys_user_id_fkey",
	}).onDelete("cascade"),

	foreignKey({
		columns: [table.productId],
		foreignColumns: [products.id],
		name: "api_keys_product_id_fkey",
	}).onDelete("restrict"),
]);

export const links = pgTable("links", {
	id: varchar({ length: 64 }).primaryKey().notNull(),
	slug: varchar({ length: 32 }).notNull(),
	target: text().notNull(),
	userId: uuid("user_id").notNull(),
	createdAt: timestamp("created_at", {
		withTimezone: true,
		mode: "string",
	}).notNull(),
	updatedAt: timestamp("updated_at", {
		withTimezone: true,
		mode: "string",
	}).defaultNow().notNull(),
	expiresAt: timestamp("expires_at", {
		withTimezone: true,
		mode: "string",
	}),
}, (table) => [
	unique("uq_links_slug").on(table.slug),
	index("idx_links_user_created_at").on(
		table.userId,
		table.createdAt,
	),
	foreignKey({
		columns: [table.userId],
		foreignColumns: [users.id],
		name: "links_user_id_fkey",
	}).onDelete("cascade"),
	check(
		"chk_links_slug_format",
		sql`slug ~ '^[A-Za-z0-9_-]{3,32}$'`,
	),
]);

