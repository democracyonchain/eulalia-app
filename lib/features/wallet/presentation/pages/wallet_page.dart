import 'package:eulalia_app/core/constants/app_colors.dart';
import 'package:eulalia_app/core/store/user_session.dart';
import 'package:eulalia_app/features/affiliation/data/services/afiliacion_service.dart';
import 'package:eulalia_app/features/affiliation/data/services/organizacion_service.dart';
import 'package:eulalia_app/features/auth/data/models/registro_estado_model.dart';
import 'package:eulalia_app/features/auth/data/services/registro_estado_service.dart';
import 'package:flutter/material.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  final _registroEstadoService = RegistroEstadoService();
  final _afiliacionService = AfiliacionService();
  final _organizacionService = OrganizacionService();

  RegistroEstadoDto? _estado;
  String? _organizacionNombre;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadWalletData();
  }

  Future<void> _loadWalletData() async {
    final identity = UserSession().currentIdentity;
    if (identity == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    try {
      final status = await _registroEstadoService.getStatus(identity.dni);
      final afiliaciones = await _afiliacionService.getAll();
      final organizaciones = await _organizacionService.getAll();

      final activa = afiliaciones
          .where((a) => a.cedula == identity.dni && a.estado != 'Anulado');
      String? nombreOrg;
      if (activa.isNotEmpty) {
        final orgId = activa.first.organizacionId;
        final org = organizaciones.where((o) => o.organizacionId == orgId);
        if (org.isNotEmpty) {
          nombreOrg = org.first.nombre;
        }
      }

      if (mounted) {
        setState(() {
          _estado = status;
          _organizacionNombre = nombreOrg;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final identity = UserSession().currentIdentity;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mi Billetera',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/scanner'),
            icon:
                const Icon(Icons.qr_code_scanner, color: AppColors.primaryBlue),
          ),
          IconButton(
            onPressed: () {
              UserSession().logout();
              Navigator.pushReplacementNamed(context, '/');
            },
            icon: const Icon(Icons.logout, color: AppColors.error),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(24.0),
              children: [
                _buildIdentityCard(identity),
                const SizedBox(height: 32),
                const Text(
                  'Credenciales Disponibles',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/affiliation'),
                  child: _buildCredentialItem(
                    'Afiliación Política',
                    _organizacionNombre ?? 'SIN AFILIACIÓN ACTIVA',
                    Icons.how_to_reg,
                    AppColors.primaryBlue,
                  ),
                ),
                _buildCredentialItem(
                  'Estado SSI',
                  _estado?.ssiStatus ?? 'NotStarted',
                  Icons.verified_user,
                  _estado?.ssiOk == true
                      ? AppColors.success
                      : AppColors.warning,
                ),
                _buildCredentialItem(
                  'Estado Biométrico',
                  _estado?.bioStatus ?? 'not_started',
                  Icons.face,
                  _estado?.bioOk == true ? AppColors.success : Colors.orange,
                ),
              ],
            ),
    );
  }

  Widget _buildIdentityCard(UserIdentity? identity) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.shield, color: Colors.white, size: 30),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _estado?.readyForAffiliation == true
                      ? 'Registro 360 Completo'
                      : 'Registro 360 En Proceso',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Text(
            identity?.name.toUpperCase() ?? 'CIUDADANO',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            identity?.did ?? 'did:prism:pending',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 12,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCardStat('DNI', identity?.dni ?? '-'),
              _buildCardStat(
                  'ESTADO',
                  _estado?.readyForAffiliation == true
                      ? 'ACTIVO'
                      : 'PENDIENTE'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCredentialItem(
      String title, String subtitle, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right,
              color: AppColors.textSecondary.withValues(alpha: 0.3)),
        ],
      ),
    );
  }
}
