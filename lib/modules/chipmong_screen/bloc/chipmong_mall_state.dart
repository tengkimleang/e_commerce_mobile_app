import '../models/chipmong_mall_model.dart';

class ChipmongMallState {
  final List<ChipmongMallPromotion> promotions;
  final List<ChipmongMallPromotion> programs;
  final List<ChipmongMallPromotion> news;
  final ChipmongMallLoyaltyInfo loyaltyInfo;
  final List<String> bannerImages;
  final int selectedTabIndex;
  final int bottomNavIndex;
  final bool isLoading;
  final String selectedBranch;
  final String? errorMessage;

  const ChipmongMallState({
    required this.promotions,
    required this.programs,
    required this.news,
    required this.loyaltyInfo,
    required this.bannerImages,
    required this.selectedTabIndex,
    required this.bottomNavIndex,
    required this.isLoading,
    required this.selectedBranch,
    this.errorMessage,
  });

  const ChipmongMallState.initial()
      : promotions = const [],
        programs = const [],
        news = const [],
        loyaltyInfo = chipmongMallDefaultLoyalty,
        bannerImages = const [],
        selectedTabIndex = 0,
        bottomNavIndex = 0,
        isLoading = true,
        selectedBranch = 'CHIP MONG 271 MEGA MALL',
        errorMessage = null;

  List<ChipmongMallPromotion> get currentTabItems {
    switch (selectedTabIndex) {
      case 0:
        return promotions;
      case 1:
        return programs;
      case 2:
        return news;
      default:
        return promotions;
    }
  }

  ChipmongMallState copyWith({
    List<ChipmongMallPromotion>? promotions,
    List<ChipmongMallPromotion>? programs,
    List<ChipmongMallPromotion>? news,
    ChipmongMallLoyaltyInfo? loyaltyInfo,
    List<String>? bannerImages,
    int? selectedTabIndex,
    int? bottomNavIndex,
    bool? isLoading,
    String? selectedBranch,
    String? errorMessage,
  }) {
    return ChipmongMallState(
      promotions: promotions ?? this.promotions,
      programs: programs ?? this.programs,
      news: news ?? this.news,
      loyaltyInfo: loyaltyInfo ?? this.loyaltyInfo,
      bannerImages: bannerImages ?? this.bannerImages,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      bottomNavIndex: bottomNavIndex ?? this.bottomNavIndex,
      isLoading: isLoading ?? this.isLoading,
      selectedBranch: selectedBranch ?? this.selectedBranch,
      errorMessage: errorMessage,
    );
  }
}
