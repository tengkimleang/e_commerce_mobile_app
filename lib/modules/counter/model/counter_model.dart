class CounterModel {
  int _counter = 0;
  int get counter => _counter;
  void increment() => _counter += 2;
  void reset() => _counter = 0;
}
