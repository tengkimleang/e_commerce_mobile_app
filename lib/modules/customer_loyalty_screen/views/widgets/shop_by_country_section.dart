import 'package:e_commerce_mobile_app/core/models/product_item.dart';
import 'package:e_commerce_mobile_app/modules/customer_loyalty_screen/views/shop_by_country_view.dart';
import 'package:e_commerce_mobile_app/modules/home_screen/view/product_detail_view.dart';
import 'package:e_commerce_mobile_app/modules/home_screen/view/widgets/product_card.dart';
import 'package:flutter/material.dart';

// Country model
class _Country {
  final String name;
  final String flag; // emoji flag
  const _Country({required this.name, required this.flag});
}

// Products are filtered by ProductModel.countryOfOrigin — no hardcoded ID map needed.

const _countries = [
  _Country(name: 'Cambodia',      flag: '🇰🇭'),
  _Country(name: 'Canada',        flag: '🇨🇦'),
  _Country(name: 'Egypt',         flag: '🇪🇬'),
  _Country(name: 'South Korea',   flag: '🇰🇷'),
  _Country(name: 'Japan',         flag: '🇯🇵'),
  _Country(name: 'China',         flag: '🇨🇳'),
  _Country(name: 'Singapore',     flag: '🇸🇬'),
  _Country(name: 'Italy',         flag: '🇮🇹'),
  _Country(name: 'Spain',         flag: '🇪🇸'),
  _Country(name: 'Indonesia',     flag: '🇮🇩'),
  _Country(name: 'Argentina',     flag: '🇦🇷'),
  _Country(name: 'United States', flag: '🇺🇸'),
  _Country(name: 'France',        flag: '🇫🇷'),
];

class ShopByCountrySection extends StatefulWidget {
  final List<ProductModel> allProducts;

  const ShopByCountrySection({super.key, required this.allProducts});

  @override
  State<ShopByCountrySection> createState() => _ShopByCountrySectionState();
}

class _ShopByCountrySectionState extends State<ShopByCountrySection> {
  String? _selected; // null = All

  List<ProductModel> get _filtered {
    if (_selected == null) return widget.allProducts;
    return widget.allProducts
        .where((p) =>
            p.countryOfOrigin?.toLowerCase() == _selected!.toLowerCase())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFEC407A);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Text(
                'Shop by country',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ShopByCountryView(
                      allProducts: widget.allProducts,
                      initialCountry: _selected,
                    ),
                  ),
                ),
                child: Row(
                  children: const [
                    Text(
                      'View all',
                      style: TextStyle(
                        fontSize: 14,
                        color: accent,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(Icons.chevron_right, color: accent, size: 18),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Country filter chips
        SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _Chip(
                label: 'All',
                selected: _selected == null,
                onTap: () => setState(() => _selected = null),
              ),
              ..._countries.map((c) => Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: _Chip(
                      flag: c.flag,
                      label: c.name.toUpperCase(),
                      selected: _selected == c.name,
                      onTap: () => setState(() => _selected = c.name),
                    ),
                  )),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Product cards
        SizedBox(
          height: 260,
          child: _filtered.isEmpty
              ? const Center(child: Text('No products'))
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final product = _filtered[index];
                    return SizedBox(
                      width: 160,
                      child: ProductCard(
                        product: product,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ProductDetailView(
                              product: product,
                              relatedProducts: widget.allProducts,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final String? flag;
  final bool selected;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.flag,
  });

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFEC407A);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? accent : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? accent : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (flag != null) ...[
              Text(flag!, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.black87,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
