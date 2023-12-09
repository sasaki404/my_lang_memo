import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraView extends StatefulWidget {
  final bool isJapanese;
  const CameraView({
    super.key,
    required this.isJapanese,
  });

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> with WidgetsBindingObserver {
  bool _isPermissionGranted = false;
  late final Future<void> _future;
  CameraController? _cameraController;
  late final TextRecognizer textRecognizer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _future = _requestCameraPermission();
    if (widget.isJapanese && Platform.isIOS) {
      // Androidではissue解決まで使えない。https://github.com/flutter-ml/google_ml_kit_flutter/issues/549、https://github.com/flutter-ml/google_ml_kit_flutter/issues/519
      textRecognizer = TextRecognizer(script: TextRecognitionScript.japanese);
    } else {
      textRecognizer = TextRecognizer();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopCamera();
    textRecognizer.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      _stopCamera();
    } else if (state == AppLifecycleState.resumed &&
        _cameraController != null &&
        _cameraController!.value.isInitialized) {
      _startCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        return Stack(
          children: [
            if (_isPermissionGranted)
              FutureBuilder<List<CameraDescription>>(
                future: availableCameras(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    _initCameraController(snapshot.data!);
                    return Center(child: CameraPreview(_cameraController!));
                  } else {
                    return const LinearProgressIndicator();
                  }
                },
              ),
            Scaffold(
              backgroundColor: _isPermissionGranted ? Colors.transparent : null,
              body: _isPermissionGranted
                  ? Column(
                      children: [
                        Expanded(
                          child: Container(),
                        ),
                        Container(
                          padding: const EdgeInsets.only(bottom: 30.0),
                          child: Wrap(
                            spacing: 20,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                style: const ButtonStyle(
                                  backgroundColor:
                                      MaterialStatePropertyAll(Colors.black12),
                                ),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(
                                      color: Colors.white38,
                                      fontWeight: FontWeight.w900),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: _scanImage,
                                style: const ButtonStyle(
                                  backgroundColor:
                                      MaterialStatePropertyAll(Colors.black12),
                                ),
                                child: const Text(
                                  'Scan',
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Center(
                      child: Container(
                        padding: const EdgeInsets.only(left: 24.0, right: 24.0),
                        child: const Text(
                          'Camera permission denied',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    _isPermissionGranted = (status == PermissionStatus.granted);
  }

  void _startCamera() {
    if (_cameraController != null) {
      _cameraSelected(_cameraController!.description);
    }
  }

  void _stopCamera() {
    if (_cameraController != null) {
      _cameraController?.dispose();
    }
  }

  void _initCameraController(List<CameraDescription> cameras) {
    if (_cameraController != null) {
      return;
    }

    CameraDescription? camera;
    for (var i = 0; i < cameras.length; i++) {
      final CameraDescription current = cameras[i];
      if (current.lensDirection == CameraLensDirection.back) {
        camera = current;
        break;
      }
    }
    if (camera != null) {
      _cameraSelected(camera);
    }
  }

  Future<void> _cameraSelected(CameraDescription camera) async {
    _cameraController = CameraController(
      camera,
      ResolutionPreset.max,
      enableAudio: false,
    );
    await _cameraController!.initialize();
    await _cameraController!.setFlashMode(FlashMode.off);
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  Future<void> _scanImage() async {
    if (_cameraController == null) return;
    final navigator = Navigator.of(context);
    try {
      final pictureFile = await _cameraController!.takePicture();
      final file = File(pictureFile.path);

      final inputImage = InputImage.fromFile(file);
      final recognizedText = await textRecognizer.processImage(inputImage);
      // final blocks = recognizedText.blocks;
      // final Size imageSize = Size(
      //   _cameraController!.value.previewSize!.width,
      //   _cameraController!.value.previewSize!.height,
      // );
      // final Size absImageSize = await getImageSize(file);
      navigator.pop(recognizedText.text);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred when scanning text'),
        ),
      );
    }
  }

  Future<Size> getImageSize(File file) async {
    final List<int> headerBytes = await file.readAsBytes();
    final int height = ((headerBytes[6] & 0xFF) << 8) | (headerBytes[7] & 0xFF);
    final int width = ((headerBytes[8] & 0xFF) << 8) | (headerBytes[9] & 0xFF);

    return Size(width.toDouble() / 10, height.toDouble() / 10);
  }
}
