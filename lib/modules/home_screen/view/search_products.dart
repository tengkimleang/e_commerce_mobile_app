import 'package:flutter/material.dart';
import 'package:e_commerce_mobile_app/modules/home_screen/model/product_model.dart';
import 'package:e_commerce_mobile_app/modules/home_screen/view/product_detail_view.dart';
import 'package:e_commerce_mobile_app/modules/home_screen/view/widgets/product_card.dart';

class SearchProducts extends StatefulWidget {
  final List<ProductModel> products;

  const SearchProducts({super.key, required this.products});

  @override
  State<SearchProducts> createState() => _SearchProductsState();
}

class _SearchProductsState extends State<SearchProducts> {
  final _controller = TextEditingController();
  late List<ProductModel> _filtered;

  @override
  void initState() {
    super.initState();
    _filtered = List.from(widget.products);
    _controller.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final q = _controller.text.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _filtered = List.from(widget.products);
      } else {
        _filtered = widget.products
            .where((p) => p.name.toLowerCase().contains(q))
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onSearchChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Search products, brands and more',
                prefixIcon: const Icon(Icons.search, color: Color(0xFFEC407A)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      backgroundColor: const Color(0xFFF6F6F6),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: _filtered.isEmpty
            ? const Center(child: Text('No products found'))
            : GridView.builder(
                itemCount: _filtered.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.80,
                ),
                itemBuilder: (context, index) {
                  final product = _filtered[index];
                  return ProductCard(
                    product: product,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ProductDetailView(
                          product: product,
                          relatedProducts: widget.products,
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
