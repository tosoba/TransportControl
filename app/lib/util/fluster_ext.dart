import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:fluster/fluster.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:transport_control/pages/map/map_marker.dart';

extension FlusterMapMarkerExt on Fluster<MapMarker> {
  Future<List<Marker>> getClusterMarkers({
    @required double currentZoom,
    @required Color clusterColor,
    @required Color clusterTextColor,
    @required int clusterWidth,
  }) {
    assert(currentZoom != null);
    assert(clusterColor != null);
    assert(clusterTextColor != null);
    assert(clusterWidth != null);

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

/// If there is a cached file and it's not old returns the cached marker image file
/// else it will download the image and save it on the temp dir and return that file.
///
/// This mechanism is possible using the [DefaultCacheManager] package and is useful
/// to improve load times on the next map loads, the first time will always take more
/// time to download the file and set the marker image.
///
/// You can resize the marker image by providing a [targetWidth].
Future<BitmapDescriptor> getMarkerImageFromUrl(
  String url, {
  int targetWidth,
}) async {
  assert(url != null);

  final File markerImageFile = await DefaultCacheManager().getSingleFile(url);

  Uint8List markerImageBytes = await markerImageFile.readAsBytes();

  if (targetWidth != null) {
    markerImageBytes = await _resizeImageBytes(
      markerImageBytes,
      targetWidth,
    );
  }

  return BitmapDescriptor.fromBytes(markerImageBytes);
}

/// Draw a [clusterColor] circle with the [clusterSize] text inside that is [width] wide.
///
/// Then it will convert the canvas to an image and generate the [BitmapDescriptor]
/// to be used on the cluster marker icons.
Future<BitmapDescriptor> _getClusterMarker(
  int clusterSize,
  Color clusterColor,
  Color textColor,
  int width,
) async {
  assert(clusterSize != null);
  assert(clusterColor != null);
  assert(width != null);

  final PictureRecorder pictureRecorder = PictureRecorder();
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
  final data = await image.toByteData(format: ImageByteFormat.png);

  return BitmapDescriptor.fromBytes(data.buffer.asUint8List());
}

/// Resizes the given [imageBytes] with the [targetWidth].
///
/// We don't want the marker image to be too big so we might need to resize the image.
Future<Uint8List> _resizeImageBytes(
  Uint8List imageBytes,
  int targetWidth,
) async {
  assert(imageBytes != null);
  assert(targetWidth != null);

  final Codec imageCodec = await instantiateImageCodec(
    imageBytes,
    targetWidth: targetWidth,
  );

  final FrameInfo frameInfo = await imageCodec.getNextFrame();

  final ByteData byteData = await frameInfo.image.toByteData(
    format: ImageByteFormat.png,
  );

  return byteData.buffer.asUint8List();
}
