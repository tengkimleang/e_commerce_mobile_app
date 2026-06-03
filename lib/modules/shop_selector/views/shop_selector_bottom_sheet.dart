import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:e_commerce_mobile_app/l10n/generated/app_localizations.dart';
import 'package:e_commerce_mobile_app/modules/shop_selector/models/shop_option.dart';

Future<ShopOption?> showShopSelectorBottomSheet(
  BuildContext context, {
  required List<ShopOption> shops,
  required ShopOption selectedShop,
  bool isGuest = false,
}) {
  return showModalBottomSheet<ShopOption>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      final l10n = Localizations.of<AppLocalizations>(
        context,
        AppLocalizations,
      );
      return FractionallySizedBox(
        heightFactor: 0.86,
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF3F3F3),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 12, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n?.selectShop ?? 'Select shop',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.close,
                        color: Color(0xFF7A7A7A),
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.60,
                  ),
                  itemCount: shops.length,
                  itemBuilder: (context, index) {
                    final shop = shops[index];
                    final isSelected = shop.shopId.isNotEmpty
                        ? shop.shopId == selectedShop.shopId
                        : shop.storeName == selectedShop.storeName;
                    return _ShopCard(
                      shop: shop,
                      selected: isSelected,
                      showGuestLock: isGuest && !shop.guestAllowed,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _ShopCard extends StatelessWidget {
  const _ShopCard({
    required this.shop,
    required this.selected,
    required this.showGuestLock,
  });

  final ShopOption shop;
  final bool selected;
  final bool showGuestLock;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations);

    String storeName = shop.displayStoreName.isNotEmpty
        ? shop.displayStoreName
        : 'CHIP MONG';
        
    String mainTitle = 'CHIP MONG';
    String subTitle = shop.displayBranchLabel;

    if (storeName.toLowerCase().startsWith('chip mong')) {
      String remaining = storeName.substring('chip mong'.length).trim();
      if (remaining.isNotEmpty) {
        subTitle = remaining;
      }
    }

    return InkWell(
      onTap: () => Navigator.of(context).pop(shop),
      borderRadius: BorderRadius.circular(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final imageRatio = showGuestLock ? 0.45 : 0.50;
          final imageHeight = (constraints.maxHeight * imageRatio).clamp(
            104.0,
            150.0,
          );

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected ? accent : Colors.transparent,
                width: selected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(15),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: shop.imageUrl,
                        height: imageHeight,
                        fit: BoxFit.cover,
                        placeholder: (c, s) => Container(color: Colors.grey[200]),
                        errorWidget: (c, s, e) => Container(color: Colors.grey[300]),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 58),
                              child: Text(
                                mainTitle,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: accent,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerRight,
                              child: Text(
                                subTitle.toUpperCase(),
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: accent,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const Spacer(),
                            if (shop.distanceKm != null)
                              Text(
                                '${shop.distanceKm!.toStringAsFixed(2)} Km',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.black45,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            if (showGuestLock) ...[
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFDE3EF),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.lock_outline,
                                      size: 10,
                                      color: accent,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      l10n?.loginRequired ?? 'Login required',
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: accent,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  left: 12,
                  top: imageHeight - 24,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/icons/icon.png',
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(
                            color: accent,
                            child: const Icon(Icons.storefront, color: Colors.white, size: 24),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
