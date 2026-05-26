import 'dart:async';

import 'package:flutter/material.dart';
import 'package:e_commerce_mobile_app/core/common/di.dart';
import 'package:e_commerce_mobile_app/core/data/categories_repository.dart';
import 'package:e_commerce_mobile_app/core/router/app_router.dart';
import 'package:e_commerce_mobile_app/core/utils/responsive_layout.dart';
import 'package:e_commerce_mobile_app/modules/home_screen/model/product_model.dart';
import 'package:e_commerce_mobile_app/modules/home_screen/view/product_detail_view.dart';
import 'package:e_commerce_mobile_app/modules/home_screen/view/widgets/product_card.dart';

class SearchProducts extends StatefulWidget {
  final bool selectionMode;

  const SearchProducts({super.key, this.selectionMode = false});

  @override
  State<SearchProducts> createState() => _SearchProductsState();
}

class _SearchProductsState extends State<SearchProducts>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  List<ProductModel> _results = [];
  final Map<String, ProductModel> _selectedProductsById = {};
  bool _loading = false;
  bool _searchActive = false;
  Timer? _debounce;

  late final AnimationController _animController;
  // Title slides out to the left
  late final Animation<Offset> _titleSlideAnim;
  // Search bar slides in from just slightly to the right
  late final Animation<Offset> _searchBarSlideAnim;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onSearchChanged);
    _fetchProducts('');

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _titleSlideAnim =
        Tween<Offset>(begin: Offset.zero, end: const Offset(-1.5, 0.0)).animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
        );

    // Begin at 0.5 so the bar starts from just past the title area (near actions)
    _searchBarSlideAnim =
        Tween<Offset>(begin: const Offset(0.5, 0.0), end: Offset.zero).animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
        );
  }

  Future<void> _fetchProducts(String keyword) async {
    setState(() => _loading = true);
    try {
      final (items, _) = await di<CategoriesRepository>().searchProducts(
        keyword,
        pageSize: 50,
      );
      if (mounted) setState(() => _results = items);
    } catch (_) {
      if (mounted) setState(() => _results = []);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _fetchProducts(_controller.text.trim());
    });
  }

  void _toggleSelection(ProductModel product) {
    setState(() {
      if (_selectedProductsById.containsKey(product.id)) {
        _selectedProductsById.remove(product.id);
      } else {
        _selectedProductsById[product.id] = product;
      }
    });
  }

  void _submitSelection() {
    final selected = _selectedProductsById.values
        .map(
          (product) => {
            'id': product.id,
            'title': product.name,
            'price': '\$ ${product.price.toStringAsFixed(2)}',
            'image': product.imageUrl,
          },
        )
        .toList();

    Navigator.of(context).pop(selected);
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
          _controller.clear();
        });
        _fetchProducts('');
      }
    });
  }

  Future<void> _onScanBarcode() async {
    final code = await Navigator.pushNamed<String>(
      context,
      AppRoutes.scanBarcode,
    );
    if (code == null || !mounted) return;
    debugPrint('[BARCODE SEARCH] Received code: "$code"');
    setState(() => _loading = true);
    try {
      final product = await di<CategoriesRepository>().fetchProductByBarcode(
        code,
      );
      if (!mounted) return;
      debugPrint('[BARCODE SEARCH] Product result: $product');
      if (product == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product not found for this barcode')),
        );
      } else if (widget.selectionMode) {
        setState(() {
          _selectedProductsById[product.id] = product;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${product.name} added')));
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailView(product: product),
          ),
        );
      }
    } catch (e) {
      debugPrint('[BARCODE SEARCH] Exception: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to look up product. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.removeListener(_onSearchChanged);
    _controller.dispose();
    _focusNode.dispose();
    _animController.dispose();
    super.dispose();
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
            // color: Colors.white,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Back button — fixed width, never moves
                SizedBox(
                  width: 48,
                  child: IconButton(
                    icon: const Icon(
                      Icons.chevron_left,
                      color: Colors.black,
                      size: 28,
                    ),
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
                                      width: 1.5,
                                    ),
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const SizedBox(width: 10),
                                      const Icon(
                                        Icons.search,
                                        color: Color(0xFFEC407A),
                                        size: 20,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: TextField(
                                          controller: _controller,
                                          focusNode: _focusNode,
                                          style: const TextStyle(fontSize: 14),
                                          decoration: const InputDecoration(
                                            hintText: 'Search prod...',
                                            hintStyle: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 14,
                                            ),
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
                                            horizontal: 10,
                                          ),
                                          child: Icon(
                                            Icons.close,
                                            color: Colors.grey,
                                            size: 20,
                                          ),
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

                // Search icon — fixed slot (hidden when active to not shift layout)
                SizedBox(
                  width: 40,
                  child: _searchActive
                      ? const SizedBox.shrink()
                      : IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(
                            Icons.search,
                            color: Color(0xFFEC407A),
                            size: 24,
                          ),
                          onPressed: _activateSearch,
                        ),
                ),

                // QR icon — always visible, fixed width
                Container(
                  width: 40,
                  margin: const EdgeInsets.only(right: 8),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.qr_code_scanner,
                      color: Color(0xFFEC407A),
                      size: 22,
                    ),
                    onPressed: _onScanBarcode,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: const Color(0xFFF6F6F6),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : MediaQuery.sizeOf(context).width;

          return ResponsiveCenter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFEC407A),
                      ),
                    )
                  : _results.isEmpty
                  ? const Center(child: Text('No products found'))
                  : GridView.builder(
                      itemCount: _results.length,
                      gridDelegate: AppResponsive.productGridDelegateForWidth(
                        width,
                      ),
                      itemBuilder: (context, index) {
                        final product = _results[index];
                        final isSelected = _selectedProductsById.containsKey(
                          product.id,
                        );

                        return Stack(
                          children: [
                            ProductCard(
                              product: product,
                              onTap: () {
                                if (widget.selectionMode) {
                                  _toggleSelection(product);
                                  return;
                                }

                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ProductDetailView(
                                      product: product,
                                      relatedProducts: _results,
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
          );
        },
      ),
      bottomNavigationBar: widget.selectionMode
          ? SafeArea(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: _selectedProductsById.isEmpty ? 0 : 72,
                child: _selectedProductsById.isEmpty
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
                                '${_selectedProductsById.length} Items',
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
                                onPressed: _submitSelection,
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
