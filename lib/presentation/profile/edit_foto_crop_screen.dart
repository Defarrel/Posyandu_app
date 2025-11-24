import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:posyandu_app/core/constant/colors.dart';

class EditFotoCropScreen extends StatefulWidget {
  final File file;
  final Function(File) onSave;

  const EditFotoCropScreen({
    super.key,
    required this.file,
    required this.onSave,
  });

  @override
  State<EditFotoCropScreen> createState() => _EditFotoCropScreenState();
}

class _EditFotoCropScreenState extends State<EditFotoCropScreen> {
  final TransformationController _controller = TransformationController();

  final GlobalKey _cropKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text("Edit Photo", style: TextStyle(color: Colors.white)),
      ),

      body: Column(
        children: [
          const SizedBox(height: 20),

          Center(
            child: RepaintBoundary(
              key: _cropKey,
              child: ClipOval(
                child: Container(
                  width: 300,
                  height: 300,
                  color: Colors.black,
                  child: InteractiveViewer(
                    transformationController: _controller,
                    minScale: 1.0,
                    maxScale: 4.0,
                    child: Image.file(widget.file, fit: BoxFit.cover),
                  ),
                ),
              ),
            ),
          ),

          const Spacer(),

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: ElevatedButton(
                  onPressed: _saveCroppedImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    "Save",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Future<void> _saveCroppedImage() async {
    try {
      RenderRepaintBoundary boundary =
          _cropKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) return;

      final pngBytes = byteData.buffer.asUint8List();

      final output = File(widget.file.path.replaceAll(".jpg", "_crop.png"));
      await output.writeAsBytes(pngBytes);

      widget.onSave(output); 
      Navigator.pop(context); 
    } catch (e) {
      print("Error Crop: $e");
    }
  }
}
