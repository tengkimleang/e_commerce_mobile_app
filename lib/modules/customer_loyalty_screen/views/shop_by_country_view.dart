import 'package:e_commerce_mobile_app/core/models/product_item.dart';
import 'package:e_commerce_mobile_app/modules/home_screen/view/product_detail_view.dart';
import 'package:e_commerce_mobile_app/modules/home_screen/view/widgets/product_card.dart';
import 'package:flutter/material.dart';

// ── shared data (mirrors shop_by_country_section.dart) ──────────────────────

class CountryEntry {
  final String name;
  final String flag;
  const CountryEntry({required this.name, required this.flag});
}

const kCountryProductIds = {
  'Cambodia':      ['1', '2', '3', '4'],
  'Canada':        ['25', '26', '27', '28'],
  'Egypt':         ['29', '30', '31', '32'],
  'South Korea':   ['21', '22', '23', '24'],
  'Japan':         ['9', '10', '11', '12'],
  'China':         ['13', '14', '15', '16'],
  'Singapore':     ['17', '18', '19', '20'],
  'Italy':         ['5', '6', '7', '8'],
  'Spain':         ['33', '34', '36', '37'],
  'Indonesia':     ['1', '5', '13', '17'],
  'Argentina':     ['2', '6', '10', '18'],
  'United States': ['25', '29', '33', '9'],
  'France':        ['3', '7', '11', '15'],
};

const kCountries = [
  CountryEntry(name: 'Cambodia',      flag: '🇰🇭'),
  CountryEntry(name: 'Canada',        flag: '🇨🇦'),
  CountryEntry(name: 'Egypt',         flag: '🇪🇬'),
  CountryEntry(name: 'South Korea',   flag: '🇰🇷'),
  CountryEntry(name: 'Japan',         flag: '🇯🇵'),
  CountryEntry(name: 'China',         flag: '🇨🇳'),
  CountryEntry(name: 'Singapore',     flag: '🇸🇬'),
  CountryEntry(name: 'Italy',         flag: '🇮🇹'),
  CountryEntry(name: 'Spain',         flag: '🇪🇸'),
  CountryEntry(name: 'Indonesia',     flag: '🇮🇩'),
  CountryEntry(name: 'Argentina',     flag: '🇦🇷'),
  CountryEntry(name: 'United States', flag: '🇺🇸'),
  CountryEntry(name: 'France',        flag: '🇫🇷'),
];

// ── Screen ───────────────────────────────────────────────────────────────────

class ShopByCountryView extends StatefulWidget {
  final List<ProductModel> allProducts;
  final String? initialCountry;

  const ShopByCountryView({
    super.key,
    required this.allProducts,
    this.initialCountry,
  });

  @override
  State<ShopByCountryView> createState() => _ShopByCountryViewState();
}

class _ShopByCountryViewState extends State<ShopByCountryView> {
  late String _selectedCountry;

  @override
  void initState() {
    super.initState();
    _selectedCountry = widget.initialCountry ?? kCountries.first.name;
  }

  List<ProductModel> get _products {
    final ids = kCountryProductIds[_selectedCountry] ?? [];
    return widget.allProducts.where((p) => ids.contains(p.id)).toList();
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFEC407A);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        centerTitle: true,
        title: const Text(
          'Shop by country',
          style: TextStyle(
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
                  onTap: () =>
                      setState(() => _selectedCountry = country.name),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 6),
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
                          country.name.toUpperCase(),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color:
                                isSelected ? Colors.white : Colors.black87,
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
            child: _products.isEmpty
                ? const Center(child: Text('No products'))
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
                        countryLabel: '${country.name} ${country.flag}',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ProductDetailView(
                              product: product,
                              relatedProducts: widget.allProducts,
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
