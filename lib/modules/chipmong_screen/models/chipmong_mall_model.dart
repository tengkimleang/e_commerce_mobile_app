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
  final List<String> imageUrls;
  final String brandName;
  final String title;
  final String date;
  final String description;
  final bool isActive;

  const ChipmongMallPromotion({
    required this.imageUrl,
    this.imageUrls = const [],
    required this.brandName,
    required this.title,
    required this.date,
    this.description = '',
    this.isActive = true,
  });

  List<String> get galleryImages => imageUrls.isEmpty ? [imageUrl] : imageUrls;
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
  username: 'Member',
  memberId: '000000000',
  tier: 'LIFESTYLE',
  points: 0,
  expiryDate: '--',
);

const chipmongMallCategories = <ChipmongMallCategory>[
  ChipmongMallCategory(
    icon: Icons.card_giftcard,
    label: 'កម្មវិធីស្មោះស្ម័គ្រ',
    hasBadge: true,
    badgeLabel: 'SALE',
  ),
  ChipmongMallCategory(icon: Icons.shopping_bag_outlined, label: 'ហាងទំនិញ'),
  ChipmongMallCategory(icon: Icons.restaurant, label: 'ភោជនីយដ្ឋាន'),
  ChipmongMallCategory(
    icon: Icons.sports_esports_outlined,
    label: 'ហ្គេមកម្សាន្ត',
  ),
  ChipmongMallCategory(icon: Icons.apps, label: 'ច្រើនបន្ថែម'),
];

final chipmongMallBannerImages = <String>[
  'https://www.chipmong.com/wp-content/uploads/2020/04/2.Chip-mong-Supermarket-.jpg',
  'https://www.apacoutlookmag.com/media/chip-mong-retail-1-1597331139.profileImage.2x-1536x884.webp',
  'https://cdn.kiripost.com/static/images/_WC19073.2e16d0ba.fill-960x540.jpg',
];

const _chipmongMallKhmerDetailFromDesign =
    'ARMY! ARE YOU READY? 🔥 សម្រាប់ការផ្សាយផ្ទាល់ក៏នៅជិតមកដល់ទៀតហើយ 😱\n\n'
    'ត្រៀមខ្លួនចាំទិញសំបុត្រឱ្យហើយណា សម្រាប់ BTS WORLD TOUS ARIRANG! '
    'មកបង្ហាញភាពគាំទ្រក្នុងនាមអ្នកជា ARMY 🥰💜\n\n'
    'ដោយសារតែការគាំទ្រខ្លាំងក្លាក្នុងការទន្ទឹងរង់ចាំមើលជាយូរ '
    'Live Stream <BTS WORLD TOUR AIRANG> នឹងត្រូវបានបញ្ចាំងនៅផ្សារទំនើបជីបម៉ុង ម៉ល 271 '
    'នៅថ្ងៃទី 11 មេសា 2026\n\n'
    '⏰ មើលព័ត៌មានលម្អិតបន្ថែម https://bit.ly/42VKAlz\n'
    '🍿 ទិញតាម Tiktok: សម្រាប់ព័ត៌មានបន្ថែម https://tinyurl.com/nu26cc4c';

final chipmongMallPromotions = <ChipmongMallPromotion>[
  const ChipmongMallPromotion(
    imageUrl:
        'https://cdn.kiripost.com/static/images/_WC19073.2e16d0ba.fill-960x540.jpg',
    imageUrls: [
      'https://cdn.kiripost.com/static/images/_WC19073.2e16d0ba.fill-960x540.jpg',
      'https://www.apacoutlookmag.com/media/chip-mong-retail-1-1597331139.profileImage.2x-1536x884.webp',
      'https://www.chipmong.com/wp-content/uploads/portfolio/retail/598-Mall/2.jpg',
    ],
    brandName: 'The Pizza Company',
    title: 'BITE BOX SET! 🍕',
    date: 'Jan 28, 2026',
    description: _chipmongMallKhmerDetailFromDesign,
  ),
  const ChipmongMallPromotion(
    imageUrl:
        'https://www.apacoutlookmag.com/media/chip-mong-retail-1-1597331139.profileImage.2x-1536x884.webp',
    imageUrls: [
      'https://www.apacoutlookmag.com/media/chip-mong-retail-1-1597331139.profileImage.2x-1536x884.webp',
      'https://www.chipmong.com/wp-content/uploads/2020/04/2.Chip-mong-Supermarket-.jpg',
    ],
    brandName: "LEVI'S",
    title: 'MID SEASON SALE ✨',
    date: 'Mar 20, 2026',
    description: _chipmongMallKhmerDetailFromDesign,
  ),
  const ChipmongMallPromotion(
    imageUrl:
        'https://www.chipmong.com/wp-content/uploads/portfolio/retail/598-Mall/2.jpg',
    brandName: 'FILA',
    title: 'New Collection',
    date: 'Mar 10, 2026',
    description: _chipmongMallKhmerDetailFromDesign,
  ),
  const ChipmongMallPromotion(
    imageUrl:
        'https://www.chipmong.com/wp-content/uploads/2020/04/2.Chip-mong-Supermarket-.jpg',
    brandName: 'Chip Mong Retail',
    title: 'Weekend Deals 🛒',
    date: 'Mar 15, 2026',
    description: _chipmongMallKhmerDetailFromDesign,
  ),
];

final chipmongMallPrograms = <ChipmongMallPromotion>[
  const ChipmongMallPromotion(
    imageUrl:
        'https://www.chipmong.com/wp-content/uploads/2022/02/1-585x391.jpg',
    imageUrls: [
      'https://www.chipmong.com/wp-content/uploads/2022/02/1-585x391.jpg',
      'https://www.chipmong.com/wp-content/uploads/2020/12/DSC_7842-1-585x391.jpg',
    ],
    brandName: 'Chip Mong Mall',
    title: 'Loyalty Rewards Program',
    date: 'Feb 01, 2026',
    description: _chipmongMallKhmerDetailFromDesign,
  ),
  const ChipmongMallPromotion(
    imageUrl:
        'https://www.chipmong.com/wp-content/uploads/2020/12/DSC_7842-1-585x391.jpg',
    brandName: 'Chip Mong Mall',
    title: 'Members Exclusive Benefits',
    date: 'Mar 01, 2026',
    description: _chipmongMallKhmerDetailFromDesign,
  ),
];

final chipmongMallNews = <ChipmongMallPromotion>[
  const ChipmongMallPromotion(
    imageUrl:
        'https://www.apacoutlookmag.com/media/chip-mong-retail-1-1597331139.profileImage.2x-1536x884.webp',
    brandName: 'Chip Mong',
    title: 'Grand Reopening 2026',
    date: 'Mar 21, 2026',
    description: _chipmongMallKhmerDetailFromDesign,
  ),
  const ChipmongMallPromotion(
    imageUrl:
        'https://cdn.kiripost.com/static/images/_WC19073.2e16d0ba.fill-960x540.jpg',
    brandName: 'Chip Mong',
    title: 'New Outlet Opening',
    date: 'Mar 25, 2026',
    description: _chipmongMallKhmerDetailFromDesign,
  ),
];
