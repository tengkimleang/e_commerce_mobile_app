import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_commerce_mobile_app/modules/qr_code_screen/models/mall_membership_qr_model.dart';
import 'package:e_commerce_mobile_app/modules/qr_code_screen/repositories/mall_membership_qr_repository.dart';

import 'chipmong_mall_event.dart';
import 'chipmong_mall_state.dart';
import '../models/chipmong_mall_model.dart';

class ChipmongMallBloc extends Bloc<ChipmongMallEvent, ChipmongMallState> {
  ChipmongMallBloc({MallMembershipQrRepository? membershipRepository})
    : _membershipRepository =
          membershipRepository ?? MallMembershipQrRepository(),
      super(const ChipmongMallState.initial()) {
    on<ChipmongMallStarted>(_onStarted);
    on<ChipmongMallTabChanged>(_onTabChanged);
    on<ChipmongMallBottomNavChanged>(_onBottomNavChanged);
    on<ChipmongMallLoyaltyInfoUpdated>(_onLoyaltyInfoUpdated);
    on<ChipmongMallReturnedFromLoyalty>(_onReturnedFromLoyalty);
  }

  final MallMembershipQrRepository _membershipRepository;

  Future<void> _onStarted(
    ChipmongMallStarted event,
    Emitter<ChipmongMallState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    final fallbackMembership = _membershipRepository.buildLocalFallback();

    emit(
      state.copyWith(
        isLoading: false,
        promotions: chipmongMallPromotions,
        programs: chipmongMallPrograms,
        news: chipmongMallNews,
        bannerImages: chipmongMallBannerImages,
        loyaltyInfo: _toLoyaltyInfo(
          fallbackMembership,
          current: state.loyaltyInfo,
        ),
        errorMessage: fallbackMembership.statusMessage,
      ),
    );

    try {
      final remoteMembership = await _membershipRepository.loadMembershipQr();
      emit(
        state.copyWith(
          loyaltyInfo: _toLoyaltyInfo(
            remoteMembership,
            current: state.loyaltyInfo,
          ),
          errorMessage: remoteMembership.statusMessage,
        ),
      );
    } catch (_) {
      // Fallback loyalty info already emitted above.
    }
  }

  void _onTabChanged(
    ChipmongMallTabChanged event,
    Emitter<ChipmongMallState> emit,
  ) {
    emit(state.copyWith(selectedTabIndex: event.tabIndex));
  }

  void _onBottomNavChanged(
    ChipmongMallBottomNavChanged event,
    Emitter<ChipmongMallState> emit,
  ) {
    emit(state.copyWith(bottomNavIndex: event.index));
  }

  void _onLoyaltyInfoUpdated(
    ChipmongMallLoyaltyInfoUpdated event,
    Emitter<ChipmongMallState> emit,
  ) {
    emit(state.copyWith(loyaltyInfo: event.loyaltyInfo));
  }

  void _onReturnedFromLoyalty(
    ChipmongMallReturnedFromLoyalty event,
    Emitter<ChipmongMallState> emit,
  ) {
    // Single atomic emit — no intermediate Home-tab flash.
    emit(
      state.copyWith(
        loyaltyInfo: event.loyaltyInfo,
        bottomNavIndex: event.targetBottomNavIndex,
      ),
    );
  }

  ChipmongMallLoyaltyInfo _toLoyaltyInfo(
    MallMembershipQrModel membership, {
    required ChipmongMallLoyaltyInfo current,
  }) {
    final resolvedUsername = membership.username.trim();
    final resolvedMemberId = membership.membershipId.trim();
    final resolvedTier = membership.tierLevel.trim();
    final resolvedExpiry = membership.expiresAt == null
        ? current.expiryDate
        : _formatDate(membership.expiresAt!);

    return ChipmongMallLoyaltyInfo(
      username: resolvedUsername.isEmpty ? current.username : resolvedUsername,
      memberId: resolvedMemberId.isEmpty ? current.memberId : resolvedMemberId,
      tier: resolvedTier.isEmpty ? current.tier : resolvedTier.toUpperCase(),
      points: membership.points,
      expiryDate: resolvedExpiry,
    );
  }

  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
