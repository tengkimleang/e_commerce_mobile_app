import 'dart:async';

import 'package:e_commerce_mobile_app/core/common/di.dart';
import 'package:e_commerce_mobile_app/core/theme/app_theme.dart';
import 'package:e_commerce_mobile_app/core/localization/app_language.dart';
import 'package:e_commerce_mobile_app/core/widgets/app_skeleton.dart';
import 'package:e_commerce_mobile_app/core/utils/text_input_utils.dart';
import 'package:e_commerce_mobile_app/l10n/generated/app_localizations.dart';
import 'package:e_commerce_mobile_app/modules/customer_loyalty_screen/models/repositories/shop_by_category_repository.dart';
import 'package:e_commerce_mobile_app/modules/customer_loyalty_screen/models/shop_by_category_model.dart';
import 'package:e_commerce_mobile_app/modules/home_screen/model/product_model.dart';
import 'package:e_commerce_mobile_app/modules/home_screen/model/sub_category_model.dart';
import 'package:e_commerce_mobile_app/modules/home_screen/view/product_detail_view.dart';
import 'package:e_commerce_mobile_app/modules/home_screen/view/widgets/product_card.dart';
import 'package:flutter/material.dart';

class ShopCategoryProductView extends StatefulWidget {
  const ShopCategoryProductView({
    super.key,
    required this.category,
    ShopByCategoryRepository? repository,
  }) : _repository = repository;

  final ShopByCategoryModel category;
  final ShopByCategoryRepository? _repository;

  @override
  State<ShopCategoryProductView> createState() =>
      _ShopCategoryProductViewState();
}

class _ShopCategoryProductViewState extends State<ShopCategoryProductView> {
  static const _accent = Color(0xFFEC407A);
  static const _pageSize = 20;

  late final ShopByCategoryRepository _repository;
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();

  final List<ProductModel> _products = [];
  List<SubCategoryModel> _subCategories = [];

  Timer? _searchDebounce;
  int _selectedTabIndex = 0;
  int _page = 1;
  int _total = 0;
  int _requestSerial = 0;
  bool _loadingSubCategories = false;
  bool _loadingProducts = false;
  bool _loadingMore = false;
  bool _searchActive = false;
  String? _subCategoryError;
  String? _productError;

  @override
  void initState() {
    super.initState();
    _repository = widget._repository ?? di<ShopByCategoryRepository>();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
    _loadSubCategories();
    _fetchFirstPage();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  SubCategoryModel? get _selectedSubCategory {
    if (_selectedTabIndex == 0) return null;
    final index = _selectedTabIndex - 1;
    if (index < 0 || index >= _subCategories.length) return null;
    return _subCategories[index];
  }

  String get _keyword => _searchController.text.trim();

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 240) {
      _fetchNextPage();
    }
  }

  void _onSearchChanged() {
    if (hasActiveComposingRegion(_searchController)) return;
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), _fetchFirstPage);
  }

  Future<void> _loadSubCategories() async {
    setState(() {
      _loadingSubCategories = true;
      _subCategoryError = null;
    });

    try {
      final subCategories = List<SubCategoryModel>.of(
        await _repository.fetchSubCategories(widget.category.id),
      );
      subCategories.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
      if (!mounted) return;
      setState(() {
        _subCategories = subCategories;
        if (_selectedTabIndex > _subCategories.length) {
          _selectedTabIndex = 0;
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _subCategoryError = 'Failed to load subcategories';
      });
    } finally {
      if (mounted) {
        setState(() => _loadingSubCategories = false);
      }
    }
  }

  Future<void> _fetchFirstPage() async {
    final requestId = ++_requestSerial;
    setState(() {
      _loadingProducts = true;
      _loadingMore = false;
      _productError = null;
      _page = 1;
      _total = 0;
      _products.clear();
    });

    try {
      final (items, total) = await _fetchProductsPage(page: 1);
      if (!mounted || requestId != _requestSerial) return;
      setState(() {
        _products.addAll(items);
        _total = total;
        _page = 2;
      });
    } catch (_) {
      if (!mounted || requestId != _requestSerial) return;
      setState(() {
        _productError = 'Failed to load products';
      });
    } finally {
      if (mounted && requestId == _requestSerial) {
        setState(() => _loadingProducts = false);
      }
    }
  }

  Future<void> _fetchNextPage() async {
    if (_loadingProducts || _loadingMore) return;
    if (_total > 0 && _products.length >= _total) return;

    final requestId = _requestSerial;
    setState(() => _loadingMore = true);
    try {
      final (items, total) = await _fetchProductsPage(page: _page);
      if (!mounted || requestId != _requestSerial) return;
      setState(() {
        _products.addAll(items);
        _total = total;
        _page++;
      });
    } catch (_) {
      if (!mounted || requestId != _requestSerial) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.failedToLoadMoreProducts),
        ),
      );
    } finally {
      if (mounted && requestId == _requestSerial) {
        setState(() => _loadingMore = false);
      }
    }
  }

  Future<(List<ProductModel>, int)> _fetchProductsPage({required int page}) {
    final selectedSubCategory = _selectedSubCategory;
    return _repository.fetchProducts(
      widget.category.id,
      subCategoryId: selectedSubCategory?.id,
      page: page,
      pageSize: _pageSize,
      keyword: _keyword,
    );
  }

  Future<void> _onRefresh() async {
    await Future.wait([_loadSubCategories(), _fetchFirstPage()]);
  }

  void _selectTab(int index) {
    if (_selectedTabIndex == index) return;
    setState(() => _selectedTabIndex = index);
    _fetchFirstPage();
  }

  Future<void> _openSubCategoryFilter() async {
    _searchFocusNode.unfocus();
    if (_subCategories.isEmpty &&
        !_loadingSubCategories &&
        _subCategoryError != null) {
      await _loadSubCategories();
    }
    if (!mounted) return;

    final selectedIndex = await Navigator.of(context).push<int>(
      MaterialPageRoute(
        builder: (_) => _SubCategoryFilterView(
          title: widget.category.displayTitle,
          subCategories: _subCategories,
          selectedIndex: _selectedTabIndex,
        ),
      ),
    );

    if (!mounted || selectedIndex == null) return;
    _selectTab(selectedIndex);
  }

  void _activateSearch() {
    setState(() => _searchActive = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _searchFocusNode.requestFocus();
    });
  }

  void _deactivateSearch() {
    final hadKeyword = _keyword.isNotEmpty;
    _searchFocusNode.unfocus();
    setState(() {
      _searchActive = false;
      _searchController.clear();
    });
    _searchDebounce?.cancel();
    if (hadKeyword) _fetchFirstPage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        child: Column(
          children: [
            _CategoryProductHeader(
              title: widget.category.displayTitle,
              searchActive: _searchActive,
              searchController: _searchController,
              searchFocusNode: _searchFocusNode,
              onBack: () => Navigator.of(context).maybePop(),
              onActivateSearch: _activateSearch,
              onDeactivateSearch: _deactivateSearch,
              onOpenFilter: _openSubCategoryFilter,
            ),
            _buildSubCategoryTabs(),
            Expanded(
              child: RefreshIndicator(
                color: _accent,
                onRefresh: _onRefresh,
                child: _buildProductContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubCategoryTabs() {
    final showTabSkeleton = _loadingSubCategories && _subCategories.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 56,
          child: showTabSkeleton
              ? const _SubCategoryTabsSkeleton()
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _subCategories.length + 1,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 22),
                  itemBuilder: (context, index) {
                    final l10n = Localizations.of<AppLocalizations>(
                      context,
                      AppLocalizations,
                    );
                    final label = index == 0
                        ? (l10n?.all ?? 'All')
                        : _subCategories[index - 1].displayName;
                    return _SubCategoryTab(
                      label: label,
                      selected: _selectedTabIndex == index,
                      onTap: () => _selectTab(index),
                    );
                  },
                ),
        ),
        if (_loadingSubCategories && !showTabSkeleton)
          const LinearProgressIndicator(
            minHeight: 2,
            color: _accent,
            backgroundColor: Colors.transparent,
          )
        else if (_subCategoryError != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _subCategoryError!,
                    style: const TextStyle(color: Colors.black45),
                  ),
                ),
                TextButton(
                  onPressed: _loadSubCategories,
                  child: Text(
                    Localizations.of<AppLocalizations>(
                          context,
                          AppLocalizations,
                        )?.retry ??
                        'Retry',
                    style: const TextStyle(color: _accent),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildProductContent() {
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations);
    if (_loadingProducts && _products.isEmpty) {
      return SkeletonProductGrid(controller: _scrollController);
    }

    if (_productError != null && _products.isEmpty) {
      return _ScrollableMessage(
        icon: Icons.error_outline,
        message: _productError!,
        actionLabel: l10n?.retry ?? 'Retry',
        onAction: _fetchFirstPage,
      );
    }

    if (_products.isEmpty) {
      return _ScrollableMessage(
        icon: Icons.inventory_2_outlined,
        message: l10n?.noProductsFound ?? 'No products found',
      );
    }

    return GridView.builder(
      key: const ValueKey('shop-category-product-grid'),
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: _products.length + (_loadingMore ? 2 : 0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.80,
      ),
      itemBuilder: (context, index) {
        if (index >= _products.length) {
          return const SkeletonProductCard();
        }

        final product = _products[index];
        return ProductCard(
          product: product,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ProductDetailView(
                product: product,
                relatedProducts: _products,
                loadSubCategorySuggestions: false,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CategoryProductHeader extends StatelessWidget {
  const _CategoryProductHeader({
    required this.title,
    required this.searchActive,
    required this.searchController,
    required this.searchFocusNode,
    required this.onBack,
    required this.onActivateSearch,
    required this.onDeactivateSearch,
    required this.onOpenFilter,
  });

  final String title;
  final bool searchActive;
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final VoidCallback onBack;
  final VoidCallback onActivateSearch;
  final VoidCallback onDeactivateSearch;
  final VoidCallback onOpenFilter;

  @override
  Widget build(BuildContext context) {
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations);
    return SizedBox(
      height: 64,
      child: Row(
        children: [
          SizedBox(
            width: 96,
            child: Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: 52,
                child: IconButton(
                  onPressed: onBack,
                  icon: const Icon(
                    Icons.chevron_left,
                    color: Color(0xFF6A6A6A),
                    size: 30,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: searchActive
                  ? _SearchField(
                      controller: searchController,
                      focusNode: searchFocusNode,
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        title,
                        key: const ValueKey('shop-category-title'),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF1D1B24),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          height: 1.12,
                        ),
                      ),
                    ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 48,
                child: IconButton(
                  onPressed: searchActive
                      ? onDeactivateSearch
                      : onActivateSearch,
                  tooltip: searchActive
                      ? (l10n?.closeSearch ?? 'Close search')
                      : (l10n?.searchProducts ?? 'Search products'),
                  icon: Icon(
                    searchActive ? Icons.close : Icons.search,
                    color: const Color(0xFFEC407A),
                    size: 25,
                  ),
                ),
              ),
              SizedBox(
                width: 48,
                child: IconButton(
                  onPressed: onOpenFilter,
                  tooltip: l10n?.filterSubcategories ?? 'Filter subcategories',
                  icon: const Icon(
                    Icons.filter_alt_outlined,
                    color: Color(0xFFEC407A),
                    size: 25,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SubCategoryFilterView extends StatelessWidget {
  const _SubCategoryFilterView({
    required this.title,
    required this.subCategories,
    required this.selectedIndex,
  });

  final String title;
  final List<SubCategoryModel> subCategories;
  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations);
    final labels = <String>[
      l10n?.all ?? 'All',
      ...subCategories.map((subCategory) => subCategory.displayName),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(38, 10, 24, 18),
              child: Text(
                title.toUpperCase(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFFEC407A),
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  height: 1.05,
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(38, 20, 38, 32),
                itemCount: labels.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  return _SubCategoryFilterTile(
                    label: labels[index],
                    selected: selectedIndex == index,
                    onTap: () => Navigator.of(context).pop(index),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubCategoryFilterTile extends StatelessWidget {
  const _SubCategoryFilterTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: 0.16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 78,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected
                        ? const Color(0xFFEC407A)
                        : const Color(0xFF35323A),
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0,
                  ),
                ),
              ),
              if (selected)
                Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEC407A),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 25),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.focusNode});

  final TextEditingController controller;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations);
    return Container(
      key: const ValueKey('shop-category-search-container'),
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFEC407A), width: 1.4),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          const Icon(Icons.search, color: Color(0xFFEC407A), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              key: const ValueKey('shop-category-search-field'),
              controller: controller,
              focusNode: focusNode,
              style: AppTypography.inputStyle(isKhmer: AppLanguage.isKhmer),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: l10n?.searchProducts ?? 'Search products',
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubCategoryTab extends StatelessWidget {
  const _SubCategoryTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: selected ? const Color(0xFFEC407A) : const Color(0xFF35323A),
            fontSize: 17,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _SubCategoryTabsSkeleton extends StatelessWidget {
  const _SubCategoryTabsSkeleton();

  @override
  Widget build(BuildContext context) {
    return AppSkeleton(
      child: ListView.separated(
        key: const ValueKey('shop-category-tabs-skeleton'),
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 4,
        separatorBuilder: (context, index) => const SizedBox(width: 22),
        itemBuilder: (context, index) => Center(
          child: SkeletonBox(
            width: index == 0 ? 42 : 88,
            height: 18,
            radius: 6,
          ),
        ),
      ),
    );
  }
}

class _ScrollableMessage extends StatelessWidget {
  const _ScrollableMessage({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: Colors.black38, size: 44),
                  const SizedBox(height: 10),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.black54),
                  ),
                  if (actionLabel != null && onAction != null) ...[
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: onAction,
                      child: Text(
                        actionLabel!,
                        style: const TextStyle(color: Color(0xFFEC407A)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
