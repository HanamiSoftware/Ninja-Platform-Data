import "dotenv/config";
import postgres from "postgres";

type AccountPlan = {
  label: string;
  userId: string;
  planCode: "free" | "pro" | "pro_plus";
};

const UUID_PATTERN = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

function requiredEnv(name: string): string {
  const value = process.env[name]?.trim();
  if (!value) throw new Error(`${name} is required.`);
  return value;
}

async function main(): Promise<void> {
  if (requiredEnv("CONFIRM_TEST_DATABASE") !== "YES_I_CONFIRM_TEST_DATABASE") {
    throw new Error("Refusing to modify the database: explicit test-database confirmation is missing.");
  }

  const databaseUrl = requiredEnv("DATABASE_URL");
  const accounts: AccountPlan[] = [
    { label: "FREE", userId: requiredEnv("FREE_USER_ID"), planCode: "free" },
    { label: "PRO", userId: requiredEnv("PRO_USER_ID"), planCode: "pro" },
    { label: "PRO+", userId: requiredEnv("PRO_PLUS_USER_ID"), planCode: "pro_plus" },
  ];

  for (const account of accounts) {
    if (!UUID_PATTERN.test(account.userId)) {
      throw new Error(`${account.label} user ID is not a valid UUID.`);
    }
  }

  if (new Set(accounts.map((account) => account.userId)).size !== accounts.length) {
    throw new Error("The three test accounts must have distinct user IDs.");
  }

  const sql = postgres(databaseUrl, {
    ssl: "require",
    connect_timeout: 15,
    max: 1,
  });

  try {
    const database = await sql`SELECT current_database() AS name`;
    console.log(`Connected database: ${database[0]?.name ?? "unknown"}`);
    console.log("Applying the three explicitly supplied NinjaURL test-account plans...");

    const results = await sql.begin(async (tx) => {
      const productRows = await tx`
        SELECT id
        FROM products
        WHERE code = 'ninjaurl'
        LIMIT 1
        FOR SHARE
      `;
      if (productRows.length !== 1) {
        throw new Error("Expected exactly one NinjaURL product in products.");
      }
      const productId = productRows[0].id as string;

      const planRows = await tx`
        SELECT id, code
        FROM plans
        WHERE product_id = ${productId}::uuid
          AND code IN ('free', 'pro', 'pro_plus')
      `;
      const planIds = new Map(planRows.map((row) => [String(row.code), String(row.id)]));
      for (const code of ["free", "pro", "pro_plus"] as const) {
        if (!planIds.has(code)) throw new Error(`NinjaURL plan '${code}' was not found.`);
      }

      const applied: Array<{ label: string; planCode: string; action: string }> = [];

      for (const account of accounts) {
        const users = await tx`
          SELECT id
          FROM users
          WHERE id = ${account.userId}::uuid
          FOR UPDATE
        `;
        if (users.length !== 1) {
          throw new Error(`${account.label} account was not found in users; no changes were committed.`);
        }

        const planId = planIds.get(account.planCode)!;
        const activeSubscriptions = await tx`
          SELECT id, plan_id, status
          FROM subscriptions
          WHERE user_id = ${account.userId}::uuid
            AND product_id = ${productId}::uuid
            AND status IN ('trialing', 'active', 'past_due')
          FOR UPDATE
        `;

        if (activeSubscriptions.length > 1) {
          throw new Error(`${account.label} account has multiple active NinjaURL subscriptions; refusing to guess.`);
        }

        if (activeSubscriptions.length === 1) {
          const current = activeSubscriptions[0];
          if (String(current.plan_id) === planId) {
            applied.push({ label: account.label, planCode: account.planCode, action: "already-correct" });
          } else {
            await tx`
              UPDATE subscriptions
              SET plan_id = ${planId}::uuid,
                  updated_at = now()
              WHERE id = ${String(current.id)}::uuid
            `;
            applied.push({ label: account.label, planCode: account.planCode, action: "plan-updated" });
          }
        } else {
          await tx`
            INSERT INTO subscriptions (
              user_id,
              product_id,
              plan_id,
              status,
              current_period_start,
              created_at,
              updated_at
            )
            VALUES (
              ${account.userId}::uuid,
              ${productId}::uuid,
              ${planId}::uuid,
              'active',
              now(),
              now(),
              now()
            )
          `;
          applied.push({ label: account.label, planCode: account.planCode, action: "subscription-created" });
        }
      }

      return applied;
    });

    for (const result of results) {
      console.log(`[${result.label}] ${result.planCode}: ${result.action}`);
    }
    console.log("Test-account plan assignment completed. No users, links, or historical subscriptions were deleted.");
  } finally {
    await sql.end({ timeout: 5 });
  }
}

main().catch((error: unknown) => {
  const message = error instanceof Error ? error.message : "Unknown error";
  console.error("Test-account plan assignment failed:", message);
  process.exitCode = 1;
});
