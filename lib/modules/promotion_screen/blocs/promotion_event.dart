abstract class PromotionEvent {
  const PromotionEvent();
}

class LoadPromotionSections extends PromotionEvent {
  final String shopId;
  const LoadPromotionSections(this.shopId);
}
