import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as UI;

import 'package:flutter/services.dart';

class ImageAssets {
  static const marker = 'assets/img/marker.png';
  static const selectedMarker = 'assets/img/selected_marker.png';

  ImageAssets._();
}

class JsonAssets {
  static const lines = 'assets/json/lines.json';
  static const darkMapStyle = 'assets/json/dark_map_style.json';

  JsonAssets._();
}

extension AssetBundleExt on AssetBundle {
  Future<UI.Image> loadUiImage(String path) async {
    final data = await load(path);
    final completer = Completer<UI.Image>();
    UI.decodeImageFromList(Uint8List.view(data.buffer), (UI.Image img) {
      return completer.complete(img);
    });
    return completer.future;
  }
}
