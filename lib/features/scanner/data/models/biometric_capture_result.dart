class BiometricCaptureResult {
  final List<double> embedding;
  final double livenessScore;
  final double qualityScore;
  final String modelVersion;

  BiometricCaptureResult({
    required this.embedding,
    required this.livenessScore,
    required this.qualityScore,
    required this.modelVersion,
  });
}
