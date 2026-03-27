class UserInfoModel {
  final String username;
  final DateTime? dateOfBirth;
  final String languageCode;
  final String? profileImagePath;

  const UserInfoModel({
    required this.username,
    this.dateOfBirth,
    this.languageCode = 'en',
    this.profileImagePath,
  });

  factory UserInfoModel.initial() => const UserInfoModel(username: 'User');

  UserInfoModel copyWith({
    String? username,
    DateTime? dateOfBirth,
    String? languageCode,
    String? profileImagePath,
  }) {
    return UserInfoModel(
      username: username ?? this.username,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      languageCode: languageCode ?? this.languageCode,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }
}
