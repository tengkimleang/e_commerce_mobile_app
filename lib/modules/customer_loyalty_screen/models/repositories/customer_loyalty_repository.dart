import '../customer_loyalty_data.dart';

abstract class CustomerLoyaltyRepository {
  Future<CustomerLoyaltyData> fetchLoyaltyData();
}
