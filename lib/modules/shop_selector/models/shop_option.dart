class ShopOption {
  const ShopOption({
    required this.storeName,
    required this.branchLabel,
    required this.imageUrl,
    this.guestAllowed = true,
  });

  final String storeName;
  final String branchLabel;
  final String imageUrl;
  final bool guestAllowed;
}
