# S01: Project, sign-ups off, your login

**Goal:** a Supabase dev project with exactly one user (you) and sign-ups disabled.

**Prerequisites:** a free Supabase account.

Menu names in the console move around from time to time. If a label below differs slightly, look for the closest one.

## Steps

1. **Create the project.** Dashboard, **New project**. Name it `money-tracker-dev`, pick the region closest to you, set a database password and **save it in your password manager** (you rarely need it, but it cannot be shown again). Wait for the project to finish provisioning.
2. **Email sign-in on.** **Authentication**, **Sign In / Providers**, make sure **Email** is enabled. Leave other providers off.
3. **Turn sign-ups off.** On the same page, switch off **Allow new users to sign up**. From now on only a user you create by hand can sign in.
4. **Create your user.** **Authentication**, **Users**, **Add user**, **Create new user**. Enter your email and a strong password, and tick **Auto Confirm User**. This is the only account the app will ever have.
5. **Note the connection values.** **Project Settings**, **API** (or **API Keys**): copy the **Project URL** and the **publishable** key (older projects call it the `anon` key). Keep them in a note for Phase B. Do **not** copy the `service_role` or secret key anywhere near the app.

## Do not

Put any key in the Flutter repo yet. Phase B passes them in at run time, not in committed code.

## Verify

- [x] **Authentication, Users** lists exactly one user: your email.
- [x] The sign-ups switch is off.
- [x] In the SQL Editor, `select id, email from auth.users;` returns one row. Keep this tab or copy the `id`, you will use it in S05.
