import 'package:e_commerce_mobile_app/core/models/product_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'galleryImages keeps the primary image first and removes duplicates',
    () {
      const product = ProductModel(
        id: '1',
        name: 'Test Product',
        price: 1,
        imageUrl: 'https://example.com/front.png',
        imageUrls: [
          'https://example.com/side.png',
          'https://example.com/front.png',
          '',
        ],
      );

      expect(product.galleryImages, [
        'https://example.com/front.png',
        'https://example.com/side.png',
      ]);
    },
  );

  test('fromJson reads gallery images from backend list shapes', () {
    final product = ProductModel.fromJson({
      'id': '1',
      'name': 'Test Product',
      'price': 1,
      'imageUrls': [
        {'imageUrl': 'https://example.com/front.png'},
        {'url': 'https://example.com/side.png'},
        {'path': 'https://example.com/back.png'},
      ],
    });

    expect(product.imageUrl, 'https://example.com/front.png');
    expect(product.imageUrls, [
      'https://example.com/front.png',
      'https://example.com/side.png',
      'https://example.com/back.png',
    ]);
    expect(product.galleryImages, [
      'https://example.com/front.png',
      'https://example.com/side.png',
      'https://example.com/back.png',
    ]);
  });
}
