import 'package:e_commerce_mobile_app/core/common/di.dart';
import 'package:e_commerce_mobile_app/core/data/categories_repository.dart';
import 'package:e_commerce_mobile_app/core/models/product_item.dart';
import 'package:e_commerce_mobile_app/core/widgets/app_skeleton.dart';
import 'package:e_commerce_mobile_app/modules/customer_loyalty_screen/views/shop_by_country_view.dart';
import 'package:e_commerce_mobile_app/modules/home_screen/view/product_detail_view.dart';
import 'package:e_commerce_mobile_app/modules/home_screen/view/widgets/product_card.dart';
import 'package:e_commerce_mobile_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

// Country model
class _Country {
  final String name;
  final String flag; // emoji flag
  const _Country({required this.name, required this.flag});

  String displayName(AppLocalizations? l10n) =>
      _localizedCountryName(l10n, name);
}

// Products are filtered by ProductModel.countryOfOrigin — no hardcoded ID map needed.

const _countries = [
  _Country(name: 'Cambodia', flag: '🇰🇭'),
  _Country(name: 'Canada', flag: '🇨🇦'),
  _Country(name: 'Egypt', flag: '🇪🇬'),
  _Country(name: 'South Korea', flag: '🇰🇷'),
  _Country(name: 'Japan', flag: '🇯🇵'),
  _Country(name: 'China', flag: '🇨🇳'),
  _Country(name: 'Singapore', flag: '🇸🇬'),
  _Country(name: 'Italy', flag: '🇮🇹'),
  _Country(name: 'Spain', flag: '🇪🇸'),
  _Country(name: 'Indonesia', flag: '🇮🇩'),
  _Country(name: 'Argentina', flag: '🇦🇷'),
  _Country(name: 'United States', flag: '🇺🇸'),
  _Country(name: 'France', flag: '🇫🇷'),
];

class ShopByCountrySection extends StatefulWidget {
  const ShopByCountrySection({super.key});

  @override
  State<ShopByCountrySection> createState() => _ShopByCountrySectionState();
}

class _ShopByCountrySectionState extends State<ShopByCountrySection> {
  String? _selected; // null = All
  List<ProductModel> _products = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      final List<ProductModel> result;
      if (_selected == null) {
        // "All" — use search with empty keyword to get all products
        final (products, _) = await di<CategoriesRepository>().searchProducts(
          '',
          pageSize: 100,
        );
        result = products;
      } else {
        final (products, _) = await di<CategoriesRepository>()
            .fetchProductsByCountry(_selected!, pageSize: 50);
        result = products;
      }
      if (mounted) {
        setState(() {
          _products = result;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<ProductModel> get _filtered => _products;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                l10n?.shopByCountry ?? 'Shop by country',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        ShopByCountryView(initialCountry: _selected),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      l10n?.viewAll ?? 'View all',
                      style: TextStyle(
                        fontSize: 14,
                        color: accent,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 2),
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
                label: l10n?.all ?? 'All',
                selected: _selected == null,
                onTap: () {
                  setState(() => _selected = null);
                  _loadProducts();
                },
              ),
              ..._countries.map(
                (c) => Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: _Chip(
                    flag: c.flag,
                    label: c.displayName(l10n).toUpperCase(),
                    selected: _selected == c.name,
                    onTap: () {
                      setState(() => _selected = c.name);
                      _loadProducts();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Product cards
        SizedBox(
          height: 260,
          child: _isLoading
              ? const _CountryProductSkeletonList()
              : _filtered.isEmpty
              ? Center(child: Text(l10n?.noProducts ?? 'No products'))
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filtered.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
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
                              relatedProducts: _products,
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

String _localizedCountryName(AppLocalizations? l10n, String countryName) {
  if (l10n == null) return countryName;
  return switch (countryName) {
    'Cambodia' => l10n.countryCambodia,
    'Canada' => l10n.countryCanada,
    'Egypt' => l10n.countryEgypt,
    'South Korea' => l10n.countrySouthKorea,
    'Japan' => l10n.countryJapan,
    'China' => l10n.countryChina,
    'Singapore' => l10n.countrySingapore,
    'Italy' => l10n.countryItaly,
    'Spain' => l10n.countrySpain,
    'Indonesia' => l10n.countryIndonesia,
    'Argentina' => l10n.countryArgentina,
    'United States' => l10n.countryUnitedStates,
    'France' => l10n.countryFrance,
    _ => countryName,
  };
}

class _CountryProductSkeletonList extends StatelessWidget {
  const _CountryProductSkeletonList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      key: const ValueKey('shop-by-country-products-skeleton'),
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 3,
      separatorBuilder: (context, index) => const SizedBox(width: 12),
      itemBuilder: (context, index) =>
          const SizedBox(width: 160, child: SkeletonProductCard()),
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
    final accent = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? accent : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? accent : Colors.grey.shade300),
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
