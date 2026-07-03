import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class FarmerProfileModel {
  final String username;
  final List<String> crops;
  final String district;
  final String landSize;
  final String gender;
  final String? phoneNumber;

  FarmerProfileModel({
    required this.username,
    required this.crops,
    required this.district,
    required this.landSize,
    required this.gender,
    this.phoneNumber,
  });

  factory FarmerProfileModel.fromJson(Map<String, dynamic> json) {
    return FarmerProfileModel(
      username: json['username'] as String,
      crops: (json['crops'] as List<dynamic>).map((e) => e as String).toList(),
      district: json['district'] as String,
      landSize: json['landSize'] as String,
      gender: json['gender'] as String,
      phoneNumber: json['phoneNumber'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'crops': crops,
      'district': district,
      'landSize': landSize,
      'gender': gender,
      'phoneNumber': phoneNumber,
    };
  }

  FarmerProfileModel copyWith({
    String? username,
    List<String>? crops,
    String? district,
    String? landSize,
    String? gender,
    String? phoneNumber,
  }) {
    return FarmerProfileModel(
      username: username ?? this.username,
      crops: crops ?? this.crops,
      district: district ?? this.district,
      landSize: landSize ?? this.landSize,
      gender: gender ?? this.gender,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
}
