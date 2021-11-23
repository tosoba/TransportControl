import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

extension BlocExt<Event, State> on Bloc<Event, State> {
  void emitAllOn<E extends Event>({
    @required Stream<State> Function(E) nextStates,
  }) {
    on<E>((event, emit) async {
      await for (final nextState in nextStates(event)) {
        emit(nextState);
      }
    });
  }
}
