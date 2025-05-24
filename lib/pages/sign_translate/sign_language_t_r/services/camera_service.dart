import 'package:camera/camera.dart';

class CameraService {
  late CameraController controller;
  bool isInitialized = false;

  /// Initializes the camera and sets up the controller.
  Future<void> initialize() async {
    // Retrieve the available cameras on the device.
    final cameras = await availableCameras();
    CameraController? cam;
    cameras.forEach((e) {
      if (e.lensDirection == CameraLensDirection.front) {
        cam = CameraController(
          e,
          ResolutionPreset.medium,
          imageFormatGroup: ImageFormatGroup.yuv420,
          enableAudio: false,
        );
      }
    });

    if (cam == null) {
      controller = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        imageFormatGroup: ImageFormatGroup.yuv420,
        enableAudio: false,
      );
    } else {
      controller = cam!;
    }
    // Choose the first available camera.

    await controller.initialize();
    isInitialized = true;
  }

  /// Starts the image stream and calls [onLatestImage] for each frame.
  void startImageStream(Function(CameraImage) onLatestImage) {
    if (isInitialized) {
      controller.startImageStream(onLatestImage);
    }
  }

  /// Stops the image stream.
  void stopImageStream() {
    if (isInitialized) {
      controller.stopImageStream();
    }
  }

  /// Disposes the camera controller.
  void dispose() {
    controller.dispose();
  }
}
