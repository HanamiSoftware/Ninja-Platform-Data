import { relations } from "drizzle-orm/relations";
import { users, authSessions, products, plans, subscriptions } from "./schema";

export const authSessionsRelations = relations(authSessions, ({one}) => ({
	user: one(users, {
		fields: [authSessions.userId],
		references: [users.id]
	}),
}));

export const usersRelations = relations(users, ({many}) => ({
	authSessions: many(authSessions),
	subscriptions: many(subscriptions),
}));

export const plansRelations = relations(plans, ({one, many}) => ({
	product: one(products, {
		fields: [plans.productId],
		references: [products.id]
	}),
	subscriptions: many(subscriptions),
}));

export const productsRelations = relations(products, ({many}) => ({
	plans: many(plans),
	subscriptions: many(subscriptions),
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
			plans.id,
			plans.productId,
		],
	}),
}));
