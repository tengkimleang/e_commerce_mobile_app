import '../customer_loyalty_data.dart';
import 'customer_loyalty_repository.dart';

class CustomerLoyaltyLocalRepository implements CustomerLoyaltyRepository {
  @override
  Future<CustomerLoyaltyData> fetchLoyaltyData() async {
    return customerLoyaltyDefaultData;
  }
}
