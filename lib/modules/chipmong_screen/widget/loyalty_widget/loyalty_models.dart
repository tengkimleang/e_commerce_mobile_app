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
    gradient: [Color.fromARGB(255, 244, 143, 177), Color.fromARGB(255, 178, 147, 157)],
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
  final String imageUrl;
  final String brandName;
  final String title;
  final String store;
  final int points;

  const LoyaltyProduct({
    required this.imageUrl,
    required this.brandName,
    required this.title,
    required this.store,
    required this.points,
  });
}

const loyaltyMockProducts = <LoyaltyProduct>[
  LoyaltyProduct(
    imageUrl:
        'https://arystorephone.com/wp-content/uploads/2025/06/galaxy-zfold7-blueshadow.jpg',
    brandName: 'SAMSUNG',
    title: 'Samsung Galaxy Z Fold7 12+256GB',
    store: 'Chip Mong 271 Mega Mall',
    points: 81999,
  ),
  LoyaltyProduct(
    imageUrl:
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTX1xLn8U0gUCrtLY41YKZWW5fsH6sNG-_bpw&s',
    brandName: 'Apple',
    title: 'iPhone 17 Pro Max 512G (Refurbished)',
    store: 'Chip Mong 271 Mega Mall',
    points: 72399,
  ),
  LoyaltyProduct(
    imageUrl:
      'https://images.samsung.com/levant/smartphones/galaxy-s25-ultra/buy/product_color_black_PC.png',
    brandName: 'SAMSUNG',
    title: 'Samsung Galaxy S25 Ultra 512GB',
    store: 'Chip Mong 271 Mega Mall',
    points: 69899,
  ),
  LoyaltyProduct(
    imageUrl:
        
        'https://cdsassets.apple.com/live/7WUAS350/images/tech-specs/ipad-pro-11-inch-13-inch.png',
    brandName: 'Apple',
    title: 'iPad Pro M4 13-inch 256GB',
    store: 'Chip Mong 271 Mega Mall',
    points: 55000,
  ),
  LoyaltyProduct(
    imageUrl:
        'https://images.samsung.com/is/image/samsung/assets/in/tablets/galaxy-tab-s10/buy/S10-Plus_Color-Selection_Platinum-Silver_PC_1600x864.png?imbypass=true',
    brandName: 'SAMSUNG',
    title: 'Samsung Galaxy Tab S10+ 12GB/256GB',
    store: 'Chip Mong 271 Mega Mall',
    points: 42500,
  ),
  LoyaltyProduct(
    imageUrl:
    'https://m.media-amazon.com/images/I/71-D1xCuVwL._AC_UF894,1000_QL80_.jpg',
    brandName: 'Apple',
    title: 'MacBook Air M3 13" 8GB/256GB',
    store: 'Chip Mong 271 Mega Mall',
    points: 95000,
  ),
];
