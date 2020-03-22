import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:transport_control/pages/map/map_bloc.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage>
    with AutomaticKeepAliveClientMixin<MapPage> {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<MapBloc, MapState>(
      builder: (context, state) {
        return GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: CameraPosition(
            target: LatLng(52.237049, 21.017532),
            zoom: 11,
          ),
          markers: state.trackedVehicles
              .map(
                (vehicle) => Marker(
                  markerId: MarkerId(vehicle.number),
                  position: LatLng(vehicle.lat, vehicle.lon),
                  infoWindow: InfoWindow(
                    title: 'Last updated at: ${vehicle.lastUpdate}',
                  ),
                ),
              )
              .toSet(),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
