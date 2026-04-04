import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

// ---------------------------------------------------------------------------
// Tier model + data
// ---------------------------------------------------------------------------
class LoyaltyTier {
  final String name;
  final List<Color> gradient;
  final Color badgeColor;
  final List<Color>? badgeGradient;
  final bool locked;

  const LoyaltyTier({
    required this.name,
    required this.gradient,
    required this.badgeColor,
    this.badgeGradient,
    required this.locked,
  });
}

const loyaltyTiers = <LoyaltyTier>[
  LoyaltyTier(
    name: 'Lifestyle',
    gradient: [
      Color.fromARGB(255, 244, 143, 177),
      Color.fromARGB(255, 178, 147, 157),
    ],
    badgeColor: AppColors.primary,
    locked: false,
  ),
  LoyaltyTier(
    name: 'Prestige',
    gradient: [Color(0xFFC4956C), Color(0xFFEDDDAB)],
    badgeColor: Color(0xFFB5813C),
    badgeGradient: [Color(0xFF8B5E1A), Color(0xFFB5813C), Color(0xFF8B5E1A)],
    locked: true,
  ),
  LoyaltyTier(
    name: 'Elite',
    gradient: [Color(0xFFFFB74D), Color(0xFFE65100)],
    badgeColor: Color(0xFFE65100),
    locked: true,
  ),
];

// ---------------------------------------------------------------------------
// Loyalty product model + mock data
// ---------------------------------------------------------------------------
class LoyaltyProduct {
  final String rewardId;
  final String imageUrl;
  final String brandName;
  final String category;
  final String title;
  final String store;
  final int points;
  final String expiryDate;
  final int redeemLimit;
  final String pointCondition;
  final String termsAndConditions;

  const LoyaltyProduct({
    this.rewardId = '',
    required this.imageUrl,
    required this.brandName,
    this.category = 'Shopping Voucher',
    required this.title,
    required this.store,
    required this.points,
    this.expiryDate = 'Dec 31, 2026',
    this.redeemLimit = 1,
    this.pointCondition = '',
    this.termsAndConditions = '',
  });

  LoyaltyProduct copyWith({
    String? rewardId,
    String? imageUrl,
    String? brandName,
    String? category,
    String? title,
    String? store,
    int? points,
    String? expiryDate,
    int? redeemLimit,
    String? pointCondition,
    String? termsAndConditions,
  }) {
    return LoyaltyProduct(
      rewardId: rewardId ?? this.rewardId,
      imageUrl: imageUrl ?? this.imageUrl,
      brandName: brandName ?? this.brandName,
      category: category ?? this.category,
      title: title ?? this.title,
      store: store ?? this.store,
      points: points ?? this.points,
      expiryDate: expiryDate ?? this.expiryDate,
      redeemLimit: redeemLimit ?? this.redeemLimit,
      pointCondition: pointCondition ?? this.pointCondition,
      termsAndConditions: termsAndConditions ?? this.termsAndConditions,
    );
  }
}

enum LoyaltyFulfillmentMethod { delivery, pickup }

extension LoyaltyFulfillmentMethodX on LoyaltyFulfillmentMethod {
  String get label {
    switch (this) {
      case LoyaltyFulfillmentMethod.delivery:
        return 'Delivery';
      case LoyaltyFulfillmentMethod.pickup:
        return 'Pick up';
    }
  }

  String get khmerLabel {
    switch (this) {
      case LoyaltyFulfillmentMethod.delivery:
        return 'Delivery';
      case LoyaltyFulfillmentMethod.pickup:
        return 'Pick up';
    }
  }
}

enum LoyaltyPickupUserType { accountOwner, representative }

extension LoyaltyPickupUserTypeX on LoyaltyPickupUserType {
  String get label {
    switch (this) {
      case LoyaltyPickupUserType.accountOwner:
        return 'Account owner';
      case LoyaltyPickupUserType.representative:
        return 'Representative';
    }
  }

  String get khmerLabel {
    switch (this) {
      case LoyaltyPickupUserType.accountOwner:
        return 'Account owner';
      case LoyaltyPickupUserType.representative:
        return 'Representative';
    }
  }
}

class LoyaltyItemExchange {
  final LoyaltyProduct product;
  final DateTime exchangedAt;
  final int exchangedPoints;
  final int remainingPoints;
  final String referenceNo;
  final String status;
  final LoyaltyFulfillmentMethod fulfillmentMethod;
  final LoyaltyPickupUserType? pickupUserType;
  final String receiverName;
  final String receiverPhone;
  final String? representativeName;
  final String? representativePhone;
  final String pickupLocation;
  final String? deliveryAddress;
  final String? exchangeNote;
  final DateTime collectBeforeDate;

  const LoyaltyItemExchange({
    required this.product,
    required this.exchangedAt,
    required this.exchangedPoints,
    required this.remainingPoints,
    required this.referenceNo,
    required this.status,
    required this.fulfillmentMethod,
    this.pickupUserType,
    required this.receiverName,
    required this.receiverPhone,
    this.representativeName,
    this.representativePhone,
    required this.pickupLocation,
    this.deliveryAddress,
    this.exchangeNote,
    required this.collectBeforeDate,
  });
}

class LoyaltyExchangeRequest {
  final LoyaltyFulfillmentMethod fulfillmentMethod;
  final LoyaltyPickupUserType? pickupUserType;
  final String receiverName;
  final String receiverPhone;
  final String? representativeName;
  final String? representativePhone;
  final String? deliveryAddress;
  final String? note;

  const LoyaltyExchangeRequest({
    required this.fulfillmentMethod,
    this.pickupUserType,
    required this.receiverName,
    required this.receiverPhone,
    this.representativeName,
    this.representativePhone,
    this.deliveryAddress,
    this.note,
  });
}

const loyaltyDefaultTermsAndConditions = '''
Terms and Conditions:
1. Redemption must be completed within 7 days of reservation, or the reward will be forfeited, and points will be cancelled.
2. CMRT reserves up to 10 working days after redemption confirmation to complete verification before handover.
3. The reward is non-transferable and can only be redeemed by the account holder.
4. No cash, credit, or exchanges will be provided.
5. Reward handover is at the mall Information Counter (in front of H&M, Ground Floor) with the registered phone number and National ID/Passport.
6. Any fraudulent activity will lead to disqualification from the promotion.
''';

const loyaltyMockProducts = <LoyaltyProduct>[
  LoyaltyProduct(
    imageUrl:
        'https://arystorephone.com/wp-content/uploads/2025/06/galaxy-zfold7-blueshadow.jpg',
    brandName: 'SAMSUNG',
    title: 'Samsung Galaxy Z Fold7 16G / 1TB (Random Color)',
    store: 'Chip Mong 271 Mega Mall',
    points: 81999,
    pointCondition: 'Samsung Galaxy Z Fold7 16G / 1TB (Random Color)',
    termsAndConditions: loyaltyDefaultTermsAndConditions,
  ),
  LoyaltyProduct(
    imageUrl:
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTX1xLn8U0gUCrtLY41YKZWW5fsH6sNG-_bpw&s',
    brandName: 'Apple',
    title: 'iPhone 17 Pro Max 512G (Refurbished)',
    store: 'Chip Mong 271 Mega Mall',
    points: 72399,
    pointCondition: 'iPhone 17 Pro Max 512G (Refurbished)',
    termsAndConditions: loyaltyDefaultTermsAndConditions,
  ),
  LoyaltyProduct(
    imageUrl:
        'https://images.samsung.com/levant/smartphones/galaxy-s25-ultra/buy/product_color_black_PC.png',
    brandName: 'SAMSUNG',
    title: 'Samsung Galaxy S25 Ultra 512GB',
    store: 'Chip Mong 271 Mega Mall',
    points: 69899,
    pointCondition: 'Samsung Galaxy S25 Ultra 512GB',
    termsAndConditions: loyaltyDefaultTermsAndConditions,
  ),
  LoyaltyProduct(
    imageUrl:
        'https://cdsassets.apple.com/live/7WUAS350/images/tech-specs/ipad-pro-11-inch-13-inch.png',
    brandName: 'Apple',
    title: 'iPad Pro M4 13-inch 256GB',
    store: 'Chip Mong 271 Mega Mall',
    points: 55000,
    pointCondition: 'iPad Pro M4 13-inch 256GB',
    termsAndConditions: loyaltyDefaultTermsAndConditions,
  ),
  LoyaltyProduct(
    imageUrl:
        'https://images.samsung.com/is/image/samsung/assets/in/tablets/galaxy-tab-s10/buy/S10-Plus_Color-Selection_Platinum-Silver_PC_1600x864.png?imbypass=true',
    brandName: 'SAMSUNG',
    title: 'Samsung Galaxy Tab S10+ 12GB/256GB',
    store: 'Chip Mong 271 Mega Mall',
    points: 10,
    pointCondition: 'Samsung Galaxy Tab S10+ 12GB/256GB',
    termsAndConditions: loyaltyDefaultTermsAndConditions,
  ),
  LoyaltyProduct(
    imageUrl:
        'https://m.media-amazon.com/images/I/71-D1xCuVwL._AC_UF894,1000_QL80_.jpg',
    brandName: 'Apple',
    title: 'MacBook Air M3 13" 8GB/256GB',
    store: 'Chip Mong 271 Mega Mall',
    points: 95000,
    pointCondition: 'MacBook Air M3 13" 8GB/256GB',
    termsAndConditions: loyaltyDefaultTermsAndConditions,
  ),
];
