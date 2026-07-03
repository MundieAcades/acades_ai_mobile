# Acades AI - Production Setup Checklist

## ✅ Pre-Setup Requirements

- [ ] Flutter 3.13.0+ installed
- [ ] Dart 3.0.0+ installed
- [ ] Git configured
- [ ] Supabase account created at [supabase.com](https://supabase.com)
- [ ] Docker installed (optional, for local dev)
- [ ] Code editor (VS Code, Android Studio, or Xcode)

## 🔧 Initial Setup

### Phase 1: Local Environment Setup

- [ ] Clone repository
  ```bash
  git clone https://github.com/your-org/acades_ai.git
  cd acades_ai_mobile
  ```

- [ ] Create `.env` file from template
  ```bash
  cp .env.example .env
  ```

- [ ] Install Flutter dependencies
  ```bash
  flutter pub get
  flutter pub run build_runner build
  ```

- [ ] Verify Flutter setup
  ```bash
  flutter doctor
  # Should show all green checkmarks
  ```

### Phase 2: Supabase Backend Setup

#### Create Supabase Project

- [ ] Sign up at [supabase.com](https://supabase.com)
- [ ] Click "New Project"
- [ ] Select region closest to your users
- [ ] Set a strong database password
- [ ] Wait for project initialization (2-3 minutes)

#### Copy Credentials

- [ ] Go to Settings → API
- [ ] Copy `Project URL` → `SUPABASE_URL` in `.env`
- [ ] Copy `anon (public)` key → `SUPABASE_ANON_KEY` in `.env`

#### Set Up Database

- [ ] Go to SQL Editor
- [ ] Create new query
- [ ] Copy entire content from `database_schema.sql`
- [ ] Paste and execute
- [ ] Wait for all tables to be created
- [ ] Verify tables appear in "Tables" view

#### Configure Authentication

- [ ] Go to Authentication → Providers
- [ ] Enable "Phone" authentication
- [ ] Configure SMS provider:
  - [ ] Choose: Twilio or Vonage (others may require custom setup)
  - [ ] Add API credentials from your SMS provider
  - [ ] Test with a sample SMS
- [ ] Set JWT Secret (Settings → API):
  - [ ] Copy the auto-generated JWT Secret
  - [ ] Store securely (don't share)

#### Enable Row Level Security

- [ ] Go to SQL Editor
- [ ] Run: `ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;`
- [ ] Run: `ALTER TABLE farm_records ENABLE ROW LEVEL SECURITY;`
- [ ] (Other RLS statements already in schema)

#### Set Up Storage Bucket

- [ ] Go to Storage → Buckets
- [ ] Create new bucket: `farm-images`
- [ ] Make it public: ✓ Public bucket
- [ ] Create folder policies (optional):
  - [ ] Allow users to upload: `/farm-images/user-id/*`

### Phase 3: Redis Setup (Optional but Recommended)

#### Option A: Docker (Local Development)

```bash
docker-compose up -d redis
# Redis available at localhost:6379
```

- [ ] Verify connection:
  ```bash
  redis-cli ping
  # Should return: PONG
  ```

#### Option B: AWS ElastiCache (Production)

- [ ] Create ElastiCache cluster on AWS
- [ ] Copy endpoint URL
- [ ] Update `.env`:
  ```env
  REDIS_URL=your-redis-endpoint:6379
  ```

#### Option C: Google Memorystore (Production)

- [ ] Create Memorystore instance on GCP
- [ ] Copy connection string
- [ ] Update `.env`

### Phase 4: Monitoring Setup (Optional)

#### Sentry Error Tracking

- [ ] Sign up at [sentry.io](https://sentry.io)
- [ ] Create new project for Flutter
- [ ] Copy DSN
- [ ] Update `.env`:
  ```env
  ENABLE_SENTRY=true
  SENTRY_DSN=your-sentry-dsn
  ```

#### Logging

- [ ] Logs stored locally in app
- [ ] Configure log level in `.env`:
  ```env
  LOG_LEVEL=info  # debug, info, warning, error
  ```

## 🧪 Testing

### Verify Setup

- [ ] Run app in debug mode
  ```bash
  flutter run
  ```

- [ ] Test authentication flow
  - [ ] Splash screen appears
  - [ ] Onboarding flow loads
  - [ ] Can enter username
  - [ ] Phone input works
  - [ ] OTP verification (if SMS configured)

- [ ] Check database
  - [ ] Supabase Dashboard → Tables
  - [ ] Verify `user_profiles` table has new user
  - [ ] Verify `farmer_profile` JSONB data saved

- [ ] Test logging
  - [ ] Check Flutter console for logs
  - [ ] Should see ✅ and ❌ indicators

### Performance Testing

- [ ] Check app startup time
- [ ] Verify no crashes on navigation
- [ ] Test with slow 3G network (DevTools)
- [ ] Monitor memory usage

## 🚀 Build for Release

### Android

- [ ] Generate keystore (one time):
  ```bash
  keytool -genkey -v -keystore ~/key.jks \
    -keyalg RSA -keysize 2048 -validity 10000 -alias key
  ```

- [ ] Create `android/key.properties`:
  ```properties
  storePassword=your-keystore-password
  keyPassword=your-key-password
  keyAlias=key
  storeFile=/path/to/key.jks
  ```

- [ ] Build release APK:
  ```bash
  flutter build apk --release
  ```
  Output: `build/app/outputs/apk/release/app-release.apk`

- [ ] Build App Bundle (for Play Store):
  ```bash
  flutter build appbundle --release
  ```
  Output: `build/app/outputs/bundle/release/app-release.aab`

### iOS

- [ ] Set up Apple Developer Account
- [ ] Create App ID and certificates in Apple Developer Portal
- [ ] Set Deployment Target to iOS 11.0+
- [ ] Update Version and Build Number in Xcode
- [ ] Build:
  ```bash
  flutter build ios --release
  ```

- [ ] Sign and upload via Xcode:
  ```bash
  open ios/Runner.xcworkspace
  ```
  Then: Product → Scheme → Runner → Build → Archive → Upload

## 📊 Deploy to App Stores

### Google Play Store

- [ ] Create Google Play Console account
- [ ] Create new app
- [ ] Fill in app details (description, screenshots, etc.)
- [ ] Upload signed App Bundle
- [ ] Set up pricing and distribution
- [ ] Submit for review
- [ ] Monitor review status (typically 24-48 hours)

### Apple App Store

- [ ] Create Apple App Store account
- [ ] Create new app in App Store Connect
- [ ] Complete app information
- [ ] Add screenshots and preview videos
- [ ] Set up pricing
- [ ] Upload IPA via Xcode or Transporter
- [ ] Submit for review
- [ ] Monitor review status (typically 24-48 hours)

## 🔒 Security Hardening

- [ ] Review `.env` - no sensitive data committed
- [ ] Verify RLS policies on all tables
- [ ] Enable 2FA on Supabase account
- [ ] Enable 2FA on GitHub
- [ ] Set up secret management in CI/CD
- [ ] Review API rate limits
- [ ] Configure CORS on backend
- [ ] Enable HTTPS everywhere
- [ ] Review data privacy policy
- [ ] Implement audit logging
- [ ] Set up incident response plan

## 📈 Post-Launch

### Monitoring

- [ ] Set up Sentry alerts
- [ ] Configure email notifications for errors
- [ ] Monitor database performance
- [ ] Track user metrics
- [ ] Set up uptime monitoring

### Backup & Recovery

- [ ] Enable automated Supabase backups
- [ ] Test backup restoration
- [ ] Document disaster recovery procedures
- [ ] Store backup credentials securely

### Updates & Maintenance

- [ ] Plan release schedule
- [ ] Set up beta testing (Google Play Beta, TestFlight)
- [ ] Monitor user feedback
- [ ] Track bug reports
- [ ] Plan feature releases

## 🆘 Troubleshooting Quick Links

| Issue | Solution |
|-------|----------|
| Supabase connection fails | Check `SUPABASE_URL` and `SUPABASE_ANON_KEY` in `.env` |
| OTP not receiving | Verify SMS provider credentials and phone number format |
| Database permission denied | Check RLS policies - user might not have access |
| Redis connection error | Verify Redis server is running and endpoint is correct |
| App crashes on auth | Check Logcat/Console for error messages |
| Build fails | Run `flutter clean` then `flutter pub get` |

## 📞 Support

- **Supabase Docs**: https://supabase.com/docs
- **Flutter Docs**: https://flutter.dev/docs
- **Community**: Stack Overflow `flutter` tag
- **Issues**: GitHub Issues

---

## ✨ Completion Status

Track your progress:

- Phase 1 (Local Setup): [ ] Complete
- Phase 2 (Supabase): [ ] Complete
- Phase 3 (Redis): [ ] Complete  
- Phase 4 (Monitoring): [ ] Complete
- Testing: [ ] Complete
- Release Build: [ ] Complete
- App Store Deploy: [ ] Complete

**Estimated time: 2-4 hours for complete setup**

---

*Last Updated: 2024-07-03*
*For latest updates, see PRODUCTION_SETUP.md*
