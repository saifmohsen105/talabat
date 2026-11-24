create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.categories (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text not null unique,
  image_url text,
  sort_order integer not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  category_id uuid not null references public.categories(id),
  name text not null,
  slug text not null unique,
  description text not null default '',
  price numeric(10,2) not null check (price >= 0),
  image_url text not null,
  is_featured boolean not null default false,
  is_popular boolean not null default false,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  status text not null default 'pending'
    check (status in ('pending', 'confirmed', 'preparing', 'out_for_delivery', 'delivered', 'cancelled')),
  delivery_address text not null,
  payment_method text not null default 'cash_on_delivery'
    check (payment_method = 'cash_on_delivery'),
  subtotal numeric(10,2) not null check (subtotal >= 0),
  delivery_fee numeric(10,2) not null default 0 check (delivery_fee >= 0),
  total numeric(10,2) not null check (total >= 0),
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete cascade,
  product_id uuid references public.products(id) on delete set null,
  product_name text not null,
  unit_price numeric(10,2) not null check (unit_price >= 0),
  quantity integer not null check (quantity between 1 and 99),
  line_total numeric(10,2) not null check (line_total >= 0)
);

-- The cart is stored locally in the app for this starter. These optional tables
-- are included for a future synchronized cart and are protected by owner RLS.
create table if not exists public.carts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null unique references auth.users(id) on delete cascade,
  is_checkout boolean default false,
  updated_at timestamptz not null default now()
);

create table if not exists public.cart_items (
  id uuid primary key default gen_random_uuid(),
  cart_id uuid not null references public.carts(id) on delete cascade,
  product_id uuid not null references public.products(id) on delete cascade,
  quantity integer not null check (quantity between 1 and 99),
  unique (cart_id, product_id)
);

create index if not exists products_category_id_idx on public.products(category_id);
create index if not exists orders_user_id_created_at_idx on public.orders(user_id, created_at desc);
create index if not exists order_items_order_id_idx on public.order_items(order_id);

alter table public.profiles enable row level security;
alter table public.categories enable row level security;
alter table public.products enable row level security;
alter table public.orders enable row level security;
alter table public.order_items enable row level security;
alter table public.carts enable row level security;
alter table public.cart_items enable row level security;

-- SQL privileges complement RLS; both must allow an operation.
grant select on public.categories, public.products to anon, authenticated;
grant select, insert, update on public.profiles to authenticated;
grant select on public.orders, public.order_items to authenticated;
grant select, insert, update, delete on public.carts, public.cart_items to authenticated;

create policy "Profiles are readable by their owner"
  on public.profiles for select to authenticated using (auth.uid() = id);
create policy "Profiles are insertable by their owner"
  on public.profiles for insert to authenticated with check (auth.uid() = id);
create policy "Profiles are updateable by their owner"
  on public.profiles for update to authenticated using (auth.uid() = id) with check (auth.uid() = id);

create policy "Categories are publicly readable"
  on public.categories for select to anon, authenticated using (is_active = true);
create policy "Products are publicly readable"
  on public.products for select to anon, authenticated using (is_active = true);

create policy "Users can read their own orders"
  on public.orders for select to authenticated using (auth.uid() = user_id);
create policy "Users can read their own order items"
  on public.order_items for select to authenticated
  using (exists (
    select 1 from public.orders o
    where o.id = order_items.order_id and o.user_id = auth.uid()
  ));

create policy "Users manage their own carts"
  on public.carts for all to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);
create policy "Users manage items in their own carts"
  on public.cart_items for all to authenticated
  using (exists (
    select 1 from public.carts c
    where c.id = cart_items.cart_id and c.user_id = auth.uid()
  ))
  with check (exists (
    select 1 from public.carts c
    where c.id = cart_items.cart_id and c.user_id = auth.uid()
  ));

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id, full_name)
  values (new.id, coalesce(new.raw_user_meta_data ->> 'full_name', ''))
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- Prices are read from the database, never trusted from the client.
create or replace function public.place_order(
  p_delivery_address text,
  p_items jsonb
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := auth.uid();
  v_order_id uuid;
  v_subtotal numeric(10,2) := 0;
  v_item jsonb;
  v_product public.products%rowtype;
  v_quantity integer;
  v_line_total numeric(10,2);
begin
  if v_user_id is null then
    raise exception 'You must be signed in to place an order.';
  end if;
  if length(trim(coalesce(p_delivery_address, ''))) < 10 then
    raise exception 'Please provide a complete delivery address.';
  end if;
  if jsonb_typeof(p_items) <> 'array' or jsonb_array_length(p_items) = 0 then
    raise exception 'Your cart is empty.';
  end if;

  for v_item in select value from jsonb_array_elements(p_items)
  loop
    v_quantity := (v_item ->> 'quantity')::integer;
    if v_quantity < 1 or v_quantity > 99 then
      raise exception 'Invalid item quantity.';
    end if;

    select * into v_product
    from public.products
    where id = (v_item ->> 'product_id')::uuid and is_active = true;

    if not found then
      raise exception 'A product in your cart is no longer available.';
    end if;

    v_subtotal := v_subtotal + (v_product.price * v_quantity);
  end loop;

  insert into public.orders (
    user_id, delivery_address, subtotal, delivery_fee, total
  )
  values (v_user_id, trim(p_delivery_address), v_subtotal, 0, v_subtotal)
  returning id into v_order_id;

  for v_item in select value from jsonb_array_elements(p_items)
  loop
    v_quantity := (v_item ->> 'quantity')::integer;
    select * into v_product
    from public.products
    where id = (v_item ->> 'product_id')::uuid and is_active = true;

    v_line_total := v_product.price * v_quantity;
    insert into public.order_items (
      order_id, product_id, product_name, unit_price, quantity, line_total
    )
    values (
      v_order_id, v_product.id, v_product.name, v_product.price, v_quantity, v_line_total
    );
  end loop;

  return v_order_id;
end;
$$;

revoke all on function public.place_order(text, jsonb) from public;
grant execute on function public.place_order(text, jsonb) to authenticated;
