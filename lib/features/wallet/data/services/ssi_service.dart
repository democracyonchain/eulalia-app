import 'package:dio/dio.dart';
import 'package:eulalia_app/core/network/api_client.dart';
import 'package:eulalia_app/features/wallet/data/models/ssi_model.dart';

class SSIService {
  final ApiClient _apiClient;

  SSIService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<SSIInvitationDto> requestInvitation(String cedula) async {
    try {
      final response = await _apiClient.post('/api/SSI/invitation/$cedula');
      return SSIInvitationDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Error al solicitar invitación SSI: ${e.message}');
    }
  }

  Future<SSIStatusDto> getStatus(String cedula) async {
    try {
      final response = await _apiClient.get('/api/SSI/status/$cedula');
      return SSIStatusDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Error al consultar estado SSI: ${e.message}');
    }
  }
}
