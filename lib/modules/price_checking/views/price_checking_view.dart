import 'package:e_commerce_mobile_app/modules/home_screen/view/product_detail_view.dart';
import 'package:e_commerce_mobile_app/modules/home_screen/view/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:e_commerce_mobile_app/core/common/di.dart';
import 'package:e_commerce_mobile_app/core/data/categories_repository.dart';
import 'package:e_commerce_mobile_app/core/models/product_item.dart';
import 'package:e_commerce_mobile_app/core/data/product_data.dart';
import 'package:e_commerce_mobile_app/core/router/app_router.dart';

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

class _PriceCheckingViewState extends State<PriceCheckingView>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late List<ProductItem> _displayedProducts;
  final Set<String> _selectedIds = {};
  bool _searchActive = false;

  late final AnimationController _animController;
  late final Animation<Offset> _titleSlideAnim;
  late final Animation<Offset> _searchBarSlideAnim;

  @override
  void initState() {
    super.initState();
    _displayedProducts = List<ProductItem>.from(widget.products);
    _searchController.addListener(_onSearchChanged);

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _titleSlideAnim = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-1.5, 0.0),
    ).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeInOut));

    _searchBarSlideAnim = Tween<Offset>(
      begin: const Offset(0.5, 0.0),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeInOut));
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

  void _activateSearch() {
    setState(() => _searchActive = true);
    _animController.forward();
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) _focusNode.requestFocus();
    });
  }

  void _deactivateSearch() {
    _focusNode.unfocus();
    _animController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _searchActive = false;
          _searchController.clear();
          _displayedProducts = List<ProductItem>.from(widget.products);
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _focusNode.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _onScanBarcode() async {
    final code = await Navigator.pushNamed<String>(
      context, AppRoutes.scanBarcode);
    if (code == null || !mounted) return;
    try {
      final product =
          await di<CategoriesRepository>().fetchProductByBarcode(code);
      if (!mounted) return;
      if (product == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product not found for this barcode')),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailView(product: product),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to look up product. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: 56,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Back button
                SizedBox(
                  width: 48,
                  child: IconButton(
                    icon: const Icon(Icons.chevron_left,
                        color: Colors.black, size: 28),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ),

                // Middle: title ↔ search bar animation
                Expanded(
                  child: ClipRect(
                    child: SizedBox(
                      height: 56,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // "Search" title — slides out to the left
                          SlideTransition(
                            position: _titleSlideAnim,
                            child: const Center(
                              child: Text(
                                'Search',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),

                          // Search bar — slides in from the right
                          if (_searchActive)
                            SlideTransition(
                              position: _searchBarSlideAnim,
                              child: Center(
                                child: Container(
                                  height: 40,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: const Color(0xFFEC407A),
                                        width: 1.5),
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const SizedBox(width: 10),
                                      const Icon(Icons.search,
                                          color: Color(0xFFEC407A), size: 20),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: TextField(
                                          controller: _searchController,
                                          focusNode: _focusNode,
                                          style:
                                              const TextStyle(fontSize: 14),
                                          decoration: const InputDecoration(
                                            hintText: 'Search prod...',
                                            hintStyle: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 14),
                                            border: InputBorder.none,
                                            isDense: true,
                                            contentPadding: EdgeInsets.zero,
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: _deactivateSearch,
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: Icon(Icons.close,
                                              color: Colors.grey, size: 20),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Search icon — hidden when active
                SizedBox(
                  width: 40,
                  child: _searchActive
                      ? const SizedBox.shrink()
                      : IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.search,
                              color: Color(0xFFEC407A), size: 24),
                          onPressed: _activateSearch,
                        ),
                ),

                // QR icon — always visible
                Container(
                  width: 40,
                  margin: const EdgeInsets.only(right: 8),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.qr_code_scanner,
                        color: Color(0xFFEC407A), size: 22),
                    onPressed: _onScanBarcode,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: const Color(0xFFF6F6F6),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: _displayedProducts.isEmpty
            ? const Center(child: Text('No products found'))
            : GridView.builder(
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

                  return Stack(
                    children: [
                      ProductCard(
                        product: product,
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
                },
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


