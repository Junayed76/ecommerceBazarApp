import 'package:flutter/foundation.dart';

/// Where the parcel should be delivered.
@immutable
class ShippingAddress {
  const ShippingAddress({
    required this.fullName,
    required this.addressLine,
    required this.city,
    required this.postalCode,
    required this.phone,
  });

  final String fullName;
  final String addressLine;
  final String city;
  final String postalCode;
  final String phone;

  factory ShippingAddress.fromJson(Map<String, dynamic> json) =>
      ShippingAddress(
        fullName: json['fullName']?.toString() ?? '',
        addressLine: json['addressLine']?.toString() ?? '',
        city: json['city']?.toString() ?? '',
        postalCode: json['postalCode']?.toString() ?? '',
        phone: json['phone']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'addressLine': addressLine,
    'city': city,
    'postalCode': postalCode,
    'phone': phone,
  };

  ShippingAddress copyWith({
    String? fullName,
    String? addressLine,
    String? city,
    String? postalCode,
    String? phone,
  }) => ShippingAddress(
    fullName: fullName ?? this.fullName,
    addressLine: addressLine ?? this.addressLine,
    city: city ?? this.city,
    postalCode: postalCode ?? this.postalCode,
    phone: phone ?? this.phone,
  );

  String get oneLineSummary => '$addressLine, $city $postalCode';
}
