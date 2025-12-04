-- Quick Test Data - Simple version
-- This creates test data with a single tenant_id that you can reuse

-- Step 1: Set your tenant_id (replace with your actual tenant_id from Supabase auth.users or your system)
-- For testing, you can generate one: SELECT gen_random_uuid();

-- Step 2: Insert a lead
INSERT INTO public.leads (tenant_id, owner_id, email, full_name, stage, source)
VALUES (
  gen_random_uuid(), -- Replace with your tenant_id if you have one
  gen_random_uuid(),
  'john.doe@example.com',
  'John Doe',
  'new',
  'website'
)
RETURNING id, tenant_id;

-- Step 3: Copy the lead_id and tenant_id from above, then insert application
-- Replace 'LEAD_ID_FROM_ABOVE' with the id returned above
INSERT INTO public.applications (tenant_id, lead_id, stage, status)
VALUES (
  'TENANT_ID_FROM_ABOVE'::uuid, -- Replace with tenant_id from lead insert
  'LEAD_ID_FROM_ABOVE'::uuid,   -- Replace with id from lead insert
  'inquiry',
  'open'
)
RETURNING id, tenant_id;

-- Step 4: Copy the application_id and tenant_id, then insert tasks
-- Replace 'APPLICATION_ID_FROM_ABOVE' and 'TENANT_ID_FROM_ABOVE' with values from above
INSERT INTO public.tasks (tenant_id, application_id, type, status, due_at, title)
VALUES
  -- Task due today in 1 hour
  ('TENANT_ID_FROM_ABOVE'::uuid, 'APPLICATION_ID_FROM_ABOVE'::uuid, 'call', 'open', NOW() + INTERVAL '1 hour', 'Call client'),
  -- Task due today in 3 hours
  ('TENANT_ID_FROM_ABOVE'::uuid, 'APPLICATION_ID_FROM_ABOVE'::uuid, 'email', 'open', NOW() + INTERVAL '3 hours', 'Send email'),
  -- Task due today in 6 hours
  ('TENANT_ID_FROM_ABOVE'::uuid, 'APPLICATION_ID_FROM_ABOVE'::uuid, 'review', 'open', NOW() + INTERVAL '6 hours', 'Review documents'),
  -- Completed task (won't show in today's list)
  ('TENANT_ID_FROM_ABOVE'::uuid, 'APPLICATION_ID_FROM_ABOVE'::uuid, 'email', 'completed', NOW() + INTERVAL '2 hours', 'Already done');

