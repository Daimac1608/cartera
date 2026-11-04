-- =====================================================================
-- CARTERA DE CLIENTES - Base de datos para Supabase
-- Copia TODO este texto, pégalo en Supabase > SQL Editor y dale "Run".
-- =====================================================================

-- Registro de clientes (quedan guardados aunque paguen)
create table if not exists public.clientes (
  id         bigint generated always as identity primary key,
  user_id    uuid not null default auth.uid() references auth.users(id) on delete cascade,
  nombre     text not null,
  telefono   text,
  direccion  text,
  notas      text,
  creado     timestamptz not null default now()
);

create table if not exists public.prestamos (
  id              bigint generated always as identity primary key,
  user_id         uuid not null default auth.uid() references auth.users(id) on delete cascade,
  nombre          text not null,
  telefono        text,
  capital         bigint not null,
  tasa            integer not null,
  deuda           bigint not null,
  fecha_prestamo  date not null,
  fecha_pago      date not null,
  estado          text not null default 'activo',
  fecha_pagado    date,
  notas           text,
  creado          timestamptz not null default now()
);

create table if not exists public.movimientos (
  id           bigint generated always as identity primary key,
  user_id      uuid not null default auth.uid() references auth.users(id) on delete cascade,
  prestamo_id  bigint not null references public.prestamos(id) on delete cascade,
  fecha        date not null,
  tipo         text not null,
  monto        bigint not null,
  detalle      text
);

-- Cada préstamo pertenece a un cliente del registro
alter table public.prestamos add column if not exists cliente_id bigint references public.clientes(id) on delete set null;

create index if not exists movimientos_prestamo_idx on public.movimientos(prestamo_id);
create index if not exists prestamos_cliente_idx on public.prestamos(cliente_id);

-- Seguridad: cada usuario SOLO puede ver y cambiar sus propios datos
alter table public.clientes    enable row level security;
alter table public.prestamos   enable row level security;
alter table public.movimientos enable row level security;

drop policy if exists "solo el dueno" on public.clientes;
create policy "solo el dueno" on public.clientes
  for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists "solo el dueno" on public.prestamos;
create policy "solo el dueno" on public.prestamos
  for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists "solo el dueno" on public.movimientos;
create policy "solo el dueno" on public.movimientos
  for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());
