import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as UI;

import 'package:fluster/fluster.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:transport_control/pages/map/map_marker.dart';

extension FlusterMapMarkerExt on Fluster<MapMarker> {
  Future<List<Marker>> getClusterMarkers({
    @required double currentZoom,
    @required Color clusterColor,
    @required Color clusterTextColor,
    @required int clusterWidth,
  }) async {
    assert(currentZoom != null);
    assert(clusterColor != null);
    assert(clusterTextColor != null);
    assert(clusterWidth != null);

    final markerImage = await _loadUiImageFromAsset('assets/img/marker.png');

    return Future.wait(
      clusters(
        _bbox,
        currentZoom.toInt(),
      ).map(
        (mapMarker) async {
          if (mapMarker.isCluster) {
            mapMarker.icon = await _getClusterMarker(
              mapMarker.pointsSize,
              clusterColor,
              clusterTextColor,
              clusterWidth,
            );
          } else {
            final symbol = mapMarker.id.substring(
              mapMarker.id.indexOf('_') + 1,
            );
            mapMarker.icon = await _getMarker(
              symbol: symbol,
              width: 60,
              height: 80,
              imageAsset: markerImage,
            );
          }
          return mapMarker.toMarker();
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

Future<UI.Image> _loadUiImageFromAsset(String path) async {
  final ByteData data = await rootBundle.load(path);
  final Completer<UI.Image> completer = Completer();
  UI.decodeImageFromList(Uint8List.view(data.buffer), (UI.Image img) {
    return completer.complete(img);
  });
  return completer.future;
}

Future<BitmapDescriptor> _getMarker({
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
      fontSize: 40,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  );

  textPainter.layout();
  textPainter.paint(
    canvas,
    Offset(
      30 - textPainter.width / 2,
      30 - textPainter.height / 2,
    ),
  );

  final image = await pictureRecorder.endRecording().toImage(width, height);
  final data = await image.toByteData(format: UI.ImageByteFormat.png);

  return BitmapDescriptor.fromBytes(data.buffer.asUint8List());
}

Future<BitmapDescriptor> _getClusterMarker(
  int clusterSize,
  Color clusterColor,
  Color textColor,
  int width,
) async {
  assert(clusterSize != null);
  assert(clusterColor != null);
  assert(width != null);

  final UI.PictureRecorder pictureRecorder = UI.PictureRecorder();
  final Canvas canvas = Canvas(pictureRecorder);
  final Paint paint = Paint()..color = clusterColor;
  final TextPainter textPainter = TextPainter(
    textDirection: TextDirection.ltr,
  );

  final double radius = width / 2;

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
