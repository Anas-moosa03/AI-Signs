import 'package:flutter/services.dart';

class MediapipeService {
  static const platform = MethodChannel('mediapipe');

  Future<Map<String, dynamic>> processImage(List<int> bytes) async {
    try {
      final result = await platform.invokeMethod('processImage', {'bytes': bytes});
      return Map<String, dynamic>.from(result);
    } catch (e) {
      print('Failed to process image: $e');
      return {};
    }
  }
}
