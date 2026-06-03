// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Khmer Central Khmer (`km`).
class AppLocalizationsKm extends AppLocalizations {
  AppLocalizationsKm([String locale = 'km']) : super(locale);

  @override
  String get appTitle => 'ជីព ម៉ុង រីតែល';

  @override
  String get hello => 'សួស្តី';

  @override
  String get loginOrSignup => 'ចូល ឬ ចុះឈ្មោះ';

  @override
  String get logout => 'ចាកចេញ';

  @override
  String get language => 'ភាសា';

  @override
  String get english => 'English';

  @override
  String get khmer => 'ខ្មែរ';

  @override
  String get noConnection => 'គ្មានការតភ្ជាប់';

  @override
  String get serverError => 'បញ្ហាម៉ាស៊ីនមេ';

  @override
  String get invalidInput => 'ការបញ្ចូលមិនត្រឹមត្រូវ';

  @override
  String get somethingWentWrong => 'មានបញ្ហាខ្លះកើតឡើង';

  @override
  String get accountNotFound => 'រកមិនឃើញគណនី';

  @override
  String get phoneDeleted => 'លេខទូរស័ព្ទនេះត្រូវបានលុបចោល';

  @override
  String get activatePhonePrompt =>
      'ដើម្បីដំណើរការលេខទូរស័ព្ទនេះឡើងវិញ សូមចុចបញ្ជាក់ការដំណើរការ និងធ្វើការផ្ទៀងផ្ទាត់ម្តងទៀត។';

  @override
  String get unableToRequestOtp =>
      'មិនអាចស្នើសុំលេខកូដ OTP សម្រាប់ដំណើរការពេលនេះទេ។';

  @override
  String get pleaseSignUpFirst => 'សូមចុះឈ្មោះជាមុនសិន។';

  @override
  String get ok => 'យល់ព្រម';

  @override
  String get cancel => 'បោះបង់';

  @override
  String get goToSignUp => 'ទៅកាន់ការចុះឈ្មោះ';

  @override
  String get confirmActivation => 'បញ្ជាក់ការដំណើរការ';

  @override
  String get phoneNumberLabel => 'លេខទូរស័ព្ទ';

  @override
  String get enterPhoneNumber => 'បញ្ចូលលេខទូរស័ព្ទ';

  @override
  String get agreeTermsPrefix => 'ដោយចុចប៊ូតុងបន្ទាប់ អ្នកយល់ព្រមនឹង ';

  @override
  String get termsOfUse => 'លក្ខខណ្ឌនៃការប្រើប្រាស់';

  @override
  String get agreeTermsMiddle => ' និង ';

  @override
  String get privacyPolicy => 'គោលការណ៍ឯកជនភាព';

  @override
  String get invalidPhoneNumber => 'សូមបញ្ចូលលេខទូរស័ព្ទឱ្យបានត្រឹមត្រូវ';

  @override
  String get signUp => 'ចុះឈ្មោះ';

  @override
  String get continueAsGuest => 'បន្តជាភ្ញៀវ';

  @override
  String get login => 'ចូលគណនី';

  @override
  String get footerVersion => '@2026 ក្រុមហ៊ុន ជីព ម៉ុង | ជំនាន់ 1.8.3';

  @override
  String get enterOtpCode => 'បញ្ចូលលេខកូដ OTP';

  @override
  String get otpSentTelegram =>
      'លេខកូដ OTP ត្រូវបានផ្ញើទៅកាន់ Telegram របស់អ្នក។ សូមពិនិត្យមើល និងបញ្ចូលលេខកូដ 4 ខ្ទង់ខាងក្រោម។';

  @override
  String otpSentSms(String phoneNumber) {
    return 'លេខកូដ OTP ត្រូវបានផ្ញើតាម SMS ទៅ $phoneNumber។ សូមពិនិត្យមើល និងបញ្ចូលលេខកូដ 4 ខ្ទង់ខាងក្រោម។';
  }

  @override
  String get otpSentAgainTelegram =>
      'លេខកូដ OTP ត្រូវបានផ្ញើទៅ Telegram របស់អ្នកម្តងទៀត។';

  @override
  String otpSentAgainSms(String phoneNumber) {
    return 'លេខកូដ OTP ត្រូវបានផ្ញើទៅ $phoneNumber ម្តងទៀត។';
  }

  @override
  String get verificationFailed => 'ការផ្ទៀងផ្ទាត់មិនជោគជ័យ';

  @override
  String get requestFailed => 'ការស្នើសុំមិនជោគជ័យ';

  @override
  String get pleaseWait => 'សូមរង់ចាំ';

  @override
  String get fullNameMissing =>
      'បាត់ឈ្មោះពេញ។ សូមត្រឡប់ក្រោយ និងព្យាយាមចុះឈ្មោះម្តងទៀត។';

  @override
  String get requestOtpFailed => 'ស្នើសុំលេខកូដ OTP មិនជោគជ័យ។';

  @override
  String pleaseWaitSeconds(int seconds) {
    return 'សូមរង់ចាំ $seconds វិនាទី មុននឹងស្នើសុំ OTP។';
  }

  @override
  String get noInternetConnection =>
      'គ្មានការតភ្ជាប់អ៊ីនធឺណិតទេ។ សូមពិនិត្យបណ្តាញរបស់អ្នករួចព្យាយាមម្តងទៀត។';

  @override
  String get unableToRequestOtpRightNow => 'មិនអាចស្នើសុំលេខកូដ OTP ពេលនេះទេ។';

  @override
  String get otpVerificationFailed => 'ការផ្ទៀងផ្ទាត់ OTP មិនជោគជ័យ។';

  @override
  String get phoneNotRegistered =>
      'លេខទូរស័ព្ទនេះមិនទាន់បានចុះឈ្មោះទេ។ សូមចុះឈ្មោះជាមុនសិន។';

  @override
  String get activationTokenMissing =>
      'បាត់លេខកូដដំណើរការ។ សូមស្នើសុំ OTP ថ្មី និងព្យាយាមម្តងទៀត។';

  @override
  String get serverErrorTryLater =>
      'បញ្ហាម៉ាស៊ីនមេ។ សូមព្យាយាមម្តងទៀតនៅពេលក្រោយ។';

  @override
  String get unableToReachServer => 'មិនអាចទាក់ទងម៉ាស៊ីនមេ។ សូមព្យាយាមម្តងទៀត។';

  @override
  String get back => 'ថយក្រោយ';

  @override
  String get requestNewOtp => 'ស្នើសុំ OTP ថ្មី';

  @override
  String get showOtp => 'បង្ហាញ OTP';

  @override
  String get hideOtp => 'លាក់ OTP';

  @override
  String get sending => 'កំពុងបញ្ជូន...';

  @override
  String resendOtpIn(int seconds) {
    return 'ផ្ញើ OTP ឡើងវិញក្នុងរយៈពេល $seconds វិនាទី';
  }

  @override
  String get resendOtp => 'ផ្ញើ OTP ម្តងទៀត';

  @override
  String get verifyOtp => 'ផ្ទៀងផ្ទាត់ OTP';

  @override
  String get enterPinCode => 'បញ្ចូលលេខកូដសម្ងាត់ (PIN)';

  @override
  String enterPinForPhone(String phoneNumber) {
    return 'សូមបញ្ចូលលេខកូដសម្ងាត់ (PIN) ដើម្បីចូលគណនីសម្រាប់ $phoneNumber';
  }

  @override
  String get pinNotSetTitle => 'មិនទាន់កំណត់កូដ PIN';

  @override
  String get pinLoginNotReady => 'ការចូលគណនីតាម PIN មិនទាន់រួចរាល់';

  @override
  String get loginFailed => 'ការចូលគណនីមិនជោគជ័យ';

  @override
  String get biometricNotReady => 'ការចូលគណនីតាមជីវមាត្រមិនទាន់រួចរាល់';

  @override
  String get biometricFailed => 'ការចូលគណនីតាមជីវមាត្រមិនជោគជ័យ';

  @override
  String get pinNotSetMessage =>
      'មិនទាន់បានកំណត់លេខកូដ PIN ទេ។ សូមផ្ទៀងផ្ទាត់ OTP និងបង្កើត PIN ជាមុនសិន។';

  @override
  String get pinLoginEndpointNotAvailable =>
      'សេវាចូលគណនីដោយ PIN មិនទាន់មាននៅលើម៉ាស៊ីនមេនៅឡើយ។ តើអ្នកចង់ប្រើការចូលដោយ OTP ជាបណ្ដោះអាសន្នទេ?';

  @override
  String get invalidPhoneOrPin => 'លេខទូរស័ព្ទ ឬ លេខកូដ PIN មិនត្រឹមត្រូវ។';

  @override
  String get unableToVerifyPin =>
      'មិនអាចផ្ទៀងផ្ទាត់លេខកូដ PIN របស់អ្នកពេលនេះទេ។';

  @override
  String get unableToVerifyBiometric =>
      'មិនអាចផ្ទៀងផ្ទាត់ការចូលតាមជីវមាត្រពេលនេះទេ។';

  @override
  String get unableToSendOtpPinReset =>
      'មិនអាចផ្ញើ OTP សម្រាប់កំណត់ PIN ឡើងវិញទេ។';

  @override
  String get useOtp => 'ប្រើ OTP';

  @override
  String get pinTemporarilyLocked => 'PIN ត្រូវបានចាក់សោបណ្តោះអាសន្ន';

  @override
  String get tooManyIncorrectAttempts => 'អ្នកបានព្យាយាមបញ្ចូលខុសច្រើនដងពេក។';

  @override
  String get remaining => 'នៅសល់';

  @override
  String get showPin => 'បង្ហាញ PIN';

  @override
  String get scanning => 'កំពុងស្កេន...';

  @override
  String get sendingOtp => 'កំពុងផ្ញើ OTP...';

  @override
  String get forgotPinCode => 'ភ្លេចលេខកូដ PIN មែនទេ?';

  @override
  String get submit => 'បញ្ជូន';

  @override
  String get setNewPin => 'កំណត់ PIN ថ្មី';

  @override
  String get resetYourPin => 'កំណត់ PIN របស់អ្នកឡើងវិញ';

  @override
  String get makeSureYouRemember => 'សូមប្រាកដថាអ្នកចងចាំវាច្បាស់';

  @override
  String get chooseNewPinLogin => 'ជ្រើសរើស PIN ថ្មីសម្រាប់ការចូលគណនី';

  @override
  String get chooseNewPinReactivate =>
      'ជ្រើសរើស PIN ថ្មីដើម្បីដំណើរការគណនីឡើងវិញ';

  @override
  String get pinSetupFailed => 'កំណត់ PIN មិនជោគជ័យ';

  @override
  String get pinResetFailed => 'កំណត់ PIN ឡើងវិញមិនជោគជ័យ។ សូមព្យាយាមម្តងទៀត។';

  @override
  String get unableToSetPin =>
      'មិនអាចកំណត់ PIN របស់អ្នកពេលនេះទេ។ សូមព្យាយាមម្តងទៀត។';

  @override
  String get unableToSetPinRightNow => 'មិនអាចកំណត់ PIN ពេលនេះទេ។';

  @override
  String get pinUpdatedLoginFailed =>
      'PIN របស់អ្នកត្រូវបានធ្វើបច្ចុប្បន្នភាព ប៉ុន្តែការចូលគណនីស្វ័យប្រវត្តិមិនជោគជ័យ។ សូមចូលគណនីជាមួយនឹង PIN ថ្មីរបស់អ្នក។';

  @override
  String get yourCart => 'កន្ត្រករបស់អ្នក';

  @override
  String get yourCartIsEmpty => 'កន្ត្រករបស់អ្នកទទេ';

  @override
  String get deliveryInfo => 'ព័ត៌មានដឹកជញ្ជូន';

  @override
  String get productOrder => 'ការបញ្ជាទិញផលិតផល';

  @override
  String get selectAddress => 'ជ្រើសរើសអាសយដ្ឋាន';

  @override
  String get ifProductNotAvailable => 'ប្រសិនបើផលិតផលនេះមិនមាន';

  @override
  String get removeFromMyOrder => 'ដកចេញពីការបញ្ជាទិញរបស់ខ្ញុំ';

  @override
  String get home => 'ទំព័រដើម';

  @override
  String get offers => 'ការផ្តល់ជូន';

  @override
  String get scan => 'ស្កេន';

  @override
  String get orders => 'ការបញ្ជាទិញ';

  @override
  String get profile => 'គណនី';

  @override
  String get outOfStock => 'អស់ពីស្តុក';

  @override
  String get addToCart => 'បន្ថែមទៅកន្ត្រក';

  @override
  String get checkOut => 'ទូទាត់ប្រាក់';

  @override
  String itemsDetail(int count) {
    return 'ព័ត៌មានលម្អិតមុខទំនិញ $count';
  }

  @override
  String totalAmount(String amount) {
    return 'សរុប៖ \$ $amount';
  }

  @override
  String percentOff(int percent) {
    return 'បញ្ចុះតម្លៃ $percent%';
  }

  @override
  String get youMayAlsoLike => 'អ្នកក៏អាចចូលចិត្ត';

  @override
  String get noRelatedProducts => 'គ្មានផលិតផលពាក់ព័ន្ធ';

  @override
  String get image => 'រូបភាព';

  @override
  String get wholesaleForm => 'ទម្រង់លក់ដុំ';

  @override
  String get pleaseEnterNameAndPhone => 'សូមបញ្ចូលឈ្មោះ និងលេខទូរស័ព្ទ។';

  @override
  String get invalidPhone => 'លេខទូរស័ព្ទមិនត្រឹមត្រូវ';

  @override
  String get submissionFailed => 'ការបញ្ជូនមិនជោគជ័យ';

  @override
  String get somethingWentWrongTryAgain =>
      'មានបញ្ហាខ្លះកើតឡើង។ សូមព្យាយាមម្តងទៀត។';

  @override
  String get requestSubmitted => 'ការស្នើសុំត្រូវបានបញ្ជូនជោគជ័យ!';

  @override
  String get wholesaleRequestSuccess =>
      'សំណើទិញដុំរបស់អ្នកត្រូវបានបញ្ជូនជោគជ័យ។ ក្រុមការងាររបស់យើងនឹងទាក់ទងអ្នកក្នុងពេលឆាប់ៗនេះ។';

  @override
  String get done => 'រួចរាល់';

  @override
  String get customerName => 'ឈ្មោះអតិថិជន';

  @override
  String get remark => 'ចំណាំ';

  @override
  String get searchProduct => 'ស្វែងរកផលិតផល';
}
