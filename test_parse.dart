import 'dart:convert';
import 'lib/modules/customer_loyalty_screen/models/shop_by_category_model.dart';
import 'lib/core/localization/app_language.dart';

void main() {
  final jsonStr = '''
    {
        "id": 4,
        "storeId": 5,
        "shopId": "shop_271",
        "categoryId": 1,
        "titleEn": "Recommend for you",
        "titleKm": "មុខទំនិញណែនាំ សម្រាប់អ្នក",
        "imageUrl": "https://i1-c.pinimg.com/1200x/d1/11/ba/d111ba73542116f35f268de3cb136c07.jpg",
        "displayOrder": 0,
        "isActive": true,
        "isDeleted": false,
        "createdDate": "2026-05-20T04:04:27.928633Z",
        "updatedDate": "2026-05-20T04:49:08.483479Z"
      }
  ''';
  
  final json = jsonDecode(jsonStr);
  final model = ShopByCategoryModel.fromJson(json);
  
  AppLanguage.setCurrentLanguageCode('km');
  print('Khmer title: ${model.displayTitle}');
  
  AppLanguage.setCurrentLanguageCode('en');
  print('English title: ${model.displayTitle}');
}
