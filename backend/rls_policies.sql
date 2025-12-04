-- LearnLynk Tech Test - Task 2: RLS Policies on leads

alter table public.leads enable row level security;

-- Example helper: assume JWT has tenant_id, user_id, role.
-- You can use: current_setting('request.jwt.claims', true)::jsonb

-- Drop existing policies if they exist (allows re-running this script)
drop policy if exists "leads_select_policy" on public.leads;
drop policy if exists "leads_insert_policy" on public.leads;

-- SELECT policy: counselors see leads they own or assigned to their teams, admins see all tenant leads
create policy "leads_select_policy"
on public.leads
for select
using (
  -- Admin can see all leads in their tenant
  (
    (current_setting('request.jwt.claims', true)::jsonb->>'role') = 'admin' AND
    tenant_id = ((current_setting('request.jwt.claims', true)::jsonb->>'tenant_id'))::uuid
  )
  OR
  -- Counselor can see leads they own
  (
    (current_setting('request.jwt.claims', true)::jsonb->>'role') = 'counselor' AND
    owner_id = ((current_setting('request.jwt.claims', true)::jsonb->>'user_id'))::uuid AND
    tenant_id = ((current_setting('request.jwt.claims', true)::jsonb->>'tenant_id'))::uuid
  )
  OR
  -- Counselor can see leads assigned to teams they belong to
  (
    (current_setting('request.jwt.claims', true)::jsonb->>'role') = 'counselor' AND
    tenant_id = ((current_setting('request.jwt.claims', true)::jsonb->>'tenant_id'))::uuid AND
    EXISTS (
      SELECT 1
      FROM public.user_teams ut
      JOIN public.teams t ON ut.team_id = t.id
      WHERE ut.user_id = ((current_setting('request.jwt.claims', true)::jsonb->>'user_id'))::uuid
        AND t.tenant_id = ((current_setting('request.jwt.claims', true)::jsonb->>'tenant_id'))::uuid
        AND leads.owner_id IN (
          SELECT ut2.user_id
          FROM public.user_teams ut2
          WHERE ut2.team_id = t.id
        )
    )
  )
);

-- INSERT policy: counselors and admins can insert leads for their tenant
create policy "leads_insert_policy"
on public.leads
for insert
with check (
  (
    (current_setting('request.jwt.claims', true)::jsonb->>'role') IN ('counselor', 'admin') AND
    tenant_id = ((current_setting('request.jwt.claims', true)::jsonb->>'tenant_id'))::uuid
  )
);
