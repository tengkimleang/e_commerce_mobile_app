import 'package:e_commerce_mobile_app/core/common/di.dart';
import 'package:e_commerce_mobile_app/core/data/categories_repository.dart';
import 'package:e_commerce_mobile_app/core/models/product_item.dart';
import 'package:e_commerce_mobile_app/modules/home_screen/view/product_detail_view.dart';
import 'package:e_commerce_mobile_app/modules/home_screen/view/widgets/product_card.dart';
import 'package:e_commerce_mobile_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

// ── shared data (mirrors shop_by_country_section.dart) ──────────────────────

class CountryEntry {
  final String name;
  final String flag;
  const CountryEntry({required this.name, required this.flag});

  String displayName(AppLocalizations? l10n) => _localizedCountryName(
    l10n,
    name,
  );
}

// Products are filtered by ProductModel.countryOfOrigin — no hardcoded ID map needed.

const kCountries = [
  CountryEntry(name: 'Cambodia', flag: '🇰🇭'),
  CountryEntry(name: 'Canada', flag: '🇨🇦'),
  CountryEntry(name: 'Egypt', flag: '🇪🇬'),
  CountryEntry(name: 'South Korea', flag: '🇰🇷'),
  CountryEntry(name: 'Japan', flag: '🇯🇵'),
  CountryEntry(name: 'China', flag: '🇨🇳'),
  CountryEntry(name: 'Singapore', flag: '🇸🇬'),
  CountryEntry(name: 'Italy', flag: '🇮🇹'),
  CountryEntry(name: 'Spain', flag: '🇪🇸'),
  CountryEntry(name: 'Indonesia', flag: '🇮🇩'),
  CountryEntry(name: 'Argentina', flag: '🇦🇷'),
  CountryEntry(name: 'United States', flag: '🇺🇸'),
  CountryEntry(name: 'France', flag: '🇫🇷'),
];

// ── Screen ───────────────────────────────────────────────────────────────────

class ShopByCountryView extends StatefulWidget {
  final String? initialCountry;

  const ShopByCountryView({super.key, this.initialCountry});

  @override
  State<ShopByCountryView> createState() => _ShopByCountryViewState();
}

class _ShopByCountryViewState extends State<ShopByCountryView> {
  late String _selectedCountry;
  List<ProductModel> _products = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selectedCountry = widget.initialCountry ?? kCountries.first.name;
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final (products, _) = await di<CategoriesRepository>()
          .fetchProductsByCountry(_selectedCountry, pageSize: 100);
      if (mounted) {
        setState(() {
          _products = products;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final l10n = Localizations.of<AppLocalizations>(
      context,
      AppLocalizations,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        centerTitle: true,
        title: Text(
          l10n?.shopByCountry ?? 'Shop by country',
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
      ),
      body: Row(
        children: [
          // ── Left: country list ──────────────────────────────────────────
          Container(
            width: 110,
            color: Colors.white,
            child: ListView.builder(
              itemCount: kCountries.length,
              itemBuilder: (context, index) {
                final country = kCountries[index];
                final isSelected = country.name == _selectedCountry;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedCountry = country.name);
                    _loadProducts();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? accent
                          : accent.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          country.flag,
                          style: const TextStyle(fontSize: 28),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          country.displayName(l10n).toUpperCase(),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? Colors.white : Colors.black87,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // ── Right: product grid ─────────────────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.grey,
                          size: 40,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n?.failedToLoadProducts ??
                              'Failed to load products',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _loadProducts,
                          child: Text(l10n?.retry ?? 'Retry'),
                        ),
                      ],
                    ),
                  )
                : _products.isEmpty
                ? Center(child: Text(l10n?.noProducts ?? 'No products'))
                : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _products.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.72,
                        ),
                    itemBuilder: (context, index) {
                      final product = _products[index];
                      final country = kCountries.firstWhere(
                        (c) => c.name == _selectedCountry,
                      );
                      return ProductCard(
                        product: product,
                        countryLabel:
                            '${country.displayName(l10n)} ${country.flag}',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ProductDetailView(
                              product: product,
                              relatedProducts: _products,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
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
