export declare const authSessionsRelations: import("drizzle-orm").Relations<"auth_sessions", {
    user: import("drizzle-orm").One<"users", true>;
}>;
export declare const usersRelations: import("drizzle-orm").Relations<"users", {
    authSessions: import("drizzle-orm").Many<"auth_sessions">;
    subscriptions: import("drizzle-orm").Many<"subscriptions">;
    links: import("drizzle-orm").Many<"links">;
    apiKeys: import("drizzle-orm").Many<"api_keys">;
}>;
export declare const plansRelations: import("drizzle-orm").Relations<"plans", {
    product: import("drizzle-orm").One<"products", true>;
    subscriptions: import("drizzle-orm").Many<"subscriptions">;
}>;
export declare const productsRelations: import("drizzle-orm").Relations<"products", {
    plans: import("drizzle-orm").Many<"plans">;
    subscriptions: import("drizzle-orm").Many<"subscriptions">;
    apiKeys: import("drizzle-orm").Many<"api_keys">;
}>;
export declare const subscriptionsRelations: import("drizzle-orm").Relations<"subscriptions", {
    user: import("drizzle-orm").One<"users", true>;
    product: import("drizzle-orm").One<"products", true>;
    plan: import("drizzle-orm").One<"plans", true>;
}>;
export declare const linksRelations: import("drizzle-orm").Relations<"links", {
    user: import("drizzle-orm").One<"users", true>;
}>;
export declare const apiKeysRelations: import("drizzle-orm").Relations<"api_keys", {
    user: import("drizzle-orm").One<"users", true>;
    product: import("drizzle-orm").One<"products", true>;
}>;
