import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:ui' as ui;

class MemoryManager {
  static final MemoryManager _instance = MemoryManager._internal();
  factory MemoryManager() => _instance;
  MemoryManager._internal();

  final Map<String, ui.Codec> _svgCache = {};

  final Map<String, Image> _imageCache = {};

  Future<void> preloadSVGAssets(List<String> assetPaths) async {
    for (final assetPath in assetPaths) {
      try {
        if (!_svgCache.containsKey(assetPath)) {
          final data = await rootBundle.load(assetPath);
          final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
          _svgCache[assetPath] = codec;
        }
      } catch (e) {
        // Silently ignore
      }
    }
  }

  Future<void> preloadImages(List<String> imagePaths) async {
    for (final imagePath in imagePaths) {
      try {
        if (!_imageCache.containsKey(imagePath)) {
          final image = Image.asset(imagePath);
          _imageCache[imagePath] = image;
        }
      } catch (e) {
        // Silently ignore
      }
    }
  }

  void clearCaches() {
    _svgCache.clear();
    _imageCache.clear();
    PaintingBinding.instance.imageCache.clear();
  }

  ui.Codec? getCachedSVG(String assetPath) {
    return _svgCache[assetPath];
  }

  Image? getCachedImage(String imagePath) {
    return _imageCache[imagePath];
  }

  Map<String, dynamic> getMemoryStats() {
    return {
      'svgCacheSize': _svgCache.length,
      'imageCacheSize': _imageCache.length,
      'totalCachedAssets': _svgCache.length + _imageCache.length,
    };
  }

  static Widget buildOptimizedWidget({
    required Widget child,
    List<Object>? keys,
  }) {
    return RepaintBoundary(
      child: child,
    );
  }

  static Widget profileWidgetBuild({
    required String widgetName,
    required Widget child,
  }) {
    return child;
  }
}

MemoryManager memoryManager = MemoryManager();

extension MemoryManagerExtension on String {
  Future<void> preloadAsset() async {
    if (endsWith('.svg')) {
      await memoryManager.preloadSVGAssets([this]);
    } else {
      await memoryManager.preloadImages([this]);
    }
  }
}
