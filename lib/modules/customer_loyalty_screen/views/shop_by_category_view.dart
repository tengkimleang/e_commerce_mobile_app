import 'package:e_commerce_mobile_app/core/common/di.dart';
import 'package:e_commerce_mobile_app/core/services/user_session.dart';
import 'package:e_commerce_mobile_app/modules/customer_loyalty_screen/models/repositories/shop_by_category_repository.dart';
import 'package:e_commerce_mobile_app/modules/customer_loyalty_screen/models/shop_by_category_model.dart';
import 'package:e_commerce_mobile_app/modules/customer_loyalty_screen/views/shop_category_product_view.dart';
import 'package:e_commerce_mobile_app/modules/customer_loyalty_screen/views/widgets/shop_category_card.dart';
import 'package:flutter/material.dart';

class ShopByCategoryView extends StatefulWidget {
  const ShopByCategoryView({
    super.key,
    required this.title,
    this.shopId = '',
    ShopByCategoryRepository? repository,
  }) : _repository = repository;

  final String title;
  final String shopId;
  final ShopByCategoryRepository? _repository;

  @override
  State<ShopByCategoryView> createState() => _ShopByCategoryViewState();
}

class _ShopByCategoryViewState extends State<ShopByCategoryView> {
  late final ShopByCategoryRepository _repository;
  List<ShopByCategoryModel> _categories = [];
  bool _loading = true;
  String? _error;
  String _loadedShopId = '';
  int _loadSerial = 0;

  @override
  void initState() {
    super.initState();
    _repository = widget._repository ?? di<ShopByCategoryRepository>();
    _loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    final currentShopId = _effectiveShopId;
    final isCurrentShopLoaded = _loadedShopId == currentShopId;
    if (!isCurrentShopLoaded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _loadedShopId != _effectiveShopId) {
          _loadCategories();
        }
      });
    }

    final activeCategories = _categories
        .where((category) => category.isActive)
        .toList();
    final title = widget.title.trim().isEmpty
        ? 'Shop by category'
        : widget.title.trim();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 64,
              child: Row(
                children: [
                  SizedBox(
                    width: 56,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(
                        Icons.chevron_left,
                        color: Color(0xFF6A6A6A),
                        size: 30,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF1D1B24),
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 56),
                ],
              ),
            ),
            Expanded(
              child: _loading || !isCurrentShopLoaded
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? _ShopByCategoryLoadError(onRetry: _loadCategories)
                  : activeCategories.isEmpty
                  ? const Center(child: Text('No categories available'))
                  : RefreshIndicator(
                      onRefresh: _loadCategories,
                      child: GridView.builder(
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
                        itemCount: activeCategories.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.78,
                            ),
                        itemBuilder: (context, index) {
                          final category = activeCategories[index];
                          return ShopCategoryCard(
                            category: category,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    ShopCategoryProductView(category: category),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadCategories() async {
    final shopId = _effectiveShopId;
    final requestId = ++_loadSerial;
    setState(() {
      _loading = true;
      _error = null;
      _loadedShopId = shopId;
      _categories = [];
    });

    try {
      final categories = await _repository.fetchCategories(shopId: shopId);
      if (!mounted || requestId != _loadSerial || shopId != _effectiveShopId) {
        return;
      }
      setState(() {
        _categories = categories;
      });
    } catch (e) {
      if (!mounted || requestId != _loadSerial || shopId != _effectiveShopId) {
        return;
      }
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted && requestId == _loadSerial && shopId == _effectiveShopId) {
        setState(() => _loading = false);
      }
    }
  }

  String get _effectiveShopId => widget.shopId.trim().isNotEmpty
      ? widget.shopId.trim()
      : UserSession.selectedShopId.trim();
}

class _ShopByCategoryLoadError extends StatelessWidget {
  const _ShopByCategoryLoadError({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: onRetry,
        child: const Text('Failed to load categories. Retry'),
      ),
    );
  }
}
