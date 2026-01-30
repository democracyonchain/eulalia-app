import 'package:flutter/material.dart';
import 'package:eulalia_app/core/constants/app_colors.dart';
import 'package:eulalia_app/core/store/user_session.dart';
import 'dart:math';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Step 1 Data
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _idController = TextEditingController();
  final _pinController = TextEditingController();

  // Step 2 Data
  final List<String> _seedPhrase = [];
  bool _seedConfirmed = false;

  // Step 3 Data
  String _generatedDid = '';
  bool _isAnchoring = false;

  @override
  void initState() {
    super.initState();
    _generateSeedPhrase();
  }

  void _generateSeedPhrase() {
    final words = [
      'ocean',
      'mountain',
      'river',
      'forest',
      'sky',
      'cloud',
      'sun',
      'moon',
      'star',
      'earth',
      'wind',
      'fire',
      'water',
      'desert',
      'island',
      'valley',
      'light',
      'dark',
      'spirit',
      'nature',
      'life',
      'dream',
      'hope',
      'peace'
    ];
    final random = Random();
    for (int i = 0; i < 12; i++) {
      _seedPhrase.add(words[random.nextInt(words.length)]);
    }
  }

  void _generateDid() {
    final random = Random();
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    String suffix =
        List.generate(10, (index) => chars[random.nextInt(chars.length)])
            .join();
    _generatedDid = 'did:prism:$suffix';
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (_formKey.currentState!.validate()) {
        _pageController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut);
      }
    } else {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _startAnchoring() async {
    setState(() {
      _isAnchoring = true;
      _generateDid();
    });

    // Simulate blockchain latency
    await Future.delayed(const Duration(seconds: 4));

    if (mounted) {
      // Save to session
      UserSession().setIdentity(UserIdentity(
        name: _nameController.text,
        dni: _idController.text,
        pin: _pinController.text,
        did: _generatedDid,
        seedPhrase: _seedPhrase,
      ));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Identidad Digital Anclada Exitosamente!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pushReplacementNamed(context, '/wallet');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        title: Text('Paso ${_currentStep + 1} de 3',
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary)),
        centerTitle: true,
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (int page) => setState(() => _currentStep = page),
        children: [
          _buildStepForm(),
          _buildStepSeedPhrase(),
          _buildStepAnchoring(),
        ],
      ),
    );
  }

  // --- STEP 1: FORM ---
  Widget _buildStepForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Datos del Ciudadano',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            const Text('Comienza tu registro en la red nacional de identidad.',
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
            const SizedBox(height: 32),
            _buildTextField(
                label: 'Nombre Completo',
                controller: _nameController,
                icon: Icons.person_outline,
                hint: 'Ej. Juan Pérez'),
            const SizedBox(height: 20),
            _buildTextField(
                label: 'DNI',
                controller: _idController,
                icon: Icons.badge_outlined,
                hint: '8 dígitos',
                keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            _buildTextField(
                label: 'PIN de Transacción',
                controller: _pinController,
                icon: Icons.lock_outline,
                hint: '4 dígitos',
                isPassword: true,
                keyboardType: TextInputType.number),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Continuar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // --- STEP 2: SEED PHRASE ---
  Widget _buildStepSeedPhrase() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Llave Maestra',
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          const Text(
              'Estas 12 palabras son la única forma de recuperar tu identidad. Guárdalas en un lugar seguro.',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primaryBlue.withOpacity(0.1)),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(_seedPhrase.length, (index) {
                return Chip(
                  label: Text('${index + 1}. ${_seedPhrase[index]}'),
                  backgroundColor: AppColors.background,
                  side: BorderSide.none,
                );
              }),
            ),
          ),
          const Spacer(),
          CheckboxListTile(
            value: _seedConfirmed,
            onChanged: (val) => setState(() => _seedConfirmed = val!),
            title: const Text(
                'He guardado mi frase de recuperación en un lugar seguro.',
                style: TextStyle(fontSize: 14)),
            activeColor: AppColors.primaryBlue,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _seedConfirmed ? _nextStep : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Continuar',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // --- STEP 3: ANCHORING ---
  Widget _buildStepAnchoring() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!_isAnchoring) ...[
            const Icon(Icons.cloud_upload_outlined,
                size: 80, color: AppColors.primaryBlue),
            const SizedBox(height: 24),
            const Text('Listo para el anclaje',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text(
                'Vamos a registrar tu identidad digital en la red Identus usando blockchain.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: _startAnchoring,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Registrar en Blockchain',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ] else ...[
            const CircularProgressIndicator(
                strokeWidth: 6, color: AppColors.primaryBlue),
            const SizedBox(height: 32),
            const Text('Generando DID...',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(_generatedDid,
                style: const TextStyle(
                    fontFamily: 'monospace', color: AppColors.primaryBlue)),
            const SizedBox(height: 32),
            const Text('Iniciando consenso...',
                style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            const LinearProgressIndicator(
                backgroundColor: AppColors.background,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.success)),
          ],
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.primaryBlue),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
          validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
        ),
      ],
    );
  }
}
