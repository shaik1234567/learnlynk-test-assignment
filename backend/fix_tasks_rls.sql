-- Fix: Allow public access to tasks table for testing
-- Since tasks table doesn't have RLS enabled, this shouldn't be needed
-- But let's make sure RLS is disabled on tasks for testing

-- Check if RLS is enabled on tasks
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' AND tablename = 'tasks';

-- Disable RLS on tasks table (if it was enabled)
ALTER TABLE public.tasks DISABLE ROW LEVEL SECURITY;

-- Verify it's disabled
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' AND tablename = 'tasks';

-- Also check what tasks exist and their due_at values
SELECT 
  id,
  type,
  status,
  due_at,
  due_at::date AS due_date,
  CURRENT_DATE AS today,
  CASE 
    WHEN due_at::date = CURRENT_DATE THEN 'TODAY'
    WHEN due_at::date < CURRENT_DATE THEN 'PAST'
    ELSE 'FUTURE'
  END AS date_status
FROM public.tasks
ORDER BY created_at DESC
LIMIT 10;

