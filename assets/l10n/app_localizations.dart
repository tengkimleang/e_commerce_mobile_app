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
/// import 'l10n/app_localizations.dart';
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

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Chipmong Retail'**
  String get appTitle;

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get hello;

  /// No description provided for @loginOrSignup.
  ///
  /// In en, this message translates to:
  /// **'Login or Signup'**
  String get loginOrSignup;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @khmer.
  ///
  /// In en, this message translates to:
  /// **'Khmer'**
  String get khmer;

  /// No description provided for @noConnection.
  ///
  /// In en, this message translates to:
  /// **'No Connection'**
  String get noConnection;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'Server Error'**
  String get serverError;

  /// No description provided for @invalidInput.
  ///
  /// In en, this message translates to:
  /// **'Invalid Input'**
  String get invalidInput;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something Went Wrong'**
  String get somethingWentWrong;

  /// No description provided for @accountNotFound.
  ///
  /// In en, this message translates to:
  /// **'Account Not Found'**
  String get accountNotFound;

  /// No description provided for @phoneDeleted.
  ///
  /// In en, this message translates to:
  /// **'This phone number has been deleted'**
  String get phoneDeleted;

  /// No description provided for @activatePhonePrompt.
  ///
  /// In en, this message translates to:
  /// **'To activate this phone number back, please click confirm activation and do the verification process again.'**
  String get activatePhonePrompt;

  /// No description provided for @unableToRequestOtp.
  ///
  /// In en, this message translates to:
  /// **'Unable to request activation OTP right now.'**
  String get unableToRequestOtp;

  /// No description provided for @pleaseSignUpFirst.
  ///
  /// In en, this message translates to:
  /// **'Please sign up first.'**
  String get pleaseSignUpFirst;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @goToSignUp.
  ///
  /// In en, this message translates to:
  /// **'Go to Sign Up'**
  String get goToSignUp;

  /// No description provided for @confirmActivation.
  ///
  /// In en, this message translates to:
  /// **'Confirm Activation'**
  String get confirmActivation;

  /// No description provided for @phoneNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneNumberLabel;

  /// No description provided for @enterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get enterPhoneNumber;

  /// No description provided for @agreeTermsPrefix.
  ///
  /// In en, this message translates to:
  /// **'By clicking Next button you are agreeing to the '**
  String get agreeTermsPrefix;

  /// No description provided for @termsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get termsOfUse;

  /// No description provided for @agreeTermsMiddle.
  ///
  /// In en, this message translates to:
  /// **' and the '**
  String get agreeTermsMiddle;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @invalidPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get invalidPhoneNumber;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @continueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as guest'**
  String get continueAsGuest;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @footerVersion.
  ///
  /// In en, this message translates to:
  /// **'@2026 CHIP MONG GROUP | v1.8.3'**
  String get footerVersion;

  /// No description provided for @enterOtpCode.
  ///
  /// In en, this message translates to:
  /// **'Enter OTP Code'**
  String get enterOtpCode;

  /// No description provided for @otpSentTelegram.
  ///
  /// In en, this message translates to:
  /// **'Your OTP has been sent to Telegram. Please check your Telegram chat and enter the 4-digit code below.'**
  String get otpSentTelegram;

  /// No description provided for @otpSentSms.
  ///
  /// In en, this message translates to:
  /// **'Your OTP has been sent by SMS to {phoneNumber}. Please check your phone and enter the 4-digit code below.'**
  String otpSentSms(String phoneNumber);

  /// No description provided for @otpSentAgainTelegram.
  ///
  /// In en, this message translates to:
  /// **'OTP has been sent again to your Telegram.'**
  String get otpSentAgainTelegram;

  /// No description provided for @otpSentAgainSms.
  ///
  /// In en, this message translates to:
  /// **'OTP has been sent again to {phoneNumber}.'**
  String otpSentAgainSms(String phoneNumber);

  /// No description provided for @verificationFailed.
  ///
  /// In en, this message translates to:
  /// **'Verification Failed'**
  String get verificationFailed;

  /// No description provided for @requestFailed.
  ///
  /// In en, this message translates to:
  /// **'Request Failed'**
  String get requestFailed;

  /// No description provided for @pleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please Wait'**
  String get pleaseWait;

  /// No description provided for @fullNameMissing.
  ///
  /// In en, this message translates to:
  /// **'Full name is missing. Please go back and try signup again.'**
  String get fullNameMissing;

  /// No description provided for @requestOtpFailed.
  ///
  /// In en, this message translates to:
  /// **'Request OTP failed.'**
  String get requestOtpFailed;

  /// No description provided for @pleaseWaitSeconds.
  ///
  /// In en, this message translates to:
  /// **'Please wait {seconds} second(s) before requesting OTP.'**
  String pleaseWaitSeconds(int seconds);

  /// No description provided for @noInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please check your network and try again.'**
  String get noInternetConnection;

  /// No description provided for @unableToRequestOtpRightNow.
  ///
  /// In en, this message translates to:
  /// **'Unable to request OTP right now.'**
  String get unableToRequestOtpRightNow;

  /// No description provided for @otpVerificationFailed.
  ///
  /// In en, this message translates to:
  /// **'OTP verification failed.'**
  String get otpVerificationFailed;

  /// No description provided for @phoneNotRegistered.
  ///
  /// In en, this message translates to:
  /// **'This phone is not registered. Please sign up first.'**
  String get phoneNotRegistered;

  /// No description provided for @activationTokenMissing.
  ///
  /// In en, this message translates to:
  /// **'Activation token is missing. Please request a new OTP and try again.'**
  String get activationTokenMissing;

  /// No description provided for @serverErrorTryLater.
  ///
  /// In en, this message translates to:
  /// **'Server error. Please try again later.'**
  String get serverErrorTryLater;

  /// No description provided for @unableToReachServer.
  ///
  /// In en, this message translates to:
  /// **'Unable to reach the server. Please try again.'**
  String get unableToReachServer;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @requestNewOtp.
  ///
  /// In en, this message translates to:
  /// **'Request New OTP'**
  String get requestNewOtp;

  /// No description provided for @showOtp.
  ///
  /// In en, this message translates to:
  /// **'Show OTP'**
  String get showOtp;

  /// No description provided for @hideOtp.
  ///
  /// In en, this message translates to:
  /// **'Hide OTP'**
  String get hideOtp;

  /// No description provided for @sending.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get sending;

  /// No description provided for @resendOtpIn.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP in {seconds}s'**
  String resendOtpIn(int seconds);

  /// No description provided for @resendOtp.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP'**
  String get resendOtp;

  /// No description provided for @verifyOtp.
  ///
  /// In en, this message translates to:
  /// **'VERIFY OTP'**
  String get verifyOtp;

  /// No description provided for @enterPinCode.
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN Code'**
  String get enterPinCode;

  /// No description provided for @enterPinForPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter the PIN Code to login for {phoneNumber}'**
  String enterPinForPhone(String phoneNumber);

  /// No description provided for @pinNotSetTitle.
  ///
  /// In en, this message translates to:
  /// **'PIN Not Set'**
  String get pinNotSetTitle;

  /// No description provided for @pinLoginNotReady.
  ///
  /// In en, this message translates to:
  /// **'PIN Login Not Ready'**
  String get pinLoginNotReady;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login Failed'**
  String get loginFailed;

  /// No description provided for @biometricNotReady.
  ///
  /// In en, this message translates to:
  /// **'Biometric Login Not Ready'**
  String get biometricNotReady;

  /// No description provided for @biometricFailed.
  ///
  /// In en, this message translates to:
  /// **'Biometric Login Failed'**
  String get biometricFailed;

  /// No description provided for @pinNotSetMessage.
  ///
  /// In en, this message translates to:
  /// **'PIN is not set yet. Please verify OTP and create a PIN first.'**
  String get pinNotSetMessage;

  /// No description provided for @pinLoginEndpointNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'PIN login endpoint is not available on backend yet. Use OTP login for now?'**
  String get pinLoginEndpointNotAvailable;

  /// No description provided for @invalidPhoneOrPin.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone or PIN code.'**
  String get invalidPhoneOrPin;

  /// No description provided for @unableToVerifyPin.
  ///
  /// In en, this message translates to:
  /// **'Unable to verify your PIN right now.'**
  String get unableToVerifyPin;

  /// No description provided for @unableToVerifyBiometric.
  ///
  /// In en, this message translates to:
  /// **'Unable to verify biometric login right now.'**
  String get unableToVerifyBiometric;

  /// No description provided for @unableToSendOtpPinReset.
  ///
  /// In en, this message translates to:
  /// **'Unable to send OTP for PIN reset.'**
  String get unableToSendOtpPinReset;

  /// No description provided for @useOtp.
  ///
  /// In en, this message translates to:
  /// **'Use OTP'**
  String get useOtp;

  /// No description provided for @pinTemporarilyLocked.
  ///
  /// In en, this message translates to:
  /// **'PIN Temporarily Locked'**
  String get pinTemporarilyLocked;

  /// No description provided for @tooManyIncorrectAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many incorrect attempts.'**
  String get tooManyIncorrectAttempts;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'remaining'**
  String get remaining;

  /// No description provided for @showPin.
  ///
  /// In en, this message translates to:
  /// **'Show PIN'**
  String get showPin;

  /// No description provided for @scanning.
  ///
  /// In en, this message translates to:
  /// **'Scanning...'**
  String get scanning;

  /// No description provided for @sendingOtp.
  ///
  /// In en, this message translates to:
  /// **'Sending OTP...'**
  String get sendingOtp;

  /// No description provided for @forgotPinCode.
  ///
  /// In en, this message translates to:
  /// **'Forgot the PIN code?'**
  String get forgotPinCode;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'SUBMIT'**
  String get submit;

  /// No description provided for @setNewPin.
  ///
  /// In en, this message translates to:
  /// **'Set new PIN'**
  String get setNewPin;

  /// No description provided for @resetYourPin.
  ///
  /// In en, this message translates to:
  /// **'Reset your PIN'**
  String get resetYourPin;

  /// No description provided for @makeSureYouRemember.
  ///
  /// In en, this message translates to:
  /// **'Make sure you remember'**
  String get makeSureYouRemember;

  /// No description provided for @chooseNewPinLogin.
  ///
  /// In en, this message translates to:
  /// **'Choose a new PIN for login'**
  String get chooseNewPinLogin;

  /// No description provided for @chooseNewPinReactivate.
  ///
  /// In en, this message translates to:
  /// **'Choose a new PIN to reactivate your account'**
  String get chooseNewPinReactivate;

  /// No description provided for @pinSetupFailed.
  ///
  /// In en, this message translates to:
  /// **'PIN Setup Failed'**
  String get pinSetupFailed;

  /// No description provided for @pinResetFailed.
  ///
  /// In en, this message translates to:
  /// **'PIN reset failed. Please try again.'**
  String get pinResetFailed;

  /// No description provided for @unableToSetPin.
  ///
  /// In en, this message translates to:
  /// **'Unable to set your PIN right now. Please try again.'**
  String get unableToSetPin;

  /// No description provided for @unableToSetPinRightNow.
  ///
  /// In en, this message translates to:
  /// **'Unable to set PIN right now.'**
  String get unableToSetPinRightNow;

  /// No description provided for @pinUpdatedLoginFailed.
  ///
  /// In en, this message translates to:
  /// **'Your PIN was updated, but automatic sign-in failed. Please log in with your new PIN.'**
  String get pinUpdatedLoginFailed;

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

  /// No description provided for @productOrder.
  ///
  /// In en, this message translates to:
  /// **'Product Order'**
  String get productOrder;

  /// No description provided for @selectAddress.
  ///
  /// In en, this message translates to:
  /// **'Select address'**
  String get selectAddress;

  /// No description provided for @ifProductNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'If this product is not available'**
  String get ifProductNotAvailable;

  /// No description provided for @removeFromMyOrder.
  ///
  /// In en, this message translates to:
  /// **'Remove it from my order'**
  String get removeFromMyOrder;

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

  /// No description provided for @outOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock'**
  String get outOfStock;

  /// No description provided for @addToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to cart'**
  String get addToCart;

  /// No description provided for @checkOut.
  ///
  /// In en, this message translates to:
  /// **'Check Out'**
  String get checkOut;

  /// No description provided for @itemsDetail.
  ///
  /// In en, this message translates to:
  /// **'{count} Items detail'**
  String itemsDetail(int count);

  /// No description provided for @totalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total: \$ {amount}'**
  String totalAmount(String amount);

  /// No description provided for @percentOff.
  ///
  /// In en, this message translates to:
  /// **'{percent}% OFF'**
  String percentOff(int percent);

  /// No description provided for @youMayAlsoLike.
  ///
  /// In en, this message translates to:
  /// **'You may also like'**
  String get youMayAlsoLike;

  /// No description provided for @noRelatedProducts.
  ///
  /// In en, this message translates to:
  /// **'No related products'**
  String get noRelatedProducts;

  /// No description provided for @image.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get image;

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

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @customerName.
  ///
  /// In en, this message translates to:
  /// **'Customer Name'**
  String get customerName;

  /// No description provided for @remark.
  ///
  /// In en, this message translates to:
  /// **'Remark'**
  String get remark;

  /// No description provided for @searchProduct.
  ///
  /// In en, this message translates to:
  /// **'Search product'**
  String get searchProduct;

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

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

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

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;
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
