-- Acades AI - Supabase Database Schema
-- Run this in Supabase SQL Editor to set up the database

-- ============================================
-- USER PROFILES TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS user_profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  username TEXT NOT NULL UNIQUE,
  phone_number TEXT UNIQUE,
  email TEXT,
  farmer_profile JSONB NOT NULL DEFAULT '{
    "crops": [],
    "district": "",
    "landSize": "",
    "gender": ""
  }',
  profile_image_url TEXT,
  bio TEXT,
  location TEXT,
  is_verified BOOLEAN DEFAULT FALSE,
  is_active BOOLEAN DEFAULT TRUE,
  last_login_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
);

-- ============================================
-- FARM RECORDS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS farm_records (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
  crop_type TEXT NOT NULL,
  variety TEXT,
  planting_date DATE,
  harvest_date DATE,
  yield_amount DECIMAL(10, 2),
  yield_unit TEXT DEFAULT 'kg',
  field_size_acres DECIMAL(10, 2),
  fertilizer_used TEXT,
  pesticide_used TEXT,
  irrigation_method TEXT,
  weather_notes TEXT,
  general_notes TEXT,
  images JSONB DEFAULT '[]',
  status TEXT DEFAULT 'active' CHECK (status IN ('active', 'archived', 'completed')),
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
);

-- ============================================
-- WEATHER DATA TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS weather_data (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
  district TEXT NOT NULL,
  temperature_min DECIMAL(5, 2),
  temperature_max DECIMAL(5, 2),
  rainfall_mm DECIMAL(8, 2),
  humidity_percent DECIMAL(5, 2),
  wind_speed_kmh DECIMAL(6, 2),
  weather_condition TEXT,
  forecast_date DATE,
  created_at TIMESTAMP DEFAULT now()
);

-- ============================================
-- CHAT SESSIONS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS chat_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
  title TEXT,
  topic TEXT,
  context JSONB DEFAULT '{}',
  is_archived BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
);

-- ============================================
-- CHAT MESSAGES TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS chat_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id UUID NOT NULL REFERENCES chat_sessions(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
  role TEXT NOT NULL CHECK (role IN ('user', 'assistant', 'system')),
  content TEXT NOT NULL,
  image_urls JSONB DEFAULT '[]',
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMP DEFAULT now()
);

-- ============================================
-- AI RECOMMENDATIONS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS ai_recommendations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
  farm_record_id UUID REFERENCES farm_records(id) ON DELETE SET NULL,
  recommendation_type TEXT NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  action_items JSONB DEFAULT '[]',
  priority TEXT DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high')),
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT now(),
  expires_at TIMESTAMP
);

-- ============================================
-- NOTIFICATIONS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
  type TEXT NOT NULL,
  title TEXT NOT NULL,
  message TEXT,
  data JSONB DEFAULT '{}',
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT now()
);

-- ============================================
-- ACTIVITY LOG TABLE (Audit Trail)
-- ============================================
CREATE TABLE IF NOT EXISTS activity_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES user_profiles(id) ON DELETE SET NULL,
  action TEXT NOT NULL,
  table_name TEXT,
  record_id UUID,
  old_values JSONB,
  new_values JSONB,
  ip_address TEXT,
  user_agent TEXT,
  created_at TIMESTAMP DEFAULT now()
);

-- ============================================
-- CREATE INDEXES FOR PERFORMANCE
-- ============================================
CREATE INDEX IF NOT EXISTS idx_user_profiles_username ON user_profiles(username);
CREATE INDEX IF NOT EXISTS idx_user_profiles_phone ON user_profiles(phone_number);
CREATE INDEX IF NOT EXISTS idx_user_profiles_is_active ON user_profiles(is_active);
CREATE INDEX IF NOT EXISTS idx_farm_records_user_id ON farm_records(user_id);
CREATE INDEX IF NOT EXISTS idx_farm_records_crop_type ON farm_records(crop_type);
CREATE INDEX IF NOT EXISTS idx_farm_records_status ON farm_records(status);
CREATE INDEX IF NOT EXISTS idx_weather_data_district ON weather_data(district);
CREATE INDEX IF NOT EXISTS idx_weather_data_forecast_date ON weather_data(forecast_date);
CREATE INDEX IF NOT EXISTS idx_chat_sessions_user_id ON chat_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_chat_messages_session_id ON chat_messages(session_id);
CREATE INDEX IF NOT EXISTS idx_chat_messages_user_id ON chat_messages(user_id);
CREATE INDEX IF NOT EXISTS idx_ai_recommendations_user_id ON ai_recommendations(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON notifications(is_read);
CREATE INDEX IF NOT EXISTS idx_activity_logs_user_id ON activity_logs(user_id);

-- ============================================
-- ENABLE ROW LEVEL SECURITY (RLS)
-- ============================================
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE farm_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE weather_data ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_recommendations ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE activity_logs ENABLE ROW LEVEL SECURITY;

-- ============================================
-- ROW LEVEL SECURITY POLICIES
-- ============================================

-- User Profiles: Users can see their own profile and public info
CREATE POLICY "Users can view their own profile" 
ON user_profiles FOR SELECT 
USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile" 
ON user_profiles FOR UPDATE 
USING (auth.uid() = id);

CREATE POLICY "Anon can insert their own profile (signup)"
ON user_profiles FOR INSERT
WITH CHECK (auth.uid() = id);

-- Farm Records: Users can only access their own
CREATE POLICY "Users can view their own farm records" 
ON farm_records FOR SELECT 
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own farm records" 
ON farm_records FOR INSERT 
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own farm records" 
ON farm_records FOR UPDATE 
USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own farm records" 
ON farm_records FOR DELETE 
USING (auth.uid() = user_id);

-- Weather Data: Users can view their own
CREATE POLICY "Users can view weather for their district" 
ON weather_data FOR SELECT 
USING (true); -- Allow reading weather data

CREATE POLICY "Service role can insert weather data"
ON weather_data FOR INSERT
WITH CHECK (auth.role() = 'service_role');

-- Chat Sessions: Users can only access their own
CREATE POLICY "Users can view their own chat sessions" 
ON chat_sessions FOR SELECT 
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own chat sessions" 
ON chat_sessions FOR INSERT 
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own chat sessions" 
ON chat_sessions FOR UPDATE 
USING (auth.uid() = user_id);

-- Chat Messages: Users can only view their own conversations
CREATE POLICY "Users can view their own chat messages" 
ON chat_messages FOR SELECT 
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert messages in their sessions" 
ON chat_messages FOR INSERT 
WITH CHECK (auth.uid() = user_id);

-- AI Recommendations: Users can only view their own
CREATE POLICY "Users can view their own recommendations" 
ON ai_recommendations FOR SELECT 
USING (auth.uid() = user_id);

CREATE POLICY "Service role can insert recommendations"
ON ai_recommendations FOR INSERT
WITH CHECK (auth.role() = 'service_role');

-- Notifications: Users can only view their own
CREATE POLICY "Users can view their own notifications" 
ON notifications FOR SELECT 
USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own notifications" 
ON notifications FOR UPDATE 
USING (auth.uid() = user_id);

-- Activity Logs: Users can view their own, only service role can insert
CREATE POLICY "Users can view their own activity logs" 
ON activity_logs FOR SELECT 
USING (auth.uid() = user_id OR auth.role() = 'service_role');

CREATE POLICY "Only service role can insert activity logs" 
ON activity_logs FOR INSERT 
WITH CHECK (auth.role() = 'service_role');

-- ============================================
-- CREATE FUNCTIONS & TRIGGERS
-- ============================================

-- Function to update the 'updated_at' timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers for updated_at
CREATE TRIGGER update_user_profiles_updated_at
BEFORE UPDATE ON user_profiles
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_farm_records_updated_at
BEFORE UPDATE ON farm_records
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_chat_sessions_updated_at
BEFORE UPDATE ON chat_sessions
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- STORAGE SETUP (for images and files)
-- ============================================

-- Enable storage for farm images
INSERT INTO storage.buckets (id, name, public)
VALUES ('farm-images', 'farm-images', true)
ON CONFLICT (id) DO NOTHING;

-- Create policy to allow users to upload their own images
CREATE POLICY "Allow users to upload farm images"
ON storage.objects FOR INSERT
WITH CHECK (bucket_id = 'farm-images' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Allow users to view farm images"
ON storage.objects FOR SELECT
USING (bucket_id = 'farm-images');

-- ============================================
-- SAMPLE DATA (Remove in production)
-- ============================================

-- This section can be used for testing
-- Comment out after initial setup

-- Example: Insert sample weather data for testing
-- INSERT INTO weather_data (user_id, district, temperature_min, temperature_max, rainfall_mm, humidity_percent, wind_speed_kmh, weather_condition, forecast_date)
-- VALUES (current_user_id(), 'Lilongwe', 15.5, 28.3, 5.2, 65, 12.4, 'Partly Cloudy', CURRENT_DATE + INTERVAL '1 day');
