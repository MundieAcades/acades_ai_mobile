# Acades AI - Production Setup Guide

## Overview
This guide explains how to set up and deploy Acades AI with Supabase backend and Redis caching.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Flutter Mobile App                       │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │ Riverpod State Management                               │ │
│  │ - Auth Provider                                         │ │
│  │ - User Profile Provider                                │ │
│  │ - Farmer Profile Provider                              │ │
│  └─────────────────────────────────────────────────────────┘ │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │ Service Layer                                           │ │
│  │ - SupabaseService (Auth + Database)                    │ │
│  │ - ApiService (REST API calls)                          │ │
│  └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                             │
                    HTTPS / WebSocket
                             │
        ┌────────────────────┴────────────────────┐
        │                                         │
┌───────▼────────────────┐          ┌────────────▼──────────┐
│  Supabase Backend      │          │  Redis Cache Layer    │
│  ┌──────────────────┐  │          │                       │
│  │ PostgreSQL DB    │  │          │ - User sessions       │
│  │ - user_profiles  │  │          │ - Chat cache          │
│  │ - farm_records   │  │          │ - AI responses        │
│  │ - farm_chats     │  │          │ - Rate limits         │
│  └──────────────────┘  │          │                       │
│  ┌──────────────────┐  │          └───────────────────────┘
│  │ Auth (Supabase)  │  │
│  │ - JWT tokens     │  │
│  │ - OTP management │  │
│  └──────────────────┘  │
│  ┌──────────────────┐  │
│  │ Real-time Subs   │  │
│  │ - Chat updates   │  │
│  │ - Farm alerts    │  │
│  └──────────────────┘  │
└───────────────────────┘
```

## Setup Instructions

### 1. Environment Configuration

Create a `.env` file in the project root:

```bash
cp .env.example .env
```

Fill in your Supabase credentials:

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
ENVIRONMENT=production
LOG_LEVEL=info
ENABLE_SENTRY=true
SENTRY_DSN=https://your-sentry-key@sentry.io/project-id
```

### 2. Supabase Setup

#### Create Tables

Run these SQL queries in Supabase SQL Editor:

```sql
-- User Profiles Table
CREATE TABLE user_profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  username TEXT NOT NULL UNIQUE,
  phone_number TEXT UNIQUE,
  email TEXT,
  farmer_profile JSONB NOT NULL DEFAULT '{}',
  is_verified BOOLEAN DEFAULT FALSE,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
);

-- Farm Records Table
CREATE TABLE farm_records (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
  crop_type TEXT NOT NULL,
  planting_date DATE,
  harvest_date DATE,
  yield_amount DECIMAL,
  yield_unit TEXT,
  notes TEXT,
  images JSONB DEFAULT '[]',
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
);

-- Chat Sessions Table
CREATE TABLE chat_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
  title TEXT,
  topic TEXT,
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
);

-- Chat Messages Table
CREATE TABLE chat_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id UUID NOT NULL REFERENCES chat_sessions(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
  role TEXT NOT NULL CHECK (role IN ('user', 'assistant')),
  content TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT now()
);

-- Create Indexes for Performance
CREATE INDEX idx_user_profiles_username ON user_profiles(username);
CREATE INDEX idx_user_profiles_phone ON user_profiles(phone_number);
CREATE INDEX idx_farm_records_user_id ON farm_records(user_id);
CREATE INDEX idx_chat_sessions_user_id ON chat_sessions(user_id);
CREATE INDEX idx_chat_messages_session_id ON chat_messages(session_id);
CREATE INDEX idx_chat_messages_user_id ON chat_messages(user_id);

-- Enable Row Level Security (RLS)
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE farm_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;

-- RLS Policies
-- Users can only see their own profile
CREATE POLICY "Users can view their own profile" 
ON user_profiles FOR SELECT 
USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile" 
ON user_profiles FOR UPDATE 
USING (auth.uid() = id);

-- Users can only see their own farm records
CREATE POLICY "Users can view their own farm records" 
ON farm_records FOR SELECT 
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own farm records" 
ON farm_records FOR INSERT 
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own farm records" 
ON farm_records FOR UPDATE 
USING (auth.uid() = user_id);

-- Similar policies for chat tables
CREATE POLICY "Users can view their own chat sessions" 
ON chat_sessions FOR SELECT 
USING (auth.uid() = user_id);

CREATE POLICY "Users can view their own chat messages" 
ON chat_messages FOR SELECT 
USING (auth.uid() = user_id);
```

#### Configure Authentication

1. Go to Supabase Dashboard → Authentication → Providers
2. Enable "Phone Auth" for OTP-based sign-up
3. Configure SMS settings with your provider (Twilio, etc.)

#### Set JWT Secret

1. Go to Settings → API → JWT Secret
2. Copy and store it securely

### 3. Redis Setup (Optional but Recommended)

#### Local Development (Docker)

```bash
docker run -d -p 6379:6379 redis:latest
```

#### Production (AWS ElastiCache or Google Memorystore)

```bash
# AWS ElastiCache
aws elasticache create-cache-cluster \
  --cache-cluster-id acades-cache \
  --engine redis \
  --cache-node-type cache.t3.micro \
  --engine-version 7.0

# Update .env with connection string
REDIS_URL=redis://your-elasticache-endpoint:6379
```

### 4. Install Dependencies

```bash
flutter pub get
flutter pub run build_runner build
```

### 5. Run the App

```bash
flutter run
```

## Production Deployment

### Android Build

```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### iOS Build

```bash
flutter build ios --release
```

### Environment Secrets

**Never commit sensitive data:**

1. Use environment variables for secrets
2. Store credentials in CI/CD secrets
3. Use Supabase's built-in secret management
4. Use AWS Secrets Manager or similar for production

## Monitoring & Logging

### Sentry Integration

1. Create account at [Sentry.io](https://sentry.io)
2. Add DSN to `.env`:
   ```env
   SENTRY_DSN=https://your-key@sentry.io/project-id
   ENABLE_SENTRY=true
   ```

### Logs

- Local logs: Check Flutter Debug Console
- Production logs: Configure Sentry or use Supabase logs

## Database Backups

### Supabase Automatic Backups

- Daily backups included in Pro plan
- Access from Dashboard → Backups

### Manual Backup

```bash
pg_dump postgresql://user:password@host:5432/database > backup.sql
```

## Security Best Practices

1. ✅ Use environment variables for secrets
2. ✅ Enable Row Level Security (RLS)
3. ✅ Use HTTPS for all connections
4. ✅ Validate input on client and server
5. ✅ Implement rate limiting (Redis)
6. ✅ Use secure password hashing
7. ✅ Enable 2FA for admin accounts
8. ✅ Regular security audits

## Troubleshooting

### Supabase Connection Issues

```dart
// Check if Supabase is initialized
if (SupabaseService.isAuthenticated) {
  // User is authenticated
}
```

### Redis Connection Issues

```bash
redis-cli ping
# Should return: PONG
```

### Database Permissions

Check Supabase RLS policies if you can't access data:

```sql
SELECT * FROM pg_policies WHERE schemaname = 'public';
```

## Performance Optimization

1. **Indexing**: Create indexes on frequently queried columns
2. **Pagination**: Implement pagination for large datasets
3. **Caching**: Use Redis for frequently accessed data
4. **CDN**: Serve images through CDN (Supabase has built-in support)
5. **Lazy Loading**: Load data on demand

## Additional Resources

- [Supabase Documentation](https://supabase.com/docs)
- [Flutter Riverpod](https://riverpod.dev)
- [Redis Documentation](https://redis.io/documentation)
- [Sentry Flutter](https://docs.sentry.io/platforms/flutter/)
