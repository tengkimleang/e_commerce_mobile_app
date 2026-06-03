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
  String get hello => 'Hello';

  @override
  String get loginOrSignup => 'Login or Signup';

  @override
  String get logout => 'Logout';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get khmer => 'Khmer';

  @override
  String get noConnection => 'No Connection';

  @override
  String get serverError => 'Server Error';

  @override
  String get invalidInput => 'Invalid Input';

  @override
  String get somethingWentWrong => 'Something Went Wrong';

  @override
  String get accountNotFound => 'Account Not Found';

  @override
  String get phoneDeleted => 'This phone number has been deleted';

  @override
  String get activatePhonePrompt =>
      'To activate this phone number back, please click confirm activation and do the verification process again.';

  @override
  String get unableToRequestOtp =>
      'Unable to request activation OTP right now.';

  @override
  String get pleaseSignUpFirst => 'Please sign up first.';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancel';

  @override
  String get goToSignUp => 'Go to Sign Up';

  @override
  String get confirmActivation => 'Confirm Activation';

  @override
  String get phoneNumberLabel => 'Phone number';

  @override
  String get enterPhoneNumber => 'Enter phone number';

  @override
  String get agreeTermsPrefix =>
      'By clicking Next button you are agreeing to the ';

  @override
  String get termsOfUse => 'Terms of Use';

  @override
  String get agreeTermsMiddle => ' and the ';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get invalidPhoneNumber => 'Please enter a valid phone number';

  @override
  String get signUp => 'Sign Up';

  @override
  String get continueAsGuest => 'Continue as guest';

  @override
  String get login => 'Login';

  @override
  String get footerVersion => '@2026 CHIP MONG GROUP | v1.8.3';

  @override
  String get enterOtpCode => 'Enter OTP Code';

  @override
  String get otpSentTelegram =>
      'Your OTP has been sent to Telegram. Please check your Telegram chat and enter the 4-digit code below.';

  @override
  String otpSentSms(String phoneNumber) {
    return 'Your OTP has been sent by SMS to $phoneNumber. Please check your phone and enter the 4-digit code below.';
  }

  @override
  String get otpSentAgainTelegram =>
      'OTP has been sent again to your Telegram.';

  @override
  String otpSentAgainSms(String phoneNumber) {
    return 'OTP has been sent again to $phoneNumber.';
  }

  @override
  String get verificationFailed => 'Verification Failed';

  @override
  String get requestFailed => 'Request Failed';

  @override
  String get pleaseWait => 'Please Wait';

  @override
  String get fullNameMissing =>
      'Full name is missing. Please go back and try signup again.';

  @override
  String get requestOtpFailed => 'Request OTP failed.';

  @override
  String pleaseWaitSeconds(int seconds) {
    return 'Please wait $seconds second(s) before requesting OTP.';
  }

  @override
  String get noInternetConnection =>
      'No internet connection. Please check your network and try again.';

  @override
  String get unableToRequestOtpRightNow => 'Unable to request OTP right now.';

  @override
  String get otpVerificationFailed => 'OTP verification failed.';

  @override
  String get phoneNotRegistered =>
      'This phone is not registered. Please sign up first.';

  @override
  String get activationTokenMissing =>
      'Activation token is missing. Please request a new OTP and try again.';

  @override
  String get serverErrorTryLater => 'Server error. Please try again later.';

  @override
  String get unableToReachServer =>
      'Unable to reach the server. Please try again.';

  @override
  String get back => 'Back';

  @override
  String get requestNewOtp => 'Request New OTP';

  @override
  String get showOtp => 'Show OTP';

  @override
  String get hideOtp => 'Hide OTP';

  @override
  String get sending => 'Sending...';

  @override
  String resendOtpIn(int seconds) {
    return 'Resend OTP in ${seconds}s';
  }

  @override
  String get resendOtp => 'Resend OTP';

  @override
  String get verifyOtp => 'VERIFY OTP';

  @override
  String get enterPinCode => 'Enter your PIN Code';

  @override
  String enterPinForPhone(String phoneNumber) {
    return 'Please enter the PIN Code to login for $phoneNumber';
  }

  @override
  String get pinNotSetTitle => 'PIN Not Set';

  @override
  String get pinLoginNotReady => 'PIN Login Not Ready';

  @override
  String get loginFailed => 'Login Failed';

  @override
  String get biometricNotReady => 'Biometric Login Not Ready';

  @override
  String get biometricFailed => 'Biometric Login Failed';

  @override
  String get pinNotSetMessage =>
      'PIN is not set yet. Please verify OTP and create a PIN first.';

  @override
  String get pinLoginEndpointNotAvailable =>
      'PIN login endpoint is not available on backend yet. Use OTP login for now?';

  @override
  String get invalidPhoneOrPin => 'Invalid phone or PIN code.';

  @override
  String get unableToVerifyPin => 'Unable to verify your PIN right now.';

  @override
  String get unableToVerifyBiometric =>
      'Unable to verify biometric login right now.';

  @override
  String get unableToSendOtpPinReset => 'Unable to send OTP for PIN reset.';

  @override
  String get useOtp => 'Use OTP';

  @override
  String get pinTemporarilyLocked => 'PIN Temporarily Locked';

  @override
  String get tooManyIncorrectAttempts => 'Too many incorrect attempts.';

  @override
  String get remaining => 'remaining';

  @override
  String get showPin => 'Show PIN';

  @override
  String get scanning => 'Scanning...';

  @override
  String get sendingOtp => 'Sending OTP...';

  @override
  String get forgotPinCode => 'Forgot the PIN code?';

  @override
  String get submit => 'SUBMIT';

  @override
  String get setNewPin => 'Set new PIN';

  @override
  String get resetYourPin => 'Reset your PIN';

  @override
  String get makeSureYouRemember => 'Make sure you remember';

  @override
  String get chooseNewPinLogin => 'Choose a new PIN for login';

  @override
  String get chooseNewPinReactivate =>
      'Choose a new PIN to reactivate your account';

  @override
  String get pinSetupFailed => 'PIN Setup Failed';

  @override
  String get pinResetFailed => 'PIN reset failed. Please try again.';

  @override
  String get unableToSetPin =>
      'Unable to set your PIN right now. Please try again.';

  @override
  String get unableToSetPinRightNow => 'Unable to set PIN right now.';

  @override
  String get pinUpdatedLoginFailed =>
      'Your PIN was updated, but automatic sign-in failed. Please log in with your new PIN.';

  @override
  String get yourCart => 'Your Cart';

  @override
  String get yourCartIsEmpty => 'Your cart is empty';

  @override
  String get deliveryInfo => 'Delivery Info';

  @override
  String get productOrder => 'Product Order';

  @override
  String get selectAddress => 'Select address';

  @override
  String get ifProductNotAvailable => 'If this product is not available';

  @override
  String get removeFromMyOrder => 'Remove it from my order';

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
  String get outOfStock => 'Out of Stock';

  @override
  String get addToCart => 'Add to cart';

  @override
  String get checkOut => 'Check Out';

  @override
  String itemsDetail(int count) {
    return '$count Items detail';
  }

  @override
  String totalAmount(String amount) {
    return 'Total: \$ $amount';
  }

  @override
  String percentOff(int percent) {
    return '$percent% OFF';
  }

  @override
  String get youMayAlsoLike => 'You may also like';

  @override
  String get noRelatedProducts => 'No related products';

  @override
  String get image => 'Image';

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
  String get done => 'Done';

  @override
  String get customerName => 'Customer Name';

  @override
  String get remark => 'Remark';

  @override
  String get searchProduct => 'Search product';
}
