import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eulalia_app/core/network/api_client.dart';
import 'package:eulalia_app/features/auth/data/models/auth_models.dart';

class AuthService {
  final ApiClient _apiClient;

  AuthService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// POST /api/Auth/login
  /// Inicia sesión y devuelve un JWT
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await _apiClient.post(
        '/api/Auth/login',
        data: request.toJson(),
      );

      final loginResponse = LoginResponse.fromJson(response.data);

      // Save token to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', loginResponse.token);

      return loginResponse;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Correo o contraseña inválidos');
      }
      throw Exception('Error de conexión: ${e.message}');
    }
  }

  /// Logout - clear token
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('auth_token');
  }

  /// Get current token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
}
