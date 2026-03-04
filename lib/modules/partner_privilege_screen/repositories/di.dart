import 'package:e_commerce_mobile_app/core/common/di.dart';
import 'package:e_commerce_mobile_app/modules/partner_privilege_screen/repositories/privilege_partner.dart';

Future<void> registerPartnerPrivilegeModuleDi() async {
  di.registerFactory(() => PrivilegePartnerRepository());
}
