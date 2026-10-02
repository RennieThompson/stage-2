-- Run this ONE time in the Supabase SQL Editor, AFTER the admin has
-- registered on the site and confirmed the email.
update public.profiles
set role = 'admin'
where lower(email) = lower('ibiyemi2samson@gmail.com');

-- Check: this must return one row with role = admin.
select id, email, role from public.profiles where role = 'admin';
