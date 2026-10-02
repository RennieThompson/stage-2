-- =====================================================================
-- The Beauty Bar: order and payment functions
-- These functions are the ONLY way to write orders, order items,
-- status history, payments and stock changes caused by orders.
-- =====================================================================

-- ---------------------------------------------------------------------
-- Order reference: ORD-YYYY-NNNNNN
-- ---------------------------------------------------------------------
create sequence public.order_reference_seq;

create or replace function public.generate_order_reference()
returns text
language plpgsql
volatile
set search_path = ''
as $$
declare
  n bigint := nextval('public.order_reference_seq');
begin
  return 'ORD-' || to_char(now() at time zone 'Africa/Lagos', 'YYYY') || '-'
         || lpad(n::text, greatest(6, length(n::text)), '0');
end;
$$;

-- ---------------------------------------------------------------------
-- Order summary as JSON (confirmation page, emails, admin results)
-- ---------------------------------------------------------------------
create or replace function public.order_summary(p_order_id uuid)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select jsonb_build_object(
    'id',              o.id,
    'reference',       o.reference,
    'user_id',         o.user_id,
    'status',          o.status,
    'payment_status',  o.payment_status,
    'payment_method',  o.payment_method,
    'currency',        o.currency,
    'subtotal',        o.subtotal,
    'delivery_fee',    o.delivery_fee,
    'total',           o.total,
    'created_at',      o.created_at,
    'customer', jsonb_build_object(
      'first_name', o.customer_first_name, 'last_name', o.customer_last_name,
      'email', o.customer_email, 'phone', o.customer_phone),
    'delivery', jsonb_build_object(
      'address', o.delivery_address, 'city', o.delivery_city, 'state', o.delivery_state,
      'country', o.delivery_country, 'phone', o.delivery_phone,
      'instructions', o.delivery_instructions),
    'items', coalesce((
      select jsonb_agg(jsonb_build_object(
               'product_id', i.product_id, 'variant_id', i.variant_id,
               'product_name', i.product_name, 'variant_name', i.variant_name, 'sku', i.sku,
               'unit_price', i.unit_price, 'quantity', i.quantity, 'line_total', i.line_total)
             order by i.created_at, i.product_name)
      from public.order_items i where i.order_id = o.id), '[]'::jsonb),
    'store_name', s.store_name,
    'payment_instructions',
      case when o.payment_method = 'bank_transfer' then s.bank_transfer_instructions end
  )
  from public.orders o
  cross join public.store_settings s
  where o.id = p_order_id;
$$;

-- ---------------------------------------------------------------------
-- Stock helpers (internal)
-- ---------------------------------------------------------------------
create or replace function public._deduct_order_stock(p_order_id uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_deducted boolean;
  v_short    uuid;
begin
  select stock_deducted into v_deducted from public.orders where id = p_order_id for update;
  if v_deducted then
    return;
  end if;

  if exists (select 1 from public.order_items where order_id = p_order_id and variant_id is null) then
    raise exception 'VARIANT_UNAVAILABLE' using detail = 'A product in this order no longer exists.';
  end if;

  -- Lock the variant rows in a fixed order to prevent deadlocks.
  perform 1 from public.product_variants v
  where v.id in (select variant_id from public.order_items where order_id = p_order_id)
  order by v.id
  for update;

  select s.variant_id into v_short
  from (select variant_id, sum(quantity) as qty
        from public.order_items where order_id = p_order_id group by variant_id) s
  join public.product_variants v on v.id = s.variant_id
  where v.stock_quantity < s.qty
  limit 1;

  if v_short is not null then
    raise exception 'OUT_OF_STOCK' using detail = v_short::text;
  end if;

  update public.product_variants v
  set stock_quantity = v.stock_quantity - s.qty
  from (select variant_id, sum(quantity) as qty
        from public.order_items where order_id = p_order_id group by variant_id) s
  where v.id = s.variant_id;

  update public.orders set stock_deducted = true where id = p_order_id;
end;
$$;

create or replace function public._restore_order_stock(p_order_id uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_deducted boolean;
begin
  select stock_deducted into v_deducted from public.orders where id = p_order_id for update;
  if not v_deducted then
    return;
  end if;

  update public.product_variants v
  set stock_quantity = v.stock_quantity + s.qty
  from (select variant_id, sum(quantity) as qty
        from public.order_items
        where order_id = p_order_id and variant_id is not null
        group by variant_id) s
  where v.id = s.variant_id;

  update public.orders set stock_deducted = false where id = p_order_id;
end;
$$;

-- ---------------------------------------------------------------------
-- place_order: called ONLY by the server with the secret key.
-- The server passes p_user_id from supabase.auth.getUser() (null for guests).
-- Prices come from the database. p_expected_total is only for the
-- "price changed" message; it is never used as the price.
--
-- Errors (exception message): STORE_NOT_CONFIGURED, PAYMENT_METHOD_NOT_ALLOWED,
-- INVALID_CUSTOMER, INVALID_DELIVERY, INVALID_ITEMS, VARIANT_UNAVAILABLE,
-- OUT_OF_STOCK (detail = variant id), PRICE_CHANGED (detail = new total).
-- ---------------------------------------------------------------------
create or replace function public.place_order(
  p_idempotency_key  uuid,
  p_user_id          uuid,
  p_customer         jsonb,
  p_delivery         jsonb,
  p_items            jsonb,
  p_payment_method   public.payment_method default 'bank_transfer',
  p_expected_total   integer default null
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_settings  public.store_settings;
  v_order_id  uuid;
  v_subtotal  integer;
  v_total     integer;
  v_bad       uuid;
begin
  if p_idempotency_key is null then
    raise exception 'INVALID_ITEMS' using detail = 'Missing idempotency key.';
  end if;

  -- 1. Same key again (double click, retry): return the first order.
  select id into v_order_id from public.orders where idempotency_key = p_idempotency_key;
  if found then
    return public.order_summary(v_order_id) || jsonb_build_object('replayed', true);
  end if;

  select * into v_settings from public.store_settings where id;
  if not found then
    raise exception 'STORE_NOT_CONFIGURED';
  end if;

  if not (p_payment_method = any (v_settings.enabled_payment_methods)) then
    raise exception 'PAYMENT_METHOD_NOT_ALLOWED';
  end if;

  -- 2. Customer and delivery data.
  if coalesce(trim(p_customer->>'first_name'), '') = ''
     or coalesce(trim(p_customer->>'last_name'), '') = ''
     or coalesce(trim(p_customer->>'phone'), '') = ''
     or coalesce(trim(p_customer->>'email'), '') !~* '^[^@\s]+@[^@\s]+\.[^@\s]+$' then
    raise exception 'INVALID_CUSTOMER';
  end if;

  if coalesce(trim(p_delivery->>'address'), '') = ''
     or coalesce(trim(p_delivery->>'city'), '') = ''
     or coalesce(trim(p_delivery->>'state'), '') = ''
     or coalesce(trim(p_delivery->>'country'), '') = ''
     or coalesce(trim(p_delivery->>'phone'), '') = '' then
    raise exception 'INVALID_DELIVERY';
  end if;

  -- 3. Items: [{ "variant_id": uuid, "quantity": int }]. Duplicates are added together.
  if p_items is null or jsonb_typeof(p_items) <> 'array'
     or jsonb_array_length(p_items) = 0 or jsonb_array_length(p_items) > 50 then
    raise exception 'INVALID_ITEMS';
  end if;

  if to_regclass('pg_temp._order_lines') is not null then
    drop table pg_temp._order_lines;
  end if;
  create temp table _order_lines on commit drop as
  select r.variant_id,
         r.quantity,
         v.product_id,
         p.name                                   as product_name,
         v.name                                   as variant_name,
         v.sku,
         coalesce(v.price, p.price)               as unit_price,
         v.stock_quantity,
         coalesce(v.is_active and p.status = 'active', false) as available
  from (
    select (e->>'variant_id')::uuid      as variant_id,
           sum((e->>'quantity')::int)::int as quantity
    from jsonb_array_elements(p_items) e
    group by 1
  ) r
  left join public.product_variants v on v.id = r.variant_id
  left join public.products p on p.id = v.product_id;

  if exists (select 1 from pg_temp._order_lines
             where variant_id is null or quantity is null or quantity < 1 or quantity > 99) then
    raise exception 'INVALID_ITEMS';
  end if;

  select variant_id into v_bad from pg_temp._order_lines where not available limit 1;
  if v_bad is not null then
    raise exception 'VARIANT_UNAVAILABLE' using detail = v_bad::text;
  end if;

  -- Availability check. Stock changes later if stock_policy = deduct_on_confirm.
  select variant_id into v_bad from pg_temp._order_lines where stock_quantity < quantity limit 1;
  if v_bad is not null then
    raise exception 'OUT_OF_STOCK' using detail = v_bad::text;
  end if;

  -- 4. Totals from database prices.
  select sum(unit_price * quantity)::int into v_subtotal from pg_temp._order_lines;
  v_total := v_subtotal + v_settings.delivery_fee;

  if p_expected_total is not null and p_expected_total <> v_total then
    raise exception 'PRICE_CHANGED' using detail = v_total::text;
  end if;

  -- 5. Order. A parallel request with the same key gets the first order.
  begin
    insert into public.orders (
      reference, user_id, idempotency_key,
      customer_first_name, customer_last_name, customer_email, customer_phone,
      delivery_address, delivery_city, delivery_state, delivery_country, delivery_phone,
      delivery_instructions,
      currency, subtotal, delivery_fee, total,
      status, payment_status, payment_method
    ) values (
      public.generate_order_reference(), p_user_id, p_idempotency_key,
      trim(p_customer->>'first_name'), trim(p_customer->>'last_name'),
      lower(trim(p_customer->>'email')), trim(p_customer->>'phone'),
      trim(p_delivery->>'address'), trim(p_delivery->>'city'), trim(p_delivery->>'state'),
      trim(p_delivery->>'country'), trim(p_delivery->>'phone'),
      nullif(trim(p_delivery->>'instructions'), ''),
      v_settings.currency, v_subtotal, v_settings.delivery_fee, v_total,
      'pending', 'pending', p_payment_method
    )
    returning id into v_order_id;
  exception when unique_violation then
    select id into v_order_id from public.orders where idempotency_key = p_idempotency_key;
    if found then
      return public.order_summary(v_order_id) || jsonb_build_object('replayed', true);
    end if;
    raise;
  end;

  -- 6. Order items (snapshot).
  insert into public.order_items (order_id, product_id, variant_id, product_name, variant_name,
                                  sku, unit_price, quantity, line_total)
  select v_order_id, product_id, variant_id, product_name, variant_name,
         sku, unit_price, quantity, unit_price * quantity
  from pg_temp._order_lines;

  -- 7. First payment row. A future provider adds its reference to this row.
  insert into public.payments (order_id, provider, method, amount, currency, status)
  values (v_order_id, case when p_payment_method = 'online' then 'pending_provider' else 'manual' end,
          p_payment_method, v_total, v_settings.currency, 'pending');

  -- 8. History.
  insert into public.order_status_history (order_id, to_status, to_payment_status, note, changed_by)
  values (v_order_id, 'pending', 'pending', 'Order placed', p_user_id);

  -- 9. Stock (only if the store deducts at placement).
  if v_settings.stock_policy = 'deduct_on_place' then
    perform public._deduct_order_stock(v_order_id);
  end if;

  -- 10. Clear the signed-in user's cart.
  if p_user_id is not null then
    delete from public.cart_items
    where cart_id in (select id from public.carts where user_id = p_user_id);
  end if;

  return public.order_summary(v_order_id) || jsonb_build_object('replayed', false);
end;
$$;

-- ---------------------------------------------------------------------
-- admin_update_order_status: called by an admin with the user's session.
-- Allowed changes:
--   pending    -> confirmed, cancelled
--   confirmed  -> processing, shipped, cancelled
--   processing -> shipped, cancelled
--   shipped    -> delivered
-- Stock is deducted at the first change away from "pending" (if not done).
-- Result includes "changed": false when the status is already p_status.
-- ---------------------------------------------------------------------
create or replace function public.admin_update_order_status(
  p_order_id  uuid,
  p_status    public.order_status,
  p_note      text default null
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_order     public.orders;
  v_settings  public.store_settings;
  v_allowed   boolean;
begin
  if not public.is_admin() then
    raise exception 'NOT_AUTHORIZED' using errcode = '42501';
  end if;

  select * into v_order from public.orders where id = p_order_id for update;
  if not found then
    raise exception 'ORDER_NOT_FOUND';
  end if;

  if v_order.status = p_status then
    return public.order_summary(p_order_id) || jsonb_build_object('changed', false);
  end if;

  v_allowed := case v_order.status
    when 'pending'    then p_status in ('confirmed', 'cancelled')
    when 'confirmed'  then p_status in ('processing', 'shipped', 'cancelled')
    when 'processing' then p_status in ('shipped', 'cancelled')
    when 'shipped'    then p_status = 'delivered'
    else false
  end;
  if not v_allowed then
    raise exception 'INVALID_STATUS_CHANGE' using detail = v_order.status::text || ' -> ' || p_status::text;
  end if;

  select * into v_settings from public.store_settings where id;

  if p_status <> 'cancelled' and not v_order.stock_deducted then
    perform public._deduct_order_stock(p_order_id);   -- raises OUT_OF_STOCK if necessary
  end if;

  if p_status = 'cancelled' and v_order.stock_deducted and v_settings.restock_on_cancel then
    perform public._restore_order_stock(p_order_id);
  end if;

  update public.orders
  set status       = p_status,
      confirmed_at = case when p_status = 'confirmed' then now() else confirmed_at end,
      cancelled_at = case when p_status = 'cancelled' then now() else cancelled_at end
  where id = p_order_id;

  insert into public.order_status_history (order_id, from_status, to_status, note, changed_by)
  values (p_order_id, v_order.status, p_status, nullif(trim(p_note), ''), (select auth.uid()));

  return public.order_summary(p_order_id)
         || jsonb_build_object('changed', true, 'from_status', v_order.status);
end;
$$;

-- ---------------------------------------------------------------------
-- Payment status (internal). Allowed changes:
--   pending -> paid, failed
--   failed  -> pending, paid
--   paid    -> refunded
-- Same status again = no change ("changed": false). This makes webhooks
-- and double clicks safe.
-- ---------------------------------------------------------------------
create or replace function public._set_payment_status(
  p_order_id            uuid,
  p_status              public.payment_status,
  p_provider_reference  text,
  p_raw                 jsonb,
  p_actor               uuid,
  p_note                text
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_order       public.orders;
  v_payment_id  uuid;
  v_allowed     boolean;
begin
  select * into v_order from public.orders where id = p_order_id for update;
  if not found then
    raise exception 'ORDER_NOT_FOUND';
  end if;

  if v_order.payment_status = p_status then
    return public.order_summary(p_order_id) || jsonb_build_object('changed', false);
  end if;

  v_allowed := case v_order.payment_status
    when 'pending' then p_status in ('paid', 'failed')
    when 'failed'  then p_status in ('pending', 'paid')
    when 'paid'    then p_status = 'refunded'
    else false
  end;
  if not v_allowed then
    raise exception 'INVALID_PAYMENT_CHANGE'
      using detail = v_order.payment_status::text || ' -> ' || p_status::text;
  end if;

  select id into v_payment_id from public.payments
  where order_id = p_order_id order by created_at desc limit 1;

  if v_payment_id is null then
    insert into public.payments (order_id, provider, method, amount, currency, status)
    values (p_order_id, 'manual', v_order.payment_method, v_order.total, v_order.currency, 'pending')
    returning id into v_payment_id;
  end if;

  update public.payments
  set status             = p_status,
      provider_reference = coalesce(p_provider_reference, provider_reference),
      raw                = coalesce(p_raw, raw),
      recorded_by        = coalesce(p_actor, recorded_by),
      paid_at            = case when p_status = 'paid' then now() else paid_at end
  where id = v_payment_id;

  update public.orders set payment_status = p_status where id = p_order_id;

  insert into public.order_status_history (order_id, from_payment_status, to_payment_status, note, changed_by)
  values (p_order_id, v_order.payment_status, p_status, nullif(trim(p_note), ''), p_actor);

  return public.order_summary(p_order_id)
         || jsonb_build_object('changed', true, 'from_payment_status', v_order.payment_status);
end;
$$;

-- For the server and future webhooks (secret key only).
create or replace function public.mark_order_paid(
  p_order_id uuid, p_provider_reference text default null, p_raw jsonb default null)
returns jsonb language sql security definer set search_path = '' as $$
  select public._set_payment_status(p_order_id, 'paid', p_provider_reference, p_raw, null, 'Payment confirmed by provider');
$$;

create or replace function public.mark_payment_failed(
  p_order_id uuid, p_provider_reference text default null, p_raw jsonb default null)
returns jsonb language sql security definer set search_path = '' as $$
  select public._set_payment_status(p_order_id, 'failed', p_provider_reference, p_raw, null, 'Payment failed');
$$;

create or replace function public.mark_refunded(
  p_order_id uuid, p_provider_reference text default null, p_raw jsonb default null)
returns jsonb language sql security definer set search_path = '' as $$
  select public._set_payment_status(p_order_id, 'refunded', p_provider_reference, p_raw, null, 'Payment refunded');
$$;

-- For admins (user session). Version 1: "Record payment" after a bank transfer.
create or replace function public.admin_set_payment_status(
  p_order_id  uuid,
  p_status    public.payment_status,
  p_note      text default null
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
begin
  if not public.is_admin() then
    raise exception 'NOT_AUTHORIZED' using errcode = '42501';
  end if;
  return public._set_payment_status(p_order_id, p_status, null, null, (select auth.uid()), p_note);
end;
$$;

-- =====================================================================
-- Permissions. Only the listed roles can call each function.
-- =====================================================================
revoke all on sequence public.order_reference_seq from public, anon, authenticated;

revoke all on function public.generate_order_reference()                   from public, anon, authenticated;
revoke all on function public.order_summary(uuid)                          from public, anon, authenticated;
revoke all on function public._deduct_order_stock(uuid)                    from public, anon, authenticated, service_role;
revoke all on function public._restore_order_stock(uuid)                   from public, anon, authenticated, service_role;
revoke all on function public._set_payment_status(uuid, public.payment_status, text, jsonb, uuid, text)
                                                                            from public, anon, authenticated, service_role;

revoke all on function public.place_order(uuid, uuid, jsonb, jsonb, jsonb, public.payment_method, integer)
  from public, anon, authenticated;
grant execute on function public.place_order(uuid, uuid, jsonb, jsonb, jsonb, public.payment_method, integer)
  to service_role;

revoke all on function public.mark_order_paid(uuid, text, jsonb)     from public, anon, authenticated;
revoke all on function public.mark_payment_failed(uuid, text, jsonb) from public, anon, authenticated;
revoke all on function public.mark_refunded(uuid, text, jsonb)       from public, anon, authenticated;
grant execute on function public.mark_order_paid(uuid, text, jsonb)     to service_role;
grant execute on function public.mark_payment_failed(uuid, text, jsonb) to service_role;
grant execute on function public.mark_refunded(uuid, text, jsonb)       to service_role;
grant execute on function public.order_summary(uuid)                    to service_role;

revoke all on function public.admin_update_order_status(uuid, public.order_status, text)   from public, anon;
revoke all on function public.admin_set_payment_status(uuid, public.payment_status, text)  from public, anon;
grant execute on function public.admin_update_order_status(uuid, public.order_status, text)  to authenticated;
grant execute on function public.admin_set_payment_status(uuid, public.payment_status, text) to authenticated;
