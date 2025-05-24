import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/camera_service.dart';
import 'dart:ui' as ui;

class DetectionScreen extends StatefulWidget {
  @override
  _DetectionScreenState createState() => _DetectionScreenState();
}

class _DetectionScreenState extends State<DetectionScreen> {
  final CameraService _cameraService = CameraService();
  // final MediapipeService _mediapipeService = MediapipeService();
  static const platform =
      MethodChannel('com.mycompany.travelapp/hand_tracking');

  ValueNotifier<Uint8List?> list = ValueNotifier(null);
  ValueNotifier<ui.Image?> list2 = ValueNotifier(null);

  int retryCount = 0;
  int maxRetries = 3;
  bool isCameraWorking = false;

  @override
  void initState() {
    super.initState();
    // _setupMethodChannel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // _initialize();
    });
    // Future.delayed(Duration(milliseconds: 500), () {
    //   setState(() {}); // Force refresh
    // });
    // initHandLandmarker();
  }

  initHandLandmarker() async {
    await platform.invokeMethod('initCamera');
  }

  closeHandLandmarker() async {
    await platform.invokeMethod('closeCamera');
  }

  @override
  void dispose() {
    // closeHandLandmarker();
    // _cameraService.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    await _cameraService.initialize();
    setState(() {});
  }

  String id = Uuid().v4();

  late final InAppWebViewController webViewController;

  @override
  Widget build(BuildContext context) {
    // if (!_cameraService.isInitialized) {
    //   return Center(child: CircularProgressIndicator());
    // }

    var height2 = MediaQuery.of(context).size.height -
        (MediaQuery.of(context).padding.top +
            MediaQuery.of(context).padding.bottom);
    var width2 = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Translations"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: InAppWebView(
          initialUrlRequest: URLRequest(
            url: WebUri.uri(Uri.parse("https://aisigns.netlify.app")),
          ),
          initialSettings: InAppWebViewSettings(
            mediaPlaybackRequiresUserGesture: false,
            allowsInlineMediaPlayback: true,
            javaScriptEnabled: true,
            useHybridComposition: true, // Android
            hardwareAcceleration: true,
            allowContentAccess: true,
            clearCache: true,
          ),
          
          onWebViewCreated: (controller) {
            webViewController = controller;
          },
          onPermissionRequest: (controller, request) async {
            final resources = <PermissionResourceType>[];
            if (request.resources.contains(PermissionResourceType.CAMERA)) {
              final cameraStatus = await Permission.camera.request();
              if (!cameraStatus.isDenied) {
                resources.add(PermissionResourceType.CAMERA);
              }
            }
            if (request.resources.contains(PermissionResourceType.MICROPHONE)) {
              final microphoneStatus = await Permission.microphone.request();
              if (!microphoneStatus.isDenied) {
                resources.add(PermissionResourceType.MICROPHONE);
              }
            }
            // only for iOS and macOS
            if (request.resources
                .contains(PermissionResourceType.CAMERA_AND_MICROPHONE)) {
              final cameraStatus = await Permission.camera.request();
              final microphoneStatus = await Permission.microphone.request();
              if (!cameraStatus.isDenied && !microphoneStatus.isDenied) {
                resources.add(PermissionResourceType.CAMERA_AND_MICROPHONE);
              }
            }

            return PermissionResponse(
                resources: resources,
                action: resources.isEmpty
                    ? PermissionResponseAction.DENY
                    : PermissionResponseAction.GRANT);
          },
        ),
      ),
    );
    // return SafeArea(
    //   child: Scaffold(
    //     appBar: AppBar(
    //       title: Text("Translation"),
    //       actions: [
    //         BackButton(),
    //       ],
    //     ),
    //     body: ClipRRect(
    //       child: AndroidView(
    //         key: ValueKey(id),
    //         viewType: 'camerax-fragment-view',
    //         layoutDirection: TextDirection.ltr,
    //         creationParams: {
    //           'width': width2.toInt(),
    //           'height': height2.toInt(),
    //           'paddingLeft': 0.toInt(), // Custom padding values
    //           'paddingTop':
    //               (kToolbarHeight * 1.42 + MediaQuery.of(context).padding.top)
    //                   .toInt(),
    //           'paddingRight': 0.toInt(),
    //           'paddingBottom': 0.toInt(),
    //         },
    //         creationParamsCodec: StandardMessageCodec(),
    //       ),
    //     ),
    //   ),
    // );

    // return PopScope(
    //   onPopInvokedWithResult: (didPop, result) {
    //     if (didPop) {
    //       // Navigator.pop(context);
    //     }
    //   },
    //   child: Scaffold(
    //     appBar: AppBar(
    //       title: Text("Translation"),
    //       actions: [BackButton()],
    //     ),
    //     body: Transform.translate(
    //       offset: Offset(50, 100),
    //       child: Center(
    //         child: Padding(
    //           padding: const EdgeInsets.all(20),
    //           child: SizedBox(
    //             height: 300,
    //             width: 300,
    //             child: ClipRRect(
    //               child: LayoutBuilder(
    //                 builder: (context, constraints) => AndroidView(
    //                   viewType: 'camerax-fragment-view',
    //                   layoutDirection: TextDirection.ltr,
    //                   creationParams: {
    //                     'width': constraints.maxWidth.toInt(),
    //                     'height': constraints.maxHeight.toInt(),
    //                   },
    //                   creationParamsCodec: StandardMessageCodec(),
    //                 ),
    //               ),
    //             ),
    //           ),
    //         ),
    //       ),
    //     ),
    //   ),
    // );
  }

  // void _setupMethodChannel() {
  //   platform.setMethodCallHandler((MethodCall call) async {
  //     if (call.method == 'onHandLandmarks') {
  //       print('Hand Landmarks: ${call.arguments}');
  //     }
  //     if (call.method == 'cameraStatus') {
  //       print('cameraStatus: ${call.arguments}');
  //       if (call.arguments is bool) {
  //         if (call.arguments) {
  //           setState(() {
  //             isCameraWorking = true;
  //           });
  //         } else {
  //           if (retryCount < maxRetries && !isCameraWorking) {
  //             Future.delayed(Duration(seconds: 1)).then((_) {
  //               setState(() {
  //                 retryCount++;
  //                 id = Uuid().v4();
  //               });
  //             });
  //           }
  //         }
  //       }
  //     }
  //   });
  // }

  // Uint8List yuv420ToRgba8888(List<Plane> planes, int width, int height) {
  //   final yPlane = planes[0].bytes;
  //   final uPlane = planes[1].bytes;
  //   final vPlane = planes[2].bytes;

  //   final int yRowStride = planes[0].bytesPerRow;
  //   final int uvRowStride = planes[1].bytesPerRow;
  //   final int uvPixelStride = planes[1].bytesPerPixel ?? 1;

  //   final Uint8List rgbaBytes = Uint8List(width * height * 4);

  //   for (int y = 0; y < height; y++) {
  //     for (int x = 0; x < width; x++) {
  //       final int yIndex = y * yRowStride + x;

  //       // Safe UV index: avoid out-of-bounds by checking row stride and pixel stride
  //       final int uvX = (x ~/ 2) * uvPixelStride;
  //       final int uvY = (y ~/ 2) * uvRowStride;
  //       final int uvIndex = uvY + uvX;

  //       if (uvIndex >= uPlane.length || uvIndex >= vPlane.length) {
  //         continue; // Skip out-of-bounds UV data
  //       }

  //       final int yValue = yPlane[yIndex] & 0xFF;
  //       final int uValue = uPlane[uvIndex] & 0xFF;
  //       final int vValue = vPlane[uvIndex] & 0xFF;

  //       // YUV420 to RGBA conversion
  //       final r = (yValue + 1.402 * (vValue - 128)).round().clamp(0, 255);
  //       final g =
  //           (yValue - 0.344136 * (uValue - 128) - 0.714136 * (vValue - 128))
  //               .round()
  //               .clamp(0, 255);
  //       final b = (yValue + 1.772 * (uValue - 128)).round().clamp(0, 255);

  //       final rgbaIndex = (y * width + x) * 4;
  //       rgbaBytes[rgbaIndex] = r;
  //       rgbaBytes[rgbaIndex + 1] = g;
  //       rgbaBytes[rgbaIndex + 2] = b;
  //       rgbaBytes[rgbaIndex + 3] = 255; // Full alpha
  //     }
  //   }

  //   return rgbaBytes;
  // }
}
