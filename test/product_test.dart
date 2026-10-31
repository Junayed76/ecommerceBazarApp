import 'package:bazaar_app/features/product/models/product.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Product.fromMap', () {
    test('reads every field from a complete payload', () {
      final product = Product.fromMap({
        'id': 7,
        'title': 'Wireless Headphones',
        'description': 'Noise cancelling over-ear headphones.',
        'category': 'audio',
        'price': 199.5,
        'discountPercentage': 20,
        'rating': 4.6,
        'stock': 12,
        'brand': 'SoundLab',
        'tags': ['audio', 'wireless'],
        'thumbnail': 'https://cdn.example.com/thumb.jpg',
        'images': ['https://cdn.example.com/1.jpg'],
        'reviews': [
          {'rating': 5, 'comment': 'Great', 'reviewerName': 'Ayesha'},
        ],
      });

      expect(product.id, 7);
      expect(product.title, 'Wireless Headphones');
      expect(product.category, 'audio');
      expect(product.price, 199.5);
      expect(product.discountPercentage, 20);
      expect(product.rating, 4.6);
      expect(product.stock, 12);
      expect(product.brand, 'SoundLab');
      expect(product.tags, ['audio', 'wireless']);
      expect(product.images.length, 1);
      expect(product.reviews.single.comment, 'Great');
      expect(product.isInStock, isTrue);
    });

    test('falls back to defaults when fields are missing', () {
      final product = Product.fromMap(const {});

      expect(product.id, 0);
      expect(product.title, '');
      expect(product.price, 0);
      expect(product.stock, 0);
      expect(product.tags, isEmpty);
      expect(product.images, isEmpty);
      expect(product.reviews, isEmpty);
      expect(product.isInStock, isFalse);
    });

    test('accepts whole numbers for double fields', () {
      final product = Product.fromMap({
        'id': 1,
        'title': 'Pen',
        'price': 5,
        'rating': 4,
        'discountPercentage': 10,
      });

      expect(product.price, 5.0);
      expect(product.rating, 4.0);
      expect(product.discountPercentage, 10.0);
    });

    test('ignores invalid review dates instead of throwing', () {
      final review = ProductReview.fromMap({
        'rating': 4,
        'comment': 'Fine',
        'date': 'not-a-date',
      });

      expect(review.date, isNull);
    });
  });

  group('Product pricing', () {
    test('discountedPrice applies the discount percentage', () {
      const product = Product(
        id: 1,
        title: 'Speaker',
        price: 100,
        discountPercentage: 25,
      );

      expect(product.discountedPrice, 75);
      expect(product.hasDiscount, isTrue);
    });

    test('discountedPrice returns the base price without a discount', () {
      const product = Product(id: 2, title: 'Cable', price: 9.99);

      expect(product.discountedPrice, 9.99);
      expect(product.hasDiscount, isFalse);
    });
  });

  group('Product immutability helpers', () {
    test('copyWith keeps untouched fields', () {
      const original = Product(
        id: 3,
        title: 'Old name',
        price: 40,
        category: 'garden',
      );

      final updated = original.copyWith(title: 'New name', price: 30);

      expect(updated.id, 3);
      expect(updated.title, 'New name');
      expect(updated.price, 30);
      expect(updated.category, 'garden');
    });

    test('equality is based on the product id', () {
      const first = Product(id: 9, title: 'A');
      const second = Product(id: 9, title: 'B');
      const third = Product(id: 10, title: 'A');

      expect(first, equals(second));
      expect(first.hashCode, equals(second.hashCode));
      expect(first, isNot(equals(third)));
    });

    test('toMap / fromMap round trip preserves data', () {
      const original = Product(
        id: 11,
        title: 'Lamp',
        price: 22.5,
        tags: ['home'],
        reviews: [ProductReview(rating: 5, comment: 'Bright')],
      );

      final restored = Product.fromMap(original.toMap());

      expect(restored.id, original.id);
      expect(restored.title, original.title);
      expect(restored.price, original.price);
      expect(restored.tags, original.tags);
      expect(restored.reviews.single.rating, 5);
    });
  });
}
