import 'package:e_commerce_mobile_app/modules/user_info_screen/models/user_info_model.dart';

abstract class UserInfoState {
  const UserInfoState();
}

class UserInfoInitial extends UserInfoState {
  final UserInfoModel userInfo;
  const UserInfoInitial(this.userInfo);
}

class UserInfoUpdated extends UserInfoState {
  final UserInfoModel userInfo;
  const UserInfoUpdated(this.userInfo);

  UserInfoUpdated copyWith({UserInfoModel? userInfo}) {
    return UserInfoUpdated(userInfo ?? this.userInfo);
  }
}
