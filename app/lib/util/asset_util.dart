import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as UI;

import 'package:flutter/services.dart';

class Assets {
  static const String marker = 'assets/img/marker.png';
  static const String selectedMarker = 'assets/img/selected_marker.png';

  Assets._();
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
