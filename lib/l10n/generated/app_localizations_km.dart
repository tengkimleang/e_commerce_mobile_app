// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Khmer Central Khmer (`km`).
class AppLocalizationsKm extends AppLocalizations {
  AppLocalizationsKm([String locale = 'km']) : super(locale);

  @override
  String get appTitle => 'Chipmong Retail';

  @override
  String get language => 'ភាសា';

  @override
  String get english => 'អង់គ្លេស';

  @override
  String get khmer => 'ខ្មែរ';

  @override
  String get setProfilePhoto => 'កំណត់រូបថតប្រវត្តិរូប';

  @override
  String get logout => 'ចាកចេញ';

  @override
  String get reallyWantToLogout => 'តើអ្នកពិតជាចង់ចាកចេញមែនទេ?';

  @override
  String get cancel => 'បោះបង់';

  @override
  String get yes => 'បាទ/ចាស';

  @override
  String get signUp => 'ចុះឈ្មោះ';

  @override
  String get phoneNumber => 'លេខទូរសព្ទ';

  @override
  String get enterPhoneNumber => 'បញ្ចូលលេខទូរសព្ទ';

  @override
  String get personalInformation => 'ព័ត៌មានផ្ទាល់ខ្លួន';

  @override
  String get yourName => 'ឈ្មោះរបស់អ្នក';

  @override
  String get dateOfBirth => 'ថ្ងៃខែឆ្នាំកំណើត';

  @override
  String get address => 'អាសយដ្ឋាន';

  @override
  String get notAdded => 'មិនទាន់បញ្ចូល';

  @override
  String get account => 'គណនី';

  @override
  String get security => 'សុវត្ថិភាព';

  @override
  String get changePin => 'ប្ដូរ PIN';

  @override
  String get change => 'ប្ដូរ';

  @override
  String get termsAndConditions => 'លក្ខខណ្ឌប្រើប្រាស់';

  @override
  String get seeMore => 'មើលបន្ថែម';

  @override
  String get dangerZone => 'តំបន់គ្រោះថ្នាក់';

  @override
  String get orderStatusRequesting => 'កំពុងស្នើសុំ';

  @override
  String get orderStatusPicking => 'កំពុងរៀបចំ';

  @override
  String get orderStatusDelivering => 'កំពុងដឹកជញ្ជូន';

  @override
  String get orderStatusDelivered => 'បានដឹកជញ្ជូន';

  @override
  String get orderStatusCanceled => 'បានបោះបង់';

  @override
  String get home => 'ទំព័រដើម';

  @override
  String get offers => 'ប្រូម៉ូសិន';

  @override
  String get scan => 'ស្កេន';

  @override
  String get orders => 'ការបញ្ជាទិញ';

  @override
  String get profile => 'ប្រវត្តិរូប';

  @override
  String get favorites => 'ចូលចិត្ត';

  @override
  String get noFavoriteProductsYet => 'មិនទាន់មានផលិតផលដែលចូលចិត្ត';

  @override
  String get notification => 'ការជូនដំណឹង';

  @override
  String get order => 'ការបញ្ជាទិញ';

  @override
  String get promotion => 'ប្រូម៉ូសិន';

  @override
  String get promoteCode => 'កូដប្រូម៉ូសិន';

  @override
  String get failedToLoadPromotions => 'មិនអាចទាញយកប្រូម៉ូសិនបានទេ';

  @override
  String get retry => 'ព្យាយាមម្ដងទៀត';

  @override
  String get noResultFound => 'រកមិនឃើញលទ្ធផល';

  @override
  String get shopByCountry => 'ទិញតាមប្រទេស';

  @override
  String get shopByCategory => 'ទិញតាមប្រភេទ';

  @override
  String get failedToLoadShopCategories => 'មិនអាចទាញយកប្រភេទហាងបានទេ';

  @override
  String get viewAll => 'មើលទាំងអស់';

  @override
  String get all => 'ទាំងអស់';

  @override
  String get noProducts => 'មិនមានផលិតផល';

  @override
  String get failedToLoadProducts => 'មិនអាចទាញយកផលិតផលបានទេ';

  @override
  String get exchangePoints => 'ប្ដូរពិន្ទុ';

  @override
  String get priceChecking => 'ពិនិត្យតម្លៃ';

  @override
  String get search => 'ស្វែងរក';

  @override
  String get searchProductHint => 'ស្វែងរកផលិតផល...';

  @override
  String get noProductsFound => 'រកមិនឃើញផលិតផល';

  @override
  String get productDescription => 'ពិពណ៌នា';

  @override
  String get searchProducts => 'ស្វែងរកផលិតផល';

  @override
  String get closeSearch => 'បិទការស្វែងរក';

  @override
  String get filterSubcategories => 'តម្រងប្រភេទរង';

  @override
  String get noCategoriesAvailable => 'មិនមានប្រភេទ';

  @override
  String get failedToLoadCategoriesRetry =>
      'មិនអាចទាញយកប្រភេទបានទេ។ ព្យាយាមម្ដងទៀត';

  @override
  String get productNotFoundForBarcode => 'រកមិនឃើញផលិតផលសម្រាប់បាកូដនេះ';

  @override
  String get failedToLookUpProduct =>
      'មិនអាចស្វែងរកផលិតផលបានទេ។ សូមព្យាយាមម្ដងទៀត។';

  @override
  String productAdded(String productName) {
    return 'បានបន្ថែម $productName';
  }

  @override
  String itemCount(int count) {
    return '$count មុខ';
  }

  @override
  String get add => 'បន្ថែម';

  @override
  String get partnerPrivileges => 'អត្ថប្រយោជន៍ដៃគូ';

  @override
  String get wholesalePrice => 'តម្លៃបោះដុំ';

  @override
  String get wholesalePriceSubtitle => 'ផលិតផលគុណភាពខ្ពស់\nជាមួយតម្លៃពិសេស';

  @override
  String get wholesaleRequest => 'សំណើបោះដុំ';

  @override
  String get dropYourInquiry => 'ផ្ញើសំណួររបស់អ្នក';

  @override
  String get requestHistory => 'ប្រវត្តិសំណើ';

  @override
  String get failedToLoadHistory => 'មិនអាចទាញយកប្រវត្តិបានទេ';

  @override
  String get allCaughtUp => 'បានបង្ហាញទាំងអស់ហើយ';

  @override
  String requestNumber(String requestId) {
    return 'សំណើ #$requestId';
  }

  @override
  String get customer => 'អតិថិជន';

  @override
  String get phone => 'ទូរសព្ទ';

  @override
  String get remark => 'កំណត់ចំណាំ';

  @override
  String get productImages => 'រូបភាពផលិតផល';

  @override
  String get close => 'បិទ';

  @override
  String get selectShop => 'ជ្រើសរើសហាង';

  @override
  String get loginRequired => 'ត្រូវការចូលគណនី';

  @override
  String get shopAt => 'ទិញនៅ';

  @override
  String get branchUnavailable => 'សាខាមិនអាចប្រើបាន';

  @override
  String get branchRequiresLoginOrSignup => 'សាខានេះត្រូវការចូលគណនី ឬចុះឈ្មោះ';

  @override
  String get selectShopFallback => 'ជ្រើសរើសហាង';

  @override
  String get searchProductsBrandsMore => 'ស្វែងរក';

  @override
  String get skip => 'រំលង';

  @override
  String get login => 'ចូលគណនី';

  @override
  String get exchange => 'ប្ដូរ';

  @override
  String get noPromotionsAvailable => 'មិនមានប្រូម៉ូសិន';

  @override
  String get paymentMethod => 'វិធីបង់ប្រាក់';

  @override
  String get cashOnDelivery => 'បង់ប្រាក់ពេលទទួលទំនិញ';

  @override
  String get checkOut => 'បញ្ជាទិញ';

  @override
  String get yourCart => 'រទេះទំនិញរបស់អ្នក';

  @override
  String get yourCartIsEmpty => 'រទេះទំនិញរបស់អ្នកទទេ';

  @override
  String get deliveryInfo => 'ព័ត៌មានដឹកជញ្ជូន';

  @override
  String get noDeliveryAddressSelected => 'មិនទាន់ជ្រើសរើសអាសយដ្ឋានដឹកជញ្ជូន';

  @override
  String get selectAddress => 'ជ្រើសរើសអាសយដ្ឋាន';

  @override
  String get deliveryFee => 'ថ្លៃដឹកជញ្ជូន';

  @override
  String get subtotal => 'តម្លៃសរុបរង';

  @override
  String get packageFees => 'ថ្លៃវេចខ្ចប់';

  @override
  String get discount => 'បញ្ចុះតម្លៃ';

  @override
  String get total => 'សរុប';

  @override
  String get includingVat => '(រួមបញ្ចូល VAT)';

  @override
  String get enterPromoCodeHere => 'បញ្ចូលកូដប្រូម៉ូសិននៅទីនេះ';

  @override
  String get apply => 'អនុវត្ត';

  @override
  String get placeOrder => 'ដាក់ការបញ្ជាទិញ';

  @override
  String get pleaseSelectDeliveryAddressFirst =>
      'សូមជ្រើសរើសអាសយដ្ឋានដឹកជញ្ជូនជាមុន';

  @override
  String get confirmOrder => 'បញ្ជាក់ការបញ្ជាទិញ';

  @override
  String get confirmOrderMessage =>
      'សូមបញ្ជាក់ការបញ្ជាទិញរបស់អ្នក។ បន្ទាប់ពីបុគ្គលិកអនុម័ត អ្នកប្រហែលជាមិនអាចបោះបង់បានទៀតទេ។';

  @override
  String get back => 'ត្រឡប់ក្រោយ';

  @override
  String get confirm => 'បញ្ជាក់';

  @override
  String get orderSubmitted => 'បានដាក់ការបញ្ជាទិញ!';

  @override
  String orderPlacedSuccessfully(String orderNumber) {
    return 'ការបញ្ជាទិញ #$orderNumber របស់អ្នកត្រូវបានដាក់\nដោយជោគជ័យ។';
  }

  @override
  String get trackOrder => 'តាមដានការបញ្ជាទិញ';

  @override
  String get supermarketPointMember => 'សមាជិកពិន្ទុស៊ុបភើម៉ាឃីត';

  @override
  String pointValue(int points) {
    return 'ពិន្ទុ $points';
  }

  @override
  String get countryCambodia => 'កម្ពុជា';

  @override
  String get countryCanada => 'កាណាដា';

  @override
  String get countryEgypt => 'អេហ្ស៊ីប';

  @override
  String get countrySouthKorea => 'កូរ៉េខាងត្បូង';

  @override
  String get countryJapan => 'ជប៉ុន';

  @override
  String get countryChina => 'ចិន';

  @override
  String get countrySingapore => 'សិង្ហបុរី';

  @override
  String get countryItaly => 'អ៊ីតាលី';

  @override
  String get countrySpain => 'អេស្ប៉ាញ';

  @override
  String get countryIndonesia => 'ឥណ្ឌូណេស៊ី';

  @override
  String get countryArgentina => 'អាហ្សង់ទីន';

  @override
  String get countryUnitedStates => 'សហរដ្ឋអាមេរិក';

  @override
  String get countryFrance => 'បារាំង';

  @override
  String get shareActionComingSoon => 'មុខងារចែករំលែកនឹងមកដល់ឆាប់ៗនេះ';

  @override
  String get unableToOpenLoyaltyCard =>
      'មិនអាចបើកព័ត៌មានលម្អិតកាតសមាជិកពេលនេះទេ។';

  @override
  String get unableToOpenRewardDetail =>
      'មិនអាចបើកព័ត៌មានលម្អិតរង្វាន់ពេលនេះទេ។';

  @override
  String get redeem => 'ប្តូរយករង្វាន់';

  @override
  String get useCurrentLocation => 'ប្រើទីតាំងបច្ចុប្បន្ន';

  @override
  String get confirmRedemption => 'បញ្ជាក់ការប្តូររង្វាន់';

  @override
  String get failedToLoadMoreProducts => 'បរាជ័យក្នុងការទាញយកផលិតផលបន្ថែម';

  @override
  String get orderCanceledSuccessfully => 'ការបញ្ជាទិញត្រូវបានលុបចោលដោយជោគជ័យ។';

  @override
  String get cancelOrder => 'លុបចោលការបញ្ជាទិញ';

  @override
  String get yourRecentPurchaseHistory => 'ប្រវត្តិការទិញថ្មីៗរបស់អ្នក';

  @override
  String get filterByStatus => 'ចម្រាញ់តាមស្ថានភាព';

  @override
  String get chipMongMall => 'ផ្សារទំនើបជីពម៉ុង';

  @override
  String get shoppingGlobalBrand => 'ទិញទំនិញម៉ាកល្បីៗជុំវិញពិភពលោក';

  @override
  String get chipMongSupermarket => 'ផ្សារទំនើបជីពម៉ុង Supermarket';

  @override
  String get exploreOurMarketplace => 'ស្វែងរកទំនិញក្នុងទីផ្សាររបស់យើង។';

  @override
  String get label => 'ស្លាកសញ្ញា';

  @override
  String get defaultDeliveryAddress => 'អាសយដ្ឋានដឹកជញ្ជូនលំនាំដើម';

  @override
  String get save => 'រក្សាទុក';

  @override
  String get receivingAddress => 'អាសយដ្ឋានទទួល';

  @override
  String get qrCode => 'កូដ QR';

  @override
  String get qrSavedToGallery =>
      'កូដ QR ត្រូវបានរក្សាទុកក្នុងវិចិត្រសាល/រូបថត។';

  @override
  String get savedOnDeviceForOfflineDisplay =>
      'បានរក្សាទុកនៅលើឧបករណ៍នេះសម្រាប់ការបង្ហាញពេលគ្មានអ៊ីនធឺណិត។';

  @override
  String get availablePoints => 'ពិន្ទុដែលមាន';

  @override
  String get ok => 'យល់ព្រម';

  @override
  String get phoneNumberLabel => 'លេខទូរសព្ទ:';

  @override
  String get loginWithBiometric => 'ចូលដោយជីវវិទ្យា';

  @override
  String get telegramOtpBackup => 'ការបម្រុងទុក OTP តេឡេក្រាម';

  @override
  String get deleteAccount => 'លុបគណនី';

  @override
  String get permanentlyDeleteAccount =>
      'លុបគណនី និងទិន្នន័យទាំងអស់ជាអចិន្ត្រៃយ៍';

  @override
  String get loginOrSignup => 'ចូលគណនី ឬ ចុះឈ្មោះ';

  @override
  String get done => 'រួចរាល់';

  @override
  String get wholesaleForm => 'ទម្រង់លក់ដុំ';

  @override
  String get pleaseEnterNameAndPhone => 'សូមបញ្ចូលឈ្មោះ និងលេខទូរស័ព្ទ។';

  @override
  String get invalidPhone => 'លេខទូរស័ព្ទមិនត្រឹមត្រូវ';

  @override
  String get submissionFailed => 'ការបញ្ជូនបរាជ័យ';

  @override
  String get somethingWentWrongTryAgain => 'មានបញ្ហាខ្លះ។ សូមព្យាយាមម្តងទៀត។';

  @override
  String get requestSubmitted => 'សំណើត្រូវបានបញ្ជូន!';

  @override
  String get wholesaleRequestSuccess =>
      'សំណើលក់ដុំរបស់អ្នកត្រូវបានបញ្ជូនដោយជោគជ័យ។ ក្រុមការងារយើងនឹងទាក់ទងអ្នកក្នុងពេលឆាប់ៗនេះ។';

  @override
  String get customerName => 'ឈ្មោះអតិថិជន';

  @override
  String get searchProduct => 'ស្វែងរកផលិតផល';

  @override
  String get byClickingNextAgreeing =>
      'តាមរយៈការចុចប៊ូតុង បន្ទាប់ អ្នកយល់ព្រមនឹង ';

  @override
  String get termsOfUse => 'លក្ខខណ្ឌប្រើប្រាស់';

  @override
  String get andThe => ' និង ';

  @override
  String get privacyPolicy => 'គោលការណ៍ភាពឯកជន';

  @override
  String get continueAsGuest => 'បន្តដោយមិនចូលគណនី';

  @override
  String get fullName => 'ឈ្មោះពេញ';

  @override
  String get enterFullName => 'បញ្ចូលឈ្មោះពេញ';

  @override
  String get next => 'បន្ទាប់';

  @override
  String get enterPinCode => 'បញ្ចូលលេខកូដ PIN របស់អ្នក';

  @override
  String pleaseEnterPinCodeFor(String phoneNumber) {
    return 'សូមបញ្ចូលលេខកូដ PIN ដើម្បីចូលគណនីសម្រាប់ $phoneNumber';
  }

  @override
  String get showPin => 'បង្ហាញ PIN';

  @override
  String get hidePin => 'លាក់ PIN';

  @override
  String get forgotPinCode => 'ភ្លេចលេខកូដ PIN?';

  @override
  String get submitAllCaps => 'បញ្ជូន';

  @override
  String get setNewPin => 'កំណត់លេខកូដ PIN ថ្មី';

  @override
  String get makeSureYouRemember => 'សូមប្រាកដថាអ្នកចងចាំវា';

  @override
  String get oldPin => 'លេខកូដ PIN ចាស់';

  @override
  String get newPin => 'លេខកូដ PIN ថ្មី';

  @override
  String get resetYourPin => 'កំណត់លេខកូដ PIN របស់អ្នកឡើងវិញ';

  @override
  String get chooseNewPinForLogin => 'ជ្រើសរើសលេខកូដ PIN ថ្មីសម្រាប់ចូលគណនី';

  @override
  String get chooseNewPinToReactivate =>
      'ជ្រើសរើសលេខកូដ PIN ថ្មីដើម្បីដំណើរការគណនីរបស់អ្នកឡើងវិញ';

  @override
  String get loginWithFaceId => 'ចូលដោយ Face ID';

  @override
  String get usernameLabel => 'ឈ្មោះអ្នកប្រើប្រាស់:';

  @override
  String get supermarketPointLabel => 'ពិន្ទុផ្សារទំនើប:';

  @override
  String get removeTelegramBackup => 'លុបការបម្រុងទុកតាមតេឡេក្រាម';

  @override
  String get otpSmsWarningTelegram =>
      'លេខកូដ OTP នឹងត្រូវផ្ញើតាម SMS តែប៉ុណ្ណោះ បន្ទាប់ពីអ្នកលុបការបម្រុងទុកតាមតេឡេក្រាម។';

  @override
  String get remove => 'លុប';

  @override
  String get submit => 'បញ្ជូន';

  @override
  String get nameAddressLabel => 'ឈ្មោះអាសយដ្ឋាន';

  @override
  String get nameAddressHint => 'សូមវាយបញ្ចូលឈ្មោះអាសយដ្ឋានរបស់អ្នក';

  @override
  String get addAddress => 'បន្ថែមអាសយដ្ឋាន';

  @override
  String get editAddress => 'កែប្រែអាសយដ្ឋាន';

  @override
  String get searchHere => 'ស្វែងរកទីនេះ';
}
