import 'package:dio/dio.dart';
import 'package:eulalia_app/core/network/api_client.dart';
import 'package:eulalia_app/features/affiliation/data/models/afiliacion_model.dart';

class AfiliacionService {
  final ApiClient _apiClient;

  AfiliacionService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// GET /api/Afiliacion
  /// Listar todas las afiliaciones
  Future<List<AfiliacionDto>> getAll() async {
    try {
      final response = await _apiClient.get('/api/Afiliacion');
      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((json) => AfiliacionDto.fromJson(json)).toList();
    } on DioException catch (_) {
      throw Exception(
          'No se pudieron cargar sus afiliaciones. Inténtelo nuevamente.');
    }
  }

  /// GET /api/Afiliacion/{id}
  /// Obtener detalle de una afiliación
  Future<AfiliacionDto> getById(int id) async {
    try {
      final response = await _apiClient.get('/api/Afiliacion/$id');
      return AfiliacionDto.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Afiliación no encontrada');
      }
      throw Exception('No se pudo cargar la afiliación. Inténtelo nuevamente.');
    }
  }

  /// POST /api/Afiliacion
  /// Crear una nueva afiliación política
  Future<AfiliacionDto> create(CreateAfiliacionRequest request) async {
    try {
      final response = await _apiClient.post(
        '/api/Afiliacion',
        data: request.toJson(),
      );
      return AfiliacionDto.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw Exception('Ya existe una afiliación activa para este ciudadano');
      }
      throw Exception(
          'No se pudo registrar la afiliación. Inténtelo nuevamente.');
    }
  }

  /// PUT /api/Afiliacion/{id}/anular
  /// Anular/Cancelar una afiliación
  Future<AfiliacionDto> cancel(int id) async {
    try {
      final response = await _apiClient.put('/api/Afiliacion/$id/anular');
      return AfiliacionDto.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Afiliación no encontrada');
      }
      throw Exception('No se pudo anular la afiliación. Inténtelo nuevamente.');
    }
  }
}
