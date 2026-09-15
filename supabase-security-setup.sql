-- ══════════════════════════════════════════════
-- RIJAN WEBSITE — Analytics + Admin Security Setup
-- Run in: Supabase Dashboard → SQL Editor
-- (Run AFTER supabase-setup.sql)
-- ══════════════════════════════════════════════

-- 1. PAGE VIEWS (real visitor tracking for the public site)
CREATE TABLE IF NOT EXISTS page_views (
  id          bigserial PRIMARY KEY,
  session_id  text NOT NULL,          -- random id stored in visitor's browser localStorage
  page        text NOT NULL,          -- e.g. '/', '#blog', '#contact'
  referrer    text DEFAULT NULL,
  user_agent  text DEFAULT NULL,
  device_type text DEFAULT NULL,      -- mobile / tablet / desktop
  browser     text DEFAULT NULL,
  created_at  timestamptz DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_pageviews_created ON page_views(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_pageviews_session ON page_views(session_id);

-- 2. ADMIN SESSIONS (one row per device/browser that has logged into admin.html)
CREATE TABLE IF NOT EXISTS admin_sessions (
  id            bigserial PRIMARY KEY,
  session_token text NOT NULL UNIQUE,
  device_name   text DEFAULT NULL,    -- e.g. "iPhone · Safari"
  browser       text DEFAULT NULL,
  os            text DEFAULT NULL,
  user_agent    text DEFAULT NULL,
  ip_address    text DEFAULT NULL,    -- best-effort, from a public IP lookup, NOT guaranteed accurate
  login_at      timestamptz DEFAULT now(),
  last_active   timestamptz DEFAULT now(),
  revoked       boolean DEFAULT false,
  revoked_at    timestamptz DEFAULT NULL
);
CREATE INDEX IF NOT EXISTS idx_sessions_token   ON admin_sessions(session_token);
CREATE INDEX IF NOT EXISTS idx_sessions_revoked ON admin_sessions(revoked);

-- 3. ADMIN ACTIVITY LOG (what happened, from which session)
CREATE TABLE IF NOT EXISTS admin_activity_log (
  id            bigserial PRIMARY KEY,
  session_token text DEFAULT NULL,
  action        text NOT NULL,        -- 'login','logout','blog_create','message_delete', etc.
  detail        text DEFAULT NULL,
  created_at    timestamptz DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_activity_created ON admin_activity_log(created_at DESC);

-- ✅ Verification
SELECT 'page_views' as tbl, count(*) from page_views
UNION ALL SELECT 'admin_sessions', count(*) from admin_sessions
UNION ALL SELECT 'admin_activity_log', count(*) from admin_activity_log;

-- ══════════════════════════════════════════════
-- ⚠️ IMPORTANT — READ THIS
-- ══════════════════════════════════════════════
-- Your site currently has NO Row Level Security (RLS) and admin.html
-- authenticates using the same public "anon" key that index.html uses.
-- That means:
--   • Anyone who opens dev tools can call this Supabase project directly
--     with the anon key and read/write ANY table, including the new
--     admin_sessions and admin_activity_log tables below.
--   • The "Logout all devices" and "Revoke session" buttons in this
--     update only stop a device the NEXT time it checks in — they
--     cannot force an already-open tab to close immediately, and they
--     don't stop someone who has the anon key from bypassing the UI
--     entirely and querying Supabase directly.
--
-- This update makes admin sessions/activity trackable and revocable
-- through the dashboard UI, which is a real improvement over "log in once,
-- stay in forever" — but it is UI-level protection, not database-level
-- protection. Closing that gap for real requires moving admin auth to
-- Supabase Auth (a real login system) plus RLS policies that check the
-- logged-in user's identity, not just the anon key. That's a separate,
-- larger migration — say the word and it can be done as its own task.
