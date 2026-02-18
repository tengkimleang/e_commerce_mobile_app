import 'package:bloc/bloc.dart';
import 'counter_event.dart';
import 'counter_state.dart';
import '../model/counter_model.dart';

class CounterBloc extends Bloc<CounterEvent, CounterState> {
  final CounterModel _model = CounterModel();

  CounterBloc() : super(const CounterInitial()) {
    on<IncrementCounterEvent>(_onIncrementCounter);
    on<ResetCounterEvent>(_onResetCounter);
  }

  Future<void> _onIncrementCounter(
    IncrementCounterEvent event,
    Emitter<CounterState> emit,
  ) async {
    _model.increment();
    emit(CounterUpdated(counter: _model.counter));
  }

  Future<void> _onResetCounter(
    ResetCounterEvent event,
    Emitter<CounterState> emit,
  ) async {
    _model.reset();
    emit(CounterUpdated(counter: _model.counter));
  }
}

