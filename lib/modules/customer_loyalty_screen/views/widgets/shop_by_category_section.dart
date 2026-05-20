import 'package:e_commerce_mobile_app/core/common/di.dart';
import 'package:e_commerce_mobile_app/core/services/user_session.dart';
import 'package:e_commerce_mobile_app/modules/customer_loyalty_screen/models/repositories/shop_by_category_repository.dart';
import 'package:e_commerce_mobile_app/modules/customer_loyalty_screen/models/shop_by_category_model.dart';
import 'package:e_commerce_mobile_app/modules/customer_loyalty_screen/views/shop_by_category_view.dart';
import 'package:e_commerce_mobile_app/modules/customer_loyalty_screen/views/shop_category_product_view.dart';
import 'package:e_commerce_mobile_app/modules/customer_loyalty_screen/views/widgets/shop_category_card.dart';
import 'package:flutter/material.dart';

class ShopByCategorySection extends StatefulWidget {
  const ShopByCategorySection({super.key, ShopByCategoryRepository? repository})
    : _repository = repository;

  final ShopByCategoryRepository? _repository;

  @override
  State<ShopByCategorySection> createState() => _ShopByCategorySectionState();
}

class _ShopByCategorySectionState extends State<ShopByCategorySection> {
  static const _accent = Color(0xFFEC407A);

  late final ShopByCategoryRepository _repository;
  List<ShopByCategoryModel> _categories = [];
  bool _loading = true;
  String? _error;
  String _loadedShopId = '';

  @override
  void initState() {
    super.initState();
    _repository = widget._repository ?? di<ShopByCategoryRepository>();
    _loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    final currentShopId = UserSession.selectedShopId;
    if (_loadedShopId != currentShopId && !_loading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _loadedShopId != UserSession.selectedShopId) {
          _loadCategories();
        }
      });
    }

    if (_loading) return const _ShopByCategorySkeleton();
    if (_error != null) return _ShopByCategoryError(onRetry: _loadCategories);
    if (_categories.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Text(
                'Shop by category',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1D1B24),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _openAllCategories(context),
                child: const Row(
                  children: [
                    Text(
                      'View all',
                      style: TextStyle(
                        color: _accent,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(Icons.chevron_right, color: _accent, size: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 134,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _categories.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final category = _categories[index];
              return SizedBox(
                width: 112,
                child: ShopCategoryCard(
                  category: category,
                  onTap: () => _openCategory(context, category),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _loadCategories() async {
    final shopId = UserSession.selectedShopId;
    setState(() {
      _loading = true;
      _error = null;
      _loadedShopId = shopId;
    });

    try {
      final categories = await _repository.fetchCategories();
      if (!mounted) return;
      setState(() {
        _categories = categories;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _openAllCategories(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ShopByCategoryView(
          categories: _categories,
          title: UserSession.selectedShopName.trim().isEmpty
              ? 'Shop by category'
              : UserSession.selectedShopName.trim(),
        ),
      ),
    );
  }

  void _openCategory(BuildContext context, ShopByCategoryModel category) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ShopCategoryProductView(category: category),
      ),
    );
  }
}

class _ShopByCategoryError extends StatelessWidget {
  const _ShopByCategoryError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.grey, size: 20),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Failed to load shop categories',
                style: TextStyle(color: Colors.black54),
              ),
            ),
            TextButton(
              onPressed: onRetry,
              child: const Text(
                'Retry',
                style: TextStyle(color: _ShopByCategorySectionState._accent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShopByCategorySkeleton extends StatelessWidget {
  const _ShopByCategorySkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            width: 190,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 134,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 3,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) => Container(
              width: 112,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
