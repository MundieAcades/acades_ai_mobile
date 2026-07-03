import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config.dart';
import '../core/logger.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: AppConfig.instance.supabaseUrl,
        anonKey: AppConfig.instance.supabaseAnonKey,
      );
      AppLogger.info('✅ Supabase initialized successfully');
    } catch (e, st) {
      AppLogger.error('❌ Supabase initialization failed', e, st);
      rethrow;
    }
  }

  /// Check if user is authenticated
  static bool get isAuthenticated => client.auth.currentUser != null;

  /// Get current user
  static User? get currentUser => client.auth.currentUser;

  /// Get current user ID
  static String? get currentUserId => client.auth.currentUser?.id;

  /// Sign up with email and password
  static Future<AuthResponse> signUpWithPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await client.auth.signUp(
        email: email,
        password: password,
      );
      AppLogger.info('✅ User signed up: ${response.user?.email}');
      return response;
    } catch (e, st) {
      AppLogger.error('❌ Sign up failed', e, st);
      rethrow;
    }
  }

  /// Sign in with email and password
  static Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      AppLogger.info('✅ User signed in: ${response.user?.email}');
      return response;
    } catch (e, st) {
      AppLogger.error('❌ Sign in failed', e, st);
      rethrow;
    }
  }

  /// Send a phone OTP to the given phone number
  static Future<void> sendPhoneOtp({
    required String phoneNumber,
    bool shouldCreateUser = true,
  }) async {
    try {
      await client.auth.signInWithOtp(
        phone: phoneNumber,
        shouldCreateUser: shouldCreateUser,
      );
      AppLogger.info('✅ OTP sent to $phoneNumber');
    } catch (e, st) {
      AppLogger.error('❌ Failed to send OTP', e, st);
      rethrow;
    }
  }

  /// Sign out
  static Future<void> signOut() async {
    try {
      await client.auth.signOut();
      AppLogger.info('✅ User signed out');
    } catch (e, st) {
      AppLogger.error('❌ Sign out failed', e, st);
      rethrow;
    }
  }

  /// Insert user profile
  static Future<void> createUserProfile({
    required String userId,
    required String username,
    required String? phoneNumber,
    required Map<String, dynamic> farmerProfile,
  }) async {
    try {
      await client.from('user_profiles').insert({
        'id': userId,
        'username': username,
        'phone_number': phoneNumber,
        'farmer_profile': farmerProfile,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
      AppLogger.info('✅ User profile created for $userId');
    } catch (e, st) {
      AppLogger.error('❌ Failed to create user profile', e, st);
      rethrow;
    }
  }

  /// Get user profile
  static Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response =
          await client.from('user_profiles').select().eq('id', userId).single();
      AppLogger.info('✅ User profile fetched for $userId');
      return response;
    } catch (e, st) {
      AppLogger.warning('⚠️ Failed to fetch user profile', e, st);
      return null;
    }
  }

  /// Update user profile
  static Future<void> updateUserProfile(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    try {
      updates['updated_at'] = DateTime.now().toIso8601String();
      await client.from('user_profiles').update(updates).eq('id', userId);
      AppLogger.info('✅ User profile updated for $userId');
    } catch (e, st) {
      AppLogger.error('❌ Failed to update user profile', e, st);
      rethrow;
    }
  }

  /// Verify phone with OTP
  static Future<AuthResponse> verifyPhoneOtp({
    required String phoneNumber,
    required String token,
  }) async {
    try {
      final response = await client.auth.verifyOTP(
        phone: phoneNumber,
        token: token,
        type: OtpType.sms,
      );
      AppLogger.info('✅ Phone verified: $phoneNumber');
      return response;
    } catch (e, st) {
      AppLogger.error('❌ Phone verification failed', e, st);
      rethrow;
    }
  }
}
