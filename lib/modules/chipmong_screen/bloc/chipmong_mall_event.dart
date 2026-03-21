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
