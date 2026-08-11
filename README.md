# Holiday Planner

A small site for tracking holidays: flights, accommodation, and a day-by-day
countdown of tasks and notes in the run-up to departure. Includes a
"surprise" mode that hides a trip's details behind a countdown until a
reveal date — built for the Germany birthday trip.

## Stack

- **Plain HTML/CSS/JS** — no build step, easy to read and extend
- **Supabase** — free hosted Postgres database + auto-generated API
- **GitHub Pages** — free static hosting straight from this repo

## 1. Create the database (Supabase)

1. Go to [supabase.com](https://supabase.com) and sign up free, create a new project.
2. Once it's ready, open **SQL Editor** → **New query**.
3. Paste in the entire contents of `schema.sql` from this repo and click **Run**.
   This creates the `holidays`, `flights`, `stays`, and `day_items` tables.
4. Go to **Project Settings → API**. Copy the **Project URL** and the
   **anon public** key.
5. Open `js/config.js` in this repo and paste them in:
   ```js
   const SUPABASE_URL = "https://xxxxx.supabase.co";
   const SUPABASE_ANON_KEY = "eyJ...";
   ```

## 2. Push to GitHub

1. Create a new repository on GitHub (e.g. `holiday-planner`).
2. Upload all the files in this folder, keeping the folder structure
   (`css/`, `js/`, `index.html`, `trip.html`, `schema.sql`).
3. Commit and push.

## 3. Turn on GitHub Pages

1. In your repo, go to **Settings → Pages**.
2. Under **Build and deployment**, set **Source** to "Deploy from a branch".
3. Choose the `main` branch and `/ (root)` folder. Save.
4. GitHub gives you a live URL, something like:
   `https://yourusername.github.io/holiday-planner/`
5. It usually takes a minute or two to go live.

## Using it

- **Home page** — add a holiday with name, destination, and dates. Tick
  "This is a surprise" to lock the trip page behind a countdown to a reveal
  date/time you choose. Surprise trips **don't appear on the home page at
  all** until their reveal date has passed.
- **Trip page** — add flights and accommodation (click **Edit** on any card
  to change details), and use the day-by-day timeline to add tasks
  (checkable) or notes. The timeline covers both the run-up to departure
  *and* the days of the holiday itself, so you can plan ahead for what
  you'll do while you're away too. Click any task or note's text to edit it.
- **Editing a trip's own details** (name, dates, surprise settings) — click
  **Edit** on the card at the top of its trip page.
- **Managing a surprise trip before it's revealed** — organisers see hidden
  trips on the home page as normal, and can also use the "Manage Trips &
  People" link at the bottom to see everything in one place.

## Accounts and permissions

People sign in with a passwordless email link: enter your email, click the
link that arrives, you're in. No passwords to manage or forget.

Three roles, stored in the database and enforced by row-level security
rules (not just hidden in the interface):

| Role | Can do |
|---|---|
| **View only** | Read everything except unrevealed surprise trips |
| **Can edit** | Add, edit and delete everything |
| **Organiser** | As above, plus sees surprise trips early and sets everyone's role |

New sign-ups default to **View only**. As organiser you promote people from
the **Manage Trips & People** page.

### Setting this up

1. In Supabase, go to **Authentication → Providers** and check **Email** is
   enabled. It is by default.
2. Go to **Authentication → URL Configuration** and set the **Site URL** to
   your GitHub Pages address (e.g. `https://ukmdavis.github.io/Thail-Hol/`).
   Add the same URL under **Redirect URLs**. Sign-in links won't work
   without this.
3. Run `migration-auth.sql` in the SQL Editor.
4. Switch the photo bucket to private: **Storage → trip-photos → Settings**,
   untick **Public bucket**.
5. Deploy the new files, open your site, and sign in with your own email.
6. Back in the SQL Editor, make yourself organiser:
   ```sql
   update profiles set role = 'organiser' where email = 'you@example.com';
   ```
7. Reload. You can now set everyone else's role from the interface — no
   more SQL needed.

Then just share the site link. Anyone who wants access signs in with their
email; you approve what they can do.

## Notes on security

This setup is properly enforced server-side: the database checks who you
are on every read and write, so someone can't bypass the rules by editing
the page in their browser. Unrevealed surprise trips genuinely aren't
sent to non-organisers.

Two things still worth knowing:

- Anyone with the link can *create an account*. They land as View only and
  see trips, so treat the link as semi-private rather than public. If you'd
  rather lock that down, Supabase lets you disable open sign-ups and invite
  people individually from **Authentication → Users**.
- Photos are served via time-limited signed links rather than public URLs,
  so they can't be shared outside the app indefinitely.

## Ideas list (one-time setup)

Run `migration-ideas.sql` once in Supabase → SQL Editor. This lets items
exist without a date.

Each trip page then has an **Ideas — not yet scheduled** section: a place
for things you'd like to do but haven't pinned to a day. Click any idea to
edit it, and use the "Assign to a day" dropdown to move it onto the
timeline. The same dropdown appears when editing an item already on a day,
so you can move it to a different day or send it back to Ideas.

## Adding photos (one-time setup)

1. In Supabase, go to **Storage → New bucket**.
2. Name it exactly `trip-photos` and tick **Public bucket**. Create it.
3. Go to **SQL Editor → New query**, paste in `migration-photos.sql` from
   this repo, and Run. This creates the `photos` table and the upload
   permissions.

After that, each trip page has a **Photos** section: choose one or more
images, add an optional caption, and hit Upload. Click any photo to open
it full size, or the ✕ to delete it. Photos are stored per trip.

Free tier gives you 1GB of storage, which is roughly 300–1000 phone photos
depending on size. Uploads are capped at 10MB per image.

## Extending it

This is intentionally simple so you can keep building on it. Ideas:
- A packing list per trip
- A budget/spend tracker
- Weather widget pulling from a free API
- A simple login so only your family can access it
