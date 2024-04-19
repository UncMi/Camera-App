import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class ImagePreview extends StatefulWidget {
  ImagePreview(this.file, {Key? key});
  final XFile file;

  @override
  State<ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  bool showCircularImage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Image Preview")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: Stack(
                children: [
                  if (showCircularImage) ...[
                    Positioned(
                      top: 0,
                      left: 0,
                      child: CircularImageView(widget.file),
                    ),
                    Positioned(
                      top: 0,
                      left: MediaQuery.of(context).size.width * 0.35 + 16.0,
                      child: ImageInfoText(),
                    ),
                  ] else ...[
                    Image.file(
                      File(widget.file.path),
                      fit: BoxFit.cover,
                    ),
                  ],
                ],
              ),
            ),
          ),
          SizedBox(height: 20.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(
                      context); // Go back to the previous screen (camera view)
                },
                child: Text("Retake Photo"),
              ),
              SizedBox(width: 20.0),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    showCircularImage = true;
                  });
                },
                child: Text("Send to Server"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CircularImageView extends StatelessWidget {
  final XFile file;

  CircularImageView(this.file);

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Image.file(
        File(file.path),
        fit: BoxFit.cover,
        width: MediaQuery.of(context).size.width * 0.35,
        height: MediaQuery.of(context).size.width * 0.35,
      ),
    );
  }
}

class ImageInfoText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

      ],
    );
  }
}
