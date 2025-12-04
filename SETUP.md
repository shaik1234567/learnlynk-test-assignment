# Setup Guide

This guide will help you set up and run the LearnLynk technical assessment project.

## Prerequisites

- Node.js (v18 or higher)
- npm or yarn
- A Supabase account (free tier works fine)
- Supabase CLI (for deploying edge functions)

## Step 1: Set Up Supabase Project

1. Go to [supabase.com](https://supabase.com) and sign up/login
2. Create a new project (or use an existing one)
3. Wait for the project to be fully provisioned

## Step 2: Run Database Schema and RLS Policies

1. Go to your Supabase project dashboard
2. Navigate to **SQL Editor**
3. Copy and paste the contents of `backend/schema.sql` and run it
4. Copy and paste the contents of `backend/rls_policies.sql` and run it

Alternatively, you can use the Supabase CLI:
```bash
# Install Supabase CLI if you haven't
npm install -g supabase

# Login to Supabase
supabase login

# Link your project
supabase link --project-ref your-project-ref

# Run the SQL files
supabase db push
```

## Step 3: Get Your Supabase Credentials

1. In your Supabase dashboard, go to **Settings** → **API**
2. You'll need:
   - **Project URL** (SUPABASE_URL)
   - **anon/public key** (NEXT_PUBLIC_SUPABASE_ANON_KEY)
   - **service_role key** (SUPABASE_SERVICE_ROLE_KEY) - Keep this secret!

## Step 4: Set Up Frontend Environment Variables

1. Navigate to the `frontend` directory:
   ```bash
   cd frontend
   ```

2. Create a `.env.local` file:
   ```bash
   # Windows PowerShell
   New-Item .env.local

   # Or create manually
   ```

3. Add the following to `.env.local`:
   ```env
   NEXT_PUBLIC_SUPABASE_URL=your_supabase_project_url
   NEXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key
   ```

## Step 5: Install Frontend Dependencies

```bash
cd frontend
npm install
```

## Step 6: Run the Frontend

```bash
npm run dev
```

The frontend will be available at `http://localhost:3000`

Visit `http://localhost:3000/dashboard/today` to see the tasks dashboard.

## Step 7: Deploy Edge Function (Optional - for testing)

To test the edge function, you need to deploy it to Supabase:

1. Install Supabase CLI (if not already installed):
   ```bash
   npm install -g supabase
   ```

2. Login and link your project:
   ```bash
   supabase login
   supabase link --project-ref your-project-ref
   ```

3. Deploy the edge function:
   ```bash
   supabase functions deploy create-task
   ```

4. Set environment variables for the edge function:
   ```bash
   supabase secrets set SUPABASE_URL=your_supabase_project_url
   supabase secrets set SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
   ```

## Testing the Edge Function

Once deployed, you can test it using curl or Postman:

```bash
curl -X POST https://your-project-ref.supabase.co/functions/v1/create-task \
  -H "Authorization: Bearer your_anon_key" \
  -H "Content-Type: application/json" \
  -d '{
    "application_id": "your-application-uuid",
    "task_type": "call",
    "due_at": "2025-12-31T12:00:00Z"
  }'
```

## Creating Test Data

To test the application, you'll need to create some test data in Supabase:

1. Go to **Table Editor** in your Supabase dashboard
2. Create a lead (in `leads` table)
3. Create an application (in `applications` table) linked to that lead
4. Create tasks (in `tasks` table) linked to that application

Or use SQL in the SQL Editor:

```sql
-- Insert a test lead
INSERT INTO public.leads (tenant_id, owner_id, email, full_name, stage)
VALUES (
  gen_random_uuid(), -- Replace with actual tenant_id
  gen_random_uuid(), -- Replace with actual owner_id
  'test@example.com',
  'Test Lead',
  'new'
);

-- Insert a test application (replace lead_id with the id from above)
INSERT INTO public.applications (tenant_id, lead_id, stage, status)
VALUES (
  gen_random_uuid(), -- Replace with actual tenant_id
  'lead-id-here',    -- Replace with lead id
  'inquiry',
  'open'
);

-- Insert a test task due today (replace application_id with the id from above)
INSERT INTO public.tasks (tenant_id, application_id, type, status, due_at)
VALUES (
  gen_random_uuid(), -- Replace with actual tenant_id
  'application-id-here', -- Replace with application id
  'call',
  'open',
  NOW() + INTERVAL '2 hours'
);
```

## Troubleshooting

### Frontend can't connect to Supabase
- Check that `.env.local` has the correct values
- Make sure the environment variables start with `NEXT_PUBLIC_`
- Restart the Next.js dev server after changing `.env.local`

### Edge function errors
- Verify the service role key is set correctly
- Check that the `tasks` table exists and has the correct schema
- Ensure the application_id exists in the `applications` table

### RLS policies blocking access
- Make sure you're authenticated (if testing with user context)
- Check that the JWT contains the required claims (user_id, role, tenant_id)
- For testing, you might temporarily disable RLS or use the service role key

## Notes

- The edge function uses the service role key to bypass RLS
- The frontend uses the anon key, so RLS policies will apply
- For local development, you may need to set up authentication to test RLS policies properly

