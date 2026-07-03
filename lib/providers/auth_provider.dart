import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../models/farmer_profile.dart';
import '../services/supabase_service.dart';
import '../core/logger.dart';

// API Service provider
final apiServiceProvider = Provider((ref) {
  // TODO: Create and return ApiService instance
  return null;
});

// Supabase auth state provider
final authStateProvider = StreamProvider<bool>((ref) {
  return SupabaseService.client.auth.onAuthStateChange.map((event) {
    AppLogger.info('Auth state changed: ${event.event}');
    return event.session != null;
  });
});

// Current user provider
final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final supabaseUser = SupabaseService.currentUser;
  if (supabaseUser == null) return null;

  try {
    final profile = await SupabaseService.getUserProfile(supabaseUser.id);
    if (profile == null) return null;

    return UserModel(
      id: supabaseUser.id,
      email: supabaseUser.email ?? '',
      username: profile['username'] ?? '',
      phoneNumber: profile['phone_number'],
      farmerProfile: FarmerProfileModel.fromJson(
        profile['farmer_profile'] ?? {},
      ),
      createdAt: profile['created_at'] ?? '',
      updatedAt: profile['updated_at'] ?? '',
      isVerified: profile['is_verified'] ?? false,
      isActive: profile['is_active'] ?? true,
    );
  } catch (e, st) {
    AppLogger.error('Failed to fetch current user', e, st);
    return null;
  }
});

// Farmer profile state notifier
class FarmerProfileNotifier extends StateNotifier<FarmerProfileModel?> {
  FarmerProfileNotifier() : super(null);

  Future<void> saveFarmerProfile(
    String userId,
    FarmerProfileModel profile,
  ) async {
    try {
      state = profile;
      await SupabaseService.updateUserProfile(
        userId,
        {
          'farmer_profile': profile.toJson(),
          'username': profile.username,
        },
      );
      AppLogger.info('✅ Farmer profile saved');
    } catch (e, st) {
      AppLogger.error('❌ Failed to save farmer profile', e, st);
      rethrow;
    }
  }

  void updateProfile(FarmerProfileModel profile) {
    state = profile;
  }
}

final farmerProfileProvider =
    StateNotifierProvider<FarmerProfileNotifier, FarmerProfileModel?>((ref) {
  return FarmerProfileNotifier();
});

// Auth notifier for sign up and sign in
class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  AuthNotifier() : super(const AsyncValue.data(null));

  Future<void> signUpWithPhone(
    String phoneNumber,
    FarmerProfileModel profile,
  ) async {
    state = const AsyncValue.loading();
    try {
      await SupabaseService.sendPhoneOtp(phoneNumber: phoneNumber);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      AppLogger.error('❌ Sign up failed', e, st);
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> verifyOtpAndComplete(
    String phoneNumber,
    String otp,
    FarmerProfileModel profile,
  ) async {
    state = const AsyncValue.loading();
    try {
      // Step 1: Verify OTP and sign in the user
      final authResponse = await SupabaseService.verifyPhoneOtp(
        phoneNumber: phoneNumber,
        token: otp,
      );

      final supabaseUser = authResponse.user;
      if (supabaseUser == null) {
        throw Exception('User not found after OTP verification');
      }

      // Step 2: Create or update the Supabase profile record
      await SupabaseService.createUserProfile(
        userId: supabaseUser.id,
        username: profile.username,
        phoneNumber: phoneNumber,
        farmerProfile: profile.toJson(),
      );

      final userProfile = await SupabaseService.getUserProfile(supabaseUser.id);
      if (userProfile == null) {
        throw Exception('Failed to create user profile');
      }

      final user = UserModel(
        id: supabaseUser.id,
        email: supabaseUser.email ?? phoneNumber,
        username: profile.username,
        phoneNumber: phoneNumber,
        farmerProfile: profile,
        createdAt:
            userProfile['created_at'] ?? DateTime.now().toIso8601String(),
        updatedAt:
            userProfile['updated_at'] ?? DateTime.now().toIso8601String(),
        isVerified: true,
      );

      state = AsyncValue.data(user);
      AppLogger.info('✅ User registered and verified');
    } catch (e, st) {
      AppLogger.error('❌ OTP verification failed', e, st);
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await SupabaseService.signOut();
      state = const AsyncValue.data(null);
      AppLogger.info('✅ User signed out');
    } catch (e, st) {
      AppLogger.error('❌ Sign out failed', e, st);
      rethrow;
    }
  }
}

final authProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<UserModel?>>((ref) {
  return AuthNotifier();
});
