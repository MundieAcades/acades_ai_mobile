import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static late final AppConfig _instance;

  final String supabaseUrl;
  final String supabaseAnonKey;
  final String apiBaseUrl;
  final int apiTimeoutMs;
  final String environment;
  final String logLevel;
  final bool enableSentry;
  final String? sentryDsn;

  AppConfig._({
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.apiBaseUrl,
    required this.apiTimeoutMs,
    required this.environment,
    required this.logLevel,
    required this.enableSentry,
    this.sentryDsn,
  });

  static Future<void> initialize() async {
    await dotenv.load(fileName: ".env");

    _instance = AppConfig._(
      supabaseUrl: dotenv.env['SUPABASE_URL'] ?? '',
      supabaseAnonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
      apiBaseUrl: dotenv.env['API_BASE_URL'] ?? 'https://api.acades.local',
      apiTimeoutMs:
          int.tryParse(dotenv.env['API_TIMEOUT_MS'] ?? '30000') ?? 30000,
      environment: dotenv.env['ENVIRONMENT'] ?? 'production',
      logLevel: dotenv.env['LOG_LEVEL'] ?? 'info',
      enableSentry: dotenv.env['ENABLE_SENTRY'] == 'true',
      sentryDsn: dotenv.env['SENTRY_DSN'],
    );
  }

  static AppConfig get instance => _instance;

  bool get isProduction => environment == 'production';
  bool get isDevelopment => environment == 'development';
}
