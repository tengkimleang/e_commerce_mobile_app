abstract class UserInfoEvent {
  const UserInfoEvent();
}

class UpdateUsername extends UserInfoEvent {
  final String username;
  const UpdateUsername(this.username);
}

class UpdateDateOfBirth extends UserInfoEvent {
  final DateTime dateOfBirth;
  const UpdateDateOfBirth(this.dateOfBirth);
}

class UpdateLanguage extends UserInfoEvent {
  final String languageCode;
  const UpdateLanguage(this.languageCode);
}

class UpdateProfileImage extends UserInfoEvent {
  final String? profileImagePath;
  const UpdateProfileImage(this.profileImagePath);
}
