abstract class PriceCheckingEvent {
  const PriceCheckingEvent();
}

class SubmitCode extends PriceCheckingEvent {
  final String code;
  const SubmitCode(this.code);
}

class ClearResult extends PriceCheckingEvent {
  const ClearResult();
}
