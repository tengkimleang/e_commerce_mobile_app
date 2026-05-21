class CustomerLoyaltyData {
  final String username;
  final String phone;
  final String points;
  final String promoPeriodText;
  final String exchangePointsImageUrl;
  final String priceCheckingImageUrl;

  const CustomerLoyaltyData({
    required this.username,
    required this.phone,
    required this.points,
    required this.promoPeriodText,
    required this.exchangePointsImageUrl,
    required this.priceCheckingImageUrl,
  });
}

const customerLoyaltyDefaultData = CustomerLoyaltyData(
  username: 'Member',
  phone: '',
  points: '0',
  promoPeriodText: '01-28 Feb 2026 - Special promotions and bundles.',
  exchangePointsImageUrl:
      'https://www.shutterstock.com/image-vector/cashback-reward-program-advertising-idea-600nw-2553858371.jpg',
  priceCheckingImageUrl:
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTZ5i8QBjeV3H4nA5m5T3ILCaeeQYcWN0pg9Q&s',
);
