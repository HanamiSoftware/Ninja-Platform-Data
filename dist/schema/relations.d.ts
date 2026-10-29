export declare const authSessionsRelations: import("drizzle-orm").Relations<"auth_sessions", {
    user: import("drizzle-orm").One<"users", true>;
}>;
export declare const usersRelations: import("drizzle-orm").Relations<"users", {
    authSessions: import("drizzle-orm").Many<"auth_sessions">;
    subscriptions: import("drizzle-orm").Many<"subscriptions">;
    links: import("drizzle-orm").Many<"links">;
    apiKeys: import("drizzle-orm").Many<"api_keys">;
    domains: import("drizzle-orm").Many<"domains">;
    linkSyncJobs: import("drizzle-orm").Many<"link_sync_jobs">;
    userRoles: import("drizzle-orm").Many<"user_roles">;
}>;
export declare const plansRelations: import("drizzle-orm").Relations<"plans", {
    product: import("drizzle-orm").One<"products", true>;
    subscriptions: import("drizzle-orm").Many<"subscriptions">;
}>;
export declare const productsRelations: import("drizzle-orm").Relations<"products", {
    plans: import("drizzle-orm").Many<"plans">;
    subscriptions: import("drizzle-orm").Many<"subscriptions">;
    apiKeys: import("drizzle-orm").Many<"api_keys">;
    roles: import("drizzle-orm").Many<"roles">;
    authCapabilities: import("drizzle-orm").Many<"auth_capabilities">;
    roleCapabilities: import("drizzle-orm").Many<"role_capabilities">;
    userRoles: import("drizzle-orm").Many<"user_roles">;
}>;
export declare const subscriptionsRelations: import("drizzle-orm").Relations<"subscriptions", {
    user: import("drizzle-orm").One<"users", true>;
    product: import("drizzle-orm").One<"products", true>;
    plan: import("drizzle-orm").One<"plans", true>;
}>;
export declare const domainsRelations: import("drizzle-orm").Relations<"domains", {
    owner: import("drizzle-orm").One<"users", false>;
    links: import("drizzle-orm").Many<"links">;
}>;
export declare const linksRelations: import("drizzle-orm").Relations<"links", {
    user: import("drizzle-orm").One<"users", true>;
    domain: import("drizzle-orm").One<"domains", true>;
}>;
export declare const linkSyncJobsRelations: import("drizzle-orm").Relations<"link_sync_jobs", {
    user: import("drizzle-orm").One<"users", true>;
}>;
export declare const apiKeysRelations: import("drizzle-orm").Relations<"api_keys", {
    user: import("drizzle-orm").One<"users", true>;
    product: import("drizzle-orm").One<"products", true>;
}>;
export declare const capabilitiesRelations: import("drizzle-orm").Relations<"capabilities", {
    product: import("drizzle-orm").One<"products", true>;
    planCapabilities: import("drizzle-orm").Many<"plan_capabilities">;
    linkEntitlements: import("drizzle-orm").Many<"link_entitlements">;
}>;
export declare const planCapabilitiesRelations: import("drizzle-orm").Relations<"plan_capabilities", {
    plan: import("drizzle-orm").One<"plans", true>;
    capability: import("drizzle-orm").One<"capabilities", true>;
}>;
export declare const linkEntitlementsRelations: import("drizzle-orm").Relations<"link_entitlements", {
    link: import("drizzle-orm").One<"links", true>;
    capability: import("drizzle-orm").One<"capabilities", true>;
}>;
export declare const rolesRelations: import("drizzle-orm").Relations<"roles", {
    product: import("drizzle-orm").One<"products", true>;
    roleCapabilities: import("drizzle-orm").Many<"role_capabilities">;
    userRoles: import("drizzle-orm").Many<"user_roles">;
}>;
export declare const authCapabilitiesRelations: import("drizzle-orm").Relations<"auth_capabilities", {
    product: import("drizzle-orm").One<"products", true>;
    roleCapabilities: import("drizzle-orm").Many<"role_capabilities">;
}>;
export declare const roleCapabilitiesRelations: import("drizzle-orm").Relations<"role_capabilities", {
    product: import("drizzle-orm").One<"products", true>;
    role: import("drizzle-orm").One<"roles", true>;
    capability: import("drizzle-orm").One<"auth_capabilities", true>;
}>;
export declare const userRolesRelations: import("drizzle-orm").Relations<"user_roles", {
    user: import("drizzle-orm").One<"users", true>;
    product: import("drizzle-orm").One<"products", true>;
    role: import("drizzle-orm").One<"roles", true>;
}>;
