import 'dart:io';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:first/screen/camera_screen.dart';
import 'package:flutter/material.dart';

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CameraApp(),
    );
  }
}

class CameraApp extends StatefulWidget {
  const CameraApp({super.key});

  @override
  State<CameraApp> createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  late CameraController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(cameras[0], ResolutionPreset.max);
    _controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            print("access was denied");
            break;
          default:
            print(e.description);
            break;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Camera Preview
          CameraPreview(_controller),
          // Unblurred Circle in the Middle
          Center(
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: CustomPaint(
                  painter: CirclePainter(),
                  child: Container(),
                ),
              ),
            ),
          ),
          // Capture Button
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Container(
                  margin: EdgeInsets.all(20.0),
                  child: FloatingActionButton(
                    onPressed: () async {
                      if (!_controller.value.isInitialized) {
                        return null;
                      }
                      if (_controller.value.isTakingPicture) {
                        return null;
                      }

                      try {
                        await _controller.setFlashMode(FlashMode.auto);
                        XFile file = await _controller.takePicture();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ImagePreview(file)),
                        );
                      } on CameraException catch (e) {
                        debugPrint("Error occurred while taking picture: $e");
                        return null;
                      }
                    },
                    backgroundColor: Colors.white,
                    child: Icon(Icons.camera_alt, color: Colors.black),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}

class CirclePainter extends CustomPainter {
  final double innerCircleRadius = 0.35; // half of the screen width
  final double outerCircleRadius =
      0.35; // slightly larger than the inner circle

  @override
  void paint(Canvas canvas, Size size) {
    final Paint outerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final Paint innerPaint = Paint()
      ..color = Colors.transparent
      ..blendMode = BlendMode.dstIn;

    final Offset center = size.center(Offset.zero);

    // Draw outer circle
    canvas.drawCircle(center, outerCircleRadius * size.width, outerPaint);

    // Draw inner unblurred circle
    canvas.drawCircle(center, innerCircleRadius * size.width, innerPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
