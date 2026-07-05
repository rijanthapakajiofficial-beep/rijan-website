-- ══════════════════════════════════════════════
-- RIJAN WEBSITE — Complete Supabase Setup
-- Run in: Supabase Dashboard → SQL Editor
-- ══════════════════════════════════════════════

-- 1. SITE SETTINGS TABLE (website customize ko lagi)
CREATE TABLE IF NOT EXISTS site_settings (
  id            serial PRIMARY KEY,
  hero_name_line1  text DEFAULT 'Rijan',
  hero_name_line2  text DEFAULT 'Thapa Kaji',
  hero_badge       text DEFAULT 'Welcome to my world',
  hero_subtitle    text DEFAULT 'Nepal · Music · Mountains',
  hero_desc        text DEFAULT 'A creative soul from the Himalayas — chasing melodies, summits, and moments worth remembering.',
  bio_title        text DEFAULT 'A passionate soul<br/>from the mountains',
  bio_text         text DEFAULT '<p>Hey there! I''m <strong>Rijan Thapa Kaji</strong> — a music-loving creative from Nepal. 🇳🇵</p>',
  bio_photo        text DEFAULT 'https://res.cloudinary.com/dvd5bjlpa/image/upload/c_fill,g_face,ar_3:4,w_600,q_auto,f_auto/v1778823369/rijan-private/IMG_4500_mojoe5.jpg',
  nav_logo         text DEFAULT 'RTK',
  footer_logo      text DEFAULT 'Rijan Thapa Kaji',
  footer_copy      text DEFAULT '© 2025 · Made with ❤️ from Nepal 🇳🇵',
  accent_color     text DEFAULT '#c9a96e',
  updated_at       timestamptz DEFAULT now()
);

-- Insert default row if empty
INSERT INTO site_settings (id) VALUES (1) ON CONFLICT (id) DO NOTHING;

-- 2. FILES TABLE (if not exists)
CREATE TABLE IF NOT EXISTS files (
  id            serial PRIMARY KEY,
  name          text NOT NULL,
  url           text NOT NULL,
  type          text DEFAULT '',
  size          bigint DEFAULT 0,
  resource_type text DEFAULT 'image',
  folder_name   text DEFAULT NULL,
  folder_path   text DEFAULT NULL,
  ai_tags       text DEFAULT NULL,
  custom_tags   text DEFAULT NULL,
  color_label   text DEFAULT NULL,
  trashed       boolean DEFAULT false,
  trashed_at    timestamptz DEFAULT NULL,
  uploaded_at   timestamptz DEFAULT now()
);

-- 3. MESSAGES TABLE (if not exists)
CREATE TABLE IF NOT EXISTS messages (
  id          serial PRIMARY KEY,
  from_name   text,
  from_email  text,
  reason      text,
  message     text,
  replied     boolean DEFAULT false,
  reply_text  text DEFAULT NULL,
  replied_at  timestamptz DEFAULT NULL,
  created_at  timestamptz DEFAULT now()
);

-- 4. BLOG POSTS TABLE (if not exists)
CREATE TABLE IF NOT EXISTS blog_posts (
  id          serial PRIMARY KEY,
  title       text DEFAULT '',
  content     text DEFAULT '',
  category    text DEFAULT 'General',
  emoji       text DEFAULT '✍️',
  media_url   text DEFAULT NULL,
  media_type  text DEFAULT NULL,
  attachments text DEFAULT NULL,
  created_at  timestamptz DEFAULT now()
);

-- 5. SONGS TABLE (if not exists)
CREATE TABLE IF NOT EXISTS songs (
  id         serial PRIMARY KEY,
  title      text NOT NULL,
  artist     text DEFAULT 'Rijan Thapa Kaji',
  emoji      text DEFAULT '🎵',
  url        text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- 6. INDEXES for performance
CREATE INDEX IF NOT EXISTS idx_files_trashed    ON files(trashed);
CREATE INDEX IF NOT EXISTS idx_files_folder     ON files(folder_path);
CREATE INDEX IF NOT EXISTS idx_messages_replied ON messages(replied);
CREATE INDEX IF NOT EXISTS idx_blogs_created    ON blog_posts(created_at DESC);

-- ✅ Verification
SELECT 'site_settings' as tbl, count(*) from site_settings
UNION ALL SELECT 'files', count(*) from files
UNION ALL SELECT 'messages', count(*) from messages
UNION ALL SELECT 'blog_posts', count(*) from blog_posts
UNION ALL SELECT 'songs', count(*) from songs;

-- ══════════════════════════════════════════════
-- ADD GLOBAL ADMIN CREDENTIALS COLUMNS
-- Run this in Supabase SQL Editor
-- ══════════════════════════════════════════════

ALTER TABLE site_settings ADD COLUMN IF NOT EXISTS admin_username text DEFAULT 'rijan';
ALTER TABLE site_settings ADD COLUMN IF NOT EXISTS admin_password text DEFAULT 'rijan2025';

-- Update existing row with defaults
UPDATE site_settings SET
  admin_username = COALESCE(admin_username, 'rijan'),
  admin_password = COALESCE(admin_password, 'rijan2025')
WHERE id = 1;
