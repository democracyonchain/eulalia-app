import 'package:dio/dio.dart';
import 'package:eulalia_app/core/network/api_client.dart';
import 'package:eulalia_app/features/auth/data/models/ciudadano_model.dart';

class CiudadanoService {
  final ApiClient _apiClient;

  CiudadanoService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// GET /api/Ciudadano
  /// Listar todos los ciudadanos
  Future<List<CiudadanoDto>> getAll() async {
    try {
      final response = await _apiClient.get('/api/Ciudadano');
      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((json) => CiudadanoDto.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Error al obtener ciudadanos: ${e.message}');
    }
  }

  /// GET /api/Ciudadano/{cedula}
  /// Obtener detalle de un ciudadano por cédula
  Future<CiudadanoDto> getByCedula(String cedula) async {
    try {
      final response = await _apiClient.get('/api/Ciudadano/$cedula');
      return CiudadanoDto.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Ciudadano no encontrado');
      }
      throw Exception('Error al obtener ciudadano: ${e.message}');
    }
  }

  /// POST /api/Ciudadano
  /// Registrar un nuevo ciudadano
  Future<CiudadanoDto> register(CiudadanoDto ciudadano) async {
    try {
      final response = await _apiClient.post(
        '/api/Ciudadano',
        data: ciudadano.toJson(),
      );
      return CiudadanoDto.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw Exception('El ciudadano ya está registrado');
      }
      throw Exception('Error al registrar ciudadano: ${e.message}');
    }
  }
}
