abstract class CounterState {
  const CounterState();
}

class CounterInitial extends CounterState {
  const CounterInitial();
}

class CounterUpdated extends CounterState {
  final int counter;

  const CounterUpdated({required this.counter});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CounterUpdated &&
          runtimeType == other.runtimeType &&
          counter == other.counter;

  @override
  int get hashCode => counter.hashCode;
}

