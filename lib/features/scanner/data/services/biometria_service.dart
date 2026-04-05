import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:eulalia_app/core/network/api_client.dart';
import 'package:eulalia_app/features/scanner/data/models/biometria_model.dart';

class BiometriaService {
  final ApiClient _apiClient;

  BiometriaService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// POST /api/Biometria
  /// Registrar template biométrico (multipart/form-data)
  /// Requiere rol Admin/Validador
  Future<void> register({
    required String cedula,
    required String templateFilePath,
  }) async {
    try {
      final formData = FormData.fromMap({
        'Cedula': cedula,
        'TemplateFile': await MultipartFile.fromFile(templateFilePath),
      });

      await _apiClient.post('/api/Biometria', data: formData);
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('No tiene permisos para registrar biometría');
      }
      throw Exception('Error al registrar biometría: ${e.message}');
    }
  }

  Future<void> registerSelf({
    required String cedula,
    required List<double> embedding,
    required double livenessScore,
    required String modelVersion,
  }) async {
    try {
      final embeddingBytes = utf8.encode(embedding.join(','));
      final embeddingBase64 = base64Encode(embeddingBytes);

      await _apiClient.post(
        '/api/Biometria/enroll-self',
        data: {
          'cedula': cedula,
          'embeddingBase64': embeddingBase64,
          'livenessScore': livenessScore,
          'modelVersion': modelVersion,
        },
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('No autorizado para registrar biometría propia');
      }
      throw Exception(
          'Error al registrar biometría self-service: ${e.message}');
    }
  }

  /// GET /api/Biometria/{cedula}
  /// Consultar estado de verificación
  Future<BiometriaDto> getStatus(String cedula) async {
    try {
      final response = await _apiClient.get('/api/Biometria/$cedula');
      return BiometriaDto.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('No se encontró registro biométrico');
      }
      throw Exception('Error al consultar biometría: ${e.message}');
    }
  }
}
