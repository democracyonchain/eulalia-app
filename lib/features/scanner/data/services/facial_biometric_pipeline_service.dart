import 'dart:math';
import 'dart:typed_data';

import 'package:eulalia_app/features/scanner/data/models/biometric_capture_result.dart';
import 'package:image/image.dart' as img;

class FacialBiometricPipelineService {
  static const String modelVersion = 'oss-facepassive-v1';

  BiometricCaptureResult processFrames({
    required List<int> firstFrameBytes,
    required List<int> secondFrameBytes,
  }) {
    final first = img.decodeImage(Uint8List.fromList(firstFrameBytes));
    final second = img.decodeImage(Uint8List.fromList(secondFrameBytes));

    if (first == null || second == null) {
      throw Exception('No se pudieron decodificar las imágenes capturadas.');
    }

    final firstGray = img.grayscale(first);
    final secondGray = img.grayscale(second);

    final blurScore = _laplacianVariance(firstGray);
    final brightnessScore = _brightnessScore(firstGray);
    final motionScore = _frameDifferenceScore(firstGray, secondGray);

    final qualityScore = ((blurScore + brightnessScore) / 2).clamp(0.0, 1.0);
    final livenessScore =
        ((motionScore * 0.6) + (qualityScore * 0.4)).clamp(0.0, 1.0);

    final embedding = _buildEmbedding(firstGray);

    return BiometricCaptureResult(
      embedding: embedding,
      livenessScore: livenessScore,
      qualityScore: qualityScore,
      modelVersion: modelVersion,
    );
  }

  double _laplacianVariance(img.Image image) {
    final width = image.width;
    final height = image.height;
    if (width < 3 || height < 3) return 0;

    final values = <double>[];
    for (var y = 1; y < height - 1; y++) {
      for (var x = 1; x < width - 1; x++) {
        final center = image.getPixel(x, y).r;
        final left = image.getPixel(x - 1, y).r;
        final right = image.getPixel(x + 1, y).r;
        final up = image.getPixel(x, y - 1).r;
        final down = image.getPixel(x, y + 1).r;

        final lap = (4 * center - left - right - up - down).toDouble();
        values.add(lap);
      }
    }

    final mean = values.reduce((a, b) => a + b) / values.length;
    final variance =
        values.map((v) => (v - mean) * (v - mean)).reduce((a, b) => a + b) /
            values.length;

    // Normalize roughly for practical camera ranges.
    return (variance / 5000.0).clamp(0.0, 1.0);
  }

  double _brightnessScore(img.Image image) {
    final width = image.width;
    final height = image.height;
    var sum = 0.0;
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        sum += image.getPixel(x, y).r;
      }
    }
    final mean = sum / (width * height);
    // Ideal range around 110..190
    final distance = (mean - 150).abs();
    return (1 - (distance / 150)).clamp(0.0, 1.0);
  }

  double _frameDifferenceScore(img.Image first, img.Image second) {
    final targetWidth = min(first.width, second.width);
    final targetHeight = min(first.height, second.height);

    final a = img.copyResize(first, width: targetWidth, height: targetHeight);
    final b = img.copyResize(second, width: targetWidth, height: targetHeight);

    var diffSum = 0.0;
    for (var y = 0; y < targetHeight; y++) {
      for (var x = 0; x < targetWidth; x++) {
        diffSum += (a.getPixel(x, y).r - b.getPixel(x, y).r).abs();
      }
    }
    final meanDiff = diffSum / (targetWidth * targetHeight);
    return (meanDiff / 30.0).clamp(0.0, 1.0);
  }

  List<double> _buildEmbedding(img.Image image) {
    final resized = img.copyResize(image, width: 16, height: 8);
    final embedding = <double>[];
    for (var y = 0; y < resized.height; y++) {
      for (var x = 0; x < resized.width; x++) {
        embedding.add(resized.getPixel(x, y).r / 255.0);
      }
    }

    if (embedding.length != 128) {
      throw Exception('Embedding inválido: se esperaban 128 dimensiones.');
    }
    return embedding;
  }
}
