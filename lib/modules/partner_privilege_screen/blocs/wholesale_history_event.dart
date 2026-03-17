abstract class WholesaleHistoryEvent {
  const WholesaleHistoryEvent();
}

/// Initial load / pull-to-refresh — resets to page 1.
class WholesaleHistoryFetch extends WholesaleHistoryEvent {
  const WholesaleHistoryFetch();
}

/// Append next page of results.
class WholesaleHistoryLoadMore extends WholesaleHistoryEvent {
  const WholesaleHistoryLoadMore();
}
