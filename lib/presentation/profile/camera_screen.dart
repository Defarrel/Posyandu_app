import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:posyandu_app/services/storage_helper.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late List<CameraDescription> _cameras;
  CameraController? _controller;
  int _selectedCameraIdx = 0;
  FlashMode _flashMode = FlashMode.off;
  double _zoomLevel = 1.0;
  double _minZoom = 1.0;
  double _maxZoom = 1.0;
  bool _isZoomSupported = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _initializeCameras();
  }

  Future<void> _initializeCameras() async {
    _cameras = await availableCameras();
    await _setupCamera(_selectedCameraIdx);
  }

  Future<void> _setupCamera(int cameraIdx) async {
    if (_controller != null) await _controller!.dispose();

    final controller = CameraController(
      _cameras[cameraIdx],
      ResolutionPreset.high,
      enableAudio: false,
    );

    await controller.initialize();
    _minZoom = await controller.getMinZoomLevel();
    _maxZoom = await controller.getMaxZoomLevel();
    _isZoomSupported = _maxZoom > _minZoom;
    _zoomLevel = _minZoom;
    await controller.setZoomLevel(_zoomLevel);
    await controller.setFlashMode(_flashMode);

    if (mounted) {
      setState(() {
        _controller = controller;
        _selectedCameraIdx = cameraIdx;
      });
    }
  }

  Future<void> _captureImage() async {
    final XFile file = await _controller!.takePicture();

    // SIMPAN secara permanen
    final saved = await StorageHelper.saveImage(File(file.path), "CAM_");

    Navigator.pop(context, saved);
  }

  void _switchCamera() async {
    final nextIndex = (_selectedCameraIdx + 1) % _cameras.length;
    await _setupCamera(nextIndex);
  }

  void _toggleFlash() async {
    FlashMode next = _flashMode == FlashMode.off
        ? FlashMode.auto
        : _flashMode == FlashMode.auto
        ? FlashMode.always
        : FlashMode.off;
    await _controller!.setFlashMode(next);
    setState(() => _flashMode = next);
  }

  void _setZoom(double value) async {
    if (!_isZoomSupported) return;
    await _controller?.setZoomLevel(value);
    setState(() => _zoomLevel = value);
  }

  IconData _flashIcon() {
    switch (_flashMode) {
      case FlashMode.auto:
        return Icons.flash_auto;
      case FlashMode.always:
        return Icons.flash_on;
      default:
        return Icons.flash_off;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _controller?.value.isInitialized != true
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GestureDetector(
                  onTapDown: (details) => _controller?.setFocusPoint(
                    Offset(
                      details.localPosition.dx /
                          MediaQuery.of(context).size.width,
                      details.localPosition.dy /
                          MediaQuery.of(context).size.height,
                    ),
                  ),
                  child: CameraPreview(_controller!),
                ),
                Positioned(
                  top: 40,
                  left: 20,
                  child: _iconButton(
                    icon: Icons.close,
                    onTap: () => Navigator.pop(context),
                    background: Colors.black38,
                  ),
                ),
                Positioned(
                  top: 40,
                  right: 20,
                  child: Column(
                    children: [
                      _iconButton(
                        icon: Icons.cameraswitch,
                        onTap: _switchCamera,
                        background: Colors.black38,
                      ),
                      const SizedBox(height: 12),
                      _iconButton(
                        icon: _flashIcon(),
                        onTap: _toggleFlash,
                        background: Colors.black38,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: _captureImage,
                      child: Container(
                        width: 78,
                        height: 78,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.grey.shade800,
                            width: 5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (_isZoomSupported)
                  Positioned(
                    bottom: 120,
                    left: 40,
                    right: 40,
                    child: Column(
                      children: [
                        Slider(
                          value: _zoomLevel,
                          min: _minZoom,
                          max: _maxZoom,
                          divisions: (_maxZoom - _minZoom > 0)
                              ? ((_maxZoom - _minZoom) ~/ 0.1)
                              : null,
                          onChanged: _setZoom,
                          activeColor: Colors.white,
                          inactiveColor: Colors.white38,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${_zoomLevel.toStringAsFixed(1)}x',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _iconButton({
    required IconData icon,
    required VoidCallback onTap,
    Color background = Colors.white24,
  }) {
    return ClipOval(
      child: Material(
        color: background,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(icon, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
