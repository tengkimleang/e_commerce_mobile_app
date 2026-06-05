import 'package:e_commerce_mobile_app/core/localization/app_language.dart';
import 'package:e_commerce_mobile_app/modules/chipmong_screen/widget/loyalty_widget/loyalty_models.dart';
import 'package:e_commerce_mobile_app/modules/address/models/delivery_address.dart';
import 'package:e_commerce_mobile_app/modules/checkout/models/order_summary.dart';
import 'package:e_commerce_mobile_app/modules/user_info_screen/models/user_info_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('order summary localizes shop snapshot names with legacy fallback', () {
    final order = OrderSummary(
      orderId: '1',
      orderNumber: '00001',
      orderDate: _fixedDate,
      shopName: 'Legacy Shop',
      shopNameEn: 'English Shop',
      shopNameKm: 'ហាងខ្មែរ',
      items: [],
      deliveryAddress: _emptyAddress,
      subtotal: 0,
      deliveryFee: 0,
      packageFees: 0,
      discount: 0,
      promoDiscount: 0,
      total: 0,
      paymentMethod: 'COD',
    );

    expect(order.displayShopNameFor(AppLanguage.english), 'English Shop');
    expect(order.displayShopNameFor(AppLanguage.khmer), 'ហាងខ្មែរ');
  });

  test('loyalty product localizes reward content with English fallback', () {
    const reward = LoyaltyProduct(
      imageUrl: '',
      brandName: 'Chip Mong',
      category: 'Legacy Category',
      categoryEn: 'English Category',
      categoryKm: '',
      title: 'Legacy Reward',
      titleEn: 'English Reward',
      titleKm: '',
      store: 'Store',
      points: 100,
      pointCondition: 'Legacy condition',
      pointConditionEn: 'English condition',
      pointConditionKm: '',
      termsAndConditions: 'Legacy terms',
      termsAndConditionsEn: 'English terms',
      termsAndConditionsKm: '',
    );

    expect(reward.displayTitleFor(AppLanguage.khmer), 'English Reward');
    expect(reward.displayCategoryFor(AppLanguage.khmer), 'English Category');
    expect(
      reward.displayPointConditionFor(AppLanguage.khmer),
      'English condition',
    );
    expect(
      reward.displayTermsAndConditionsFor(AppLanguage.khmer),
      'English terms',
    );
  });

  test('user profile normalizes backend languageCode', () {
    final profile = UserInfoModel.fromProfileJson({
      'fullName': 'Dara',
      'languageCode': 'km-KH',
    });

    expect(profile.languageCode, AppLanguage.khmer);
  });
}

final _fixedDate = DateTime(2026);
const _emptyAddress = DeliveryAddress(
  id: '',
  nameAddress: '',
  address: '',
  phoneNumber: '',
  label: AddressLabel.other,
  isDefault: false,
  latitude: 0,
  longitude: 0,
);
