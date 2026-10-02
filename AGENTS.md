# AGENTS.md

## Project
E-commerce store for beauty products, hair extensions and wigs.
- Requirements: `docs/PRD.md`. Read only the sections that the task names.
- Decisions: `docs/DECISIONS.md`. These answers override your assumptions.
- Progress: `docs/PROGRESS.md`. Read it at the start of each task. Update it at the end.
Do only the current task. Do not start the next task.

## Stack
Next.js 16 (App Router, TypeScript strict), Tailwind CSS, shadcn/ui, Zod, React Hook Form,
Supabase (Postgres, Auth, Storage) with `@supabase/ssr`, Mailgun HTTP API, npm, Vercel.
The project started from the `with-supabase` template. Keep its Supabase client files and `proxy.ts`.
Do not add a major library without approval.

## Security rules (PRD 17)
- Public env vars: only `NEXT_PUBLIC_SUPABASE_URL` and the publishable key.
- `SUPABASE_SECRET_KEY` and all `MAILGUN_*` vars are server-only. Use them only in files that `import "server-only"`.
- All writes go through Server Actions or Route Handlers. Validate all input with Zod on the server.
- Never trust prices, totals, stock, user ID or role from the browser. Order placement receives only variant IDs, quantities, customer data and delivery data. The server reads prices from the database.
- Get the user only with `supabase.auth.getUser()` on the server.
- Admin = `profiles.role = 'admin'`, checked by `public.is_admin()` in RLS and by `requireAdmin()` in each admin action. `proxy.ts` checks are for redirects only.
- RLS is on for every `public` table. Customers read only their own profile, cart, addresses and orders. Guests cannot read `orders`.
- Use the secret-key client only for the place-order call and for email logs. Use the user's client everywhere else.

## Data rules
- Money: integers in minor units (kobo). Never floats. Show money with `lib/money.ts`.
- Stock is on variants. A product without options has one default variant. Variant options are `jsonb`.
- Order items keep a snapshot (PRD 16). Order status and payment status are separate enums (PRD 9).
- Order reference `ORD-YYYY-NNNNNN` from a sequence. Do not show internal IDs.
- Each status change adds a row to `order_status_history`.
- Order placement is one Postgres function (`place_order`) in one transaction, with an idempotency key.
- An email failure must not lose an order. Log each email in `email_events`.
- Archive products. Do not delete them. Categories come from the database.
- Store values (currency, delivery fee, low-stock limit, stock policy, payment methods, bank instructions) come from the `store_settings` table. Do not hard-code them.
- Order and payment writes use only these RPCs: `place_order` (secret key), `admin_update_order_status` and `admin_set_payment_status` (admin session), `mark_order_paid`, `mark_payment_failed`, `mark_refunded` (secret key). Never write to `orders`, `order_items`, `payments` or `order_status_history` directly.

## Payments (PRD 9, 21)
Version 1 has no online payment. But the code must be ready for a provider (for example Paystack).
- Table `payments`: one row for each payment attempt (order, provider, method, amount, currency, status, unique provider reference, raw data). Version 1 uses provider `manual`.
- Table `payment_events`: provider webhook events, with a unique event ID so that each event is processed one time only. Version 1 does not write to it.
- `lib/payments/` has a `PaymentProvider` interface: `initialize(order)`, `verify(reference)`, `parseWebhook(request)`. `initialize` returns `{ type: "instructions" }` or `{ type: "redirect", url }`. Version 1 has only `manualProvider` (bank transfer, pay on delivery).
- Checkout code calls the provider through the interface. It never calls a provider directly.
- Only `markOrderPaid`, `markPaymentFailed` and `markRefunded` in `lib/payments/` change `orders.payment_status`. They are idempotent. The admin action now and webhooks later both use them.
- The payment amount always comes from `orders.total` in the database.
- Do not make a webhook route in Version 1. Do not add a real provider SDK.

## Database workflow
- Each schema change is a new file in `supabase/migrations/`. Never edit an applied migration.
- Ask before `supabase db push`. Never reset a remote database.
- After a schema change: `npm run db:types` (writes `lib/database.types.ts`).

## Folders
`app/(shop)`, `app/(account)/account`, `app/(admin)/admin`, `app/auth`,
`components/ui` (shadcn), `components/<feature>`, `lib/supabase`, `lib/actions`, `lib/queries`,
`lib/email`, `supabase/migrations`, `docs`.

## Code
- Server Components by default. Use `"use client"` only for interaction.
- Data reads in `lib/queries`, writes in `lib/actions`.
- Each data view has loading, empty and error states.
- Accessible and mobile-first (375 px). Premium beauty design, with theme tokens from `docs/DECISIONS.md`.

## Token budget rules
- Read only the files that you need. Use search before you open a large file.
- Do not read `lib/database.types.ts` in full. Search it.
- Edit with small replacements. Do not rewrite a full file for a small change.
- Do not use the browser tool. The user does the browser tests.
- Do not start long-running commands (for example `npm run dev`).
- Run `npm run typecheck`, `npm run lint` and `npm run build` only at the end of the task.
- Keep your messages short. Do not repeat code back to the user.

## End of each task
1. Repair all typecheck, lint and build errors.
2. Give the user a short list of manual tests.
3. Update `docs/PROGRESS.md`: done, not done, problems, next task.
4. Suggest a commit message. Do not commit unless the user tells you to.

## Do not
Connect a real payment provider (Version 1 non-goal). Put secrets in git.
Change `AGENTS.md` or `docs/PRD.md` unless told to.
