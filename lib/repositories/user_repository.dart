import '../models/user.dart';
import '../models/farmer_profile.dart';
import '../services/supabase_service.dart';
import '../core/logger.dart';
import '../core/exceptions.dart';

class UserRepository {
  /// Create a new user profile
  Future<UserModel> createUser({
    required String userId,
    required String username,
    required String? phoneNumber,
    required FarmerProfileModel farmerProfile,
  }) async {
    try {
      AppLogger.info('Creating user: $username');

      await SupabaseService.createUserProfile(
        userId: userId,
        username: username,
        phoneNumber: phoneNumber,
        farmerProfile: farmerProfile.toJson(),
      );

      return UserModel(
        id: userId,
        email: phoneNumber ?? '',
        username: username,
        phoneNumber: phoneNumber,
        farmerProfile: farmerProfile,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );
    } catch (e, st) {
      AppLogger.error('Failed to create user', e, st);
      throw ServerException(
        message: 'Failed to create user profile',
        code: 'USER_CREATE_FAILED',
        originalError: e,
        stackTrace: st,
      );
    }
  }

  /// Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      AppLogger.info('Fetching user: $userId');

      final profile = await SupabaseService.getUserProfile(userId);
      if (profile == null) return null;

      return UserModel(
        id: userId,
        email: profile['email'] ?? '',
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
      AppLogger.error('Failed to fetch user', e, st);
      throw ServerException(
        message: 'Failed to fetch user profile',
        code: 'USER_FETCH_FAILED',
        originalError: e,
        stackTrace: st,
      );
    }
  }

  /// Update user profile
  Future<void> updateUserProfile(
    String userId,
    UserModel user,
  ) async {
    try {
      AppLogger.info('Updating user: $userId');

      await SupabaseService.updateUserProfile(
        userId,
        {
          'username': user.username,
          'phone_number': user.phoneNumber,
          'farmer_profile': user.farmerProfile.toJson(),
          'is_verified': user.isVerified,
          'is_active': user.isActive,
        },
      );

      AppLogger.info('✅ User profile updated');
    } catch (e, st) {
      AppLogger.error('Failed to update user profile', e, st);
      throw ServerException(
        message: 'Failed to update user profile',
        code: 'USER_UPDATE_FAILED',
        originalError: e,
        stackTrace: st,
      );
    }
  }

  /// Update farmer profile
  Future<void> updateFarmerProfile(
    String userId,
    FarmerProfileModel profile,
  ) async {
    try {
      AppLogger.info('Updating farmer profile for user: $userId');

      await SupabaseService.updateUserProfile(
        userId,
        {
          'farmer_profile': profile.toJson(),
          'username': profile.username,
        },
      );

      AppLogger.info('✅ Farmer profile updated');
    } catch (e, st) {
      AppLogger.error('Failed to update farmer profile', e, st);
      throw ServerException(
        message: 'Failed to update farmer profile',
        code: 'PROFILE_UPDATE_FAILED',
        originalError: e,
        stackTrace: st,
      );
    }
  }

  /// Delete user (cascading delete via database triggers)
  Future<void> deleteUser(String userId) async {
    try {
      AppLogger.info('Deleting user: $userId');

      await SupabaseService.client
          .from('user_profiles')
          .delete()
          .eq('id', userId);

      AppLogger.info('✅ User deleted');
    } catch (e, st) {
      AppLogger.error('Failed to delete user', e, st);
      throw ServerException(
        message: 'Failed to delete user',
        code: 'USER_DELETE_FAILED',
        originalError: e,
        stackTrace: st,
      );
    }
  }

  /// Check if username is available
  Future<bool> isUsernameAvailable(String username) async {
    try {
      final response = await SupabaseService.client
          .from('user_profiles')
          .select('id')
          .eq('username', username)
          .maybeSingle();

      return response == null;
    } catch (e, st) {
      AppLogger.warning('Failed to check username availability', e, st);
      // Assume available on error to not block user
      return true;
    }
  }

  /// Get user by username
  Future<UserModel?> getUserByUsername(String username) async {
    try {
      final response = await SupabaseService.client
          .from('user_profiles')
          .select()
          .eq('username', username)
          .maybeSingle();

      if (response == null) return null;

      return UserModel(
        id: response['id'],
        email: response['email'] ?? '',
        username: response['username'],
        phoneNumber: response['phone_number'],
        farmerProfile: FarmerProfileModel.fromJson(
          response['farmer_profile'] ?? {},
        ),
        createdAt: response['created_at'],
        updatedAt: response['updated_at'],
        isVerified: response['is_verified'] ?? false,
        isActive: response['is_active'] ?? true,
      );
    } catch (e, st) {
      AppLogger.error('Failed to fetch user by username', e, st);
      return null;
    }
  }
}
