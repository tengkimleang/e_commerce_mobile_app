abstract class SupermarketCategoryEvent {
  const SupermarketCategoryEvent();
}

class LoadCategories extends SupermarketCategoryEvent {
  final String shopId;

  const LoadCategories([this.shopId = '']);
}
