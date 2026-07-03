import 'package:json_annotation/json_annotation.dart';
import 'farmer_profile.dart';

@JsonSerializable()
class UserModel {
  final String id;
  final String email;
  final String username;
  final String? phoneNumber;
  final FarmerProfileModel farmerProfile;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'updated_at')
  final String updatedAt;
  final bool isVerified;
  final bool isActive;

  UserModel({
    required this.id,
    required this.email,
    required this.username,
    this.phoneNumber,
    required this.farmerProfile,
    required this.createdAt,
    required this.updatedAt,
    this.isVerified = false,
    this.isActive = true,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      farmerProfile: FarmerProfileModel.fromJson(
        json['farmerProfile'] as Map<String, dynamic>,
      ),
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      isVerified: json['isVerified'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'phoneNumber': phoneNumber,
      'farmerProfile': farmerProfile.toJson(),
      'created_at': createdAt,
      'updated_at': updatedAt,
      'isVerified': isVerified,
      'isActive': isActive,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? username,
    String? phoneNumber,
    FarmerProfileModel? farmerProfile,
    String? createdAt,
    String? updatedAt,
    bool? isVerified,
    bool? isActive,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      farmerProfile: farmerProfile ?? this.farmerProfile,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
    );
  }
}
