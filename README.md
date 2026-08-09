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
- **Managing a hidden surprise trip before it's revealed** — go to
  `admin.html` from the link at the bottom of the home page, enter your
  passcode (set in `js/config.js` as `ADMIN_PASSCODE`), and you'll see
  every trip including hidden ones, with links that let you view and edit
  them early without triggering the reveal for anyone else.

## Notes on security

The Supabase anon key is visible in your public code, and the database
policies currently allow anyone with the link to read and write. That's
fine for a private link you only share with family, but don't post the
GitHub Pages URL publicly. If you want a passcode gate later, that's a
quick addition — just ask.

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
