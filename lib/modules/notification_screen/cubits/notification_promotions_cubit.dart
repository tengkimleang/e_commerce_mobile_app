import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_commerce_mobile_app/modules/notification_screen/cubits/notification_promotions_state.dart';
import 'package:e_commerce_mobile_app/modules/notification_screen/repositories/notification_promotions_repository.dart';

class NotificationPromotionsCubit extends Cubit<NotificationPromotionsState> {
  NotificationPromotionsCubit({
    required NotificationPromotionsRepository repository,
  }) : _repository = repository,
       super(const NotificationPromotionsState());

  final NotificationPromotionsRepository _repository;

  Future<void> loadPromotions({String shopId = ''}) async {
    emit(state.copyWith(status: NotificationPromotionsStatus.loading));
    try {
      final items = await _repository.fetchPromotions(shopId: shopId);
      emit(
        NotificationPromotionsState(
          status: NotificationPromotionsStatus.success,
          items: items,
        ),
      );
    } catch (e) {
      emit(
        NotificationPromotionsState(
          status: NotificationPromotionsStatus.failure,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }
}
