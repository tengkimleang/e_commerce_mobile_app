abstract class CustomerLoyaltyEvent {
  const CustomerLoyaltyEvent();
}

class CustomerLoyaltyStarted extends CustomerLoyaltyEvent {
  const CustomerLoyaltyStarted();
}

class ExchangePointsTapped extends CustomerLoyaltyEvent {
  const ExchangePointsTapped();
}

class PriceCheckingTapped extends CustomerLoyaltyEvent {
  const PriceCheckingTapped();
}
