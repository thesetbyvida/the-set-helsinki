-- Same Supabase project: yiumnpzvbfkwgnfcrots
create extension if not exists pgcrypto;

create table if not exists public.profiles(
  id uuid primary key references auth.users(id) on delete cascade,
  email text unique,
  full_name text,
  role text not null default 'employee' check(role in ('super_admin','admin','manager','employee')),
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);
alter table public.profiles add column if not exists is_active boolean not null default true;

create table if not exists public.restaurants(
  id uuid primary key default gen_random_uuid(),
  name text not null,
  active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.employees(
  id uuid primary key default gen_random_uuid(),
  name text not null,
  hourly_rate numeric(10,2) not null default 0,
  contract_hours numeric(10,2) not null default 112.5,
  active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.employee_restaurants(
  employee_id uuid references public.employees(id) on delete cascade,
  restaurant_id uuid references public.restaurants(id) on delete cascade,
  display_order integer not null default 999,
  primary key(employee_id,restaurant_id)
);

create table if not exists public.user_restaurants(
  user_id uuid references auth.users(id) on delete cascade,
  restaurant_id uuid references public.restaurants(id) on delete cascade,
  primary key(user_id,restaurant_id)
);

create table if not exists public.shifts(
  id uuid primary key default gen_random_uuid(),
  employee_id uuid references public.employees(id) on delete cascade,
  restaurant_id uuid references public.restaurants(id) on delete cascade,
  work_date date not null,
  start_time time,
  end_time time,
  code text default '',
  color_tag text default '',
  note text default '',
  created_at timestamptz not null default now(),
  unique(employee_id,restaurant_id,work_date)
);

alter table public.profiles enable row level security;
alter table public.restaurants enable row level security;
alter table public.employees enable row level security;
alter table public.employee_restaurants enable row level security;
alter table public.user_restaurants enable row level security;
alter table public.shifts enable row level security;

drop policy if exists profiles_select_authenticated on public.profiles;
drop policy if exists profiles_update_self on public.profiles;
drop policy if exists restaurants_authenticated on public.restaurants;
drop policy if exists employees_authenticated on public.employees;
drop policy if exists employee_restaurants_authenticated on public.employee_restaurants;
drop policy if exists user_restaurants_authenticated on public.user_restaurants;
drop policy if exists shifts_authenticated on public.shifts;

create policy profiles_select_authenticated on public.profiles for select to authenticated using (true);
create policy profiles_update_self on public.profiles for update to authenticated using (id=auth.uid()) with check (id=auth.uid());
create policy restaurants_authenticated on public.restaurants for all to authenticated using (true) with check (true);
create policy employees_authenticated on public.employees for all to authenticated using (true) with check (true);
create policy employee_restaurants_authenticated on public.employee_restaurants for all to authenticated using (true) with check (true);
create policy user_restaurants_authenticated on public.user_restaurants for all to authenticated using (true) with check (true);
create policy shifts_authenticated on public.shifts for all to authenticated using (true) with check (true);

insert into public.restaurants(name,active)
select 'Jackies Kitchen',true
where not exists(select 1 from public.restaurants where name='Jackies Kitchen');

insert into public.profiles(id,email,full_name,role,is_active)
select id,email,'Victor','super_admin',true
from auth.users
where email='vida_paredes@hotmail.com'
on conflict(id) do update set email=excluded.email,full_name='Victor',role='super_admin',is_active=true;
