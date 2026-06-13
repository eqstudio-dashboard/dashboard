-- ============================================================
-- EQStudio Affiliate Dashboard — Supabase Database Schema
-- Run this in your Supabase SQL Editor
-- ============================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================
-- AFFILIATORS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS affiliators (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  promo_code TEXT NOT NULL UNIQUE,
  contact TEXT,
  status TEXT DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
  code_uses INTEGER DEFAULT 0,
  total_commission DECIMAL(10,2) DEFAULT 0,
  last_active TIMESTAMPTZ,
  onboarded BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- COMMISSION HISTORY TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS commission_history (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  affiliator_id UUID REFERENCES affiliators(id) ON DELETE CASCADE,
  amount DECIMAL(10,2) NOT NULL,
  note TEXT,
  payment_date TIMESTAMPTZ DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- ANNOUNCEMENTS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS announcements (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  pinned BOOLEAN DEFAULT FALSE,
  created_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- PROMO CODE USAGE LOG
-- ============================================================
CREATE TABLE IF NOT EXISTS promo_usage_log (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  affiliator_id UUID REFERENCES affiliators(id) ON DELETE CASCADE,
  used_at TIMESTAMPTZ DEFAULT NOW(),
  note TEXT
);

-- ============================================================
-- ADMIN SETTINGS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS admin_settings (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  key TEXT UNIQUE NOT NULL,
  value TEXT,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================

ALTER TABLE affiliators ENABLE ROW LEVEL SECURITY;
ALTER TABLE commission_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE announcements ENABLE ROW LEVEL SECURITY;
ALTER TABLE promo_usage_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE admin_settings ENABLE ROW LEVEL SECURITY;

-- Helper function: is current user admin?
CREATE OR REPLACE FUNCTION is_admin()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN (SELECT email FROM auth.users WHERE id = auth.uid()) = 'admin@eqstudio.com';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- AFFILIATORS policies
CREATE POLICY "Admin sees all affiliators" ON affiliators
  FOR ALL USING (is_admin());

CREATE POLICY "Affiliator sees own record" ON affiliators
  FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Affiliator updates own contact" ON affiliators
  FOR UPDATE USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- COMMISSION HISTORY policies
CREATE POLICY "Admin sees all commission history" ON commission_history
  FOR ALL USING (is_admin());

CREATE POLICY "Affiliator sees own commission history" ON commission_history
  FOR SELECT USING (
    affiliator_id IN (SELECT id FROM affiliators WHERE user_id = auth.uid())
  );

-- ANNOUNCEMENTS policies
CREATE POLICY "Admin manages announcements" ON announcements
  FOR ALL USING (is_admin());

CREATE POLICY "Affiliators read announcements" ON announcements
  FOR SELECT USING (auth.uid() IS NOT NULL);

-- PROMO USAGE LOG policies
CREATE POLICY "Admin sees all promo usage" ON promo_usage_log
  FOR ALL USING (is_admin());

CREATE POLICY "Affiliator sees own promo usage" ON promo_usage_log
  FOR SELECT USING (
    affiliator_id IN (SELECT id FROM affiliators WHERE user_id = auth.uid())
  );

-- ADMIN SETTINGS policies
CREATE POLICY "Admin manages settings" ON admin_settings
  FOR ALL USING (is_admin());

-- ============================================================
-- UPDATED_AT TRIGGER
-- ============================================================
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER affiliators_updated_at
  BEFORE UPDATE ON affiliators
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER announcements_updated_at
  BEFORE UPDATE ON announcements
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ============================================================
-- SAMPLE DATA (optional — remove in production)
-- ============================================================
-- Insert a welcome announcement
INSERT INTO announcements (title, content, pinned)
VALUES (
  'Welcome to EQStudio Affiliate Portal 🎉',
  'Thank you for joining the EQStudio affiliate program. Your promo code is now active. Share it with your audience and start earning commissions. Check back here regularly for tips, updates, and your latest stats.',
  TRUE
);
