import 'package:e_commerce_mobile_app/modules/partner_privilege_screen/models/wholesale_request.dart';

enum WholesaleHistoryStatus { initial, loading, success, failure }

class WholesaleHistoryState {
  final WholesaleHistoryStatus status;
  final List<WholesaleRequest> requests;
  final String? errorMessage;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;

  const WholesaleHistoryState({
    this.status = WholesaleHistoryStatus.initial,
    this.requests = const [],
    this.errorMessage,
    this.currentPage = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  WholesaleHistoryState copyWith({
    WholesaleHistoryStatus? status,
    List<WholesaleRequest>? requests,
    String? errorMessage,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return WholesaleHistoryState(
      status: status ?? this.status,
      requests: requests ?? this.requests,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}
