// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Chipmong Retail';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get khmer => 'Khmer';

  @override
  String get setProfilePhoto => 'Set profile photo';

  @override
  String get logout => 'Logout';

  @override
  String get reallyWantToLogout => 'Really want to logout?';

  @override
  String get cancel => 'Cancel';

  @override
  String get yes => 'Yes';

  @override
  String get signUp => 'Sign Up';

  @override
  String get phoneNumber => 'Phone number';

  @override
  String get enterPhoneNumber => 'Enter phone number';

  @override
  String get personalInformation => 'Personal Information';

  @override
  String get yourName => 'Your Name';

  @override
  String get dateOfBirth => 'Date of Birth';

  @override
  String get address => 'Address';

  @override
  String get notAdded => 'Not Added';

  @override
  String get account => 'Account';

  @override
  String get security => 'Security';

  @override
  String get changePin => 'Change PIN';

  @override
  String get change => 'Change';

  @override
  String get termsAndConditions => 'Terms & Conditions';

  @override
  String get seeMore => 'See More';

  @override
  String get dangerZone => 'Danger Zone';

  @override
  String get orderStatusRequesting => 'Requesting';

  @override
  String get orderStatusPicking => 'Picking';

  @override
  String get orderStatusDelivering => 'Delivering';

  @override
  String get orderStatusDelivered => 'Delivered';

  @override
  String get orderStatusCanceled => 'Canceled';

  @override
  String get home => 'Home';

  @override
  String get offers => 'Offers';

  @override
  String get scan => 'Scan';

  @override
  String get orders => 'Orders';

  @override
  String get profile => 'Profile';

  @override
  String get favorites => 'Favorites';

  @override
  String get noFavoriteProductsYet => 'No favorite products yet';

  @override
  String get notification => 'Notification';

  @override
  String get order => 'Order';

  @override
  String get promotion => 'Promotion';

  @override
  String get promoteCode => 'Promote Code';

  @override
  String get failedToLoadPromotions => 'Failed to load promotions';

  @override
  String get retry => 'Retry';

  @override
  String get noResultFound => 'No result found';

  @override
  String get shopByCountry => 'Shop by country';

  @override
  String get shopByCategory => 'Shop by category';

  @override
  String get failedToLoadShopCategories => 'Failed to load shop categories';

  @override
  String get viewAll => 'View all';

  @override
  String get all => 'All';

  @override
  String get noProducts => 'No products';

  @override
  String get failedToLoadProducts => 'Failed to load products';

  @override
  String get exchangePoints => 'Exchange Points';

  @override
  String get priceChecking => 'Price Checking';

  @override
  String get search => 'Search';

  @override
  String get searchProductHint => 'Search prod...';

  @override
  String get noProductsFound => 'No products found';

  @override
  String get searchProducts => 'Search products';

  @override
  String get closeSearch => 'Close search';

  @override
  String get filterSubcategories => 'Filter subcategories';

  @override
  String get noCategoriesAvailable => 'No categories available';

  @override
  String get failedToLoadCategoriesRetry => 'Failed to load categories. Retry';

  @override
  String get productNotFoundForBarcode => 'Product not found for this barcode';

  @override
  String get failedToLookUpProduct =>
      'Failed to look up product. Please try again.';

  @override
  String productAdded(String productName) {
    return '$productName added';
  }

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Items',
      one: '1 Item',
    );
    return '$_temp0';
  }

  @override
  String get add => 'Add';

  @override
  String get partnerPrivileges => 'Partner Privileges';

  @override
  String get wholesalePrice => 'Wholesale Price';

  @override
  String get wholesalePriceSubtitle =>
      'High quality products\nwith special price';

  @override
  String get wholesaleRequest => 'Wholesale Request';

  @override
  String get dropYourInquiry => 'Drop your Inquiry';

  @override
  String get requestHistory => 'Request History';

  @override
  String get failedToLoadHistory => 'Failed to load history';

  @override
  String get allCaughtUp => 'All caught up';

  @override
  String requestNumber(String requestId) {
    return 'Request #$requestId';
  }

  @override
  String get customer => 'Customer';

  @override
  String get phone => 'Phone';

  @override
  String get remark => 'Remark';

  @override
  String get productImages => 'Product Images';

  @override
  String get close => 'Close';

  @override
  String get selectShop => 'Select shop';

  @override
  String get loginRequired => 'Login required';

  @override
  String get shopAt => 'Shop at';

  @override
  String get branchUnavailable => 'Branch unavailable';

  @override
  String get branchRequiresLoginOrSignup =>
      'This branch requires Login or Signup';

  @override
  String get selectShopFallback => 'Select Shop';

  @override
  String get searchProductsBrandsMore => 'Search products, brands and more';

  @override
  String get skip => 'Skip';

  @override
  String get login => 'Login';

  @override
  String get exchange => 'Exchange';

  @override
  String get noPromotionsAvailable => 'No promotions available';

  @override
  String get paymentMethod => 'Payment method';

  @override
  String get cashOnDelivery => 'Cash on Delivery';

  @override
  String get checkOut => 'Check Out';

  @override
  String get yourCart => 'Your Cart';

  @override
  String get yourCartIsEmpty => 'Your cart is empty';

  @override
  String get deliveryInfo => 'Delivery Info';

  @override
  String get noDeliveryAddressSelected => 'No delivery address selected';

  @override
  String get selectAddress => 'Select address';

  @override
  String get deliveryFee => 'Delivery Fee';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get packageFees => 'Package fees';

  @override
  String get discount => 'Discount';

  @override
  String get total => 'Total';

  @override
  String get includingVat => '(incl.VAT)';

  @override
  String get enterPromoCodeHere => 'Enter promo code here';

  @override
  String get apply => 'APPLY';

  @override
  String get placeOrder => 'Place Order';

  @override
  String get pleaseSelectDeliveryAddressFirst =>
      'Please select a delivery address first';

  @override
  String get confirmOrder => 'Confirm Order';

  @override
  String get confirmOrderMessage =>
      'Please confirm your order. After staff approval, cancellation may no longer be available.';

  @override
  String get back => 'Back';

  @override
  String get confirm => 'Confirm';

  @override
  String get orderSubmitted => 'Order Submitted!';

  @override
  String orderPlacedSuccessfully(String orderNumber) {
    return 'Your order #$orderNumber has been placed\nsuccessfully.';
  }

  @override
  String get trackOrder => 'Track Order';

  @override
  String get supermarketPointMember => 'Supermarket Point Member';

  @override
  String pointValue(int points) {
    return 'POINT $points';
  }

  @override
  String get countryCambodia => 'Cambodia';

  @override
  String get countryCanada => 'Canada';

  @override
  String get countryEgypt => 'Egypt';

  @override
  String get countrySouthKorea => 'South Korea';

  @override
  String get countryJapan => 'Japan';

  @override
  String get countryChina => 'China';

  @override
  String get countrySingapore => 'Singapore';

  @override
  String get countryItaly => 'Italy';

  @override
  String get countrySpain => 'Spain';

  @override
  String get countryIndonesia => 'Indonesia';

  @override
  String get countryArgentina => 'Argentina';

  @override
  String get countryUnitedStates => 'United States';

  @override
  String get countryFrance => 'France';
}
