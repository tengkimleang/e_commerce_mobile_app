import 'package:e_commerce_mobile_app/modules/customer_loyalty_screen/models/shop_by_category_model.dart';
import 'package:e_commerce_mobile_app/modules/customer_loyalty_screen/views/shop_category_product_view.dart';
import 'package:e_commerce_mobile_app/modules/customer_loyalty_screen/views/widgets/shop_category_card.dart';
import 'package:flutter/material.dart';

class ShopByCategoryView extends StatelessWidget {
  const ShopByCategoryView({
    super.key,
    required this.categories,
    required this.title,
  });

  final List<ShopByCategoryModel> categories;
  final String title;

  @override
  Widget build(BuildContext context) {
    final activeCategories = categories
        .where((category) => category.isActive)
        .toList();

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
              child: activeCategories.isEmpty
                  ? const Center(child: Text('No categories available'))
                  : GridView.builder(
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
          ],
        ),
      ),
    );
  }
}
