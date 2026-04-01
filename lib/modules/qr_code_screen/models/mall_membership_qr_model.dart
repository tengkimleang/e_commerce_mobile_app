class MallMembershipQrModel {
  final String username;
  final String tierLevel;
  final String membershipId;
  final String membershipType;
  final int points;
  final String qrPayload;
  final DateTime? expiresAt;
  final bool isFallback;
  final String? statusMessage;

  const MallMembershipQrModel({
    required this.username,
    required this.tierLevel,
    required this.membershipId,
    required this.membershipType,
    required this.points,
    required this.qrPayload,
    this.expiresAt,
    this.isFallback = false,
    this.statusMessage,
  });

  static const fallback = MallMembershipQrModel(
    username: 'Jame',
    tierLevel: 'LifeStyle',
    membershipId: '224256797',
    membershipType: 'LifeStyle Member',
    points: 30,
    qrPayload: 'cmr://chipmong-mall/member?id=224256797',
    isFallback: true,
  );

  MallMembershipQrModel copyWith({
    String? username,
    String? tierLevel,
    String? membershipId,
    String? membershipType,
    int? points,
    String? qrPayload,
    DateTime? expiresAt,
    bool clearExpiresAt = false,
    bool? isFallback,
    String? statusMessage,
    bool clearStatusMessage = false,
  }) {
    return MallMembershipQrModel(
      username: username ?? this.username,
      tierLevel: tierLevel ?? this.tierLevel,
      membershipId: membershipId ?? this.membershipId,
      membershipType: membershipType ?? this.membershipType,
      points: points ?? this.points,
      qrPayload: qrPayload ?? this.qrPayload,
      expiresAt: clearExpiresAt ? null : (expiresAt ?? this.expiresAt),
      isFallback: isFallback ?? this.isFallback,
      statusMessage: clearStatusMessage
          ? null
          : (statusMessage ?? this.statusMessage),
    );
  }
}
