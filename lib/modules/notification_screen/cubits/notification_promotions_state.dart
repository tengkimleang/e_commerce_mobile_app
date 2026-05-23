import 'package:equatable/equatable.dart';
import 'package:e_commerce_mobile_app/modules/notification_screen/models/notification_promotion_entry.dart';

enum NotificationPromotionsStatus { initial, loading, success, failure }

class NotificationPromotionsState extends Equatable {
  const NotificationPromotionsState({
    this.status = NotificationPromotionsStatus.initial,
    this.items = const [],
    this.errorMessage = '',
  });

  final NotificationPromotionsStatus status;
  final List<NotificationPromotionEntry> items;
  final String errorMessage;

  bool get isLoading => status == NotificationPromotionsStatus.loading;
  bool get isSuccess => status == NotificationPromotionsStatus.success;
  bool get isFailure => status == NotificationPromotionsStatus.failure;

  NotificationPromotionsState copyWith({
    NotificationPromotionsStatus? status,
    List<NotificationPromotionEntry>? items,
    String? errorMessage,
  }) {
    return NotificationPromotionsState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, items, errorMessage];
}
