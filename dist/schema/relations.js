import { relations } from "drizzle-orm/relations";
import { users, authSessions, products, plans, subscriptions, links, apiKeys, domains, linkSyncJobs, capabilities, planCapabilities, linkEntitlements, roles, authCapabilities, roleCapabilities, userRoles, } from "./schema.js";
export const authSessionsRelations = relations(authSessions, ({ one }) => ({
    user: one(users, {
        fields: [authSessions.userId],
        references: [users.id],
    }),
}));
export const usersRelations = relations(users, ({ many }) => ({
    authSessions: many(authSessions),
    subscriptions: many(subscriptions),
    links: many(links),
    apiKeys: many(apiKeys),
    domains: many(domains),
    linkSyncJobs: many(linkSyncJobs),
    userRoles: many(userRoles),
}));
export const plansRelations = relations(plans, ({ one, many }) => ({
    product: one(products, {
        fields: [plans.productId],
        references: [products.id],
    }),
    subscriptions: many(subscriptions),
}));
export const productsRelations = relations(products, ({ many }) => ({
    plans: many(plans),
    subscriptions: many(subscriptions),
    apiKeys: many(apiKeys),
    roles: many(roles),
    authCapabilities: many(authCapabilities),
    roleCapabilities: many(roleCapabilities),
    userRoles: many(userRoles),
}));
export const subscriptionsRelations = relations(subscriptions, ({ one }) => ({
    user: one(users, {
        fields: [subscriptions.userId],
        references: [users.id],
    }),
    product: one(products, {
        fields: [subscriptions.productId],
        references: [products.id],
    }),
    plan: one(plans, {
        fields: [
            subscriptions.productId,
            subscriptions.planId,
        ],
        references: [
            plans.productId,
            plans.id,
        ],
    }),
}));
export const domainsRelations = relations(domains, ({ one, many }) => ({
    owner: one(users, {
        fields: [domains.userId],
        references: [users.id],
    }),
    links: many(links),
}));
export const linksRelations = relations(links, ({ one }) => ({
    user: one(users, {
        fields: [links.userId],
        references: [users.id],
    }),
    domain: one(domains, {
        fields: [links.domainId],
        references: [domains.id],
    }),
}));
export const linkSyncJobsRelations = relations(linkSyncJobs, ({ one }) => ({
    user: one(users, {
        fields: [linkSyncJobs.userId],
        references: [users.id],
    }),
}));
export const apiKeysRelations = relations(apiKeys, ({ one }) => ({
    user: one(users, {
        fields: [apiKeys.userId],
        references: [users.id],
    }),
    product: one(products, {
        fields: [apiKeys.productId],
        references: [products.id],
    }),
}));
export const capabilitiesRelations = relations(capabilities, ({ one, many }) => ({
    product: one(products, {
        fields: [capabilities.productId],
        references: [products.id],
    }),
    planCapabilities: many(planCapabilities),
    linkEntitlements: many(linkEntitlements),
}));
export const planCapabilitiesRelations = relations(planCapabilities, ({ one }) => ({
    plan: one(plans, {
        fields: [planCapabilities.productId, planCapabilities.planId],
        references: [plans.productId, plans.id],
    }),
    capability: one(capabilities, {
        fields: [planCapabilities.productId, planCapabilities.capabilityId],
        references: [capabilities.productId, capabilities.id],
    }),
}));
export const linkEntitlementsRelations = relations(linkEntitlements, ({ one }) => ({
    link: one(links, {
        fields: [linkEntitlements.linkId],
        references: [links.id],
    }),
    capability: one(capabilities, {
        fields: [linkEntitlements.capabilityId],
        references: [capabilities.id],
    }),
}));
export const rolesRelations = relations(roles, ({ one, many }) => ({
    product: one(products, {
        fields: [roles.productId],
        references: [products.id],
    }),
    roleCapabilities: many(roleCapabilities),
    userRoles: many(userRoles),
}));
export const authCapabilitiesRelations = relations(authCapabilities, ({ one, many }) => ({
    product: one(products, {
        fields: [authCapabilities.productId],
        references: [products.id],
    }),
    roleCapabilities: many(roleCapabilities),
}));
export const roleCapabilitiesRelations = relations(roleCapabilities, ({ one }) => ({
    product: one(products, {
        fields: [roleCapabilities.productId],
        references: [products.id],
    }),
    role: one(roles, {
        fields: [roleCapabilities.productId, roleCapabilities.roleId],
        references: [roles.productId, roles.id],
    }),
    capability: one(authCapabilities, {
        fields: [roleCapabilities.productId, roleCapabilities.capabilityId],
        references: [authCapabilities.productId, authCapabilities.id],
    }),
}));
export const userRolesRelations = relations(userRoles, ({ one }) => ({
    user: one(users, {
        fields: [userRoles.userId],
        references: [users.id],
    }),
    product: one(products, {
        fields: [userRoles.productId],
        references: [products.id],
    }),
    role: one(roles, {
        fields: [userRoles.productId, userRoles.roleId],
        references: [roles.productId, roles.id],
    }),
}));
