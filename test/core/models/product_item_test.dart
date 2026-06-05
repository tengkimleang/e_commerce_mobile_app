import 'package:e_commerce_mobile_app/core/models/product_item.dart';
import 'package:e_commerce_mobile_app/core/localization/app_language.dart';
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

  test(
    'displayName prefers selected language with legacy rollout fallback',
    () {
      final product = ProductModel.fromJson({
        'id': '1',
        'name': 'Legacy Product',
        'nameEn': 'English Product',
        'nameKm': 'ផលិតផលខ្មែរ',
        'price': 1,
        'imageUrl': '',
      });

      expect(product.displayNameFor(AppLanguage.english), 'English Product');
      expect(product.displayNameFor(AppLanguage.khmer), 'ផលិតផលខ្មែរ');
    },
  );

  test('displayName falls back to legacy name while BE migrates', () {
    final product = ProductModel.fromJson({
      'id': '1',
      'name': 'Legacy Product',
      'price': 1,
      'imageUrl': '',
    });

    expect(product.displayNameFor(AppLanguage.english), 'Legacy Product');
    expect(product.displayNameFor(AppLanguage.khmer), 'Legacy Product');
  });

  test('reads product description and subcategory bilingual fields', () {
    final product = ProductModel.fromJson({
      'id': '1',
      'name': 'Legacy Product',
      'nameEn': 'English Product',
      'nameKm': 'ផលិតផលខ្មែរ',
      'descriptionEn': 'English description',
      'descriptionKm': 'ការពិពណ៌នាខ្មែរ',
      'subCategoryName': 'Legacy Subcategory',
      'subCategoryNameEn': 'English Subcategory',
      'subCategoryNameKm': 'ប្រភេទរងខ្មែរ',
      'price': 1,
      'imageUrl': '',
    });

    expect(
      product.displayDescriptionFor(AppLanguage.english),
      'English description',
    );
    expect(product.displayDescriptionFor(AppLanguage.khmer), 'ការពិពណ៌នាខ្មែរ');
    expect(
      product.displaySubCategoryNameFor(AppLanguage.english),
      'English Subcategory',
    );
    expect(
      product.displaySubCategoryNameFor(AppLanguage.khmer),
      'ប្រភេទរងខ្មែរ',
    );
  });

  test(
    'falls back to English product fields while Khmer CMS data is empty',
    () {
      final product = ProductModel.fromJson({
        'id': '1',
        'name': 'Legacy Product',
        'nameEn': 'English Product',
        'nameKm': '',
        'descriptionEn': 'English description',
        'descriptionKm': '',
        'subCategoryName': 'Legacy Subcategory',
        'subCategoryNameEn': 'English Subcategory',
        'subCategoryNameKm': '',
        'price': 1,
        'imageUrl': '',
      });

      expect(product.displayNameFor(AppLanguage.khmer), 'English Product');
      expect(
        product.displayDescriptionFor(AppLanguage.khmer),
        'English description',
      );
      expect(
        product.displaySubCategoryNameFor(AppLanguage.khmer),
        'English Subcategory',
      );
    },
  );
}
