import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Domain models
// ---------------------------------------------------------------------------

class ChipmongMallCategory {
  final IconData icon;
  final String label;
  final bool hasBadge;
  final String? badgeLabel;

  const ChipmongMallCategory({
    required this.icon,
    required this.label,
    this.hasBadge = false,
    this.badgeLabel,
  });
}

class ChipmongMallPromotion {
  final String imageUrl;
  final String brandName;
  final String title;
  final String date;
  final bool isActive;

  const ChipmongMallPromotion({
    required this.imageUrl,
    required this.brandName,
    required this.title,
    required this.date,
    this.isActive = true,
  });
}

class ChipmongMallLoyaltyInfo {
  final String username;
  final String memberId;
  final String tier;
  final int points;
  final String expiryDate;

  const ChipmongMallLoyaltyInfo({
    required this.username,
    required this.memberId,
    required this.tier,
    required this.points,
    required this.expiryDate,
  });
}

// ---------------------------------------------------------------------------
// Static / mock data
// ---------------------------------------------------------------------------

const chipmongMallDefaultLoyalty = ChipmongMallLoyaltyInfo(
  username: 'Jame',
  memberId: '224256797',
  tier: 'LIFESTYLE',
  points: 30,
  expiryDate: '2027-02-25',
);

const chipmongMallCategories = <ChipmongMallCategory>[
  ChipmongMallCategory(
    icon: Icons.card_giftcard,
    label: 'កម្មវិធីស្មោះស្ម័គ្រ',
    hasBadge: true,
    badgeLabel: 'SALE',
  ),
  ChipmongMallCategory(
    icon: Icons.shopping_bag_outlined,
    label: 'ហាងទំនិញ',
  ),
  ChipmongMallCategory(
    icon: Icons.restaurant,
    label: 'ភោជនីយដ្ឋាន',
  ),
  ChipmongMallCategory(
    icon: Icons.sports_esports_outlined,
    label: 'ហ្គេមកម្សាន្ត',
  ),
  ChipmongMallCategory(
    icon: Icons.apps,
    label: 'ច្រើនបន្ថែម',
  ),
];

final chipmongMallBannerImages = <String>[
  'https://www.chipmong.com/wp-content/uploads/2020/04/2.Chip-mong-Supermarket-.jpg',
  'https://www.apacoutlookmag.com/media/chip-mong-retail-1-1597331139.profileImage.2x-1536x884.webp',
  'https://cdn.kiripost.com/static/images/_WC19073.2e16d0ba.fill-960x540.jpg',
];

final chipmongMallPromotions = <ChipmongMallPromotion>[
  const ChipmongMallPromotion(
    imageUrl:
        'https://cdn.kiripost.com/static/images/_WC19073.2e16d0ba.fill-960x540.jpg',
    brandName: 'The Pizza Company',
    title: 'BITE BOX SET! 🍕',
    date: 'Jan 28, 2026',
  ),
  const ChipmongMallPromotion(
    imageUrl:
        'https://www.apacoutlookmag.com/media/chip-mong-retail-1-1597331139.profileImage.2x-1536x884.webp',
    brandName: "LEVI'S",
    title: 'MID SEASON SALE ✨',
    date: 'Mar 20, 2026',
  ),
  const ChipmongMallPromotion(
    imageUrl:
        'https://www.chipmong.com/wp-content/uploads/portfolio/retail/598-Mall/2.jpg',
    brandName: 'FILA',
    title: 'New Collection',
    date: 'Mar 10, 2026',
  ),
  const ChipmongMallPromotion(
    imageUrl:
        'https://www.chipmong.com/wp-content/uploads/2020/04/2.Chip-mong-Supermarket-.jpg',
    brandName: 'Chip Mong Retail',
    title: 'Weekend Deals 🛒',
    date: 'Mar 15, 2026',
  ),
];

final chipmongMallPrograms = <ChipmongMallPromotion>[
  const ChipmongMallPromotion(
    imageUrl:
        'https://www.chipmong.com/wp-content/uploads/2022/02/1-585x391.jpg',
    brandName: 'Chip Mong Mall',
    title: 'Loyalty Rewards Program',
    date: 'Feb 01, 2026',
  ),
  const ChipmongMallPromotion(
    imageUrl:
        'https://www.chipmong.com/wp-content/uploads/2020/12/DSC_7842-1-585x391.jpg',
    brandName: 'Chip Mong Mall',
    title: 'Members Exclusive Benefits',
    date: 'Mar 01, 2026',
  ),
];

final chipmongMallNews = <ChipmongMallPromotion>[
  const ChipmongMallPromotion(
    imageUrl:
        'https://www.apacoutlookmag.com/media/chip-mong-retail-1-1597331139.profileImage.2x-1536x884.webp',
    brandName: 'Chip Mong',
    title: 'Grand Reopening 2026',
    date: 'Mar 21, 2026',
  ),
  const ChipmongMallPromotion(
    imageUrl:
        'https://cdn.kiripost.com/static/images/_WC19073.2e16d0ba.fill-960x540.jpg',
    brandName: 'Chip Mong',
    title: 'New Outlet Opening',
    date: 'Mar 25, 2026',
  ),
];
