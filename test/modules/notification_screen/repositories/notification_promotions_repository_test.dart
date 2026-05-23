import 'package:dio/dio.dart';
import 'package:e_commerce_mobile_app/core/constants/app_constants.dart';
import 'package:e_commerce_mobile_app/modules/notification_screen/models/notification_promotion_entry.dart';
import 'package:e_commerce_mobile_app/modules/notification_screen/repositories/notification_promotions_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'parses category and content promotions from backend response',
    () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'data': {
                    'items': [
                      {
                        'id': 'content-1',
                        'type': 'content',
                        'title': 'Content Promo',
                        'description': 'Content description',
                        'imageUrl': 'https://example.com/content.jpg',
                        'displayOrder': 2,
                        'startsAt': '2026-05-22T13:54:00',
                        'endsAt': '2026-05-22T22:54:00',
                        'publishedAt': '2026-05-22T13:54:00',
                        'createdDate': '2026-05-21T09:00:00',
                      },
                      {
                        'id': 'category-1',
                        'type': 'category',
                        'title': 'Category Promo',
                        'description': 'Category description',
                        'imageUrl': 'https://example.com/category.jpg',
                        'categoryId': 12,
                        'displayOrder': 1,
                        'startsAt': '2026-05-22T13:54:00',
                        'endsAt': '2026-05-22T22:54:00',
                        'publishedAt': '2026-05-22T13:54:00',
                        'createdDate': '2026-05-21T09:00:00',
                      },
                    ],
                  },
                },
              ),
            );
          },
        ),
      );

      final repository = HttpNotificationPromotionsRepository(dio);
      final items = await repository.fetchPromotions(shopId: 'shop-1');

      expect(items, hasLength(2));
      expect(items.first.id, 'category-1');
      expect(items.first.type, NotificationPromotionType.category);
      expect(items.first.categoryId, 12);
      expect(items.first.createdDate, isNotNull);
      expect(items.last.type, NotificationPromotionType.content);
    },
  );

  test('throws backend business errors', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              statusCode: 200,
              data: {'errorCode': 'PROMO_ERROR', 'errorMsg': 'Unavailable'},
            ),
          );
        },
      ),
    );

    final repository = HttpNotificationPromotionsRepository(dio);

    expect(() => repository.fetchPromotions(), throwsA(isA<Exception>()));
  });

  test('normalizes relative promotion image urls with API base url', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              statusCode: 200,
              data: {
                'data': {
                  'items': [
                    {
                      'id': 'content-1',
                      'type': 'content',
                      'title': 'Content Promo',
                      'description': 'Content description',
                      'imageUrl': '/uploads/promotions/content.jpg',
                      'displayOrder': 1,
                    },
                  ],
                },
              },
            ),
          );
        },
      ),
    );

    final repository = HttpNotificationPromotionsRepository(dio);
    final items = await repository.fetchPromotions(shopId: 'shop-1');

    expect(
      items.single.imageUrl,
      '${ApiUrl.baseUrl}/uploads/promotions/content.jpg',
    );
  });
}
