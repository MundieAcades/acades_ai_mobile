import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'core/config.dart';
import 'core/logger.dart';
import 'services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize configuration
    AppLogger.info('🚀 Initializing app configuration...');
    await AppConfig.initialize();
    AppLogger.info('✅ Configuration loaded');

    // Initialize Supabase
    AppLogger.info('🚀 Initializing Supabase...');
    await SupabaseService.initialize();
    AppLogger.info('✅ Supabase initialized');
  } catch (e, st) {
    AppLogger.error('❌ Failed to initialize app', e, st);
    rethrow;
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const ProviderScope(child: AcadesApp()));
}

class AcadesApp extends StatelessWidget {
  const AcadesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Acades AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const SplashScreen(),
    );
  }
}
