# PROGRESS

Task list, current state and budget log for The Beauty Bar e-commerce build.
Update this file at the end of every task.

## Task list

| #   | Task                                       | Status      |
| --- | ------------------------------------------ | ----------- |
| 0   | Foundation                                 | Done        |
| 1   | Database                                   | Not started |
| 2   | Authentication                             | Not started |
| 3   | Catalog pages                              | Not started |
| 4   | Cart                                       | Not started |
| 5   | Checkout                                   | Not started |
| 6   | Emails                                     | Not started |
| 7   | Customer account                           | Not started |
| 8   | Admin products and categories              | Not started |
| 9   | Admin dashboard, inventory and orders      | Not started |
| 10  | Polish and security review                 | Not started |

## Task 0 - Foundation

### Done

- Removed the template demo pages and demo components: `app/page.tsx`,
  `app/protected/`, `components/hero.tsx`, `components/deploy-button.tsx`,
  `components/next-logo.tsx`, `components/supabase-logo.tsx`,
  `components/env-var-warning.tsx`, `components/theme-switcher.tsx`,
  `components/tutorial/`.
- Kept the template Supabase client files (`lib/supabase/client.ts`,
  `lib/supabase/server.ts`, `lib/supabase/proxy.ts`) and both `proxy.ts` files.
- Kept the template auth pages at `/auth/*` and moved their form components to
  `components/auth/`. No duplicate login, register or forgot-password pages.
- Added the folder structure from `AGENTS.md`: `components/layout`,
  `components/shared`, `components/account`, `components/admin`,
  `components/auth`, `lib/actions`, `lib/queries`, `lib/email`.
- Added the route groups and layouts: `app/(shop)` (header + footer),
  `app/(account)` (header + account nav + footer), `app/(admin)` (admin header
  + admin nav).
- Added a placeholder page for every page in PRD section 19, plus
  `/checkout/confirmation`: `/`, `/shop`, `/category/[slug]`, `/product/[slug]`,
  `/cart`, `/checkout`, `/checkout/confirmation`, `/auth/login`,
  `/auth/sign-up`, `/auth/forgot-password`, `/account`, `/account/profile`,
  `/account/orders`, `/account/orders/[id]`, `/admin`, `/admin/products`,
  `/admin/products/new`, `/admin/products/[id]/edit`, `/admin/categories`,
  `/admin/inventory`, `/admin/orders`, `/admin/orders/[id]`.
- Brand theme in Tailwind and shadcn: brand tokens `brand-pink` (#F433AB),
  `brand-ink` (#191923), `brand-blush` (#EEE2DF), `brand-white`, plus the
  semantic tokens. `primary` is the pink with ink text on it (contrast rule).
  Headings use Playfair Display, body uses DM Sans, both through `next/font`.
- Added `lib/money.ts` (integer minor units to currency, no floats).
- Installed `server-only`.
- Added the `typecheck` and `db:types` scripts to `package.json`.
- Added `.env.example` with every variable name and no values.
- Narrowed the proxy guard so public routes render: only `/account/*` and
  `/admin/*` redirect a signed-out visitor to `/auth/login`.
- Dynamic route pages (`/category/[slug]`, `/product/[slug]`,
  `/account/orders/[id]`, `/admin/products/[id]/edit`, `/admin/orders/[id]`)
  read `params` inside `<Suspense>`, because `cacheComponents: true` in
  `next.config.ts` blocks uncached data at prerender time. Keep this pattern in
  the later tasks: page shell as the fallback, `params` and data in the child.
- Added the build output (`.next`, `out`, `build`) and `next-env.d.ts` to the
  ESLint ignores, so `npm run lint` is clean after a build.
- `npm run typecheck`, `npm run lint` and `npm run build` all pass.

### Not done

- `lib/actions`, `lib/queries` and `lib/email` are empty folders (only
  `.gitkeep`). Their real modules come with the tasks that need them.
- `store_settings` values (store name, currency, delivery fee, payment
  instructions) are not read yet. The header and footer show the values from
  `docs/DECISIONS.md` directly until Task 1 creates the table.
- No cart contents, no search and no real data anywhere yet.

### Problems

- The requirements file is `docs/PRD.md.md`, but `AGENTS.md` refers to
  `docs/PRD.md`. The file was left as it is. Rename it in a later task if you
  want the reference to match.
- `db:types` runs `supabase gen types typescript --linked`, so it needs a
  linked cloud project. It will fail until Task 1 links the project.
- `next build` downloads the Google Fonts for Playfair Display and DM Sans, so
  the build needs network access.
- `cacheComponents: true` rejects `new Date()` while prerendering, so the footer
  has no dynamic year. Add `"use cache"` or a client component if the year is
  wanted later.
- `tailwindcss-animate` ships no types and is CommonJS only, so
  `tailwind.config.ts` loads it with `require()` and one
  `eslint-disable-next-line` comment.

### Next task

Task 1 - Database: link the Supabase cloud dev project, add the migrations
(profiles, categories, products, variants, images, carts, cart items,
addresses, orders, order items, payments, payment events, order status
history, store settings, email events), the enums, the sequence for
`ORD-YYYY-NNNNNN`, RLS policies, `is_admin()`, the `place_order` function and
the `admin_update_order_status` / `admin_set_payment_status` RPCs, then run
`npm run db:types`.

## Later

Out of scope for Version 1. Keep the architecture ready for these, but do not
build them now.

- Online payment provider (Paystack and similar). The `PaymentProvider`
  interface and `payments` / `payment_events` tables must be ready, but no
  provider SDK and no webhook route in Version 1.
- Payment webhook route and `parseWebhook` handlers.
- Unpaid-order stock hold duration (DECISIONS says "decide later").
- Google OAuth setup, if it is not part of Task 2.
- Restock on cancel (DECISIONS has `restock_on_cancel = false`).
- Loyalty or rewards program.
- Multi-vendor marketplace.
- Native mobile apps.
- Advanced shipping-rate calculation.
- AI product recommendations.
- Filling in the production domain in `docs/DECISIONS.md`.

## Budget log

Approximate token usage, one row per task. These are estimates for tracking,
not exact figures.

| Task | Tool                              | Tokens |
| ---- | --------------------------------- | ------ |
| 0    | Read / search (exploration)       | ~96000 |
| 0    | Edits and commands (implementation) | ~42000 |
| 0    | Verify (typecheck / lint / build)  | ~8000  |