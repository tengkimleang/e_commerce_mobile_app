import 'package:e_commerce_mobile_app/modules/home_screen/view/product_detail_view.dart';
import 'package:flutter/material.dart';

import 'package:e_commerce_mobile_app/core/models/product_item.dart';
import 'package:e_commerce_mobile_app/core/data/product_data.dart';

class PriceCheckingView extends StatefulWidget {
  final bool selectionMode;
  final List<ProductItem> products;

  const PriceCheckingView({
    super.key,
    this.selectionMode = false,
    this.products = const [],
  });

  @override
  State<PriceCheckingView> createState() => _PriceCheckingViewState();
}

class _PriceCheckingViewState extends State<PriceCheckingView> {
  final TextEditingController _searchController = TextEditingController();
  late List<ProductItem> _displayedProducts;
  final Set<String> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _displayedProducts = List<ProductItem>.from(widget.products);
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final q = _searchController.text.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _displayedProducts = List<ProductItem>.from(widget.products);
      } else {
        _displayedProducts = widget.products
            .where((p) => p.name.toLowerCase().contains(q))
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFFEC407A),
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Scan barcode',
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Barcode scan tapped')),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search products',
                    border: InputBorder.none,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => _searchController.clear(),
                          )
                        : null,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                itemCount: _displayedProducts.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (context, index) {
                  final product = _displayedProducts[index];
                  final isSelected = _selectedIds.contains(product.id);

                  return _ProductCard(
                    product: product,
                    isSelected: isSelected,
                    onTap: () {
                      if (widget.selectionMode) {
                        setState(() {
                          if (isSelected) {
                            _selectedIds.remove(product.id);
                          } else {
                            _selectedIds.add(product.id);
                          }
                        });
                        return;
                      }

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ProductDetailView(
                            product: product,
                            relatedProducts: widget.products,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // Selection bottom bar (only when in selection mode)
      bottomNavigationBar: widget.selectionMode
          ? SafeArea(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: _selectedIds.isEmpty ? 0 : 72,
                child: _selectedIds.isEmpty
                    ? const SizedBox.shrink()
                    : Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: const BoxDecoration(
                          color: Color(0xFFEC407A),
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${_selectedIds.length} Items',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 110,
                              height: 44,
                              child: ElevatedButton(
                                onPressed: () {
                                  final base = widget.products.isEmpty
                                      ? ProductData.allProducts
                                      : widget.products;
                                  final selected = base
                                      .where((p) => _selectedIds.contains(p.id))
                                      .map((product) {
                                        return {
                                          'id': product.id,
                                          'title': product.name,
                                          'price':
                                              '\$ ${product.price.toStringAsFixed(2)}',
                                          'image': product.imageUrl,
                                        };
                                      })
                                      .toList();

                                  Navigator.of(context).pop(selected);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFFEC407A),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Add'),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            )
          : null,
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductItem product;
  final bool isSelected;
  final VoidCallback onTap;

  const _ProductCard({
    required this.product,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: Image.network(
                    product.imageUrl,
                    height: 110,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '\$ ${product.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Color(0xFFE91E63),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Icon(
                            Icons.favorite_border,
                            color: Colors.pink,
                            size: 20,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isSelected)
          Positioned(
            top: 8,
            right: 8,
            child: Material(
              color: Colors.white,
              shape: const CircleBorder(),
              elevation: 2,
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: Icon(
                  Icons.check_circle,
                  color: Color(0xFFEC407A),
                  size: 20,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
