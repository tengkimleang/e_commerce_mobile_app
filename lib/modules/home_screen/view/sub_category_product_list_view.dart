import 'package:flutter/material.dart';
import 'package:e_commerce_mobile_app/core/data/categories_repository.dart';
import 'package:e_commerce_mobile_app/core/models/product_item.dart';
import 'package:e_commerce_mobile_app/modules/home_screen/view/product_detail_view.dart';
import 'package:e_commerce_mobile_app/modules/home_screen/view/widgets/product_card.dart';

class SubCategoryProductListView extends StatefulWidget {
  final int subCategoryId;
  final String subCategoryName;
  final CategoriesRepository repository;

  const SubCategoryProductListView({
    super.key,
    required this.subCategoryId,
    required this.subCategoryName,
    required this.repository,
  });

  @override
  State<SubCategoryProductListView> createState() =>
      _SubCategoryProductListViewState();
}

class _SubCategoryProductListViewState
    extends State<SubCategoryProductListView> {
  final _scrollController = ScrollController();
  final List<ProductModel> _products = [];

  int _page = 1;
  static const _pageSize = 20;
  int _total = 0;
  bool _loading = false;
  bool _error = false;
  String _errorMsg = '';

  @override
  void initState() {
    super.initState();
    _fetchPage();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_loading &&
        _products.length < _total) {
      _fetchPage();
    }
  }

  Future<void> _fetchPage() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = false;
    });
    try {
      final (items, total) = await widget.repository.fetchSubCategoryProducts(
        widget.subCategoryId,
        page: _page,
        pageSize: _pageSize,
      );
      if (!mounted) return;
      setState(() {
        _products.addAll(items);
        _total = total;
        _page++;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = true;
        _errorMsg = e.toString();
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      _products.clear();
      _page = 1;
      _total = 0;
      _error = false;
    });
    await _fetchPage();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _onRefresh,
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: SizedBox(height: topPadding + 60),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      widget.subCategoryName,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                if (_products.isEmpty && !_loading && _error)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 48, color: Colors.black38),
                          const SizedBox(height: 12),
                          Text(
                            _errorMsg,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.black54),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _onRefresh,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (_products.isEmpty && !_loading)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: Text('No products found')),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final product = _products[index];
                          return ProductCard(
                            product: product,
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
                        childCount: _products.length,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 0.80,
                      ),
                    ),
                  ),
                if (_loading)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
              ],
            ),
          ),
          // Fixed back arrow
          Positioned(
            top: topPadding + 12,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.arrow_back_ios_new, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
