class UserInfoModel {
  final String username;
  final DateTime? dateOfBirth;
  final String languageCode;
  final String? profileImagePath;
  final String profileImageUrl;
  final String address;
  final String phoneNumber;
  final bool isVerified;
  final int points;

  const UserInfoModel({
    required this.username,
    this.dateOfBirth,
    this.languageCode = 'en',
    this.profileImagePath,
    this.profileImageUrl = '',
    this.address = '',
    this.phoneNumber = '',
    this.isVerified = false,
    this.points = 0,
  });

  factory UserInfoModel.initial() => const UserInfoModel(username: 'User');

  factory UserInfoModel.fromProfileJson(
    Map<String, dynamic> json, {
    String fallbackLanguageCode = 'en',
  }) {
    final rawDate = json['dateOfBirth']?.toString().trim() ?? '';
    final parsedDate = rawDate.isEmpty ? null : DateTime.tryParse(rawDate);

    int pointsValue = 0;
    final rawPoints = json['points'];
    if (rawPoints is int) {
      pointsValue = rawPoints;
    } else if (rawPoints is num) {
      pointsValue = rawPoints.toInt();
    } else if (rawPoints is String) {
      pointsValue = int.tryParse(rawPoints.trim()) ?? 0;
    }

    bool verified = false;
    final rawVerified = json['isVerified'];
    if (rawVerified is bool) {
      verified = rawVerified;
    } else if (rawVerified is num) {
      verified = rawVerified != 0;
    } else if (rawVerified is String) {
      final value = rawVerified.trim().toLowerCase();
      verified = value == 'true' || value == '1';
    }

    return UserInfoModel(
      username: (json['fullName'] ?? json['username'] ?? '').toString().trim(),
      dateOfBirth: parsedDate == null
          ? null
          : DateTime(parsedDate.year, parsedDate.month, parsedDate.day),
      languageCode: fallbackLanguageCode,
      profileImageUrl: (json['profileImageUrl'] ?? '').toString().trim(),
      address: (json['address'] ?? '').toString().trim(),
      phoneNumber: (json['phoneNumber'] ?? json['phone'] ?? '')
          .toString()
          .trim(),
      isVerified: verified,
      points: pointsValue,
    );
  }

  UserInfoModel copyWith({
    String? username,
    DateTime? dateOfBirth,
    bool clearDateOfBirth = false,
    String? languageCode,
    String? profileImagePath,
    bool clearProfileImagePath = false,
    String? profileImageUrl,
    bool clearProfileImageUrl = false,
    String? address,
    String? phoneNumber,
    bool? isVerified,
    int? points,
  }) {
    return UserInfoModel(
      username: username ?? this.username,
      dateOfBirth: clearDateOfBirth
          ? null
          : (dateOfBirth ?? this.dateOfBirth),
      languageCode: languageCode ?? this.languageCode,
      profileImagePath: clearProfileImagePath
          ? null
          : (profileImagePath ?? this.profileImagePath),
      profileImageUrl: clearProfileImageUrl
          ? ''
          : (profileImageUrl ?? this.profileImageUrl),
      address: address ?? this.address,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isVerified: isVerified ?? this.isVerified,
      points: points ?? this.points,
    );
  }
}
