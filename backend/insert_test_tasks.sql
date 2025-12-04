-- Simple Test Data Insertion
-- This script creates test data in one go - just run it in Supabase SQL Editor

-- Create test data with a consistent tenant_id
WITH test_tenant AS (
  SELECT gen_random_uuid() AS tenant_id, gen_random_uuid() AS owner_id
),
test_lead AS (
  INSERT INTO public.leads (tenant_id, owner_id, email, full_name, stage, source)
  SELECT tenant_id, owner_id, 'test@example.com', 'Test Lead', 'new', 'website'
  FROM test_tenant
  RETURNING id AS lead_id, tenant_id
),
test_application AS (
  INSERT INTO public.applications (tenant_id, lead_id, stage, status)
  SELECT tenant_id, lead_id, 'inquiry', 'open'
  FROM test_lead
  RETURNING id AS application_id, tenant_id
)
-- Insert multiple tasks due today
INSERT INTO public.tasks (tenant_id, application_id, type, status, due_at, title)
SELECT 
  tenant_id,
  application_id,
  type,
  status,
  due_at,
  title
FROM test_application
CROSS JOIN (
  VALUES
    ('call', 'open', NOW() + INTERVAL '1 hour', 'Call client - urgent'),
    ('email', 'open', NOW() + INTERVAL '3 hours', 'Send follow-up email'),
    ('review', 'open', NOW() + INTERVAL '5 hours', 'Review application documents'),
    ('call', 'open', NOW() + INTERVAL '2 hours', 'Schedule consultation call'),
    ('email', 'completed', NOW() + INTERVAL '30 minutes', 'Already sent email') -- This won't show (completed)
) AS task_data(type, status, due_at, title);

-- Verify the data was created
SELECT 
  'Tasks created successfully!' AS message,
  COUNT(*) FILTER (WHERE status != 'completed' AND due_at::date = CURRENT_DATE) AS tasks_due_today,
  COUNT(*) FILTER (WHERE status = 'completed') AS completed_tasks
FROM public.tasks
WHERE created_at > NOW() - INTERVAL '1 minute';

