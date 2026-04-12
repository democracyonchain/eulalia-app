import 'package:dio/dio.dart';
import 'package:eulalia_app/core/network/api_client.dart';
import 'package:eulalia_app/features/affiliation/data/models/organizacion_model.dart';

class OrganizacionService {
  final ApiClient _apiClient;

  OrganizacionService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<List<OrganizacionDto>> getAll() async {
    try {
      final response = await _apiClient.get('/api/Organizacion');
      final data = response.data as List<dynamic>;
      return data
          .map((item) => OrganizacionDto.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception('Error al cargar organizaciones: ${e.message}');
    }
  }
}
