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
  String get productDescription => 'Description';

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
  String get searchProductsBrandsMore => 'Search';

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

  @override
  String get shareActionComingSoon => 'Share action is coming soon';

  @override
  String get unableToOpenLoyaltyCard =>
      'Unable to open loyalty card detail right now.';

  @override
  String get unableToOpenRewardDetail =>
      'Unable to open reward detail right now.';

  @override
  String get redeem => 'Redeem';

  @override
  String get useCurrentLocation => 'Use current location';

  @override
  String get confirmRedemption => 'Confirm Redemption';

  @override
  String get failedToLoadMoreProducts => 'Failed to load more products';

  @override
  String get orderCanceledSuccessfully => 'Order canceled successfully.';

  @override
  String get cancelOrder => 'Cancel Order';

  @override
  String get yourRecentPurchaseHistory => 'Your recent purchase history';

  @override
  String get filterByStatus => 'Filter by status';

  @override
  String get chipMongMall => 'Chip Mong Mall';

  @override
  String get shoppingGlobalBrand => 'Shopping global brand';

  @override
  String get chipMongSupermarket => 'Chip Mong Supermarket';

  @override
  String get exploreOurMarketplace => 'Explore our marketplace.';

  @override
  String get label => 'Label';

  @override
  String get defaultDeliveryAddress => 'Default Delivery Address';

  @override
  String get save => 'Save';

  @override
  String get receivingAddress => 'Receiving address';

  @override
  String get qrCode => 'QR Code';

  @override
  String get qrSavedToGallery => 'QR saved to Gallery/Photos.';

  @override
  String get savedOnDeviceForOfflineDisplay =>
      'Saved on this device for offline display.';

  @override
  String get availablePoints => 'Available points';

  @override
  String get ok => 'OK';

  @override
  String get phoneNumberLabel => 'Phone number:';

  @override
  String get loginWithBiometric => 'Login with Biometric';

  @override
  String get telegramOtpBackup => 'Telegram OTP Backup';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get permanentlyDeleteAccount =>
      'Permanently delete your account and all data';

  @override
  String get loginOrSignup => 'Login or Signup';

  @override
  String get done => 'Done';

  @override
  String get wholesaleForm => 'Wholesale Form';

  @override
  String get pleaseEnterNameAndPhone => 'Please enter name and phone.';

  @override
  String get invalidPhone => 'Invalid Phone';

  @override
  String get submissionFailed => 'Submission Failed';

  @override
  String get somethingWentWrongTryAgain =>
      'Something went wrong. Please try again.';

  @override
  String get requestSubmitted => 'Request Submitted!';

  @override
  String get wholesaleRequestSuccess =>
      'Your wholesale request has been submitted successfully. Our team will contact you shortly.';

  @override
  String get customerName => 'Customer Name';

  @override
  String get searchProduct => 'Search product';

  @override
  String get byClickingNextAgreeing =>
      'By clicking Next button you are agreeing to the ';

  @override
  String get termsOfUse => 'Terms of Use';

  @override
  String get andThe => ' and the ';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get continueAsGuest => 'Continue as guest';

  @override
  String get fullName => 'Full name';

  @override
  String get enterFullName => 'Enter full name';

  @override
  String get next => 'NEXT';

  @override
  String get enterPinCode => 'Enter your PIN Code';

  @override
  String pleaseEnterPinCodeFor(String phoneNumber) {
    return 'Please enter the PIN Code to login for $phoneNumber';
  }

  @override
  String get showPin => 'Show PIN';

  @override
  String get hidePin => 'Hide PIN';

  @override
  String get forgotPinCode => 'Forgot the PIN code?';

  @override
  String get submitAllCaps => 'SUBMIT';

  @override
  String get setNewPin => 'Set new PIN';

  @override
  String get makeSureYouRemember => 'Make sure you remember';

  @override
  String get oldPin => 'Old PIN';

  @override
  String get newPin => 'New PIN';

  @override
  String get resetYourPin => 'Reset your PIN';

  @override
  String get chooseNewPinForLogin => 'Choose a new PIN for login';

  @override
  String get chooseNewPinToReactivate =>
      'Choose a new PIN to reactivate your account';

  @override
  String get loginWithFaceId => 'Login with Face ID';

  @override
  String get usernameLabel => 'Username:';

  @override
  String get supermarketPointLabel => 'Supermarket Point:';

  @override
  String get removeTelegramBackup => 'Remove Telegram Backup';

  @override
  String get otpSmsWarningTelegram =>
      'OTP will only be sent via SMS after removing Telegram backup.';

  @override
  String get remove => 'Remove';

  @override
  String get submit => 'Submit';

  @override
  String get nameAddressLabel => 'Name address';

  @override
  String get nameAddressHint => 'Please type your address name';

  @override
  String get addAddress => 'Add address';

  @override
  String get editAddress => 'Edit address';

  @override
  String get searchHere => 'Search here';

  @override
  String get incorrectPinTitle => 'Incorrect PIN';

  @override
  String get incorrectPinMessage => 'The PIN you entered is incorrect.';

  @override
  String get incorrectOldPinMessage => 'The old PIN you entered is incorrect.';

  @override
  String get incorrectPinTryAgain => 'Incorrect PIN. Please try again.';

  @override
  String incorrectPinAttemptsRemaining(int attempts) {
    String _temp0 = intl.Intl.pluralLogic(
      attempts,
      locale: localeName,
      other: '$attempts attempts remaining before lockout.',
      one: '1 attempt remaining before lockout.',
    );
    return '\n$_temp0';
  }

  @override
  String get privacyPolicyTitle => 'Privacy Policy';

  @override
  String get termsOfConditionsTitle => 'Terms of Conditions';

  @override
  String get privacyPolicyIntro =>
      'At CHIP MONG RETAIL APP, we are committed to protecting Customers\' privacy and ensuring Customers\' personal information is handled in a safe and responsible manner. This Privacy Policy outlines how we collect, use, disclose, and protect your information when you use our mobile application (the “App”) and any services provided through the App (collectively, the “Service”).';

  @override
  String get privacyPolicySection1Title =>
      '1. Personal Data Protection Principles';

  @override
  String get privacyPolicySection1Intro =>
      'We are conducting the following efforts to ensure the basic policy of personal data protection:';

  @override
  String get privacyPolicySection1Bullet1 =>
      'All executives and employees shall adhere to applicable laws, regulations, and internal policies regarding personal data protection.';

  @override
  String get privacyPolicySection1Bullet2 =>
      'We will regularly review and update our personal data protection policies and practices to ensure they remain effective and compliant with relevant laws and regulations.';

  @override
  String get privacyPolicySection1Bullet3 =>
      'We will provide regular training and awareness programs to our employees to ensure they understand their responsibilities regarding personal data protection and are equipped to handle personal data securely.';

  @override
  String get privacyPolicySection2Title =>
      '2. How We Handle Your Personal Information';

  @override
  String get privacyPolicySection2Body =>
      'We will clarify the purpose of collecting and using personal information, and we will not use it for any other purposes without your consent. We will take appropriate measures to protect your personal information from unauthorized access, disclosure, alteration, or destruction. We will not share your personal information with third parties without your consent, except as required by law or as necessary to provide our services.';

  @override
  String get privacyPolicySection3Title => '3. How We Use Your Information';

  @override
  String get privacyPolicySection3Intro =>
      'We may use the infomation we collect for various purposes, including to:';

  @override
  String get privacyPolicySection3Bullet1 =>
      'Provide, operate, and maintain our App and services';

  @override
  String get privacyPolicySection3Bullet2 =>
      'Improve, personalize, and expand our App and services';

  @override
  String get privacyPolicySection3Bullet3 =>
      'Understand and analyze how you use our App and services';

  @override
  String get privacyPolicySection3Bullet4 =>
      'Develop new products, services, features, and functionality';

  @override
  String get privacyPolicySection3Bullet5 =>
      'Communicate with you, either directly or through one of our partners, including for customer service, to provide you with updates and other information relating to the App, and for marketing and promotional purposes';

  @override
  String get privacyPolicySection3Bullet6 =>
      'Process your transactions and manage your orders';

  @override
  String get privacyPolicySection3Bullet7 =>
      'Send you text messages and push notifications';

  @override
  String get privacyPolicySection3Bullet8 => 'Find and prevent fraud';

  @override
  String get privacyPolicySection3Bullet9 => 'Comply with legal obligations';

  @override
  String get privacyPolicySection3Body =>
      'CHIP MONG RETAIL APP will not sell, rent, or lease your personal information to third parties. We may share your personal information with third-party service providers who perform services on our behalf, such as payment processing, data analysis, email delivery, hosting services, customer service, and marketing assistance. These third-party service providers are contractually obligated to protect your personal information and only use it for the purposes for which we disclose it to them. We may also disclose your personal information if required to do so by law or in response to valid requests by public authorities (e.g., a court or a government agency).';

  @override
  String get privacyPolicySection4Title => '4. Your Choices';

  @override
  String get privacyPolicySection4Bullet1 =>
      'You may opt-out of receiving promotional communications from us by following the unsubscribe instructions in any marketing email we send you';

  @override
  String get privacyPolicySection4Bullet2 =>
      'You have the right to access, correct, or delete your personal information';

  @override
  String get privacyPolicySection4Bullet3 =>
      'You may disable cookies through your browser settings';

  @override
  String get privacyPolicySection5Title => '5. Sharing Your Information';

  @override
  String get privacyPolicySection5Intro =>
      'We may share your personal information in the following circumstances:';

  @override
  String get privacyPolicySection5Bullet1 =>
      'All executives and employees shall adhere to applicable laws, regulations, and internal policies regarding personal data protection.';

  @override
  String get privacyPolicySection5Bullet2 =>
      'We will regularly review and update our personal data protection policies and practices to ensure they remain effective and compliant with relevant laws and regulations.';

  @override
  String get privacyPolicySection5Bullet3 =>
      'We will provide regular training and awareness programs to our employees to ensure they understand their responsibilities regarding personal data protection and are equipped to handle personal data securely.';

  @override
  String get privacyPolicySection6Title => '6. Data Security';

  @override
  String get privacyPolicySection6Body =>
      'We take reasonable measures to protect your personal information from unauthorized access, disclosure, alteration, and destruction. However, no method of transmission over the Internet or method of electronic storage is 100% secure. Therefore, we cannot guarantee its absolute security.';

  @override
  String get privacyPolicySection7Title => '7. Changes to This Privacy Policy';

  @override
  String get privacyPolicySection7Body =>
      'We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page. You are advised to review this Privacy Policy periodically for any changes. Changes to this Privacy Policy are effective when they are posted on this page.';

  @override
  String get privacyPolicySection8Title => '8. Contact Us';

  @override
  String get privacyPolicySection8Intro =>
      'If you have any questions about this Privacy Policy, please contact us at:';

  @override
  String get privacyPolicyPhone => 'Phone: (855) 90 877 811';

  @override
  String get copyrightNotice =>
      '© 2024 Chip Mong Retails. All rights reserved.';
}
