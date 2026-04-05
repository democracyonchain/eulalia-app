import 'package:camera/camera.dart';
import 'package:eulalia_app/core/constants/app_colors.dart';
import 'package:eulalia_app/features/scanner/data/models/biometric_capture_result.dart';
import 'package:eulalia_app/features/scanner/data/services/facial_biometric_pipeline_service.dart';
import 'package:flutter/material.dart';

class BiometricCapturePage extends StatefulWidget {
  const BiometricCapturePage({super.key});

  @override
  State<BiometricCapturePage> createState() => _BiometricCapturePageState();
}

class _BiometricCapturePageState extends State<BiometricCapturePage> {
  CameraController? _controller;
  bool _isLoading = true;
  bool _capturing = false;
  String? _error;

  final _pipeline = FacialBiometricPipelineService();

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      final front = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        front,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await controller.initialize();

      if (!mounted) return;
      setState(() {
        _controller = controller;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'No se pudo iniciar cámara frontal: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _captureAndAnalyze() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    setState(() => _capturing = true);
    try {
      final first = await _controller!.takePicture();
      await Future.delayed(const Duration(milliseconds: 700));
      final second = await _controller!.takePicture();

      final firstBytes = await first.readAsBytes();
      final secondBytes = await second.readAsBytes();

      final result = _pipeline.processFrames(
        firstFrameBytes: firstBytes,
        secondFrameBytes: secondBytes,
      );

      if (result.qualityScore < 0.45) {
        throw Exception(
            'Calidad de imagen insuficiente. Mejore iluminación y enfoque.');
      }

      if (!mounted) return;
      Navigator.pop<BiometricCaptureResult>(context, result);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de captura biométrica: $e')),
      );
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Captura Facial'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(_error!,
                        style: const TextStyle(color: Colors.white)),
                  ),
                )
              : Stack(
                  children: [
                    Positioned.fill(child: CameraPreview(_controller!)),
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Center(
                          child: Container(
                            width: 260,
                            height: 340,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: AppColors.primaryBlue, width: 3),
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 36,
                      child: Column(
                        children: [
                          const Text(
                            'Mire al frente y mantenga el rostro dentro del marco',
                            style: TextStyle(color: Colors.white),
                          ),
                          const SizedBox(height: 14),
                          ElevatedButton.icon(
                            onPressed: _capturing ? null : _captureAndAnalyze,
                            icon: _capturing
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : const Icon(Icons.camera_alt),
                            label:
                                Text(_capturing ? 'Procesando...' : 'Capturar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
