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

class _SearchProductsState extends State<SearchProducts>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  late List<ProductModel> _filtered;
  bool _searchActive = false;

  late final AnimationController _animController;
  // Title slides out to the left
  late final Animation<Offset> _titleSlideAnim;
  // Search bar slides in from just slightly to the right
  late final Animation<Offset> _searchBarSlideAnim;

  @override
  void initState() {
    super.initState();
    _filtered = List.from(widget.products);
    _controller.addListener(_onSearchChanged);

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _titleSlideAnim = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-1.5, 0.0),
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeInOut));

    // Begin at 0.5 so the bar starts from just past the title area (near actions)
    _searchBarSlideAnim = Tween<Offset>(
      begin: const Offset(0.5, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeInOut));
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
          _filtered = List.from(widget.products);
        });
      }
    });
  }

  @override
  void dispose() {
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
          child: Container(
            height: 56,
            // color: Colors.white,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Back button — fixed width, never moves
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
                                          controller: _controller,
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

                // Search icon — fixed slot (hidden when active to not shift layout)
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

                // QR icon — always visible, fixed width
                Container(
                  width: 40,
                  margin: const EdgeInsets.only(right: 8),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.qr_code_scanner,
                        color: Color(0xFFEC407A), size: 22),
                    onPressed: () {
                      // QR scanner action
                    },
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
