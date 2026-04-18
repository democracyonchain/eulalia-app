import 'package:eulalia_app/core/constants/app_colors.dart';
import 'package:eulalia_app/core/store/user_session.dart';
import 'package:eulalia_app/features/auth/data/models/auth_models.dart';
import 'package:eulalia_app/features/auth/data/models/registro_estado_model.dart';
import 'package:eulalia_app/features/auth/data/services/auth_service.dart';
import 'package:eulalia_app/features/auth/data/services/registro_estado_service.dart';
import 'package:eulalia_app/features/auth/data/services/registro_service.dart';
import 'package:eulalia_app/features/scanner/data/models/biometric_capture_result.dart';
import 'package:eulalia_app/features/scanner/data/services/biometria_service.dart';
import 'package:eulalia_app/features/scanner/presentation/pages/biometric_capture_page.dart';
import 'package:eulalia_app/features/wallet/data/models/ssi_model.dart';
import 'package:eulalia_app/features/wallet/data/services/ssi_service.dart';
import 'package:eulalia_app/features/wallet/data/services/secure_wallet_service.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _dniController = TextEditingController();
  final _pinController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  final _registroService = RegistroService();
  final _authService = AuthService();
  final _ssiService = SSIService();
  final _biometriaService = BiometriaService();
  final _registroEstadoService = RegistroEstadoService();
  final _walletService = SecureWalletService();
  String? _localDid;

  int _currentStep = 0;
  bool _isLoading = false;
  DateTime? _birthDate;
  SSIInvitationDto? _invitation;
  RegistroEstadoDto? _estadoRegistro;
  String? _ssiStatus;
  String? _ssiError;
  double? _lastLivenessScore;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _dniController.dispose();
    _pinController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 20, 1, 1),
      firstDate: DateTime(1930, 1, 1),
      lastDate: DateTime(now.year - 12, now.month, now.day),
    );

    if (selected != null) {
      setState(() => _birthDate = selected);
    }
  }

  Future<void> _createBaseRegistration() async {
    if (!_formKey.currentState!.validate()) return;
    if (_birthDate == null) {
      _showSnack('Seleccione fecha de nacimiento');
      return;
    }

    final fullName = _nameController.text.trim().split(RegExp(r'\s+'));
    final nombres = fullName.isNotEmpty ? fullName.first : _nameController.text;
    final apellidos =
        fullName.length > 1 ? fullName.sublist(1).join(' ') : 'N/A';

    setState(() => _isLoading = true);
    try {
      await _registroService.createCitizenUser(
        cedula: _dniController.text.trim(),
        nombres: nombres,
        apellidos: apellidos,
        fechaNacimiento: _birthDate!,
        direccion: _addressController.text.trim(),
        telefono: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        contrasena: _pinController.text.trim(),
      );

      await _authService.login(
        LoginRequest(
          email: _emailController.text.trim(),
          password: _pinController.text.trim(),
        ),
      );

      setState(() => _currentStep = 1);
      _showSnack('Registro base completado');
    } catch (e) {
      _showSnack(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _createWalletAndSSI() async {
    setState(() => _isLoading = true);
    try {
      final hasWallet = await _walletService.hasWallet();
      if (!hasWallet) {
        final walletResult = await _walletService.generateWallet();
        if (walletResult != null) {
          _localDid = walletResult.$2;
          _showSnack('Wallet local creada: $_localDid');
        }
      } else {
        _localDid = await _walletService.getStoredDID();
        _showSnack('Wallet existente: $_localDid');
      }

      _invitation =
          await _ssiService.requestInvitation(_dniController.text.trim());
      _ssiStatus = _invitation?.status;
      _ssiError = null;
      setState(() => _currentStep = 2);
      _showSnack('Wallet SSI iniciada. Invitación generada');
    } catch (e) {
      _showSnack(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshSsiStatus() async {
    setState(() => _isLoading = true);
    try {
      final status = await _ssiService.getStatus(_dniController.text.trim());
      setState(() {
        _ssiStatus = status.status;
        _ssiError = status.error;
      });
    } catch (e) {
      _showSnack(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _enrollBiometria() async {
    setState(() => _isLoading = true);
    try {
      final result = await Navigator.push<BiometricCaptureResult>(
        context,
        MaterialPageRoute(builder: (_) => const BiometricCapturePage()),
      );

      if (result == null) {
        _showSnack('Captura biométrica cancelada');
        return;
      }

      await _biometriaService.registerSelf(
        cedula: _dniController.text.trim(),
        embedding: result.embedding,
        livenessScore: result.livenessScore,
        modelVersion: result.modelVersion,
      );

      _lastLivenessScore = result.livenessScore;
      setState(() => _currentStep = 3);
      _showSnack('Biometría registrada correctamente');
    } catch (e) {
      _showSnack(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadFinalStatus() async {
    setState(() => _isLoading = true);
    try {
      final estado =
          await _registroEstadoService.getStatus(_dniController.text.trim());
      setState(() => _estadoRegistro = estado);

      UserSession().setIdentity(
        UserIdentity(
          name: _nameController.text.trim(),
          dni: _dniController.text.trim(),
          pin: _pinController.text.trim(),
          did: _localDid ?? '',
        ),
      );
    } catch (e) {
      _showSnack(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Widget _buildFormStep() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildTextField('Nombre completo', _nameController),
          const SizedBox(height: 12),
          _buildTextField('Correo', _emailController,
              keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 12),
          _buildTextField('Cédula', _dniController,
              keyboardType: TextInputType.number),
          const SizedBox(height: 12),
          _buildTextField('PIN (será su contraseña)', _pinController,
              keyboardType: TextInputType.number, obscureText: true),
          const SizedBox(height: 12),
          _buildTextField('Teléfono', _phoneController,
              keyboardType: TextInputType.phone),
          const SizedBox(height: 12),
          _buildTextField('Dirección', _addressController),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _pickBirthDate,
            icon: const Icon(Icons.calendar_month),
            label: Text(_birthDate == null
                ? 'Seleccionar fecha de nacimiento'
                : 'Fecha: ${_birthDate!.toIso8601String().split('T').first}'),
          ),
          const SizedBox(height: 20),
          _buildPrimaryButton('Crear registro base', _createBaseRegistration),
        ],
      ),
    );
  }

  Widget _buildSsiStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Paso SSI',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
            'Genera la invitación de wallet y vincula la identidad SSI.'),
        const SizedBox(height: 16),
        if (_invitation != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Invitation ID: ${_invitation!.invitationId}'),
                Text('Estado: ${_invitation!.status}'),
                if (_ssiStatus != null) Text('Estado SSI actual: $_ssiStatus'),
                if (_ssiError != null && _ssiError!.isNotEmpty)
                  Text('Error SSI: $_ssiError'),
                if (_invitation!.invitationUrl.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Escanea con tu wallet:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: QrImageView(
                      data: _invitation!.invitationUrl,
                      version: QrVersions.auto,
                      size: 200,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _invitation!.invitationUrl,
                    style: const TextStyle(fontSize: 10),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        const SizedBox(height: 20),
        _buildPrimaryButton('Generar Wallet SSI', _createWalletAndSSI),
        const SizedBox(height: 10),
        _buildPrimaryButton('Consultar estado SSI', _refreshSsiStatus),
      ],
    );
  }

  Widget _buildBiometriaStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Paso Biometría (Rostro + Liveness pasivo)',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Se captura rostro con cámara frontal y se calcula liveness pasivo + embedding local OSS en el dispositivo.',
        ),
        const SizedBox(height: 20),
        _buildPrimaryButton('Registrar biometría', _enrollBiometria),
      ],
    );
  }

  Widget _buildFinalStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Estado del Registro 360',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildPrimaryButton('Consultar estado final', _loadFinalStatus),
        const SizedBox(height: 16),
        if (_estadoRegistro != null)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _statusRow('Base tradicional', _estadoRegistro!.baseOk),
                _statusRow('SSI', _estadoRegistro!.ssiOk),
                _statusRow('Biometría', _estadoRegistro!.bioOk),
                _statusRow('Listo para afiliación',
                    _estadoRegistro!.readyForAffiliation),
                if (_lastLivenessScore != null)
                  Text(
                      'Liveness score: ${_lastLivenessScore!.toStringAsFixed(3)}'),
              ],
            ),
          ),
        const SizedBox(height: 20),
        _buildPrimaryButton(
          'Ir a mi billetera',
          () => Navigator.pushReplacementNamed(context, '/wallet'),
        ),
      ],
    );
  }

  Widget _statusRow(String label, bool ok) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(ok ? Icons.check_circle : Icons.cancel,
              color: ok ? Colors.green : Colors.red, size: 18),
          const SizedBox(width: 8),
          Text('$label: ${ok ? 'OK' : 'Pendiente'}'),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: (value) {
        if (value == null || value.trim().isEmpty) return 'Campo obligatorio';
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildPrimaryButton(String text, Future<void> Function() onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading
            ? null
            : () {
                onPressed();
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(text),
      ),
    );
  }

  Widget _buildStepBody() {
    switch (_currentStep) {
      case 0:
        return _buildFormStep();
      case 1:
        return _buildSsiStep();
      case 2:
        return _buildBiometriaStep();
      case 3:
      default:
        return _buildFinalStep();
    }
  }

  @override
  Widget build(BuildContext context) {
    final titles = [
      'Registro Base',
      'Wallet SSI',
      'Biometría',
      'Estado Final',
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Registro Ciudadano 360 • ${titles[_currentStep]}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: _buildStepBody(),
        ),
      ),
    );
  }
}
