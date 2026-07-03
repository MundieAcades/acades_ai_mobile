# Acades AI - Agricultural AI Chat Assistant
## Production-Ready Mobile Application

A Flutter mobile application for African farmers to get AI-powered agricultural advice, track farm records, monitor weather, and connect with a supportive farming community.

## 🎯 Features

- ✅ **AI Chat Assistant** - Real-time agricultural advice
- ✅ **User Authentication** - OTP-based phone authentication via Supabase
- ✅ **Farmer Profiles** - Track crops, location, land size, and demographics
- ✅ **Farm Records** - Log planting, harvest, yield, and farming practices
- ✅ **Weather Tracking** - District-based weather forecasts and alerts
- ✅ **Personalized Recommendations** - AI-generated farming tips based on profile
- ✅ **Real-time Chat** - Live messaging with persistence
- ✅ **Offline Support** - Local storage with Isar database
- ✅ **Production Ready** - Supabase backend, Redis caching, Sentry monitoring

## 🏗️ Architecture

```
┌──────────────────┐
│  Flutter App     │
│  Riverpod State  │
└────────┬─────────┘
         │
    ┌────▼───────┐
    │  Services  │
    │  - API     │
    │  - Supabase│
    │  - Local DB│
    └────┬───────┘
         │
    ┌────▼─────────────────┐
    │  Backend Services    │
    ├──────────────────────┤
    │ Supabase:            │
    │ - PostgreSQL         │
    │ - Auth (JWT/OTP)     │
    │ - Real-time Subs     │
    │ - Storage (Images)   │
    │                      │
    │ Redis:               │
    │ - User Sessions      │
    │ - Chat Cache         │
    │ - Rate Limiting      │
    └──────────────────────┘
```

## 📋 Requirements

### Development
- Flutter 3.13.0+
- Dart 3.0.0+
- Android SDK 21+ / iOS 11.0+
- Xcode 14+ (for iOS)
- Android Studio / VS Code

### Backend
- Supabase project
- Redis instance (optional but recommended)
- PostgreSQL 13+ (included in Supabase)

## 🚀 Quick Start

### 1. Clone Repository

```bash
git clone https://github.com/your-org/acades_ai.git
cd acades_ai_mobile
```

### 2. Set Up Environment

```bash
# Copy example environment file
cp .env.example .env

# Edit with your credentials
nano .env
```

Required environment variables:
```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
ENVIRONMENT=development
```

### 3. Install Dependencies

```bash
flutter pub get
flutter pub run build_runner build
```

### 4. Set Up Backend

#### Option A: Use Supabase (Recommended for Production)

1. Create account at [supabase.com](https://supabase.com)
2. Create a new project
3. Run SQL schema from `database_schema.sql` in Supabase SQL Editor
4. Configure authentication (phone OTP)
5. Copy credentials to `.env`

#### Option B: Local Development (Docker)

```bash
docker-compose up -d
```

This starts:
- PostgreSQL on localhost:5432
- Redis on localhost:6379
- pgAdmin on localhost:5050
- Redis Commander on localhost:8081

### 5. Run the App

```bash
# Debug
flutter run

# Release
flutter run --release
```

## 📱 Building for Production

### Android

```bash
# Generate keystore (first time only)
keytool -genkey -v -keystore ~/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias key

# Build signed APK
flutter build apk --release

# Build App Bundle for Play Store
flutter build appbundle --release
```

### iOS

```bash
# Build IPA
flutter build ios --release

# Generate IPA for App Store
cd build/ios/Release-iphoneos
mkdir Payload
mv Runner.app Payload/
zip -r app.ipa Payload/
```

## 🔧 Configuration

### Environment Levels

- **Development**: Local testing, debug logging
- **Staging**: Pre-production testing with Supabase
- **Production**: Full monitoring, optimized performance

Set via `.env`:
```env
ENVIRONMENT=production
LOG_LEVEL=warn
ENABLE_SENTRY=true
```

## 🗄️ Database Schema

Main tables:
- `user_profiles` - User accounts and farmer profiles
- `farm_records` - Crop planting, harvest, yield data
- `chat_sessions` - AI chat conversations
- `chat_messages` - Individual chat messages
- `ai_recommendations` - Automated farming recommendations
- `weather_data` - District weather forecasts
- `notifications` - User notifications
- `activity_logs` - Audit trail

See `database_schema.sql` for full schema.

## 🔐 Security

- Row Level Security (RLS) on all tables
- JWT-based authentication
- OTP verification for phone auth
- Encrypted sensitive data
- HTTPS for all connections
- Rate limiting via Redis
- Input validation on client & server
- Audit logging

## 📊 State Management

Using Riverpod for state management:

```dart
// Authentication
final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<UserModel?>>(...)

// User profile
final currentUserProvider = FutureProvider<UserModel?>((ref) => ...)

// Farmer profile
final farmerProfileProvider = StateNotifierProvider<FarmerProfileNotifier, FarmerProfileModel?>(...)
```

## 📝 API Endpoints

The app communicates with Supabase via:
- REST API (using Dio)
- Real-time subscriptions (WebSocket)
- Authentication endpoints

See [Supabase Documentation](https://supabase.com/docs/reference/api) for API details.

## 🔍 Logging & Monitoring

### Local Logging
- Logger package with pretty printing
- 5 levels: verbose, debug, info, warning, error

### Production Monitoring
- Sentry for error tracking
- Enable in `.env`:
  ```env
  ENABLE_SENTRY=true
  SENTRY_DSN=your-sentry-dsn
  ```

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# View coverage
lcov --list coverage/lcov.info
```

## 🚀 Deployment

### GitHub Actions CI/CD

Push to `main` branch triggers:
1. Tests and code analysis
2. Android APK build
3. iOS IPA build
4. Upload to app stores (if configured)

Configure secrets in GitHub:
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `SENTRY_DSN`
- `SLACK_WEBHOOK` (optional)

See `.github/workflows/build_deploy.yml`

### Manual Deployment

```bash
# Android - Upload to Play Store
./gradlew bundleRelease

# iOS - Upload to App Store
# Use Xcode or Transporter app
```

## 🐛 Troubleshooting

### Supabase Connection Issues

```dart
// Check initialization
if (!SupabaseService.isAuthenticated) {
  // Handle not authenticated
}
```

### Database Permission Errors

```sql
-- Check RLS policies
SELECT * FROM pg_policies WHERE schemaname = 'public';

-- Disable RLS if needed (development only)
ALTER TABLE table_name DISABLE ROW LEVEL SECURITY;
```

### Redis Connection Issues

```bash
redis-cli ping
# Should return: PONG
```

## 📚 Documentation

- [PRODUCTION_SETUP.md](./PRODUCTION_SETUP.md) - Detailed production setup
- [database_schema.sql](./database_schema.sql) - Database structure
- [Supabase Docs](https://supabase.com/docs)
- [Flutter Docs](https://flutter.dev/docs)
- [Riverpod Docs](https://riverpod.dev)

## 🤝 Contributing

1. Create feature branch: `git checkout -b feature/your-feature`
2. Commit changes: `git commit -am 'Add feature'`
3. Push to branch: `git push origin feature/your-feature`
4. Create Pull Request

### Code Style

```bash
# Format code
dart format .

# Lint
dart analyze
```

## 📄 License

MIT License - see LICENSE file

## 🙋 Support

- Issues: [GitHub Issues](https://github.com/your-org/acades_ai/issues)
- Email: support@acades.ai
- Documentation: [docs.acades.ai](https://docs.acades.ai)

## 🔄 Version History

### v1.0.0 (Current)
- Initial production release
- Supabase integration
- Farmer onboarding flow
- AI chat assistant
- Farm records tracking
- Weather integration

---

**Built with ❤️ for African Farmers**
