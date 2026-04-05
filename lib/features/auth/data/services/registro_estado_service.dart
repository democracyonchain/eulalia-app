import 'package:dio/dio.dart';
import 'package:eulalia_app/core/network/api_client.dart';
import 'package:eulalia_app/features/auth/data/models/registro_estado_model.dart';

class RegistroEstadoService {
  final ApiClient _apiClient;

  RegistroEstadoService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<RegistroEstadoDto> getStatus(String cedula) async {
    try {
      final response =
          await _apiClient.get('/api/RegistroCiudadano/estado/$cedula');
      return RegistroEstadoDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('No se pudo consultar estado de registro: ${e.message}');
    }
  }
}
