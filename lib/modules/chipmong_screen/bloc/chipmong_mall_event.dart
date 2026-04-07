import '../models/chipmong_mall_model.dart';

abstract class ChipmongMallEvent {
  const ChipmongMallEvent();
}

class ChipmongMallStarted extends ChipmongMallEvent {
  const ChipmongMallStarted();
}

class ChipmongMallTabChanged extends ChipmongMallEvent {
  final int tabIndex;
  const ChipmongMallTabChanged(this.tabIndex);
}

class ChipmongMallBottomNavChanged extends ChipmongMallEvent {
  final int index;
  const ChipmongMallBottomNavChanged(this.index);
}

class ChipmongMallLoyaltyInfoUpdated extends ChipmongMallEvent {
  final ChipmongMallLoyaltyInfo loyaltyInfo;
  const ChipmongMallLoyaltyInfoUpdated(this.loyaltyInfo);
}

/// Returned from the Loyalty detail screen — updates loyalty info AND switches
/// the bottom nav tab in a single atomic state emission to avoid a Home flash.
class ChipmongMallReturnedFromLoyalty extends ChipmongMallEvent {
  final ChipmongMallLoyaltyInfo loyaltyInfo;
  final int targetBottomNavIndex;
  const ChipmongMallReturnedFromLoyalty({
    required this.loyaltyInfo,
    required this.targetBottomNavIndex,
  });
}
