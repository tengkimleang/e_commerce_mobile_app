import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_km.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('km'),
  ];

  /// Application title shown to the OS and app shell.
  ///
  /// In en, this message translates to:
  /// **'Chipmong Retail'**
  String get appTitle;

  /// Generic label for language settings.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// English language option label.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Khmer language option label.
  ///
  /// In en, this message translates to:
  /// **'Khmer'**
  String get khmer;

  /// Menu action for choosing a profile photo.
  ///
  /// In en, this message translates to:
  /// **'Set profile photo'**
  String get setProfilePhoto;

  /// Logout menu and dialog title.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Logout confirmation message.
  ///
  /// In en, this message translates to:
  /// **'Really want to logout?'**
  String get reallyWantToLogout;

  /// Generic cancel button label.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Generic yes confirmation button label.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// Sign up action label.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// Phone number input label.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneNumber;

  /// Phone number input placeholder.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get enterPhoneNumber;

  /// Profile personal information section title.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// Profile name field label.
  ///
  /// In en, this message translates to:
  /// **'Your Name'**
  String get yourName;

  /// Profile date of birth field label.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirth;

  /// Profile address field label.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// Fallback value when profile information has not been added.
  ///
  /// In en, this message translates to:
  /// **'Not Added'**
  String get notAdded;

  /// Profile account section title.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// Profile security section title.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// Profile action to change PIN.
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get changePin;

  /// Generic change action label.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// Terms and conditions menu item.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsAndConditions;

  /// Generic see more action label.
  ///
  /// In en, this message translates to:
  /// **'See More'**
  String get seeMore;

  /// Profile section for dangerous account actions.
  ///
  /// In en, this message translates to:
  /// **'Danger Zone'**
  String get dangerZone;

  /// Display label for REQUESTING order status.
  ///
  /// In en, this message translates to:
  /// **'Requesting'**
  String get orderStatusRequesting;

  /// Display label for PICKING order status.
  ///
  /// In en, this message translates to:
  /// **'Picking'**
  String get orderStatusPicking;

  /// Display label for DELIVERING order status.
  ///
  /// In en, this message translates to:
  /// **'Delivering'**
  String get orderStatusDelivering;

  /// Display label for DELIVERED order status.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get orderStatusDelivered;

  /// Display label for CANCELED order status.
  ///
  /// In en, this message translates to:
  /// **'Canceled'**
  String get orderStatusCanceled;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @offers.
  ///
  /// In en, this message translates to:
  /// **'Offers'**
  String get offers;

  /// No description provided for @scan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scan;

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @noFavoriteProductsYet.
  ///
  /// In en, this message translates to:
  /// **'No favorite products yet'**
  String get noFavoriteProductsYet;

  /// No description provided for @notification.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get notification;

  /// No description provided for @order.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get order;

  /// No description provided for @promotion.
  ///
  /// In en, this message translates to:
  /// **'Promotion'**
  String get promotion;

  /// No description provided for @promoteCode.
  ///
  /// In en, this message translates to:
  /// **'Promote Code'**
  String get promoteCode;

  /// No description provided for @failedToLoadPromotions.
  ///
  /// In en, this message translates to:
  /// **'Failed to load promotions'**
  String get failedToLoadPromotions;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @noResultFound.
  ///
  /// In en, this message translates to:
  /// **'No result found'**
  String get noResultFound;

  /// No description provided for @shopByCountry.
  ///
  /// In en, this message translates to:
  /// **'Shop by country'**
  String get shopByCountry;

  /// No description provided for @shopByCategory.
  ///
  /// In en, this message translates to:
  /// **'Shop by category'**
  String get shopByCategory;

  /// No description provided for @failedToLoadShopCategories.
  ///
  /// In en, this message translates to:
  /// **'Failed to load shop categories'**
  String get failedToLoadShopCategories;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @noProducts.
  ///
  /// In en, this message translates to:
  /// **'No products'**
  String get noProducts;

  /// No description provided for @failedToLoadProducts.
  ///
  /// In en, this message translates to:
  /// **'Failed to load products'**
  String get failedToLoadProducts;

  /// No description provided for @exchangePoints.
  ///
  /// In en, this message translates to:
  /// **'Exchange Points'**
  String get exchangePoints;

  /// No description provided for @priceChecking.
  ///
  /// In en, this message translates to:
  /// **'Price Checking'**
  String get priceChecking;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchProductHint.
  ///
  /// In en, this message translates to:
  /// **'Search prod...'**
  String get searchProductHint;

  /// No description provided for @noProductsFound.
  ///
  /// In en, this message translates to:
  /// **'No products found'**
  String get noProductsFound;

  /// No description provided for @searchProducts.
  ///
  /// In en, this message translates to:
  /// **'Search products'**
  String get searchProducts;

  /// No description provided for @closeSearch.
  ///
  /// In en, this message translates to:
  /// **'Close search'**
  String get closeSearch;

  /// No description provided for @filterSubcategories.
  ///
  /// In en, this message translates to:
  /// **'Filter subcategories'**
  String get filterSubcategories;

  /// No description provided for @noCategoriesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No categories available'**
  String get noCategoriesAvailable;

  /// No description provided for @failedToLoadCategoriesRetry.
  ///
  /// In en, this message translates to:
  /// **'Failed to load categories. Retry'**
  String get failedToLoadCategoriesRetry;

  /// No description provided for @productNotFoundForBarcode.
  ///
  /// In en, this message translates to:
  /// **'Product not found for this barcode'**
  String get productNotFoundForBarcode;

  /// No description provided for @failedToLookUpProduct.
  ///
  /// In en, this message translates to:
  /// **'Failed to look up product. Please try again.'**
  String get failedToLookUpProduct;

  /// No description provided for @productAdded.
  ///
  /// In en, this message translates to:
  /// **'{productName} added'**
  String productAdded(String productName);

  /// No description provided for @itemCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 Item} other{{count} Items}}'**
  String itemCount(int count);

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @partnerPrivileges.
  ///
  /// In en, this message translates to:
  /// **'Partner Privileges'**
  String get partnerPrivileges;

  /// No description provided for @wholesalePrice.
  ///
  /// In en, this message translates to:
  /// **'Wholesale Price'**
  String get wholesalePrice;

  /// No description provided for @wholesalePriceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'High quality products\nwith special price'**
  String get wholesalePriceSubtitle;

  /// No description provided for @wholesaleRequest.
  ///
  /// In en, this message translates to:
  /// **'Wholesale Request'**
  String get wholesaleRequest;

  /// No description provided for @dropYourInquiry.
  ///
  /// In en, this message translates to:
  /// **'Drop your Inquiry'**
  String get dropYourInquiry;

  /// No description provided for @requestHistory.
  ///
  /// In en, this message translates to:
  /// **'Request History'**
  String get requestHistory;

  /// No description provided for @failedToLoadHistory.
  ///
  /// In en, this message translates to:
  /// **'Failed to load history'**
  String get failedToLoadHistory;

  /// No description provided for @allCaughtUp.
  ///
  /// In en, this message translates to:
  /// **'All caught up'**
  String get allCaughtUp;

  /// No description provided for @requestNumber.
  ///
  /// In en, this message translates to:
  /// **'Request #{requestId}'**
  String requestNumber(String requestId);

  /// No description provided for @customer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customer;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @remark.
  ///
  /// In en, this message translates to:
  /// **'Remark'**
  String get remark;

  /// No description provided for @productImages.
  ///
  /// In en, this message translates to:
  /// **'Product Images'**
  String get productImages;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @selectShop.
  ///
  /// In en, this message translates to:
  /// **'Select shop'**
  String get selectShop;

  /// No description provided for @loginRequired.
  ///
  /// In en, this message translates to:
  /// **'Login required'**
  String get loginRequired;

  /// No description provided for @shopAt.
  ///
  /// In en, this message translates to:
  /// **'Shop at'**
  String get shopAt;

  /// No description provided for @branchUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Branch unavailable'**
  String get branchUnavailable;

  /// No description provided for @branchRequiresLoginOrSignup.
  ///
  /// In en, this message translates to:
  /// **'This branch requires Login or Signup'**
  String get branchRequiresLoginOrSignup;

  /// No description provided for @selectShopFallback.
  ///
  /// In en, this message translates to:
  /// **'Select Shop'**
  String get selectShopFallback;

  /// No description provided for @searchProductsBrandsMore.
  ///
  /// In en, this message translates to:
  /// **'Search products, brands and more'**
  String get searchProductsBrandsMore;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @exchange.
  ///
  /// In en, this message translates to:
  /// **'Exchange'**
  String get exchange;

  /// No description provided for @noPromotionsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No promotions available'**
  String get noPromotionsAvailable;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get paymentMethod;

  /// No description provided for @cashOnDelivery.
  ///
  /// In en, this message translates to:
  /// **'Cash on Delivery'**
  String get cashOnDelivery;

  /// No description provided for @checkOut.
  ///
  /// In en, this message translates to:
  /// **'Check Out'**
  String get checkOut;

  /// No description provided for @yourCart.
  ///
  /// In en, this message translates to:
  /// **'Your Cart'**
  String get yourCart;

  /// No description provided for @yourCartIsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get yourCartIsEmpty;

  /// No description provided for @deliveryInfo.
  ///
  /// In en, this message translates to:
  /// **'Delivery Info'**
  String get deliveryInfo;

  /// No description provided for @noDeliveryAddressSelected.
  ///
  /// In en, this message translates to:
  /// **'No delivery address selected'**
  String get noDeliveryAddressSelected;

  /// No description provided for @selectAddress.
  ///
  /// In en, this message translates to:
  /// **'Select address'**
  String get selectAddress;

  /// No description provided for @deliveryFee.
  ///
  /// In en, this message translates to:
  /// **'Delivery Fee'**
  String get deliveryFee;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @packageFees.
  ///
  /// In en, this message translates to:
  /// **'Package fees'**
  String get packageFees;

  /// No description provided for @discount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discount;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @includingVat.
  ///
  /// In en, this message translates to:
  /// **'(incl.VAT)'**
  String get includingVat;

  /// No description provided for @enterPromoCodeHere.
  ///
  /// In en, this message translates to:
  /// **'Enter promo code here'**
  String get enterPromoCodeHere;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'APPLY'**
  String get apply;

  /// No description provided for @placeOrder.
  ///
  /// In en, this message translates to:
  /// **'Place Order'**
  String get placeOrder;

  /// No description provided for @pleaseSelectDeliveryAddressFirst.
  ///
  /// In en, this message translates to:
  /// **'Please select a delivery address first'**
  String get pleaseSelectDeliveryAddressFirst;

  /// No description provided for @confirmOrder.
  ///
  /// In en, this message translates to:
  /// **'Confirm Order'**
  String get confirmOrder;

  /// No description provided for @confirmOrderMessage.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your order. After staff approval, cancellation may no longer be available.'**
  String get confirmOrderMessage;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @orderSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Order Submitted!'**
  String get orderSubmitted;

  /// No description provided for @orderPlacedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Your order #{orderNumber} has been placed\nsuccessfully.'**
  String orderPlacedSuccessfully(String orderNumber);

  /// No description provided for @trackOrder.
  ///
  /// In en, this message translates to:
  /// **'Track Order'**
  String get trackOrder;

  /// No description provided for @supermarketPointMember.
  ///
  /// In en, this message translates to:
  /// **'Supermarket Point Member'**
  String get supermarketPointMember;

  /// No description provided for @pointValue.
  ///
  /// In en, this message translates to:
  /// **'POINT {points}'**
  String pointValue(int points);

  /// No description provided for @countryCambodia.
  ///
  /// In en, this message translates to:
  /// **'Cambodia'**
  String get countryCambodia;

  /// No description provided for @countryCanada.
  ///
  /// In en, this message translates to:
  /// **'Canada'**
  String get countryCanada;

  /// No description provided for @countryEgypt.
  ///
  /// In en, this message translates to:
  /// **'Egypt'**
  String get countryEgypt;

  /// No description provided for @countrySouthKorea.
  ///
  /// In en, this message translates to:
  /// **'South Korea'**
  String get countrySouthKorea;

  /// No description provided for @countryJapan.
  ///
  /// In en, this message translates to:
  /// **'Japan'**
  String get countryJapan;

  /// No description provided for @countryChina.
  ///
  /// In en, this message translates to:
  /// **'China'**
  String get countryChina;

  /// No description provided for @countrySingapore.
  ///
  /// In en, this message translates to:
  /// **'Singapore'**
  String get countrySingapore;

  /// No description provided for @countryItaly.
  ///
  /// In en, this message translates to:
  /// **'Italy'**
  String get countryItaly;

  /// No description provided for @countrySpain.
  ///
  /// In en, this message translates to:
  /// **'Spain'**
  String get countrySpain;

  /// No description provided for @countryIndonesia.
  ///
  /// In en, this message translates to:
  /// **'Indonesia'**
  String get countryIndonesia;

  /// No description provided for @countryArgentina.
  ///
  /// In en, this message translates to:
  /// **'Argentina'**
  String get countryArgentina;

  /// No description provided for @countryUnitedStates.
  ///
  /// In en, this message translates to:
  /// **'United States'**
  String get countryUnitedStates;

  /// No description provided for @countryFrance.
  ///
  /// In en, this message translates to:
  /// **'France'**
  String get countryFrance;

  /// No description provided for @shareActionComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Share action is coming soon'**
  String get shareActionComingSoon;

  /// No description provided for @unableToOpenLoyaltyCard.
  ///
  /// In en, this message translates to:
  /// **'Unable to open loyalty card detail right now.'**
  String get unableToOpenLoyaltyCard;

  /// No description provided for @unableToOpenRewardDetail.
  ///
  /// In en, this message translates to:
  /// **'Unable to open reward detail right now.'**
  String get unableToOpenRewardDetail;

  /// No description provided for @redeem.
  ///
  /// In en, this message translates to:
  /// **'Redeem'**
  String get redeem;

  /// No description provided for @useCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Use current location'**
  String get useCurrentLocation;

  /// No description provided for @confirmRedemption.
  ///
  /// In en, this message translates to:
  /// **'Confirm Redemption'**
  String get confirmRedemption;

  /// No description provided for @failedToLoadMoreProducts.
  ///
  /// In en, this message translates to:
  /// **'Failed to load more products'**
  String get failedToLoadMoreProducts;

  /// No description provided for @orderCanceledSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Order canceled successfully.'**
  String get orderCanceledSuccessfully;

  /// No description provided for @cancelOrder.
  ///
  /// In en, this message translates to:
  /// **'Cancel Order'**
  String get cancelOrder;

  /// No description provided for @yourRecentPurchaseHistory.
  ///
  /// In en, this message translates to:
  /// **'Your recent purchase history'**
  String get yourRecentPurchaseHistory;

  /// No description provided for @filterByStatus.
  ///
  /// In en, this message translates to:
  /// **'Filter by status'**
  String get filterByStatus;

  /// No description provided for @chipMongMall.
  ///
  /// In en, this message translates to:
  /// **'Chip Mong Mall'**
  String get chipMongMall;

  /// No description provided for @shoppingGlobalBrand.
  ///
  /// In en, this message translates to:
  /// **'Shopping global brand'**
  String get shoppingGlobalBrand;

  /// No description provided for @chipMongSupermarket.
  ///
  /// In en, this message translates to:
  /// **'Chip Mong Supermarket'**
  String get chipMongSupermarket;

  /// No description provided for @exploreOurMarketplace.
  ///
  /// In en, this message translates to:
  /// **'Explore our marketplace.'**
  String get exploreOurMarketplace;

  /// No description provided for @label.
  ///
  /// In en, this message translates to:
  /// **'Label'**
  String get label;

  /// No description provided for @defaultDeliveryAddress.
  ///
  /// In en, this message translates to:
  /// **'Default Delivery Address'**
  String get defaultDeliveryAddress;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @receivingAddress.
  ///
  /// In en, this message translates to:
  /// **'Receiving address'**
  String get receivingAddress;

  /// No description provided for @qrCode.
  ///
  /// In en, this message translates to:
  /// **'QR Code'**
  String get qrCode;

  /// No description provided for @qrSavedToGallery.
  ///
  /// In en, this message translates to:
  /// **'QR saved to Gallery/Photos.'**
  String get qrSavedToGallery;

  /// No description provided for @savedOnDeviceForOfflineDisplay.
  ///
  /// In en, this message translates to:
  /// **'Saved on this device for offline display.'**
  String get savedOnDeviceForOfflineDisplay;

  /// No description provided for @availablePoints.
  ///
  /// In en, this message translates to:
  /// **'Available points'**
  String get availablePoints;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @phoneNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumberLabel;

  /// No description provided for @loginOrSignup.
  ///
  /// In en, this message translates to:
  /// **'Login or Signup'**
  String get loginOrSignup;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @wholesaleForm.
  ///
  /// In en, this message translates to:
  /// **'Wholesale Form'**
  String get wholesaleForm;

  /// No description provided for @pleaseEnterNameAndPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter name and phone.'**
  String get pleaseEnterNameAndPhone;

  /// No description provided for @invalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Invalid Phone'**
  String get invalidPhone;

  /// No description provided for @submissionFailed.
  ///
  /// In en, this message translates to:
  /// **'Submission Failed'**
  String get submissionFailed;

  /// No description provided for @somethingWentWrongTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get somethingWentWrongTryAgain;

  /// No description provided for @requestSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Request Submitted!'**
  String get requestSubmitted;

  /// No description provided for @wholesaleRequestSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your wholesale request has been submitted successfully. Our team will contact you shortly.'**
  String get wholesaleRequestSuccess;

  /// No description provided for @customerName.
  ///
  /// In en, this message translates to:
  /// **'Customer Name'**
  String get customerName;

  /// No description provided for @searchProduct.
  ///
  /// In en, this message translates to:
  /// **'Search product'**
  String get searchProduct;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'km'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'km':
      return AppLocalizationsKm();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
