String resolveOtpRequestFailureMessage({
  required String errorCode,
  required String errorMsg,
  String deliveryMessage = '',
  String fallback = 'Unable to request OTP right now.',
}) {
  final cleanDeliveryMessage = deliveryMessage.trim();
  if (cleanDeliveryMessage.isNotEmpty) return cleanDeliveryMessage;

  final cleanErrorMsg = errorMsg.trim();
  if (cleanErrorMsg.isNotEmpty) return cleanErrorMsg;

  final normalizedCode = errorCode.trim().toUpperCase();
  final hasGatewayFailure =
      normalizedCode == 'SMS001' ||
      normalizedCode == 'DELIVERY_FAILED' ||
      normalizedCode == 'OTP_SEND_FAILED' ||
      normalizedCode == 'OTP_DELIVERY_FAILED';

  if (hasGatewayFailure) {
    return 'We could not send your OTP right now. No code was delivered by SMS or Telegram. Please try again in a moment.';
  }

  return fallback;
}
