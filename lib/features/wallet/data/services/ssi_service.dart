import 'package:dio/dio.dart';
import 'package:eulalia_app/core/network/api_client.dart';
import 'package:eulalia_app/features/wallet/data/models/ssi_model.dart';

String _describeDioError(DioException error, String fallback) {
  final data = error.response?.data;
  if (data is Map) {
    final message = data['message'] ?? data['mensaje'];
    final detail = data['error'];
    if (message is String && detail is String && detail.isNotEmpty) {
      return '$message: $detail';
    }
    if (message is String && message.isNotEmpty) return message;
  }

  final status = error.response?.statusCode;
  if (status != null) return '$fallback (HTTP $status)';
  return '$fallback (${error.type.name})';
}

class SSIService {
  final ApiClient _apiClient;

  SSIService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<SSIInvitationDto> requestInvitation(String cedula) async {
    try {
      final response = await _apiClient.post('/api/SSI/invitation/$cedula');
      return SSIInvitationDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_describeDioError(
          e, 'No se pudo solicitar la invitación SSI. Inténtelo nuevamente.'));
    }
  }

  Future<SSIInvitationDto> retryInvitation(String cedula) async {
    try {
      final response =
          await _apiClient.post('/api/SSI/invitation/$cedula/retry');
      return SSIInvitationDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_describeDioError(
          e, 'No se pudo regenerar la invitación SSI. Inténtelo nuevamente.'));
    }
  }

  Future<SSIStatusDto> getStatus(String cedula) async {
    try {
      final response = await _apiClient.get('/api/SSI/status/$cedula');
      return SSIStatusDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_describeDioError(
          e, 'No se pudo consultar el estado SSI. Inténtelo nuevamente.'));
    }
  }
}
