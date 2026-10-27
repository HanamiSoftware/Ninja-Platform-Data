import { pgTable, unique, uniqueIndex, uuid, varchar, timestamp, text, index, foreignKey, char, check, integer, boolean, jsonb, } from "drizzle-orm/pg-core";
import { sql } from "drizzle-orm";
export const products = pgTable("products", {
    id: uuid().defaultRandom().primaryKey().notNull(),
    code: varchar({ length: 50 }).notNull(),
    name: varchar({ length: 100 }).notNull(),
    createdAt: timestamp("created_at", {
        withTimezone: true,
        mode: "string",
    }).defaultNow().notNull(),
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
    createdAt: timestamp("created_at", {
        withTimezone: true,
        mode: "string",
    }).defaultNow().notNull(),
    updatedAt: timestamp("updated_at", {
        withTimezone: true,
        mode: "string",
    }).defaultNow().notNull(),
    lastLoginAt: timestamp("last_login_at", {
        withTimezone: true,
        mode: "string",
    }),
}, (table) => [
    unique("uq_users_auth_subject").on(table.authSubject),
]);
export const authSessions = pgTable("auth_sessions", {
    id: uuid().defaultRandom().primaryKey().notNull(),
    userId: uuid("user_id").notNull(),
    clientId: varchar("client_id", { length: 255 }).notNull(),
    sessionHash: char("session_hash", { length: 64 }).notNull(),
    refreshTokenEncrypted: text("refresh_token_encrypted").notNull(),
    createdAt: timestamp("created_at", {
        withTimezone: true,
        mode: "string",
    }).defaultNow().notNull(),
    lastUsedAt: timestamp("last_used_at", {
        withTimezone: true,
        mode: "string",
    }).defaultNow().notNull(),
    expiresAt: timestamp("expires_at", {
        withTimezone: true,
        mode: "string",
    }).notNull(),
    absoluteExpiresAt: timestamp("absolute_expires_at", {
        withTimezone: true,
        mode: "string",
    }).notNull(),
    revokedAt: timestamp("revoked_at", {
        withTimezone: true,
        mode: "string",
    }),
}, (table) => [
    index("idx_auth_sessions_active")
        .using("btree", table.userId.asc().nullsLast().op("uuid_ops"), table.expiresAt.asc().nullsLast().op("timestamptz_ops"))
        .where(sql `revoked_at IS NULL`),
    index("idx_auth_sessions_user_id").on(table.userId),
    foreignKey({
        columns: [table.userId],
        foreignColumns: [users.id],
        name: "auth_sessions_user_id_fkey",
    }).onDelete("cascade"),
    unique("auth_sessions_session_hash_key").on(table.sessionHash),
]);
export const plans = pgTable("plans", {
    id: uuid().defaultRandom().primaryKey().notNull(),
    productId: uuid("product_id").notNull(),
    code: varchar({ length: 50 }).notNull(),
    name: varchar({ length: 100 }).notNull(),
    createdAt: timestamp("created_at", {
        withTimezone: true,
        mode: "string",
    }).defaultNow().notNull(),
}, (table) => [
    foreignKey({
        columns: [table.productId],
        foreignColumns: [products.id],
        name: "plans_product_id_fkey",
    }).onDelete("restrict"),
    unique("uq_product_plan_code").on(table.productId, table.code),
    unique("uq_plan_product_pair").on(table.productId, table.id),
]);
export const subscriptions = pgTable("subscriptions", {
    id: uuid().defaultRandom().primaryKey().notNull(),
    userId: uuid("user_id").notNull(),
    productId: uuid("product_id").notNull(),
    planId: uuid("plan_id").notNull(),
    status: varchar({ length: 30 }).default("active").notNull(),
    currentPeriodStart: timestamp("current_period_start", {
        withTimezone: true,
        mode: "string",
    }),
    currentPeriodEnd: timestamp("current_period_end", {
        withTimezone: true,
        mode: "string",
    }),
    createdAt: timestamp("created_at", {
        withTimezone: true,
        mode: "string",
    }).defaultNow().notNull(),
    updatedAt: timestamp("updated_at", {
        withTimezone: true,
        mode: "string",
    }).defaultNow().notNull(),
}, (table) => [
    index("idx_subscriptions_user_product").on(table.userId, table.productId),
    uniqueIndex("uq_active_subscription_per_product").on(table.userId, table.productId).where(sql `status IN ('trialing', 'active', 'past_due')`),
    foreignKey({
        columns: [table.userId],
        foreignColumns: [users.id],
        name: "subscriptions_user_id_fkey",
    }).onDelete("cascade"),
    foreignKey({
        columns: [table.productId],
        foreignColumns: [products.id],
        name: "subscriptions_product_id_fkey",
    }).onDelete("restrict"),
    foreignKey({
        columns: [table.productId, table.planId],
        foreignColumns: [plans.productId, plans.id],
        name: "fk_subscription_plan_product",
    }).onDelete("restrict"),
    check("chk_subscription_status", sql `status IN ('trialing', 'active', 'past_due', 'cancelled', 'expired')`),
]);
export const apiKeys = pgTable("api_keys", {
    id: uuid().defaultRandom().primaryKey().notNull(),
    userId: uuid("user_id").notNull(),
    productId: uuid("product_id").notNull(),
    keyHash: char("key_hash", { length: 64 }).notNull(),
    keyPrefix: varchar("key_prefix", { length: 16 }).notNull(),
    name: varchar({ length: 100 }),
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
    index("idx_api_keys_user_product").on(table.userId, table.productId),
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
/**
 * Domini disponibili per NinjaURL.
 *
 * n2l.ink:
 *   isDefault = true, userId = null, status = active.
 *
 * Custom domain:
 *   isDefault = false, userId valorizzato.
 */
export const domains = pgTable("domains", {
    id: uuid().defaultRandom().primaryKey().notNull(),
    hostname: varchar({ length: 253 }).notNull(),
    userId: uuid("user_id"),
    isDefault: boolean("is_default").default(false).notNull(),
    status: varchar({ length: 20 }).default("pending").notNull(),
    verificationToken: varchar("verification_token", { length: 255 }),
    verifiedAt: timestamp("verified_at", {
        withTimezone: true,
        mode: "string",
    }),
    createdAt: timestamp("created_at", {
        withTimezone: true,
        mode: "string",
    }).defaultNow().notNull(),
    updatedAt: timestamp("updated_at", {
        withTimezone: true,
        mode: "string",
    }).defaultNow().notNull(),
}, (table) => [
    unique("uq_domains_hostname").on(table.hostname),
    index("idx_domains_user_status").on(table.userId, table.status),
    uniqueIndex("uq_domains_single_default")
        .on(table.isDefault)
        .where(sql `is_default = true`),
    foreignKey({
        columns: [table.userId],
        foreignColumns: [users.id],
        name: "domains_user_id_fkey",
    }).onDelete("cascade"),
    check("chk_domains_status", sql `status IN ('pending', 'verified', 'active', 'disabled')`),
    check("chk_domains_owner", sql `(
        (is_default = true AND user_id IS NULL AND hostname = 'n2l.ink')
        OR
        (is_default = false AND user_id IS NOT NULL)
      )`),
    check("chk_domains_active_verified", sql `status <> 'active' OR verified_at IS NOT NULL`),
]);
/**
 * Link registrati nel database.
 * Lo slug è univoco soltanto all'interno dello stesso dominio.
 */
export const links = pgTable("links", {
    id: varchar({ length: 64 }).primaryKey().notNull(),
    domainId: uuid("domain_id").notNull(),
    slug: varchar({ length: 32 }).notNull(),
    target: text().notNull(),
    userId: uuid("user_id").notNull(),
    createdAt: timestamp("created_at", {
        withTimezone: true,
        mode: "string",
    }).defaultNow().notNull(),
    updatedAt: timestamp("updated_at", {
        withTimezone: true,
        mode: "string",
    }).defaultNow().notNull(),
    expiresAt: timestamp("expires_at", {
        withTimezone: true,
        mode: "string",
    }),
}, (table) => [
    unique("uq_links_domain_slug").on(table.domainId, table.slug),
    index("idx_links_user_created_at").on(table.userId, table.createdAt),
    index("idx_links_domain_id").on(table.domainId),
    foreignKey({
        columns: [table.userId],
        foreignColumns: [users.id],
        name: "links_user_id_fkey",
    }).onDelete("cascade"),
    foreignKey({
        columns: [table.domainId],
        foreignColumns: [domains.id],
        name: "links_domain_id_fkey",
    }).onDelete("restrict"),
    check("chk_links_slug_format", sql `slug ~ '^[A-Za-z0-9_-]{3,32}$'`),
]);
/**
 * Stato persistente del trasferimento dei link anonimi
 * verso un account registrato.
 *
 * checkpointIndex rappresenta il prossimo indice da elaborare
 * nella lista degli slug della chiave anonima.
 */
export const linkSyncJobs = pgTable("link_sync_jobs", {
    id: uuid().defaultRandom().primaryKey().notNull(),
    userId: uuid("user_id").notNull(),
    anonymousKeyHash: char("anonymous_key_hash", {
        length: 64,
    }).notNull(),
    status: varchar({ length: 20 }).default("pending").notNull(),
    totalLinks: integer("total_links").default(0).notNull(),
    processedLinks: integer("processed_links").default(0).notNull(),
    checkpointIndex: integer("checkpoint_index").default(0).notNull(),
    attempts: integer().default(0).notNull(),
    retryable: boolean().default(false).notNull(),
    errorCode: varchar("error_code", { length: 100 }),
    startedAt: timestamp("started_at", {
        withTimezone: true,
        mode: "string",
    }),
    completedAt: timestamp("completed_at", {
        withTimezone: true,
        mode: "string",
    }),
    createdAt: timestamp("created_at", {
        withTimezone: true,
        mode: "string",
    }).defaultNow().notNull(),
    updatedAt: timestamp("updated_at", {
        withTimezone: true,
        mode: "string",
    }).defaultNow().notNull(),
}, (table) => [
    unique("uq_link_sync_jobs_anonymous_key").on(table.anonymousKeyHash),
    index("idx_link_sync_jobs_user_status").on(table.userId, table.status),
    foreignKey({
        columns: [table.userId],
        foreignColumns: [users.id],
        name: "link_sync_jobs_user_id_fkey",
    }).onDelete("cascade"),
    check("chk_link_sync_jobs_status", sql `status IN ('pending', 'in_progress', 'completed', 'failed')`),
    check("chk_link_sync_jobs_counts", sql `total_links >= 0
        AND processed_links >= 0
        AND checkpoint_index >= 0
        AND attempts >= 0`),
    check("chk_link_sync_jobs_processed", sql `processed_links <= total_links`),
]);
/**
 * Catalogo delle capabilities per prodotto.
 * La presenza nel catalogo non implica che una feature sia implementata o abilitata.
 */
export const capabilities = pgTable("capabilities", {
    id: uuid().defaultRandom().primaryKey().notNull(),
    productId: uuid("product_id").notNull(),
    code: varchar({ length: 100 }).notNull(),
    scope: varchar({ length: 30 }).notNull(),
    description: text().notNull(),
    createdAt: timestamp("created_at", {
        withTimezone: true,
        mode: "string",
    }).defaultNow().notNull(),
}, (table) => [
    unique("uq_capabilities_product_code").on(table.productId, table.code),
    unique("uq_capabilities_product_id_pair").on(table.productId, table.id),
    index("idx_capabilities_product_scope").on(table.productId, table.scope),
    foreignKey({
        columns: [table.productId],
        foreignColumns: [products.id],
        name: "capabilities_product_id_fkey",
    }).onDelete("restrict"),
    check("chk_capabilities_scope", sql `scope IN ('account', 'link_entitlement')`),
]);
/**
 * Valori predefiniti delle account capabilities per piano.
 * Le righe devono essere presenti anche quando enabled = false.
 */
export const planCapabilities = pgTable("plan_capabilities", {
    id: uuid().defaultRandom().primaryKey().notNull(),
    productId: uuid("product_id").notNull(),
    planId: uuid("plan_id").notNull(),
    capabilityId: uuid("capability_id").notNull(),
    enabled: boolean().default(false).notNull(),
    limits: jsonb("limits")
        .$type()
        .default(sql `'{}'::jsonb`)
        .notNull(),
    createdAt: timestamp("created_at", {
        withTimezone: true,
        mode: "string",
    }).defaultNow().notNull(),
    updatedAt: timestamp("updated_at", {
        withTimezone: true,
        mode: "string",
    }).defaultNow().notNull(),
}, (table) => [
    unique("uq_plan_capabilities_plan_capability").on(table.planId, table.capabilityId),
    index("idx_plan_capabilities_product").on(table.productId),
    foreignKey({
        columns: [table.productId, table.planId],
        foreignColumns: [plans.productId, plans.id],
        name: "plan_capabilities_plan_product_fkey",
    }).onDelete("cascade"),
    foreignKey({
        columns: [table.productId, table.capabilityId],
        foreignColumns: [capabilities.productId, capabilities.id],
        name: "plan_capabilities_capability_product_fkey",
    }).onDelete("cascade"),
]);
/**
 * Entitlement concessi su uno specifico NinjaLink.
 * La validità temporale è valutata dal resolver a runtime.
 */
export const linkEntitlements = pgTable("link_entitlements", {
    id: uuid().defaultRandom().primaryKey().notNull(),
    linkId: varchar("link_id", { length: 64 }).notNull(),
    capabilityId: uuid("capability_id").notNull(),
    sourceType: varchar("source_type", { length: 30 }).notNull(),
    sourceRef: varchar("source_ref", { length: 255 }),
    grantedAt: timestamp("granted_at", {
        withTimezone: true,
        mode: "string",
    }).defaultNow().notNull(),
    expiresAt: timestamp("expires_at", {
        withTimezone: true,
        mode: "string",
    }),
    revokedAt: timestamp("revoked_at", {
        withTimezone: true,
        mode: "string",
    }),
}, (table) => [
    index("idx_link_entitlements_link").on(table.linkId),
    index("idx_link_entitlements_link_capability").on(table.linkId, table.capabilityId),
    foreignKey({
        columns: [table.linkId],
        foreignColumns: [links.id],
        name: "link_entitlements_link_id_fkey",
    }).onDelete("cascade"),
    foreignKey({
        columns: [table.capabilityId],
        foreignColumns: [capabilities.id],
        name: "link_entitlements_capability_id_fkey",
    }).onDelete("restrict"),
    check("chk_link_entitlements_source_type", sql `source_type IN ('shuriken', 'admin_grant')`),
]);
