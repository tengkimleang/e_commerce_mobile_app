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
  final String description;
  final bool isActive;

  const ChipmongMallPromotion({
    required this.imageUrl,
    required this.brandName,
    required this.title,
    required this.date,
    this.description = '',
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

final chipmongMallPromotions = <ChipmongMallPromotion>[
  const ChipmongMallPromotion(
    imageUrl:
        'https://cdn.kiripost.com/static/images/_WC19073.2e16d0ba.fill-960x540.jpg',
    brandName: 'The Pizza Company',
    title: 'BITE BOX SET! 🍕',
    date: 'Jan 28, 2026',
    description:
        'BITE BOX SET! 🍕\n\n'
        'Special combo menu for friends and family at The Pizza Company. '
        'Get crispy chicken, signature pizza and drinks in one value set.\n\n'
        'Available every day at Chip Mong Mall branch.\n\n'
        'Promotion period: Jan 28, 2026 - Feb 28, 2026\n'
        'For reservation, please contact the restaurant directly.',
  ),
  const ChipmongMallPromotion(
    imageUrl:
        'https://www.apacoutlookmag.com/media/chip-mong-retail-1-1597331139.profileImage.2x-1536x884.webp',
    brandName: "LEVI'S",
    title: 'MID SEASON SALE ✨',
    date: 'Mar 20, 2026',
    description:
        'MID SEASON SALE ✨\n\n'
        'Enjoy up to 50% off selected LEVI\'S items including jeans, tops '
        'and accessories.\n\n'
        'Offer valid while stocks last and may vary by size availability.\n\n'
        'Visit LEVI\'S store at Chip Mong Mall for full promotion details.',
  ),
  const ChipmongMallPromotion(
    imageUrl:
        'https://www.chipmong.com/wp-content/uploads/portfolio/retail/598-Mall/2.jpg',
    brandName: 'FILA',
    title: 'New Collection',
    date: 'Mar 10, 2026',
    description:
        'FILA New Collection has arrived.\n\n'
        'Check out new arrivals for sportswear and lifestyle outfits with '
        'limited launch offers.\n\n'
        'Members can enjoy extra benefits at checkout.\n\n'
        'Campaign date: Mar 10, 2026 onward.',
  ),
  const ChipmongMallPromotion(
    imageUrl:
        'https://www.chipmong.com/wp-content/uploads/2020/04/2.Chip-mong-Supermarket-.jpg',
    brandName: 'Chip Mong Retail',
    title: 'Weekend Deals 🛒',
    date: 'Mar 15, 2026',
    description:
        'Weekend Deals 🛒\n\n'
        'Save more on groceries, household essentials and selected imported '
        'products every weekend.\n\n'
        'Look for in-store labels to find special prices.\n\n'
        'Promotion valid every Saturday and Sunday.',
  ),
];

final chipmongMallPrograms = <ChipmongMallPromotion>[
  const ChipmongMallPromotion(
    imageUrl:
        'https://www.chipmong.com/wp-content/uploads/2022/02/1-585x391.jpg',
    brandName: 'Chip Mong Mall',
    title: 'Loyalty Rewards Program',
    date: 'Feb 01, 2026',
    description:
        'Join Chip Mong Mall Loyalty Rewards Program today.\n\n'
        'Earn points on purchases and redeem exciting rewards from partner '
        'stores.\n\n'
        'Members also receive exclusive birthday and seasonal offers.',
  ),
  const ChipmongMallPromotion(
    imageUrl:
        'https://www.chipmong.com/wp-content/uploads/2020/12/DSC_7842-1-585x391.jpg',
    brandName: 'Chip Mong Mall',
    title: 'Members Exclusive Benefits',
    date: 'Mar 01, 2026',
    description:
        'Members Exclusive Benefits for all registered customers.\n\n'
        'Get priority campaign access, point boosters and selected store '
        'discounts.\n\n'
        'Please present your member QR code at checkout.',
  ),
];

final chipmongMallNews = <ChipmongMallPromotion>[
  const ChipmongMallPromotion(
    imageUrl:
        'https://www.apacoutlookmag.com/media/chip-mong-retail-1-1597331139.profileImage.2x-1536x884.webp',
    brandName: 'Chip Mong',
    title: 'Grand Reopening 2026',
    date: 'Mar 21, 2026',
    description:
        'Chip Mong Mall announces the Grand Reopening 2026 celebration.\n\n'
        'Enjoy store activations, live performances and opening day gifts.\n\n'
        'Please follow the official page for updated schedule and activities.',
  ),
  const ChipmongMallPromotion(
    imageUrl:
        'https://cdn.kiripost.com/static/images/_WC19073.2e16d0ba.fill-960x540.jpg',
    brandName: 'Chip Mong',
    title: 'New Outlet Opening',
    date: 'Mar 25, 2026',
    description:
        'New Outlet Opening at Chip Mong Mall.\n\n'
        'Discover new brands and opening promotions prepared for shoppers.\n\n'
        'Visit us on Mar 25, 2026 to enjoy launch-day discounts.',
  ),
];
