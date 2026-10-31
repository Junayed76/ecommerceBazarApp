import 'package:flutter/foundation.dart';

/// Lifecycle of the authentication session.
enum AuthStatus { unknown, signingIn, authenticated, unauthenticated }

/// The signed-in customer.
@immutable
class UserModel {
  const UserModel({
    required this.id,
    required this.username,
    this.email = '',
    this.firstName = '',
    this.lastName = '',
    this.gender = '',
    this.image = '',
    this.phone = '',
    this.role = '',
  });

  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String gender;
  final String image;
  final String phone;
  final String role;

  String get fullName {
    final name = '$firstName $lastName'.trim();
    return name.isEmpty ? username : name;
  }

  String get initials {
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '${firstName[0]}${lastName[0]}'.toUpperCase();
    }
    return fullName.isEmpty ? '?' : fullName[0].toUpperCase();
  }

  factory UserModel.fromMap(Map<String, dynamic> json) => UserModel(
    id: (json['id'] as num?)?.toInt() ?? 0,
    username: json['username']?.toString() ?? '',
    email: json['email']?.toString() ?? '',
    firstName: json['firstName']?.toString() ?? '',
    lastName: json['lastName']?.toString() ?? '',
    gender: json['gender']?.toString() ?? '',
    image: json['image']?.toString() ?? '',
    phone: json['phone']?.toString() ?? '',
    role: json['role']?.toString() ?? '',
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'username': username,
    'email': email,
    'firstName': firstName,
    'lastName': lastName,
    'gender': gender,
    'image': image,
    'phone': phone,
    'role': role,
  };

  UserModel copyWith({
    int? id,
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    String? gender,
    String? image,
    String? phone,
    String? role,
  }) => UserModel(
    id: id ?? this.id,
    username: username ?? this.username,
    email: email ?? this.email,
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    gender: gender ?? this.gender,
    image: image ?? this.image,
    phone: phone ?? this.phone,
    role: role ?? this.role,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserModel && other.id == id && other.username == username);

  @override
  int get hashCode => Object.hash(id, username);
}
