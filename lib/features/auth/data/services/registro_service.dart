import 'package:dio/dio.dart';
import 'package:eulalia_app/core/network/api_client.dart';

class RegistroService {
  final ApiClient _apiClient;

  RegistroService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<void> createCitizenUser({
    required String cedula,
    required String nombres,
    required String apellidos,
    required DateTime fechaNacimiento,
    required String direccion,
    required String telefono,
    required String email,
    required String contrasena,
  }) async {
    try {
      await _apiClient.post(
        '/api/Usuario/crear-usuario-ciudadano',
        data: {
          'cedula_Ciudadano': cedula,
          'nombre': nombres,
          'apellido': apellidos,
          'fecha_Nacimiento': fechaNacimiento.toIso8601String(),
          'direccion': direccion,
          'telefono': telefono,
          'correo': email,
          'contrasena': contrasena,
          'rol_Id': 4,
        },
      );
    } on DioException catch (e) {
      final errorMessage = e.response?.data?.toString() ?? e.message;
      throw Exception('No se pudo registrar el ciudadano: $errorMessage');
    }
  }
}
