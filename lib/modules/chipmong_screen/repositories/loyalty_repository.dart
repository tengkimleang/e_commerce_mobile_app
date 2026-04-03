import 'package:e_commerce_mobile_app/core/services/auth_service.dart';
import 'package:e_commerce_mobile_app/core/services/user_session.dart';
import 'package:e_commerce_mobile_app/modules/chipmong_screen/widget/loyalty_widget/loyalty_models.dart';

class LoyaltyRepositoryException implements Exception {
  final String code;
  final String message;

  const LoyaltyRepositoryException({required this.code, required this.message});

  @override
  String toString() => message;
}

class LoyaltyHistoryEntry {
  final String title;
  final String statusLabel;
  final int pointsDelta;
  final DateTime occurredAt;
  final String categoryLabel;
  final String? exchangeId;

  const LoyaltyHistoryEntry({
    required this.title,
    required this.statusLabel,
    required this.pointsDelta,
    required this.occurredAt,
    required this.categoryLabel,
    this.exchangeId,
  });
}

class LoyaltyExpiryEntry {
  final String title;
  final String statusLabel;
  final int pointsDelta;
  final DateTime? expiryDate;
  final String categoryLabel;

  const LoyaltyExpiryEntry({
    required this.title,
    required this.statusLabel,
    required this.pointsDelta,
    required this.expiryDate,
    required this.categoryLabel,
  });
}

class LoyaltyRepository {
  LoyaltyRepository({AuthService? authService})
    : _authService = authService ?? AuthService();

  final AuthService _authService;

  static const _fallbackPickupLocation =
      'Information Counter, ផ្សារទំនើប Chip Mong 271 Mega Mall';

  Future<List<LoyaltyProduct>> fetchRewards({
    String? category,
    String? sort,
    int? page,
    int? pageSize,
  }) async {
    final response = await _authService.getLoyaltyRewards(
      category: category,
      sort: sort,
      page: page,
      pageSize: pageSize,
    );
    final data = _requireData(
      response,
      defaultMessage: 'Failed to load rewards',
    );
    final items = _extractItems(data);
    return items.map((item) => _parseReward(_toMap(item))).toList();
  }

  Future<LoyaltyProduct> fetchRewardDetail({required String rewardId}) async {
    final response = await _authService.getLoyaltyRewardDetail(
      rewardId: rewardId,
    );
    final data = _requireData(
      response,
      defaultMessage: 'Failed to load reward details',
    );
    return _parseReward(data);
  }

  Future<LoyaltyItemExchange> createExchange({
    required LoyaltyProduct product,
    required LoyaltyExchangeRequest request,
    required int fallbackAvailablePoints,
    String? idempotencyKey,
  }) async {
    final rewardId = product.rewardId.trim();
    if (rewardId.isEmpty) {
      throw const LoyaltyRepositoryException(
        code: 'LOYALTY_REWARD_NOT_FOUND',
        message: 'Reward ID is missing. Please refresh and try again.',
      );
    }

    final payload = <String, dynamic>{
      'rewardId': rewardId,
      'fulfillmentMethod': _toFulfillmentCode(request.fulfillmentMethod),
      'pickupUserType': _toPickupUserTypeCode(
        request.pickupUserType ?? LoyaltyPickupUserType.accountOwner,
      ),
      'receiverName': request.receiverName.trim(),
      'receiverPhone': request.receiverPhone.trim(),
    };

    final note = _emptyToNull(request.note);
    if (note != null) {
      payload['note'] = note;
    }

    if (request.fulfillmentMethod == LoyaltyFulfillmentMethod.pickup) {
      final pickupUserType =
          request.pickupUserType ?? LoyaltyPickupUserType.accountOwner;
      if (pickupUserType == LoyaltyPickupUserType.representative) {
        final representativeName = _emptyToNull(request.representativeName);
        final representativePhone = _emptyToNull(request.representativePhone);
        if (representativeName != null) {
          payload['representativeName'] = representativeName;
        }
        if (representativePhone != null) {
          payload['representativePhone'] = representativePhone;
        }
      }
    } else {
      final deliveryAddress = _emptyToNull(request.deliveryAddress);
      if (deliveryAddress != null) {
        payload['deliveryAddress'] = deliveryAddress;
      }
    }

    final response = await _authService.createLoyaltyExchange(
      payload: payload,
      idempotencyKey: idempotencyKey,
    );
    final data = _requireData(
      response,
      defaultMessage: 'Unable to submit exchange request.',
    );

    return _parseExchange(
      data: data,
      fallbackProduct: product,
      fallbackRemainingPoints: fallbackAvailablePoints - product.points,
      fallbackFulfillmentMethod: request.fulfillmentMethod,
      fallbackPickupUserType: request.pickupUserType,
      fallbackReceiverName: request.receiverName,
      fallbackReceiverPhone: request.receiverPhone,
      fallbackRepresentativeName: request.representativeName,
      fallbackRepresentativePhone: request.representativePhone,
      fallbackDeliveryAddress: request.deliveryAddress,
      fallbackNote: request.note,
    );
  }

  Future<List<LoyaltyHistoryEntry>> fetchPointsHistory({
    int? page,
    int? pageSize,
  }) async {
    final response = await _authService.getLoyaltyExchanges(
      page: page,
      pageSize: pageSize,
    );
    final data = _requireData(
      response,
      defaultMessage: 'Failed to load loyalty history.',
    );
    final items = _extractItems(data);
    return items
        .map((item) => _parseExchangeListHistoryEntry(_toMap(item)))
        .toList();
  }

  Future<List<LoyaltyExpiryEntry>> fetchPointsExpiry({String? category}) async {
    final response = await _authService.getLoyaltyPointsExpiry(
      category: category,
    );
    final data = _requireData(
      response,
      defaultMessage: 'Failed to load loyalty expiry information.',
    );
    final items = _extractItems(data);
    return items.map((item) => _parseExpiryEntry(_toMap(item))).toList();
  }

  Future<int> fetchCurrentPoints() async {
    try {
      final mallQrResponse = await _authService.getMallMembershipQrProfile();
      final mallQrData = _requireData(
        mallQrResponse,
        defaultMessage: 'Failed to load current loyalty points.',
      );
      final points = _readInt([
        mallQrData['points'],
        mallQrData['balancePoints'],
        mallQrData['loyaltyPoints'],
      ], fallback: -1);
      if (points >= 0) return points;
    } catch (_) {
      // Fallback to /user/me below.
    }

    final profileResponse = await _authService.getUserProfile();
    final profileData = _requireData(
      profileResponse,
      defaultMessage: 'Failed to load current loyalty points.',
    );
    final points = _readInt([
      profileData['points'],
      profileData['balancePoints'],
      profileData['loyaltyPoints'],
    ], fallback: 0);
    return points < 0 ? 0 : points;
  }

  Future<LoyaltyItemExchange> fetchExchangeDetail({
    required String exchangeId,
    LoyaltyProduct? fallbackProduct,
    int fallbackRemainingPoints = 0,
  }) async {
    final response = await _authService.getLoyaltyExchangeDetail(
      exchangeId: exchangeId,
    );
    final data = _requireData(
      response,
      defaultMessage: 'Failed to load exchange details.',
    );

    return _parseExchange(
      data: data,
      fallbackProduct: fallbackProduct ?? _fallbackProduct(),
      fallbackRemainingPoints: fallbackRemainingPoints,
    );
  }

  LoyaltyProduct _parseReward(Map<String, dynamic> map) {
    final rewardId = _firstNonEmpty([
      map['rewardId'],
      map['id'],
      map['rewardID'],
    ]);

    final rawCategory = _firstNonEmpty([map['category'], map['categoryCode']]);
    final categoryLabel = _firstNonEmpty([
      map['categoryLabel'],
      _rewardCategoryLabel(rawCategory),
      'ប័ណ្ណទិញទំនិញ',
    ]);

    final points = _readInt([
      map['pointsRequired'],
      map['points'],
      map['requiredPoints'],
    ], fallback: 0);

    final expiry = _readDateTime([
      map['expiryDate'],
      map['expiresAt'],
      map['validUntil'],
    ]);
    final expiryLabel = expiry == null
        ? _firstNonEmpty([map['expiryDate'], map['expiresAt'], 'Dec 31, 2026'])
        : _formatDate(expiry);

    return LoyaltyProduct(
      rewardId: rewardId,
      imageUrl: _firstNonEmpty([
        map['imageUrl'],
        map['image'],
        map['photoUrl'],
      ]),
      brandName: _firstNonEmpty([map['brandName'], map['brand'], 'Chip Mong']),
      category: categoryLabel,
      title: _firstNonEmpty([map['title'], map['name'], 'Reward']),
      store: _firstNonEmpty([
        map['store'],
        map['storeName'],
        'Chip Mong 271 Mega Mall',
      ]),
      points: points < 0 ? 0 : points,
      expiryDate: expiryLabel,
      redeemLimit: _readInt([
        map['remainingQty'],
        map['redeemLimit'],
        map['remaining'],
      ], fallback: 0),
      pointCondition: _firstNonEmpty([
        map['pointCondition'],
        map['description'],
        map['title'],
      ]),
      termsAndConditions: _firstNonEmpty([
        map['termsAndConditions'],
        map['terms'],
      ]),
    );
  }

  LoyaltyHistoryEntry _parseExchangeListHistoryEntry(Map<String, dynamic> map) {
    final rewardMap = _toMap(map['reward']);
    final rewardTitle = _firstNonEmpty([
      rewardMap['title'],
      rewardMap['name'],
      rewardMap['rewardName'],
    ]);
    final directTitle = _firstNonEmpty([map['title'], map['description']]);
    final occurredAt = _readDateTime([
      map['occurredAt'],
      map['exchangedAt'],
      map['createdAt'],
    ]);
    final pointsDelta = _resolveHistoryPointsDelta(map, rewardMap: rewardMap);
    final exchangeId = _emptyToNull(
      _firstNonEmpty([map['exchangeId'], map['id'], map['referenceNo']]),
    );

    return LoyaltyHistoryEntry(
      title: directTitle.isNotEmpty
          ? directTitle
          : (rewardTitle.isEmpty
                ? 'ប្តូររង្វាន់'
                : 'ប្តូររង្វាន់ $rewardTitle'),
      statusLabel: _resolveStatusLabel(map),
      pointsDelta: pointsDelta,
      occurredAt: occurredAt ?? DateTime.now(),
      categoryLabel: 'ប្តូររង្វាន់',
      exchangeId: exchangeId,
    );
  }

  LoyaltyExpiryEntry _parseExpiryEntry(Map<String, dynamic> map) {
    final expiryDate = _readDateTime([
      map['expiryDate'],
      map['expiresAt'],
      map['date'],
    ]);
    final categoryCode = _firstNonEmpty([map['status'], map['category']]);

    return LoyaltyExpiryEntry(
      title: _firstNonEmpty([map['title'], map['description'], 'Loyalty']),
      statusLabel: _firstNonEmpty([
        map['statusLabelKh'],
        _expiryCategoryLabel(categoryCode),
      ]),
      pointsDelta: _readInt([map['pointsDelta'], map['points']], fallback: 0),
      expiryDate: expiryDate,
      categoryLabel: _expiryCategoryLabel(categoryCode),
    );
  }

  LoyaltyItemExchange _parseExchange({
    required Map<String, dynamic> data,
    required LoyaltyProduct fallbackProduct,
    required int fallbackRemainingPoints,
    LoyaltyFulfillmentMethod? fallbackFulfillmentMethod,
    LoyaltyPickupUserType? fallbackPickupUserType,
    String? fallbackReceiverName,
    String? fallbackReceiverPhone,
    String? fallbackRepresentativeName,
    String? fallbackRepresentativePhone,
    String? fallbackDeliveryAddress,
    String? fallbackNote,
  }) {
    final reward = _buildExchangeReward(data, fallbackProduct);
    final exchangedAt =
        _readDateTime([data['exchangedAt'], data['createdAt']]) ??
        DateTime.now();
    final collectBeforeDate =
        _readDateTime([data['collectBeforeDate'], data['collectUntil']]) ??
        exchangedAt.add(const Duration(days: 7));

    final pointsUsed = _readInt([
      data['pointsUsed'],
      data['exchangedPoints'],
      data['rewardPoints'],
    ], fallback: reward.points).abs();

    final remainingPoints = _readInt([
      data['remainingPoints'],
      data['balancePoints'],
    ], fallback: fallbackRemainingPoints);

    final fulfillmentMethod =
        _parseFulfillmentMethod(data['fulfillmentMethod']) ??
        fallbackFulfillmentMethod ??
        LoyaltyFulfillmentMethod.pickup;

    final pickupUserType =
        _parsePickupUserType(data['pickupUserType']) ?? fallbackPickupUserType;

    final receiverName = _firstNonEmpty([
      data['receiverName'],
      fallbackReceiverName,
      UserSession.displayName,
      'Member',
    ]);
    final receiverPhone = _firstNonEmpty([
      data['receiverPhone'],
      fallbackReceiverPhone,
      UserSession.phoneNumber,
      '-',
    ]);

    final status = _resolveStatusLabel(data);

    return LoyaltyItemExchange(
      product: reward,
      exchangedAt: exchangedAt,
      exchangedPoints: pointsUsed,
      remainingPoints: remainingPoints < 0 ? 0 : remainingPoints,
      referenceNo: _firstNonEmpty([
        data['referenceNo'],
        data['exchangeId'],
        '-',
      ]),
      status: status,
      fulfillmentMethod: fulfillmentMethod,
      pickupUserType: pickupUserType,
      receiverName: receiverName,
      receiverPhone: receiverPhone,
      representativeName: _emptyToNull(
        _firstNonEmpty([
          data['representativeName'],
          fallbackRepresentativeName,
        ]),
      ),
      representativePhone: _emptyToNull(
        _firstNonEmpty([
          data['representativePhone'],
          fallbackRepresentativePhone,
        ]),
      ),
      pickupLocation: _firstNonEmpty([
        data['pickupLocation'],
        _fallbackPickupLocation,
      ]),
      deliveryAddress: _emptyToNull(
        _firstNonEmpty([data['deliveryAddress'], fallbackDeliveryAddress]),
      ),
      exchangeNote: _emptyToNull(_firstNonEmpty([data['note'], fallbackNote])),
      collectBeforeDate: collectBeforeDate,
    );
  }

  LoyaltyProduct _buildExchangeReward(
    Map<String, dynamic> data,
    LoyaltyProduct fallbackProduct,
  ) {
    final rewardMap = _toMap(data['reward']);
    if (rewardMap.isNotEmpty) {
      final parsed = _parseReward(rewardMap);
      return fallbackProduct.copyWith(
        rewardId: parsed.rewardId.isEmpty
            ? fallbackProduct.rewardId
            : parsed.rewardId,
        imageUrl: parsed.imageUrl.isEmpty
            ? fallbackProduct.imageUrl
            : parsed.imageUrl,
        brandName: parsed.brandName.isEmpty
            ? fallbackProduct.brandName
            : parsed.brandName,
        category: parsed.category.isEmpty
            ? fallbackProduct.category
            : parsed.category,
        title: parsed.title.isEmpty ? fallbackProduct.title : parsed.title,
        store: parsed.store.isEmpty ? fallbackProduct.store : parsed.store,
        points: parsed.points <= 0 ? fallbackProduct.points : parsed.points,
        expiryDate: parsed.expiryDate,
        redeemLimit: parsed.redeemLimit,
        pointCondition: parsed.pointCondition,
        termsAndConditions: parsed.termsAndConditions,
      );
    }

    return fallbackProduct;
  }

  Map<String, dynamic> _requireData(
    Map<String, dynamic> payload, {
    required String defaultMessage,
  }) {
    final errorCode = _firstNonEmpty([
      payload['errorCode'],
      payload['ErrorCode'],
    ]);
    final errorMsg = _firstNonEmpty([
      payload['errorMsg'],
      payload['ErrorMsg'],
      payload['message'],
    ]);
    final success = _readBool([payload['success'], payload['Success']]);

    if (errorCode.isNotEmpty || !success) {
      throw LoyaltyRepositoryException(
        code: errorCode.isEmpty ? 'UNKNOWN' : errorCode,
        message: errorMsg.isEmpty ? defaultMessage : errorMsg,
      );
    }

    final rawData = payload['data'];
    if (rawData is List) {
      return {'items': rawData};
    }

    final dataMap = _toMap(rawData);
    if (dataMap.isNotEmpty) {
      return dataMap;
    }

    // Some backends may return items at the root level.
    return payload;
  }

  List<dynamic> _extractItems(Map<String, dynamic> data) {
    final direct = data['items'];
    if (direct is List) return direct;
    final upper = data['Items'];
    if (upper is List) return upper;
    final transactions = data['transactions'];
    if (transactions is List) return transactions;
    final history = data['history'];
    if (history is List) return history;
    final records = data['records'];
    if (records is List) return records;
    final results = data['results'];
    if (results is List) return results;
    final rows = data['rows'];
    if (rows is List) return rows;
    final rewards = data['rewards'];
    if (rewards is List) return rewards;
    final nestedData = data['data'];
    if (nestedData is List) return nestedData;
    if (nestedData is Map) {
      final nestedItems = _extractItems(_toMap(nestedData));
      if (nestedItems.isNotEmpty) return nestedItems;
    }
    final singleRewardId = _firstNonEmpty([
      data['rewardId'],
      data['id'],
      data['rewardID'],
    ]);
    if (singleRewardId.isNotEmpty) {
      return [data];
    }
    return const [];
  }

  LoyaltyFulfillmentMethod? _parseFulfillmentMethod(dynamic value) {
    final normalized = _firstNonEmpty([value]).toUpperCase();
    switch (normalized) {
      case 'DELIVERY':
        return LoyaltyFulfillmentMethod.delivery;
      case 'PICKUP':
      case 'PICK_UP':
        return LoyaltyFulfillmentMethod.pickup;
      default:
        return null;
    }
  }

  LoyaltyPickupUserType? _parsePickupUserType(dynamic value) {
    final normalized = _firstNonEmpty([value]).toUpperCase();
    switch (normalized) {
      case 'ACCOUNT_OWNER':
      case 'OWNER':
        return LoyaltyPickupUserType.accountOwner;
      case 'REPRESENTATIVE':
      case 'PROXY':
        return LoyaltyPickupUserType.representative;
      default:
        return null;
    }
  }

  String _toFulfillmentCode(LoyaltyFulfillmentMethod method) {
    return switch (method) {
      LoyaltyFulfillmentMethod.delivery => 'DELIVERY',
      LoyaltyFulfillmentMethod.pickup => 'PICKUP',
    };
  }

  String _toPickupUserTypeCode(LoyaltyPickupUserType method) {
    return switch (method) {
      LoyaltyPickupUserType.accountOwner => 'ACCOUNT_OWNER',
      LoyaltyPickupUserType.representative => 'REPRESENTATIVE',
    };
  }

  String _resolveStatusLabel(Map<String, dynamic> map) {
    final direct = _firstNonEmpty([
      map['statusLabelKh'],
      map['statusKh'],
      map['statusLabel'],
    ]);
    if (direct.isNotEmpty) return direct;

    final statusCode = _firstNonEmpty([map['status']]).toUpperCase();
    return switch (statusCode) {
      'PENDING_REVIEW' => 'កំពុងពិនិត្យ',
      'APPROVED' || 'COMPLETED' || 'SUCCESS' => 'សម្រេចជោគជ័យ',
      'REJECTED' => 'បដិសេធ',
      'CANCELLED' => 'បោះបង់',
      _ => statusCode.isEmpty ? 'កំពុងពិនិត្យ' : statusCode,
    };
  }

  String _rewardCategoryLabel(String code) {
    final normalized = code.trim().toUpperCase();
    return switch (normalized) {
      'VOUCHER' || 'COUPON' => 'ប័ណ្ណបញ្ចូល',
      'PRODUCT' => 'ផលិតផល',
      'CASH_VOUCHER' || 'CASH' => 'ប័ណ្ណទឹកប្រាក់',
      'GAME' => 'ហ្គេម',
      'ELECTRONICS' => 'គ្រឿងអេឡិចត្រូនិក',
      'EVENT_TICKET' || 'TICKET' => 'សំបុត្រកម្មវិធី',
      _ => '',
    };
  }

  int _resolveHistoryPointsDelta(
    Map<String, dynamic> map, {
    Map<String, dynamic>? rewardMap,
  }) {
    var pointsDelta = _readInt([
      map['pointsDelta'],
      map['points'],
      map['amount'],
    ], fallback: 0);
    if (pointsDelta == 0) {
      final pointsUsed = _readInt([
        map['pointsUsed'],
        map['exchangedPoints'],
        rewardMap?['pointsRequired'],
        rewardMap?['points'],
      ], fallback: 0);
      if (pointsUsed > 0) {
        pointsDelta = -pointsUsed;
      }
    }
    final categoryCode = _firstNonEmpty([
      map['category'],
      map['type'],
      map['categoryCode'],
    ]).toUpperCase();
    final hasExchangePointer = _firstNonEmpty([
      map['exchangeId'],
      map['exchangeID'],
      map['referenceNo'],
      _toMap(map['exchange'])['exchangeId'],
      _toMap(map['exchange'])['id'],
    ]).isNotEmpty;
    if ((categoryCode == 'REDEEMED' || hasExchangePointer) && pointsDelta > 0) {
      return -pointsDelta;
    }
    return pointsDelta;
  }

  String _expiryCategoryLabel(String code) {
    final normalized = code.trim().toUpperCase();
    return switch (normalized) {
      'NOT_EXPIRED' => 'មិនផុតកំណត់',
      'NEAR_EXPIRY' => 'ជិតផុតកំណត់',
      'EXPIRED' => 'ផុតកំណត់',
      _ => 'ទាំងអស់',
    };
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final day = date.day.toString().padLeft(2, '0');
    return '${months[date.month - 1]} $day, ${date.year}';
  }

  Map<String, dynamic> _toMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) {
      return data.map((key, value) => MapEntry(key.toString(), value));
    }
    return {};
  }

  String _firstNonEmpty(Iterable<dynamic> values) {
    for (final value in values) {
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty) return text;
    }
    return '';
  }

  int _readInt(Iterable<dynamic> values, {required int fallback}) {
    for (final value in values) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      final text = value?.toString().trim() ?? '';
      if (text.isEmpty) continue;
      final parsed = int.tryParse(text);
      if (parsed != null) return parsed;
    }
    return fallback;
  }

  bool _readBool(Iterable<dynamic> values) {
    for (final value in values) {
      if (value is bool) return value;
      if (value is num) return value != 0;
      final text = value?.toString().trim().toLowerCase() ?? '';
      if (text == 'true' || text == '1') return true;
      if (text == 'false' || text == '0') return false;
    }
    return false;
  }

  DateTime? _readDateTime(Iterable<dynamic> values) {
    for (final value in values) {
      final text = value?.toString().trim() ?? '';
      if (text.isEmpty) continue;
      final parsed = DateTime.tryParse(text);
      if (parsed != null) return parsed.toLocal();
    }
    return null;
  }

  String? _emptyToNull(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }

  LoyaltyProduct _fallbackProduct() {
    return const LoyaltyProduct(
      rewardId: '',
      imageUrl: '',
      brandName: 'Chip Mong Mall',
      category: 'ប័ណ្ណទិញទំនិញ',
      title: 'Reward',
      store: 'Chip Mong 271 Mega Mall',
      points: 0,
    );
  }
}
