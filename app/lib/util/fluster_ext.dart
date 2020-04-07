import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as UI;

import 'package:fluster/fluster.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:transport_control/pages/map/map_constants.dart';
import 'package:transport_control/pages/map/map_marker.dart';

extension FlusterMapMarkerExt on Fluster<MapMarker> {
  Future<List<MapMarker>> getMarkers({
    @required double currentZoom,
    @required Color clusterColor,
    @required Color clusterTextColor,
  }) async {
    assert(currentZoom != null);
    assert(clusterColor != null);
    assert(clusterTextColor != null);

    final markerImage = await loadUiImageFromAsset('assets/img/marker.png');

    return Future.wait(
      clusters(
        _bbox,
        currentZoom.toInt(),
      ).map(
        (mapMarker) async {
          if (mapMarker.isCluster) {
            mapMarker.icon = await _clusterMarkerBitmap(
              mapMarker.pointsSize,
              clusterColor,
              clusterTextColor,
            );
          } else {
            final symbol = mapMarker.id.substring(
              mapMarker.id.indexOf('_') + 1,
            );
            mapMarker.icon = await markerBitmap(
              symbol: symbol,
              width: MapConstants.markerWidth,
              height: MapConstants.markerHeight,
              imageAsset: markerImage,
            );
          }
          return mapMarker;
        },
      ).toList(),
    );
  }
}

Future<Fluster<MapMarker>> flusterFromMarkers(
  List<MapMarker> markers, {
  @required int minZoom,
  @required int maxZoom,
}) async {
  assert(markers != null);
  assert(minZoom != null);
  assert(maxZoom != null);

  return Fluster<MapMarker>(
    minZoom: minZoom,
    maxZoom: maxZoom,
    radius: 150,
    extent: 2048,
    nodeSize: 64,
    points: markers,
    createCluster: (BaseCluster cluster, double lng, double lat) {
      return MapMarker(
        id: cluster.id.toString(),
        position: LatLng(lat, lng),
        isCluster: cluster.isCluster,
        clusterId: cluster.id,
        pointsSize: cluster.pointsSize,
        childMarkerId: cluster.childMarkerId,
      );
    },
  );
}

final List<double> _bbox = [-180, -85, 180, 85];

//TODO: convert to ext function
Future<UI.Image> loadUiImageFromAsset(String path) async {
  final ByteData data = await rootBundle.load(path);
  final Completer<UI.Image> completer = Completer();
  UI.decodeImageFromList(Uint8List.view(data.buffer), (UI.Image img) {
    return completer.complete(img);
  });
  return completer.future;
}

Future<BitmapDescriptor> markerBitmap({
  @required String symbol,
  @required int width,
  @required int height,
  @required UI.Image imageAsset,
}) async {
  assert(symbol != null);
  assert(width != null);
  assert(height != null);
  assert(imageAsset != null);

  final UI.PictureRecorder pictureRecorder = UI.PictureRecorder();
  final Canvas canvas = Canvas(pictureRecorder);
  final Paint paint = Paint();
  final TextPainter textPainter = TextPainter(
    textDirection: TextDirection.ltr,
  );

  canvas.drawImage(
    imageAsset,
    Offset.zero,
    paint,
  );

  textPainter.text = TextSpan(
    text: symbol,
    style: TextStyle(
      fontSize: MapConstants.markerHeight / 2,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  );

  textPainter.layout();
  textPainter.paint(
    canvas,
    Offset(
      MapConstants.markerWidth / 2 - textPainter.width / 2,
      MapConstants.markerWidth / 2 - textPainter.height / 2,
    ),
  );

  final image = await pictureRecorder.endRecording().toImage(width, height);
  final data = await image.toByteData(format: UI.ImageByteFormat.png);

  return BitmapDescriptor.fromBytes(data.buffer.asUint8List());
}

Future<BitmapDescriptor> _clusterMarkerBitmap(
  int clusterSize,
  Color clusterColor,
  Color textColor,
) async {
  assert(clusterSize != null);
  assert(clusterColor != null);

  final UI.PictureRecorder pictureRecorder = UI.PictureRecorder();
  final Canvas canvas = Canvas(pictureRecorder);
  final Paint paint = Paint()..color = clusterColor;
  final TextPainter textPainter = TextPainter(
    textDirection: TextDirection.ltr,
  );

  final double radius = _clusterRadius(clusterSize);

  canvas.drawCircle(
    Offset(radius, radius),
    radius,
    paint,
  );

  textPainter.text = TextSpan(
    text: clusterSize.toString(),
    style: TextStyle(
      fontSize: radius - 5,
      fontWeight: FontWeight.bold,
      color: textColor,
    ),
  );

  textPainter.layout();
  textPainter.paint(
    canvas,
    Offset(radius - textPainter.width / 2, radius - textPainter.height / 2),
  );

  final image = await pictureRecorder.endRecording().toImage(
        radius.toInt() * 2,
        radius.toInt() * 2,
      );
  final data = await image.toByteData(format: UI.ImageByteFormat.png);

  return BitmapDescriptor.fromBytes(data.buffer.asUint8List());
}

double _clusterRadius(int pointsSize) {
  if (pointsSize < 5) {
    return 40;
  } else if (pointsSize < 10) {
    return 50;
  } else if (pointsSize < 25) {
    return 60;
  } else if (pointsSize < 50) {
    return 75;
  } else if (pointsSize < 100) {
    return 90;
  } else {
    return 120;
  }
}
