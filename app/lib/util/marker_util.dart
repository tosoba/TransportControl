import 'dart:async';
import 'dart:ui' as UI;

import 'package:fluster/fluster.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:transport_control/pages/map/map_constants.dart';
import 'package:transport_control/pages/map/map_markers.dart';
import 'package:transport_control/util/asset_util.dart';

class IconifiedMarkers {
  final List<IconifiedMarker> clustered;
  final List<IconifiedMarker> nonClustered;

  IconifiedMarkers({@required this.clustered, @required this.nonClustered});
}

extension FlusterMapMarkerExt on Fluster<ClusterableMarker> {
  Future<IconifiedMarkers> iconifiedMarkers({
    @required double currentZoom,
    @required Color clusterColor,
    @required Color clusterTextColor,
  }) async {
    final markerImage = await rootBundle.loadUiImage(ImageAssets.marker);
    final clusterableMarkers = clusters(
      const [-180, -85, 180, 85],
      currentZoom.toInt(),
    );
    final clustered = <IconifiedMarker>[];
    final nonClustered = <IconifiedMarker>[];
    for (final clusterable in clusterableMarkers) {
      if (clusterable.isCluster) {
        clustered.add(
          IconifiedMarker(
            clusterable,
            childrenPositions: points(clusterable.clusterId)
                .map((marker) => LatLng(marker.latitude, marker.longitude))
                .toList(),
            icon: await _clusterMarkerBitmap(
              clusterSize: clusterable.pointsSize,
              clusterColor: clusterColor,
              textColor: clusterTextColor,
            ),
          ),
        );
      } else {
        nonClustered.add(
          IconifiedMarker(
            clusterable,
            icon: await markerBitmap(
              symbol: clusterable.symbol,
              width: MapConstants.markerWidth,
              height: MapConstants.markerHeight,
              imageAsset: markerImage,
            ),
          ),
        );
      }
    }
    return IconifiedMarkers(clustered: clustered, nonClustered: nonClustered);
  }
}

extension MapMarkerListExt on Map<String, ClusterableMarker> {
  Future<Fluster<ClusterableMarker>> fluster({
    @required int minZoom,
    @required int maxZoom,
  }) {
    return Future.value(
      Fluster<ClusterableMarker>(
        minZoom: minZoom,
        maxZoom: maxZoom,
        radius: 150,
        extent: 2048,
        nodeSize: 64,
        points: values.toList(),
        createCluster: (BaseCluster cluster, double lng, double lat) {
          return ClusterableMarker(
            id: cluster.id.toString(),
            lat: lat,
            lng: lng,
            isCluster: cluster.isCluster,
            clusterId: cluster.id,
            pointsSize: cluster.pointsSize,
            childMarkerId: cluster.childMarkerId,
            number: cluster.markerId,
            symbol: cluster.isCluster ? null : this[cluster.markerId].symbol,
          );
        },
      ),
    );
  }
}

Future<BitmapDescriptor> markerBitmap({
  @required String symbol,
  @required int width,
  @required int height,
  @required UI.Image imageAsset,
}) async {
  final pictureRecorder = UI.PictureRecorder();
  final canvas = Canvas(pictureRecorder);
  final paint = Paint();
  final textPainter = TextPainter(textDirection: TextDirection.ltr);

  canvas.drawImage(
    imageAsset,
    Offset.zero,
    paint,
  );

  textPainter.text = TextSpan(
    text: symbol,
    style: const TextStyle(
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

Future<BitmapDescriptor> _clusterMarkerBitmap({
  @required int clusterSize,
  @required Color clusterColor,
  @required Color textColor,
}) async {
  final pictureRecorder = UI.PictureRecorder();
  final canvas = Canvas(pictureRecorder);
  final paint = Paint()..color = clusterColor;
  final textPainter = TextPainter(textDirection: TextDirection.ltr);
  final radius = _clusterRadius(clusterSize);

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
