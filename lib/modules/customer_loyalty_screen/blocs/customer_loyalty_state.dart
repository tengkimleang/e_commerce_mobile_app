class CustomerLoyaltyState {
  final String username;
  final String phone;
  final String points;
  final String promoPeriodText;
  final String exchangePointsImageUrl;
  final String priceCheckingImageUrl;
  final bool isLoading;
  final String? errorMessage;

  const CustomerLoyaltyState({
    required this.username,
    required this.phone,
    required this.points,
    required this.promoPeriodText,
    required this.exchangePointsImageUrl,
    required this.priceCheckingImageUrl,
    required this.isLoading,
    this.errorMessage,
  });

  const CustomerLoyaltyState.initial()
    : username = '',
      phone = '',
      points = '0',
      promoPeriodText = '',
      exchangePointsImageUrl = '',
      priceCheckingImageUrl = '',
      isLoading = true,
      errorMessage = null;

  CustomerLoyaltyState copyWith({
    String? username,
    String? phone,
    String? points,
    String? promoPeriodText,
    String? exchangePointsImageUrl,
    String? priceCheckingImageUrl,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CustomerLoyaltyState(
      username: username ?? this.username,
      phone: phone ?? this.phone,
      points: points ?? this.points,
      promoPeriodText: promoPeriodText ?? this.promoPeriodText,
      exchangePointsImageUrl:
          exchangePointsImageUrl ?? this.exchangePointsImageUrl,
      priceCheckingImageUrl:
          priceCheckingImageUrl ?? this.priceCheckingImageUrl,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
