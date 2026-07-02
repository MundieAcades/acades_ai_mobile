import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary lime/sage green accent
  static const Color primary = Color(0xFF5AAB28);
  static const Color primaryLight = Color(0xFF6ABF40);
  static const Color primarySurface = Color(0xFFEBFFCA);
  static const Color primaryBorder = Color(0xFFD4E8C2);
  static const Color primaryIcon = Color(0xFFF0F9E6);

  // Backgrounds
  static const Color white = Color(0xFFFFFFFF);
  static const Color scaffoldBg = Color(0xFFF9F9F9);
  static const Color inputBg = Color(0xFFF5F5F5);
  static const Color divider = Color(0xFFF0F0F0);

  // Text
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textMuted = Color(0xFFAAAAAA);
  static const Color textHint = Color(0xFFBBBBBB);

  // Chat bubbles
  static const Color userBubble = Color(0xFF6ABF40);
  static const Color aiBubble = Color(0xFFF4F4F4);

  // Gradient
  static const LinearGradient homeGradient = LinearGradient(
    begin: Alignment(0.50, 0.49),
    end: Alignment(0.50, 1.00),
    colors: [Colors.white, Color(0xFFEBFFCA)],
  );
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      textTheme: GoogleFonts.robotoTextTheme(),
      scaffoldBackgroundColor: AppColors.scaffoldBg,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.roboto(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary, size: 22),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 0.5,
        space: 0,
      ),
    );
  }
}
