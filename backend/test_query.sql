-- Test query to see what tasks exist and why they might not show
-- Run this in Supabase SQL Editor to debug

-- Check all tasks
SELECT 
  id,
  type,
  status,
  due_at,
  due_at::date AS due_date,
  CURRENT_DATE AS today_date,
  CASE 
    WHEN due_at::date = CURRENT_DATE THEN 'TODAY ✓'
    WHEN due_at::date < CURRENT_DATE THEN 'PAST'
    ELSE 'FUTURE'
  END AS date_status,
  created_at
FROM public.tasks
ORDER BY created_at DESC;

-- Check tasks that should show (due today, not completed)
SELECT 
  id,
  type,
  status,
  due_at,
  'Should show' AS note
FROM public.tasks
WHERE due_at::date = CURRENT_DATE
  AND status != 'completed'
ORDER BY due_at ASC;

