import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/services/user_session.dart';
import '../../../core/theme/app_theme.dart';
import '../repositories/loyalty_repository.dart';
import '../widget/loyalty_widget/loyalty_models.dart';

class LoyaltyRewardDetailScreen extends StatefulWidget {
  const LoyaltyRewardDetailScreen({
    super.key,
    required this.product,
    required this.availablePoints,
    this.repository,
  });

  final LoyaltyProduct product;
  final int availablePoints;
  final LoyaltyRepository? repository;

  @override
  State<LoyaltyRewardDetailScreen> createState() =>
      _LoyaltyRewardDetailScreenState();
}

class _LoyaltyRewardDetailScreenState extends State<LoyaltyRewardDetailScreen> {
  int _selectedTab = 0;
  OverlayEntry? _errorBannerEntry;
  late final LoyaltyRepository _repository;
  bool _isSubmittingRedeem = false;

  static const _tabs = ['Details', 'Terms & Conditions'];
  static const _defaultPickupLocation =
      'Information Counter, Chip Mong 271 Mega Mall';

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? LoyaltyRepository();
  }

  @override
  void dispose() {
    _errorBannerEntry?.remove();
    _errorBannerEntry = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.4,
        title: const Text(
          'Reward Details',
          style: TextStyle(
            fontFamily: 'Battambang',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share action is coming soon')),
              );
            },
            icon: const Icon(Icons.ios_share_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _RewardSummaryCard(product: product),
                    const SizedBox(height: 10),
                    _buildTabs(),
                    _buildTabContent(product),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _isSubmittingRedeem
                      ? null
                      : _openRedeemConfirmationSheet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(
                      fontFamily: 'Battambang',
                      fontSize: 19,
                      fontWeight: FontWeight.w500,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  child: _isSubmittingRedeem
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Redeem'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openRedeemConfirmationSheet() async {
    final exchangeForm = await showModalBottomSheet<_ExchangeFormData>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withAlpha(130),
      builder: (sheetContext) {
        return _ExchangeDetailsFormSheet(
          product: widget.product,
          pickupLocation: _defaultPickupLocation,
        );
      },
    );

    if (!mounted || exchangeForm == null) return;
    await _submitExchange(exchangeForm);
  }

  Future<void> _submitExchange(_ExchangeFormData exchangeForm) async {
    final hasEnoughPoints = widget.availablePoints >= widget.product.points;
    if (!hasEnoughPoints) {
      _showTopErrorBanner(
        requiredPoints: widget.product.points,
        availablePoints: widget.availablePoints,
      );
      return;
    }

    final rewardId = widget.product.rewardId.trim();
    if (rewardId.isEmpty) {
      _showSubmitError(
        message: 'Reward is not available yet. Please refresh and try again.',
      );
      return;
    }

    setState(() => _isSubmittingRedeem = true);
    try {
      final exchange = await _repository.createExchange(
        product: widget.product,
        request: LoyaltyExchangeRequest(
          fulfillmentMethod: exchangeForm.fulfillmentMethod,
          pickupUserType: exchangeForm.pickupUserType,
          receiverName: exchangeForm.receiverName,
          receiverPhone: exchangeForm.receiverPhone,
          representativeName: exchangeForm.representativeName,
          representativePhone: exchangeForm.representativePhone,
          deliveryAddress: exchangeForm.deliveryAddress,
          note: exchangeForm.note,
        ),
        fallbackAvailablePoints: widget.availablePoints,
        idempotencyKey: _buildIdempotencyKey(),
      );
      if (!mounted) return;
      Navigator.of(context).pop(exchange);
    } on LoyaltyRepositoryException catch (e) {
      if (!mounted) return;
      if (e.code.trim().toUpperCase() == 'LOYALTY_POINTS_INSUFFICIENT') {
        _showTopErrorBanner(
          requiredPoints: widget.product.points,
          availablePoints: widget.availablePoints,
        );
      } else {
        _showSubmitError(message: e.message);
      }
    } catch (_) {
      if (!mounted) return;
      _showSubmitError(
        message:
            'Unable to submit exchange request right now. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmittingRedeem = false);
      }
    }
  }

  String _buildIdempotencyKey() {
    final rewardPart = widget.product.rewardId.trim().isEmpty
        ? 'reward'
        : widget.product.rewardId.trim();
    final millis = DateTime.now().millisecondsSinceEpoch;
    return 'cmr-exchange-$rewardPart-$millis';
  }

  void _showSubmitError({required String message}) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showTopErrorBanner({
    required int requiredPoints,
    required int availablePoints,
  }) {
    _errorBannerEntry?.remove();
    _errorBannerEntry = null;

    final overlay = Overlay.of(context);
    _errorBannerEntry = OverlayEntry(
      builder: (overlayContext) {
        final topInset = MediaQuery.of(overlayContext).padding.top;
        return Positioned(
          left: 12,
          right: 12,
          top: topInset + 12,
          child: _RedeemErrorBanner(
            requiredPoints: requiredPoints,
            availablePoints: availablePoints,
          ),
        );
      },
    );

    overlay.insert(_errorBannerEntry!);

    Future<void>.delayed(const Duration(seconds: 5), () {
      _errorBannerEntry?.remove();
      _errorBannerEntry = null;
    });
  }

  Widget _buildTabs() {
    return Container(
      color: Colors.white,
      child: Row(
        children: List.generate(_tabs.length, (index) {
          final isSelected = _selectedTab == index;
          return Expanded(
            child: InkWell(
              onTap: () => setState(() => _selectedTab = index),
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected ? AppColors.primary : Colors.grey[300]!,
                      width: isSelected ? 3 : 1,
                    ),
                  ),
                ),
                child: Text(
                  _tabs[index],
                  style: TextStyle(
                    fontFamily: 'Battambang',
                    fontSize: 17,
                    color: isSelected ? AppColors.primary : Colors.grey[700],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTabContent(LoyaltyProduct product) {
    final text = _selectedTab == 0
        ? (product.pointCondition.isEmpty
              ? product.title
              : product.pointCondition)
        : (product.termsAndConditions.isEmpty
              ? 'Subject to store terms and actual stock availability.'
              : product.termsAndConditions);
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Battambang',
          fontSize: 16,
          color: Colors.grey[700],
        ),
      ),
    );
  }
}

class _RewardSummaryCard extends StatelessWidget {
  const _RewardSummaryCard({required this.product});

  final LoyaltyProduct product;
  static const _imageHeight = 280.0;

  @override
  Widget build(BuildContext context) {
    final imageUrl = product.imageUrl.trim();
    final hasValidImage = _isValidNetworkUrl(imageUrl);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: hasValidImage
                ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    height: _imageHeight,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        Container(height: _imageHeight, color: Colors.grey[200]),
                    errorWidget: (context, url, error) =>
                        _buildImageFallback(),
                  )
                : _buildImageFallback(),
          ),
          const SizedBox(height: 14),
          Text(
            product.category,
            style: TextStyle(
              fontFamily: 'Battambang',
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            product.title,
            style: const TextStyle(
              fontFamily: 'Battambang',
              fontSize: 21,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8F8),
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      'Points to redeem:',
                      style: TextStyle(
                        fontFamily: 'Battambang',
                        fontSize: 18,
                        color: Colors.grey[700],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${product.points} Points',
                      style: const TextStyle(
                        fontFamily: 'Battambang',
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                CustomPaint(
                  size: const Size(double.infinity, 1),
                  painter: _DashedLinePainter(),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _MetaInfoBox(
                        label: 'Expiry Date',
                        value: product.expiryDate,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _MetaInfoBox(
                        label: 'Rewards Left',
                        value: '${product.redeemLimit}',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageFallback() {
    return Container(
      height: _imageHeight,
      color: AppColors.primary.withAlpha(15),
      child: Icon(
        Icons.image_outlined,
        size: 44,
        color: AppColors.primary.withAlpha(80),
      ),
    );
  }

  bool _isValidNetworkUrl(String value) {
    if (value.isEmpty) return false;
    final uri = Uri.tryParse(value);
    if (uri == null) return false;
    return (uri.scheme == 'http' || uri.scheme == 'https') &&
        (uri.host.isNotEmpty);
  }
}

class _MetaInfoBox extends StatelessWidget {
  const _MetaInfoBox({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEDEDED),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Battambang',
              fontSize: 15,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Battambang',
              fontSize: 20,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 7.0;
    const dashSpace = 5.0;
    final paint = Paint()
      ..color = const Color(0xFFD2D2D2)
      ..strokeWidth = 2;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dashWidth, 0), paint);
      x += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class _ExchangeFormData {
  const _ExchangeFormData({
    required this.fulfillmentMethod,
    this.pickupUserType,
    required this.receiverName,
    required this.receiverPhone,
    this.representativeName,
    this.representativePhone,
    this.deliveryAddress,
    this.note,
  });

  final LoyaltyFulfillmentMethod fulfillmentMethod;
  final LoyaltyPickupUserType? pickupUserType;
  final String receiverName;
  final String receiverPhone;
  final String? representativeName;
  final String? representativePhone;
  final String? deliveryAddress;
  final String? note;
}

class _ExchangeDetailsFormSheet extends StatefulWidget {
  const _ExchangeDetailsFormSheet({
    required this.product,
    required this.pickupLocation,
  });

  final LoyaltyProduct product;
  final String pickupLocation;

  @override
  State<_ExchangeDetailsFormSheet> createState() =>
      _ExchangeDetailsFormSheetState();
}

class _ExchangeDetailsFormSheetState extends State<_ExchangeDetailsFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _receiverNameController = TextEditingController();
  final _receiverPhoneController = TextEditingController();
  final _deliveryAddressController = TextEditingController();
  final _representativeNameController = TextEditingController();
  final _representativePhoneController = TextEditingController();
  final _noteController = TextEditingController();
  LoyaltyPickupUserType _pickupUserType = LoyaltyPickupUserType.accountOwner;
  LoyaltyFulfillmentMethod _selectedFulfillmentMethod =
      LoyaltyFulfillmentMethod.pickup;
  static final _phoneInputFormatter = FilteringTextInputFormatter.allow(
    RegExp(r'[0-9០-៩+\- ]'),
  );
  static final _phoneLengthFormatter = _PhoneDigitLengthInputFormatter(
    maxDigits: 13,
  );

  bool get _isPickup =>
      _selectedFulfillmentMethod == LoyaltyFulfillmentMethod.pickup;

  @override
  void initState() {
    super.initState();
    final sessionName = UserSession.displayName.trim();
    final sessionPhone = UserSession.phoneNumber.trim();
    if (sessionName.isNotEmpty) {
      _receiverNameController.text = sessionName;
    }
    if (sessionPhone.isNotEmpty) {
      _receiverPhoneController.text = sessionPhone;
    }
  }

  @override
  void dispose() {
    _receiverNameController.dispose();
    _receiverPhoneController.dispose();
    _deliveryAddressController.dispose();
    _representativeNameController.dispose();
    _representativePhoneController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  String? _validateRequired(String? value, String fieldName) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return '$fieldName is required';
    return null;
  }

  String _normalizePhone(String input) {
    const khmerToAscii = <String, String>{
      '០': '0',
      '១': '1',
      '២': '2',
      '៣': '3',
      '៤': '4',
      '៥': '5',
      '៦': '6',
      '៧': '7',
      '៨': '8',
      '៩': '9',
    };

    final trimmed = input.trim();
    final digitBuffer = StringBuffer();
    var hasLeadingPlus = false;

    for (var i = 0; i < trimmed.length; i++) {
      final char = trimmed[i];
      if (char == '+' && digitBuffer.isEmpty && !hasLeadingPlus) {
        hasLeadingPlus = true;
        continue;
      }
      final normalizedChar = khmerToAscii[char] ?? char;
      if (RegExp(r'[0-9]').hasMatch(normalizedChar)) {
        digitBuffer.write(normalizedChar);
      }
    }

    final digitsOnly = digitBuffer.toString();
    if (digitsOnly.isEmpty) return '';
    return hasLeadingPlus ? '+$digitsOnly' : digitsOnly;
  }

  String _toLocalPhone(String input) {
    final normalized = _normalizePhone(input);
    if (normalized.startsWith('+855') && normalized.length > 4) {
      return '0${normalized.substring(4)}';
    }
    if (normalized.startsWith('855') && normalized.length > 3) {
      return '0${normalized.substring(3)}';
    }
    return normalized;
  }

  String? _validatePhone(String? value) {
    final phone = _toLocalPhone(value ?? '');
    if (phone.isEmpty) {
      return 'Phone number is required';
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(phone)) {
      return 'Phone number must contain only digits';
    }
    if (!phone.startsWith('0')) {
      return 'Phone number must start with 0';
    }
    if (phone.length <= 9) {
      return 'Phone number must be longer than 9 digits';
    }
    if (phone.length >= 14) {
      return 'Phone number must be shorter than 14 digits';
    }
    return null;
  }

  void _changeFulfillmentMethod(LoyaltyFulfillmentMethod method) {
    if (_selectedFulfillmentMethod == method) return;
    setState(() => _selectedFulfillmentMethod = method);
    _formKey.currentState?.validate();
  }

  void _changePickupUserType(LoyaltyPickupUserType type) {
    if (_pickupUserType == type) return;
    setState(() => _pickupUserType = type);
    if (type == LoyaltyPickupUserType.accountOwner) {
      _representativeNameController.clear();
      _representativePhoneController.clear();
    }
    _formKey.currentState?.validate();
  }

  void _submitForm() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final isRepresentative =
        _pickupUserType == LoyaltyPickupUserType.representative;
    final formData = _ExchangeFormData(
      fulfillmentMethod: _selectedFulfillmentMethod,
      pickupUserType: _isPickup ? _pickupUserType : null,
      receiverName: _receiverNameController.text.trim(),
      receiverPhone: _toLocalPhone(_receiverPhoneController.text),
      representativeName: _isPickup && isRepresentative
          ? _representativeNameController.text.trim()
          : null,
      representativePhone: _isPickup && isRepresentative
          ? _toLocalPhone(_representativePhoneController.text)
          : null,
      deliveryAddress: !_isPickup
          ? _deliveryAddressController.text.trim()
          : null,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );
    Navigator.of(context).pop(formData);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        margin: const EdgeInsets.only(top: 20),
        decoration: const BoxDecoration(
          color: Color(0xFFF9F9F9),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.93,
          ),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Center(
                  child: Container(
                    width: 48,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCCCCCC),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18),
                  child: Text(
                    'Exchange Details Form',
                    style: TextStyle(
                      fontFamily: 'Battambang',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Row(
                    children: [
                      _MethodChoiceChip(
                        icon: Icons.storefront_rounded,
                        label: LoyaltyFulfillmentMethod.pickup.label,
                        selected:
                            _selectedFulfillmentMethod ==
                            LoyaltyFulfillmentMethod.pickup,
                        onTap: () => _changeFulfillmentMethod(
                          LoyaltyFulfillmentMethod.pickup,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _MethodChoiceChip(
                        icon: Icons.local_shipping_rounded,
                        label: LoyaltyFulfillmentMethod.delivery.label,
                        selected:
                            _selectedFulfillmentMethod ==
                            LoyaltyFulfillmentMethod.delivery,
                        onTap: () => _changeFulfillmentMethod(
                          LoyaltyFulfillmentMethod.delivery,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.product.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontFamily: 'Battambang',
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      widget.product.store,
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 12.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withAlpha(20),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.fromLTRB(
                                  10,
                                  8,
                                  10,
                                  8,
                                ),
                                child: Text(
                                  '${widget.product.points} Points',
                                  style: const TextStyle(
                                    fontFamily: 'Battambang',
                                    fontSize: 13,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Customer Information',
                          style: TextStyle(
                            fontFamily: 'Battambang',
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _receiverNameController,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Receiver full name',
                            hintText: 'Enter full name',
                          ),
                          validator: (value) =>
                              _validateRequired(value, 'Receiver full name'),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _receiverPhoneController,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          inputFormatters: [
                            _phoneInputFormatter,
                            _phoneLengthFormatter,
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Receiver phone number',
                            hintText: 'Enter phone number',
                          ),
                          validator: _validatePhone,
                        ),
                        const SizedBox(height: 12),
                        if (_isPickup) ...[
                          const Text(
                            'Pickup User Type',
                            style: TextStyle(
                              fontFamily: 'Battambang',
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: _PickupUserTypeCard(
                                  title:
                                      LoyaltyPickupUserType.accountOwner.label,
                                  subtitle: 'Redeem by account owner',
                                  selected:
                                      _pickupUserType ==
                                      LoyaltyPickupUserType.accountOwner,
                                  onTap: () => _changePickupUserType(
                                    LoyaltyPickupUserType.accountOwner,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _PickupUserTypeCard(
                                  title: LoyaltyPickupUserType
                                      .representative
                                      .label,
                                  subtitle: 'Redeem by representative',
                                  selected:
                                      _pickupUserType ==
                                      LoyaltyPickupUserType.representative,
                                  onTap: () => _changePickupUserType(
                                    LoyaltyPickupUserType.representative,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFE2E2E2),
                              ),
                            ),
                            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.place_rounded,
                                  color: AppColors.primary.withAlpha(170),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Pickup Location',
                                        style: TextStyle(
                                          fontFamily: 'Battambang',
                                          color: Colors.grey[700],
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        widget.pickupLocation,
                                        style: const TextStyle(
                                          fontFamily: 'Battambang',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_pickupUserType ==
                              LoyaltyPickupUserType.representative) ...[
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _representativeNameController,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'Representative full name',
                                hintText: 'Enter representative name',
                              ),
                              validator: (value) {
                                if (_pickupUserType !=
                                    LoyaltyPickupUserType.representative) {
                                  return null;
                                }
                                return _validateRequired(
                                  value,
                                  'Representative full name',
                                );
                              },
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _representativePhoneController,
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.next,
                              inputFormatters: [
                                _phoneInputFormatter,
                                _phoneLengthFormatter,
                              ],
                              decoration: const InputDecoration(
                                labelText: 'Representative phone number',
                                hintText: 'Enter representative phone',
                              ),
                              validator: (value) {
                                if (_pickupUserType !=
                                    LoyaltyPickupUserType.representative) {
                                  return null;
                                }
                                return _validatePhone(value);
                              },
                            ),
                          ],
                        ] else ...[
                          const Text(
                            'Delivery Details',
                            style: TextStyle(
                              fontFamily: 'Battambang',
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _deliveryAddressController,
                            keyboardType: TextInputType.streetAddress,
                            maxLines: 3,
                            textInputAction: TextInputAction.newline,
                            decoration: const InputDecoration(
                              labelText: 'Delivery address',
                              hintText: 'House No, Street, Khan, City',
                              alignLabelWithHint: true,
                            ),
                            validator: (value) =>
                                _validateRequired(value, 'Delivery address'),
                          ),
                        ],
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _noteController,
                          maxLines: 2,
                          textInputAction: TextInputAction.done,
                          decoration: const InputDecoration(
                            labelText: 'Note (optional)',
                            hintText:
                                'Special instruction for collection/delivery',
                            alignLabelWithHint: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
                    child: SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(
                            fontFamily: 'Battambang',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text('Confirm Redemption'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MethodChoiceChip extends StatelessWidget {
  const _MethodChoiceChip({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(99),
        child: Ink(
          decoration: BoxDecoration(
            color: selected ? AppColors.primary.withAlpha(20) : Colors.white,
            borderRadius: BorderRadius.circular(99),
            border: Border.all(
              color: selected ? AppColors.primary : const Color(0xFFDADADA),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(10, 6, 12, 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 15,
                color: selected ? AppColors.primary : Colors.grey[600],
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Battambang',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: selected ? AppColors.primary : Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PickupUserTypeCard extends StatelessWidget {
  const _PickupUserTypeCard({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.primary : const Color(0xFFE0E0E0),
              width: selected ? 1.6 : 1,
            ),
          ),
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Battambang',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: selected ? AppColors.primary : Colors.black87,
                      ),
                    ),
                  ),
                  Icon(
                    selected
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded,
                    size: 18,
                    color: selected ? AppColors.primary : Colors.grey[500],
                  ),
                ],
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontFamily: 'Battambang',
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RedeemErrorBanner extends StatelessWidget {
  const _RedeemErrorBanner({
    required this.requiredPoints,
    required this.availablePoints,
  });

  final int requiredPoints;
  final int availablePoints;

  int get _missingPoints {
    if (requiredPoints <= availablePoints) return 0;
    return requiredPoints - availablePoints;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Color(0x26000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(24),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Error',
                    style: TextStyle(
                      fontFamily: 'Battambang',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'Not enough points yet. This reward needs $requiredPoints points, but your balance is $availablePoints points. Earn $_missingPoints more points and try again.',
                    style: TextStyle(
                      fontSize: 34 / 3,
                      color: Colors.grey[700],
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhoneDigitLengthInputFormatter extends TextInputFormatter {
  const _PhoneDigitLengthInputFormatter({required this.maxDigits});

  final int maxDigits;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final plusCount = RegExp(r'\+').allMatches(newValue.text).length;
    final plusIndex = newValue.text.indexOf('+');
    if (plusCount > 1 || (plusCount == 1 && plusIndex > 0)) {
      return oldValue;
    }

    final digitCount = RegExp(r'[0-9០-៩]').allMatches(newValue.text).length;
    if (digitCount > maxDigits) {
      return oldValue;
    }

    return newValue;
  }
}
