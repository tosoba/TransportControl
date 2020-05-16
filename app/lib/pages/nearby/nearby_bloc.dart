import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:transport_control/pages/nearby/nearby_event.dart';
import 'package:transport_control/pages/nearby/nearby_state.dart';

class NearbyBloc extends Bloc<NearbyEvent, NearbyState> {
  @override
  NearbyState get initialState => NearbyState.initial();

  @override
  Stream<NearbyState> mapEventToState(NearbyEvent event) async* {
    yield event.when(queryChanged: (evt) => state.copyWith(query: evt.query));
  }
}
