-- LearnLynk Tech Test - Task 1: Schema
-- Fill in the definitions for leads, applications, tasks as per README.

create extension if not exists "pgcrypto";

-- Supporting tables (assumed to exist per README requirements for RLS)
-- Users table
create table if not exists public.users (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null,
  role text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists users_tenant_id_idx on public.users(tenant_id);
create index if not exists users_role_idx on public.users(role);

-- Teams table
create table if not exists public.teams (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists teams_tenant_id_idx on public.teams(tenant_id);

-- User-Teams junction table
create table if not exists public.user_teams (
  user_id uuid not null references public.users(id) on delete cascade,
  team_id uuid not null references public.teams(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, team_id)
);

create index if not exists user_teams_user_id_idx on public.user_teams(user_id);
create index if not exists user_teams_team_id_idx on public.user_teams(team_id);

-- Leads table
create table if not exists public.leads (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null,
  owner_id uuid not null,
  email text,
  phone text,
  full_name text,
  stage text not null default 'new',
  source text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Indexes for leads
create index if not exists leads_tenant_id_idx on public.leads(tenant_id);
create index if not exists leads_owner_id_idx on public.leads(owner_id);
create index if not exists leads_stage_idx on public.leads(stage);


-- Applications table
create table if not exists public.applications (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null,
  lead_id uuid not null references public.leads(id) on delete cascade,
  program_id uuid,
  intake_id uuid,
  stage text not null default 'inquiry',
  status text not null default 'open',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Indexes for applications
create index if not exists applications_tenant_id_idx on public.applications(tenant_id);
create index if not exists applications_lead_id_idx on public.applications(lead_id);


-- Tasks table
create table if not exists public.tasks (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null,
  application_id uuid not null references public.applications(id) on delete cascade,
  title text,
  type text not null,
  status text not null default 'open',
  due_at timestamptz not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Constraints for tasks (drop if exists first to allow re-running)
alter table public.tasks drop constraint if exists tasks_type_check;
alter table public.tasks add constraint tasks_type_check check (type in ('call', 'email', 'review'));

alter table public.tasks drop constraint if exists tasks_due_at_check;
alter table public.tasks add constraint tasks_due_at_check check (due_at >= created_at);

-- Indexes for tasks
create index if not exists tasks_tenant_id_idx on public.tasks(tenant_id);
create index if not exists tasks_due_at_idx on public.tasks(due_at);
create index if not exists tasks_status_idx on public.tasks(status);
