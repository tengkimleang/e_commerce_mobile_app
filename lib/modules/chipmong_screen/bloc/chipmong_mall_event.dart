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
