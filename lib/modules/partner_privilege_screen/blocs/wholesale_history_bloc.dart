import 'package:flutter_bloc/flutter_bloc.dart';

import '../repositories/privilege_partner.dart';
import 'wholesale_history_event.dart';
import 'wholesale_history_state.dart';

const _pageSize = 10;

class WholesaleHistoryBloc
    extends Bloc<WholesaleHistoryEvent, WholesaleHistoryState> {
  final PrivilegePartnerRepository _repository;

  WholesaleHistoryBloc(this._repository)
      : super(const WholesaleHistoryState()) {
    on<WholesaleHistoryFetch>(_onFetch);
    on<WholesaleHistoryLoadMore>(_onLoadMore);
  }

  /// Initial load / pull-to-refresh: reset to page 1.
  Future<void> _onFetch(
    WholesaleHistoryFetch event,
    Emitter<WholesaleHistoryState> emit,
  ) async {
    emit(state.copyWith(
      status: WholesaleHistoryStatus.loading,
      requests: const [],
      currentPage: 1,
      hasMore: true,
      isLoadingMore: false,
    ));

    final result =
        await _repository.getRequests(page: 1, pageSize: _pageSize);

    result.fold(
      (error) => emit(state.copyWith(
        status: WholesaleHistoryStatus.failure,
        errorMessage: error.message ?? 'Failed to load history',
      )),
      (requests) => emit(state.copyWith(
        status: WholesaleHistoryStatus.success,
        requests: requests,
        currentPage: 1,
        hasMore: requests.length >= _pageSize,
      )),
    );
  }

  /// Append next page — ignored if already loading or no more data.
  Future<void> _onLoadMore(
    WholesaleHistoryLoadMore event,
    Emitter<WholesaleHistoryState> emit,
  ) async {
    if (state.isLoadingMore || !state.hasMore) return;

    emit(state.copyWith(isLoadingMore: true));

    final nextPage = state.currentPage + 1;
    final result = await _repository.getRequests(
      page: nextPage,
      pageSize: _pageSize,
    );

    result.fold(
      (error) => emit(state.copyWith(
        isLoadingMore: false,
        errorMessage: error.message ?? 'Failed to load more',
      )),
      (newItems) => emit(state.copyWith(
        isLoadingMore: false,
        requests: [...state.requests, ...newItems],
        currentPage: nextPage,
        hasMore: newItems.length >= _pageSize,
      )),
    );
  }
}
