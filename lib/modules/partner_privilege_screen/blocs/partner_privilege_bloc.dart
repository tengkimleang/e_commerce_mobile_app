import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/partner_privilege_data.dart';
import 'partner_privilege_event.dart';
import 'partner_privilege_state.dart';

class PartnerPrivilegeBloc
    extends Bloc<PartnerPrivilegeEvent, PartnerPrivilegeState> {
  PartnerPrivilegeBloc() : super(const PartnerPrivilegeState.initial()) {
    on<PartnerPrivilegeStarted>(_onStarted);
    on<PartnerPageChanged>(_onPageChanged);
  }

  void _onStarted(
    PartnerPrivilegeStarted event,
    Emitter<PartnerPrivilegeState> emit,
  ) {
    emit(
      state.copyWith(
        partnerImages: partnerPrivilegeImages,
        currentIndex: 0,
        isLoading: false,
        errorMessage: null,
      ),
    );
  }

  void _onPageChanged(
    PartnerPageChanged event,
    Emitter<PartnerPrivilegeState> emit,
  ) {
    if (event.index < 0 || event.index >= state.partnerImages.length) {
      return;
    }

    emit(state.copyWith(currentIndex: event.index));
  }
}
