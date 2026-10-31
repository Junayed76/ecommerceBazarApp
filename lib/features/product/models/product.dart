import 'dart:convert';

import 'package:flutter/foundation.dart';

/// A single customer review attached to a [Product].
@immutable
class ProductReview {
  const ProductReview({
    this.rating = 0,
    this.comment = '',
    this.reviewerName = '',
    this.date,
  });

  final int rating;
  final String comment;
  final String reviewerName;
  final DateTime? date;

  factory ProductReview.fromMap(Map<String, dynamic> json) {
    return ProductReview(
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      comment: json['comment']?.toString() ?? '',
      reviewerName: json['reviewerName']?.toString() ?? '',
      date: DateTime.tryParse(json['date']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toMap() => {
    'rating': rating,
    'comment': comment,
    'reviewerName': reviewerName,
    'date': date?.toIso8601String(),
  };
}

/// Immutable domain model for a store product.
///
/// Every field is `final`; changing a value means creating a new instance with
/// [copyWith]. That keeps Provider rebuilds predictable and makes it safe to
/// pass the same [Product] instance to several screens at once.
@immutable
class Product {
  const Product({
    required this.id,
    required this.title,
    this.description = '',
    this.category = '',
    this.price = 0,
    this.discountPercentage = 0,
    this.rating = 0,
    this.stock = 0,
    this.brand = '',
    this.tags = const [],
    this.thumbnail = '',
    this.images = const [],
    this.reviews = const [],
  });

  final int id;
  final String title;
  final String description;
  final String category;
  final double price;
  final double discountPercentage;
  final double rating;
  final int stock;
  final String brand;
  final List<String> tags;
  final String thumbnail;
  final List<String> images;
  final List<ProductReview> reviews;

  /// Price after the product's discount, already rounded to two decimals.
  double get discountedPrice {
    if (discountPercentage <= 0) return price;
    final value = price * (1 - discountPercentage / 100);
    return double.parse(value.toStringAsFixed(2));
  }

  bool get hasDiscount => discountPercentage > 0;

  bool get isInStock => stock > 0;

  Product copyWith({
    int? id,
    String? title,
    String? description,
    String? category,
    double? price,
    double? discountPercentage,
    double? rating,
    int? stock,
    String? brand,
    List<String>? tags,
    String? thumbnail,
    List<String>? images,
    List<ProductReview>? reviews,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      rating: rating ?? this.rating,
      stock: stock ?? this.stock,
      brand: brand ?? this.brand,
      tags: tags ?? this.tags,
      thumbnail: thumbnail ?? this.thumbnail,
      images: images ?? this.images,
      reviews: reviews ?? this.reviews,
    );
  }

  /// Deserialises one product coming from the API.
  ///
  /// Every value is parsed defensively: a missing or wrongly typed field falls
  /// back to a sensible default instead of throwing.
  factory Product.fromMap(Map<String, dynamic> json) {
    return Product(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      discountPercentage:
          (json['discountPercentage'] as num?)?.toDouble() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      brand: json['brand']?.toString() ?? '',
      tags: _stringList(json['tags']),
      thumbnail: json['thumbnail']?.toString() ?? '',
      images: _stringList(json['images']),
      reviews: json['reviews'] is List
          ? (json['reviews'] as List)
                .whereType<Map>()
                .map(
                  (item) => ProductReview.fromMap(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList()
          : const [],
    );
  }

  factory Product.fromJson(String source) =>
      Product.fromMap(jsonDecode(source) as Map<String, dynamic>);

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'category': category,
    'price': price,
    'discountPercentage': discountPercentage,
    'rating': rating,
    'stock': stock,
    'brand': brand,
    'tags': tags,
    'thumbnail': thumbnail,
    'images': images,
    'reviews': reviews.map((review) => review.toMap()).toList(),
  };

  String toJson() => jsonEncode(toMap());

  static List<String> _stringList(dynamic value) {
    if (value is! List) return const [];
    return value.map((item) => item.toString()).toList();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Product && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Product(id: $id, title: $title, price: $price)';
}
