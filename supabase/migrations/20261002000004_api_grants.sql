-- =====================================================================
-- The Beauty Bar: explicit Data API grants
-- New Supabase projects do not give the API roles access to new tables
-- automatically. This file gives each role only what it needs. RLS
-- policies then decide which rows each user can see or change.
-- The result is the same with or without the old default privileges.
-- =====================================================================

revoke all on all tables    in schema public from anon, authenticated;
revoke all on all sequences in schema public from anon, authenticated;

-- Public catalog (guests and signed-in users)
grant select on public.store_settings, public.categories, public.products,
                public.product_images, public.product_variants
  to anon, authenticated;

-- Signed-in users: own profile, cart and addresses
grant select on public.profiles to authenticated;
grant update (first_name, last_name, phone, avatar_url) on public.profiles to authenticated;
grant select, insert, update, delete on public.carts, public.cart_items, public.addresses to authenticated;

-- Signed-in users: read own orders (RLS). Admins: read all orders (RLS).
grant select on public.orders, public.order_items, public.order_status_history,
                public.payments, public.payment_events, public.email_events
  to authenticated;

-- Admin writes (RLS allows them only when is_admin() is true)
grant insert, update, delete on public.categories, public.products,
                                public.product_images, public.product_variants
  to authenticated;
grant update on public.store_settings to authenticated;

-- Server with the secret key (bypasses RLS). Used for place_order,
-- email logs and future payment webhooks.
grant all on all tables    in schema public to service_role;
grant all on all sequences in schema public to service_role;

-- Functions used inside RLS policies and by the app
grant execute on function public.is_admin() to anon, authenticated, service_role;
