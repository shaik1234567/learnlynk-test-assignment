-- Test Data for LearnLynk Tech Test
-- Run this after running schema.sql and rls_policies.sql

-- First, create a test tenant_id (you can replace this with your actual tenant_id)
DO $$
DECLARE
  test_tenant_id uuid := gen_random_uuid();
  test_owner_id uuid := gen_random_uuid();
  test_lead_id uuid;
  test_application_id uuid;
BEGIN
  -- Insert a test lead
  INSERT INTO public.leads (tenant_id, owner_id, email, full_name, stage, source)
  VALUES (
    test_tenant_id,
    test_owner_id,
    'test.lead@example.com',
    'Test Lead',
    'new',
    'website'
  )
  RETURNING id INTO test_lead_id;

  -- Insert a test application linked to the lead
  INSERT INTO public.applications (tenant_id, lead_id, stage, status)
  VALUES (
    test_tenant_id,
    test_lead_id,
    'inquiry',
    'open'
  )
  RETURNING id INTO test_application_id;

  -- Insert tasks due today (various times)
  INSERT INTO public.tasks (tenant_id, application_id, type, status, due_at, title)
  VALUES
    -- Task due in 2 hours (today)
    (test_tenant_id, test_application_id, 'call', 'open', NOW() + INTERVAL '2 hours', 'Call client about application'),
    -- Task due in 5 hours (today)
    (test_tenant_id, test_application_id, 'email', 'open', NOW() + INTERVAL '5 hours', 'Send follow-up email'),
    -- Task due in 1 hour (today)
    (test_tenant_id, test_application_id, 'review', 'open', NOW() + INTERVAL '1 hour', 'Review application documents'),
    -- Task due tomorrow (for testing filtering)
    (test_tenant_id, test_application_id, 'call', 'open', NOW() + INTERVAL '1 day', 'Follow-up call tomorrow'),
    -- Completed task (should not show)
    (test_tenant_id, test_application_id, 'email', 'completed', NOW() + INTERVAL '3 hours', 'Already completed email');

  RAISE NOTICE 'Test data created successfully!';
  RAISE NOTICE 'Tenant ID: %', test_tenant_id;
  RAISE NOTICE 'Lead ID: %', test_lead_id;
  RAISE NOTICE 'Application ID: %', test_application_id;
END $$;

-- Alternative: If you want to use a specific tenant_id, replace the above with:
-- Replace 'YOUR_TENANT_ID_HERE' with your actual tenant_id UUID

/*
-- Example with specific tenant_id:
INSERT INTO public.leads (tenant_id, owner_id, email, full_name, stage, source)
VALUES (
  'YOUR_TENANT_ID_HERE'::uuid,
  gen_random_uuid(),
  'test.lead@example.com',
  'Test Lead',
  'new',
  'website'
);

-- Then get the lead_id and application_id from the inserts above
-- and insert tasks with the same tenant_id
*/

