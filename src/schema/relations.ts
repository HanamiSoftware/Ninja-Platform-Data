
import { relations } from "drizzle-orm/relations";
import {
  users,
  authSessions,
  products,
  plans,
  subscriptions,
  links,
  apiKeys,
  domains,
  linkSyncJobs,
  capabilities,
  planCapabilities,
  linkEntitlements,
} from "./schema.js";

export const authSessionsRelations = relations(
  authSessions,
  ({ one }) => ({
    user: one(users, {
      fields: [authSessions.userId],
      references: [users.id],
    }),
  }),
);

export const usersRelations = relations(users, ({ many }) => ({
  authSessions: many(authSessions),
  subscriptions: many(subscriptions),
  links: many(links),
  apiKeys: many(apiKeys),
  domains: many(domains),
  linkSyncJobs: many(linkSyncJobs),
}));

export const plansRelations = relations(plans, ({ one, many }) => ({
  product: one(products, {
    fields: [plans.productId],
    references: [products.id],
  }),
  subscriptions: many(subscriptions),
}));

export const productsRelations = relations(
  products,
  ({ many }) => ({
    plans: many(plans),
    subscriptions: many(subscriptions),
    apiKeys: many(apiKeys),
  }),
);

export const subscriptionsRelations = relations(
  subscriptions,
  ({ one }) => ({
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
  }),
);

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

export const linkSyncJobsRelations = relations(
  linkSyncJobs,
  ({ one }) => ({
    user: one(users, {
      fields: [linkSyncJobs.userId],
      references: [users.id],
    }),
  }),
);

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


export const capabilitiesRelations = relations(
  capabilities,
  ({ one, many }) => ({
    product: one(products, {
      fields: [capabilities.productId],
      references: [products.id],
    }),
    planCapabilities: many(planCapabilities),
    linkEntitlements: many(linkEntitlements),
  }),
);

export const planCapabilitiesRelations = relations(
  planCapabilities,
  ({ one }) => ({
    plan: one(plans, {
      fields: [planCapabilities.productId, planCapabilities.planId],
      references: [plans.productId, plans.id],
    }),
    capability: one(capabilities, {
      fields: [planCapabilities.productId, planCapabilities.capabilityId],
      references: [capabilities.productId, capabilities.id],
    }),
  }),
);

export const linkEntitlementsRelations = relations(
  linkEntitlements,
  ({ one }) => ({
    link: one(links, {
      fields: [linkEntitlements.linkId],
      references: [links.id],
    }),
    capability: one(capabilities, {
      fields: [linkEntitlements.capabilityId],
      references: [capabilities.id],
    }),
  }),
);
