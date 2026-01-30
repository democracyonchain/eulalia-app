import 'package:dio/dio.dart';
import 'package:eulalia_app/core/network/api_client.dart';
import 'package:eulalia_app/features/wallet/data/models/ssi_model.dart';

class SSIService {
  final ApiClient _apiClient;

  SSIService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// GET /api/SSI
  /// Listar credenciales emitidas
  Future<List<SSIDto>> getAll() async {
    try {
      final response = await _apiClient.get('/api/SSI');
      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((json) => SSIDto.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Error al obtener credenciales SSI: ${e.message}');
    }
  }

  /// POST /api/SSI
  /// Registrar metadatos SSI (Fase 1 - CRUD)
  Future<SSIDto> create(SSIDto ssi) async {
    try {
      final response = await _apiClient.post(
        '/api/SSI',
        data: ssi.toJson(),
      );
      return SSIDto.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Error al crear registro SSI: ${e.message}');
    }
  }

  /// GET /api/SSI/{id}
  /// Obtener detalle de una credencial SSI
  Future<SSIDto> getById(int id) async {
    try {
      final response = await _apiClient.get('/api/SSI/$id');
      return SSIDto.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Credencial SSI no encontrada');
      }
      throw Exception('Error al obtener credencial SSI: ${e.message}');
    }
  }
}
