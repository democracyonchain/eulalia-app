import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eulalia_app/core/network/api_client.dart';
import 'package:eulalia_app/core/store/user_session.dart';
import 'package:eulalia_app/features/auth/data/models/auth_models.dart';
import 'package:eulalia_app/features/auth/data/services/ciudadano_service.dart';
import 'package:eulalia_app/features/wallet/data/services/secure_wallet_service.dart';

class AuthService {
  final ApiClient _apiClient;
  final CiudadanoService _ciudadanoService;
  final SecureWalletService _walletService;

  AuthService({
    ApiClient? apiClient,
    CiudadanoService? ciudadanoService,
    SecureWalletService? walletService,
  })  : _apiClient = apiClient ?? ApiClient(),
        _ciudadanoService =
            ciudadanoService ?? CiudadanoService(apiClient: apiClient),
        _walletService = walletService ?? SecureWalletService();

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

      try {
        await _restoreSession(loginResponse.token, request.password);
      } catch (_) {
        await prefs.remove('auth_token');
        rethrow;
      }

      return loginResponse;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Correo o contraseña inválidos');
      }
      throw Exception(
          'No se pudo iniciar sesión. Verifique su conexión e inténtelo nuevamente.');
    }
  }

  Future<void> _restoreSession(String token, String password) async {
    final payload = _decodeJwtPayload(token);
    final cedula = payload['cedula']?.toString();
    if (cedula == null || cedula.isEmpty) {
      throw Exception('La sesión no contiene una identidad ciudadana válida.');
    }

    final ciudadano = await _ciudadanoService.getByCedula(cedula);
    final did = await _walletService.getStoredDID();
    UserSession().setIdentity(
      UserIdentity(
        name: '${ciudadano.nombres} ${ciudadano.apellidos}'.trim(),
        dni: ciudadano.cedula,
        pin: password,
        did: did ?? '',
      ),
    );
  }

  Map<String, dynamic> _decodeJwtPayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) throw const FormatException();
      final normalized = base64Url.normalize(parts[1]);
      return jsonDecode(utf8.decode(base64Url.decode(normalized)))
          as Map<String, dynamic>;
    } catch (_) {
      throw Exception('La respuesta de autenticación no es válida.');
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
