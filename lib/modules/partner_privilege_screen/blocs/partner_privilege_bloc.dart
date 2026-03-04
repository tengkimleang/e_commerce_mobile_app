import 'package:flutter_bloc/flutter_bloc.dart';

import '../repositories/privilege_partner.dart';
import 'partner_privilege_event.dart';
import 'partner_privilege_state.dart';

class PartnerPrivilegeBloc
    extends Bloc<PartnerPrivilegeEvent, PartnerPrivilegeState> {
  final PrivilegePartnerRepository _repository;

  PartnerPrivilegeBloc(this._repository)
    : super(const PartnerPrivilegeState.initial()) {
    on<PartnerPrivilegeStarted>(_onStarted);
    on<PartnerPageChanged>(_onPageChanged);
  }

  Future<void> _onStarted(
    PartnerPrivilegeStarted event,
    Emitter<PartnerPrivilegeState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    final result = await _repository.getSlider();

    result.fold(
      (error) {
        emit(
          state.copyWith(
            isLoading: false,
            partnerImages: const [],
            currentIndex: 0,
            errorMessage: error.toString(),
          ),
        );
      },
      (sliders) {
        final images = sliders.map((e) => e.imageUrl).toList();

        emit(
          state.copyWith(
            isLoading: false,
            partnerImages: images,
            currentIndex: 0,
            errorMessage: null,
          ),
        );
      },
    );
  }

  void _onPageChanged(
    PartnerPageChanged event,
    Emitter<PartnerPrivilegeState> emit,
  ) {
    if (event.index < 0 || event.index >= state.partnerImages.length) return;
    emit(state.copyWith(currentIndex: event.index));
  }
}
