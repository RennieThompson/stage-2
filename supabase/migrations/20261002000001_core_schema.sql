-- =====================================================================
-- The Beauty Bar: core schema, Row Level Security and policies
-- Money is in minor units (kobo). Stock is on variants.
-- =====================================================================

create extension if not exists pg_trgm with schema extensions;

-- ---------------------------------------------------------------------
-- Enums
-- ---------------------------------------------------------------------
create type public.user_role      as enum ('customer', 'admin');
create type public.product_status as enum ('draft', 'active', 'archived');
create type public.order_status   as enum ('pending', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled');
create type public.payment_status as enum ('not_required', 'pending', 'paid', 'failed', 'refunded');
create type public.payment_method as enum ('bank_transfer', 'pay_on_delivery', 'online');
create type public.stock_policy   as enum ('deduct_on_place', 'deduct_on_confirm');
create type public.email_status   as enum ('sent', 'failed');

-- ---------------------------------------------------------------------
-- Helper: updated_at
-- ---------------------------------------------------------------------
create or replace function public.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- ---------------------------------------------------------------------
-- Store settings (one row). The app reads these values; do not hard-code them.
-- ---------------------------------------------------------------------
create table public.store_settings (
  id                          boolean primary key default true check (id),
  store_name                  text not null,
  contact_email               text,
  contact_phone               text,
  currency                    char(3) not null default 'NGN',
  delivery_fee                integer not null default 0 check (delivery_fee >= 0),
  low_stock_threshold         integer not null default 5 check (low_stock_threshold >= 0),
  stock_policy                public.stock_policy not null default 'deduct_on_confirm',
  restock_on_cancel           boolean not null default false,
  enabled_payment_methods     public.payment_method[] not null default array['bank_transfer']::public.payment_method[],
  bank_transfer_instructions  text,
  updated_at                  timestamptz not null default now()
);
create trigger store_settings_updated_at before update on public.store_settings
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------
-- Profiles (one row for each auth user)
-- ---------------------------------------------------------------------
create table public.profiles (
  id             uuid primary key references auth.users (id) on delete cascade,
  email          text,
  first_name     text,
  last_name      text,
  phone          text,
  avatar_url     text,
  auth_provider  text,
  role           public.user_role not null default 'customer',
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now()
);
create index profiles_email_idx on public.profiles (lower(email));
create trigger profiles_updated_at before update on public.profiles
  for each row execute function public.set_updated_at();

create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.profiles
    where id = (select auth.uid()) and role = 'admin'
  );
$$;

-- Make a profile when a user signs up (email/password or Google).
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  meta      jsonb := coalesce(new.raw_user_meta_data, '{}'::jsonb);
  full_name text  := coalesce(meta->>'full_name', meta->>'name', '');
begin
  insert into public.profiles (id, email, first_name, last_name, avatar_url, auth_provider)
  values (
    new.id,
    new.email,
    coalesce(nullif(meta->>'first_name', ''), nullif(meta->>'given_name', ''),
             nullif(split_part(full_name, ' ', 1), '')),
    coalesce(nullif(meta->>'last_name', ''), nullif(meta->>'family_name', ''),
             nullif(regexp_replace(full_name, '^\S+\s*', ''), '')),
    coalesce(meta->>'avatar_url', meta->>'picture'),
    coalesce(new.raw_app_meta_data->>'provider', 'email')
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- Keep profiles.email the same as auth.users.email.
create or replace function public.handle_user_email_change()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  update public.profiles set email = new.email where id = new.id;
  return new;
end;
$$;

create trigger on_auth_user_email_changed
  after update of email on auth.users
  for each row when (old.email is distinct from new.email)
  execute function public.handle_user_email_change();

-- ---------------------------------------------------------------------
-- Catalog
-- ---------------------------------------------------------------------
create table public.categories (
  id           uuid primary key default gen_random_uuid(),
  name         text not null,
  slug         text not null unique check (slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$'),
  description  text,
  image_path   text,
  sort_order   integer not null default 0,
  is_visible   boolean not null default true,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);
create trigger categories_updated_at before update on public.categories
  for each row execute function public.set_updated_at();

create table public.products (
  id                uuid primary key default gen_random_uuid(),
  category_id       uuid not null references public.categories (id) on delete restrict,
  name              text not null,
  slug              text not null unique check (slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$'),
  description       text,
  price             integer not null check (price >= 0),          -- base price; a variant can override it
  compare_at_price  integer check (compare_at_price is null or compare_at_price > price),
  status            public.product_status not null default 'draft',
  is_featured       boolean not null default false,
  search_vector     tsvector generated always as (
                      to_tsvector('english'::regconfig, coalesce(name, '') || ' ' || coalesce(description, ''))
                    ) stored,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now()
);
create index products_category_idx      on public.products (category_id);
create index products_status_idx        on public.products (status, is_featured);
create index products_created_idx       on public.products (created_at desc);
create index products_price_idx         on public.products (price);
create index products_search_idx        on public.products using gin (search_vector);
create index products_name_trgm_idx     on public.products using gin (name extensions.gin_trgm_ops);
create trigger products_updated_at before update on public.products
  for each row execute function public.set_updated_at();

create table public.product_images (
  id            uuid primary key default gen_random_uuid(),
  product_id    uuid not null references public.products (id) on delete cascade,
  storage_path  text not null,
  alt_text      text,
  sort_order    integer not null default 0,
  is_primary    boolean not null default false,
  created_at    timestamptz not null default now()
);
create index product_images_product_idx on public.product_images (product_id, sort_order);
create unique index product_images_one_primary on public.product_images (product_id) where is_primary;

create table public.product_variants (
  id              uuid primary key default gen_random_uuid(),
  product_id      uuid not null references public.products (id) on delete cascade,
  name            text not null,                                   -- for example: 14" / Natural Black
  sku             text not null unique,
  options         jsonb not null default '{}'::jsonb check (jsonb_typeof(options) = 'object'),
  price           integer check (price is null or price >= 0),    -- null = use products.price
  stock_quantity  integer not null default 0 check (stock_quantity >= 0),
  is_active       boolean not null default true,
  sort_order      integer not null default 0,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);
create index product_variants_product_idx on public.product_variants (product_id, sort_order);
create trigger product_variants_updated_at before update on public.product_variants
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------
-- Carts and addresses (signed-in users only; guest carts are in the browser)
-- ---------------------------------------------------------------------
create table public.carts (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null unique references auth.users (id) on delete cascade,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);
create trigger carts_updated_at before update on public.carts
  for each row execute function public.set_updated_at();

create table public.cart_items (
  id          uuid primary key default gen_random_uuid(),
  cart_id     uuid not null references public.carts (id) on delete cascade,
  variant_id  uuid not null references public.product_variants (id) on delete cascade,
  quantity    integer not null check (quantity between 1 and 99),
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  unique (cart_id, variant_id)
);
create index cart_items_variant_idx on public.cart_items (variant_id);
create trigger cart_items_updated_at before update on public.cart_items
  for each row execute function public.set_updated_at();

create table public.addresses (
  id                     uuid primary key default gen_random_uuid(),
  user_id                uuid not null references auth.users (id) on delete cascade,
  label                  text,
  address_line           text not null,
  city                   text not null,
  state                  text not null,
  country                text not null default 'Nigeria',
  phone                  text not null,
  delivery_instructions  text,
  is_default             boolean not null default false,
  created_at             timestamptz not null default now(),
  updated_at             timestamptz not null default now()
);
create index addresses_user_idx on public.addresses (user_id);
create unique index addresses_one_default on public.addresses (user_id) where is_default;
create trigger addresses_updated_at before update on public.addresses
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------
-- Orders. Clients never write these tables directly.
-- All writes go through the functions in the next migration.
-- ---------------------------------------------------------------------
create table public.orders (
  id                     uuid primary key default gen_random_uuid(),
  reference              text not null unique,
  user_id                uuid references auth.users (id) on delete set null,   -- null = guest order
  idempotency_key        uuid not null unique,
  customer_first_name    text not null,
  customer_last_name     text not null,
  customer_email         text not null,
  customer_phone         text not null,
  delivery_address       text not null,
  delivery_city          text not null,
  delivery_state         text not null,
  delivery_country       text not null,
  delivery_phone         text not null,
  delivery_instructions  text,
  currency               char(3) not null,
  subtotal               integer not null check (subtotal >= 0),
  delivery_fee           integer not null default 0 check (delivery_fee >= 0),
  total                  integer not null check (total = subtotal + delivery_fee),
  status                 public.order_status not null default 'pending',
  payment_status         public.payment_status not null default 'pending',
  payment_method         public.payment_method not null,
  stock_deducted         boolean not null default false,
  confirmed_at           timestamptz,
  cancelled_at           timestamptz,
  created_at             timestamptz not null default now(),
  updated_at             timestamptz not null default now()
);
create index orders_user_idx      on public.orders (user_id, created_at desc);
create index orders_status_idx    on public.orders (status, created_at desc);
create index orders_created_idx   on public.orders (created_at desc);
create index orders_email_idx     on public.orders (lower(customer_email));
create trigger orders_updated_at before update on public.orders
  for each row execute function public.set_updated_at();

-- Snapshot of the product at the time of purchase (PRD 16).
create table public.order_items (
  id            uuid primary key default gen_random_uuid(),
  order_id      uuid not null references public.orders (id) on delete cascade,
  product_id    uuid references public.products (id) on delete set null,
  variant_id    uuid references public.product_variants (id) on delete set null,
  product_name  text not null,
  variant_name  text not null,
  sku           text,
  unit_price    integer not null check (unit_price >= 0),
  quantity      integer not null check (quantity > 0),
  line_total    integer not null check (line_total = unit_price * quantity),
  created_at    timestamptz not null default now()
);
create index order_items_order_idx on public.order_items (order_id);

create table public.order_status_history (
  id                   uuid primary key default gen_random_uuid(),
  order_id             uuid not null references public.orders (id) on delete cascade,
  from_status          public.order_status,
  to_status            public.order_status,
  from_payment_status  public.payment_status,
  to_payment_status    public.payment_status,
  note                 text,
  changed_by           uuid references auth.users (id) on delete set null,   -- null = system or customer
  created_at           timestamptz not null default now()
);
create index order_status_history_order_idx on public.order_status_history (order_id, created_at);

-- ---------------------------------------------------------------------
-- Payments (ready for a provider; Version 1 uses provider 'manual')
-- ---------------------------------------------------------------------
create table public.payments (
  id                  uuid primary key default gen_random_uuid(),
  order_id            uuid not null references public.orders (id) on delete cascade,
  provider            text not null default 'manual',
  method              public.payment_method not null,
  amount              integer not null check (amount >= 0),
  currency            char(3) not null,
  status              public.payment_status not null default 'pending',
  provider_reference  text,
  raw                 jsonb,
  recorded_by         uuid references auth.users (id) on delete set null,
  paid_at             timestamptz,
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now(),
  unique (provider, provider_reference)
);
create index payments_order_idx on public.payments (order_id, created_at desc);
create trigger payments_updated_at before update on public.payments
  for each row execute function public.set_updated_at();

-- Webhook events from a future provider. Unique event ID = process one time only.
create table public.payment_events (
  id            uuid primary key default gen_random_uuid(),
  provider      text not null,
  event_id      text not null,
  event_type    text,
  payload       jsonb not null,
  received_at   timestamptz not null default now(),
  processed_at  timestamptz,
  error         text,
  unique (provider, event_id)
);

-- ---------------------------------------------------------------------
-- Email log
-- ---------------------------------------------------------------------
create table public.email_events (
  id                   uuid primary key default gen_random_uuid(),
  order_id             uuid references public.orders (id) on delete set null,
  user_id              uuid references auth.users (id) on delete set null,
  template             text not null,
  to_email             text not null,
  status               public.email_status not null,
  provider_message_id  text,
  error                text,
  created_at           timestamptz not null default now()
);
create index email_events_order_idx on public.email_events (order_id);
create index email_events_created_idx on public.email_events (created_at desc);

-- =====================================================================
-- Row Level Security
-- =====================================================================
alter table public.store_settings        enable row level security;
alter table public.profiles              enable row level security;
alter table public.categories            enable row level security;
alter table public.products              enable row level security;
alter table public.product_images        enable row level security;
alter table public.product_variants      enable row level security;
alter table public.carts                 enable row level security;
alter table public.cart_items            enable row level security;
alter table public.addresses             enable row level security;
alter table public.orders                enable row level security;
alter table public.order_items           enable row level security;
alter table public.order_status_history  enable row level security;
alter table public.payments              enable row level security;
alter table public.payment_events        enable row level security;
alter table public.email_events          enable row level security;

-- Store settings: everybody can read; only admins can change.
create policy "store_settings: public read" on public.store_settings
  for select using (true);
create policy "store_settings: admin update" on public.store_settings
  for update using (public.is_admin()) with check (public.is_admin());

-- Profiles: users read and edit their own profile; admins read all.
create policy "profiles: read own or admin" on public.profiles
  for select using (id = (select auth.uid()) or public.is_admin());
create policy "profiles: update own" on public.profiles
  for update using (id = (select auth.uid())) with check (id = (select auth.uid()));
-- Users can change only these columns. They cannot change "role" or "email".
revoke update on public.profiles from anon, authenticated;
grant update (first_name, last_name, phone, avatar_url) on public.profiles to authenticated;

-- Catalog: the public reads published data; admins read and write all.
create policy "categories: public read visible" on public.categories
  for select using (is_visible or public.is_admin());
create policy "categories: admin write" on public.categories
  for all using (public.is_admin()) with check (public.is_admin());

create policy "products: public read active" on public.products
  for select using (status = 'active' or public.is_admin());
create policy "products: admin write" on public.products
  for all using (public.is_admin()) with check (public.is_admin());

create policy "product_images: public read" on public.product_images
  for select using (
    public.is_admin() or exists (
      select 1 from public.products p where p.id = product_id and p.status = 'active'
    )
  );
create policy "product_images: admin write" on public.product_images
  for all using (public.is_admin()) with check (public.is_admin());

create policy "product_variants: public read" on public.product_variants
  for select using (
    public.is_admin() or exists (
      select 1 from public.products p where p.id = product_id and p.status = 'active'
    )
  );
create policy "product_variants: admin write" on public.product_variants
  for all using (public.is_admin()) with check (public.is_admin());

-- Carts: own cart only.
create policy "carts: own" on public.carts
  for all using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
create policy "cart_items: own" on public.cart_items
  for all using (
    exists (select 1 from public.carts c where c.id = cart_id and c.user_id = (select auth.uid()))
  ) with check (
    exists (select 1 from public.carts c where c.id = cart_id and c.user_id = (select auth.uid()))
  );

-- Addresses: own only.
create policy "addresses: own" on public.addresses
  for all using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));

-- Orders and related: read own or admin. No insert/update/delete policies.
create policy "orders: read own or admin" on public.orders
  for select using (user_id = (select auth.uid()) or public.is_admin());

create policy "order_items: read own or admin" on public.order_items
  for select using (
    public.is_admin() or exists (
      select 1 from public.orders o where o.id = order_id and o.user_id = (select auth.uid())
    )
  );

create policy "order_status_history: read own or admin" on public.order_status_history
  for select using (
    public.is_admin() or exists (
      select 1 from public.orders o where o.id = order_id and o.user_id = (select auth.uid())
    )
  );

create policy "payments: read own or admin" on public.payments
  for select using (
    public.is_admin() or exists (
      select 1 from public.orders o where o.id = order_id and o.user_id = (select auth.uid())
    )
  );

create policy "payment_events: admin read" on public.payment_events
  for select using (public.is_admin());

create policy "email_events: admin read" on public.email_events
  for select using (public.is_admin());

-- Trigger functions must not be callable through the API.
revoke all on function public.handle_new_user()          from public, anon, authenticated;
revoke all on function public.handle_user_email_change() from public, anon, authenticated;
