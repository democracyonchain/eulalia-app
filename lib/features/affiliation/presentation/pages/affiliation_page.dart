import 'package:eulalia_app/core/constants/app_colors.dart';
import 'package:eulalia_app/core/store/user_session.dart';
import 'package:eulalia_app/features/affiliation/data/models/afiliacion_model.dart';
import 'package:eulalia_app/features/affiliation/data/models/organizacion_model.dart';
import 'package:eulalia_app/features/affiliation/data/services/afiliacion_service.dart';
import 'package:eulalia_app/features/affiliation/data/services/organizacion_service.dart';
import 'package:flutter/material.dart';

class AffiliationPage extends StatefulWidget {
  const AffiliationPage({super.key});

  @override
  State<AffiliationPage> createState() => _AffiliationPageState();
}

class _AffiliationPageState extends State<AffiliationPage> {
  final TextEditingController _searchController = TextEditingController();
  final AfiliacionService _afiliacionService = AfiliacionService();
  final OrganizacionService _organizacionService = OrganizacionService();

  final List<Color> _palette = [
    AppColors.primaryBlue,
    AppColors.success,
    AppColors.warning,
    AppColors.error,
    Colors.indigo,
    Colors.teal,
  ];

  final List<IconData> _icons = [
    Icons.shield,
    Icons.groups,
    Icons.how_to_vote,
    Icons.account_balance,
    Icons.public,
    Icons.campaign,
  ];

  String _searchQuery = '';
  bool _loading = false;
  int? _activeAffiliacionId;
  int? _affiliatedOrganizacionId;
  List<OrganizacionDto> _organizaciones = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final dni = UserSession().currentIdentity?.dni;
    if (dni == null) return;

    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        _organizacionService.getAll(),
        _afiliacionService.getAll(),
      ]);

      final organizaciones = results[0] as List<OrganizacionDto>;
      final afiliaciones = results[1] as List<AfiliacionDto>;

      final activa =
          afiliaciones.where((a) => a.cedula == dni && a.estado != 'Anulado');

      setState(() {
        _organizaciones = organizaciones
            .where((o) => o.estado.toLowerCase() == 'aprobado')
            .toList();
        if (activa.isNotEmpty) {
          _activeAffiliacionId = activa.first.afiliacionId;
          _affiliatedOrganizacionId = activa.first.organizacionId;
        }
      });
    } catch (e) {
      _showMessage(e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showConfirmationDialog(OrganizacionDto org, bool isAffiliating) {
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isAffiliating ? 'Confirmar Afiliación' : 'Confirmar Desafiliación',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isAffiliating
                  ? '¿Está seguro que desea afiliarse a ${org.nombre}?'
                  : '¿Está seguro que desea desafiliarse de ${org.nombre}?',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            const Text(
              'PIN de Transacción',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Ingrese su PIN',
                filled: true,
                fillColor: Colors.black.withValues(alpha: 0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              final expectedPin = UserSession().currentIdentity?.pin;
              if (expectedPin != null &&
                  passwordController.text == expectedPin) {
                Navigator.pop(context);
                _executeAction(org, isAffiliating);
              } else {
                _showMessage('PIN de transacción incorrecto', isError: true);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isAffiliating ? AppColors.primaryBlue : AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(isAffiliating ? 'Confirmar' : 'Desafiliar'),
          ),
        ],
      ),
    );
  }

  Future<void> _executeAction(OrganizacionDto org, bool isAffiliating) async {
    final dni = UserSession().currentIdentity?.dni;
    if (dni == null) {
      _showMessage('No hay sesión activa de ciudadano', isError: true);
      return;
    }

    setState(() => _loading = true);
    try {
      if (isAffiliating) {
        final created = await _afiliacionService.create(
          CreateAfiliacionRequest(
            cedula: dni,
            organizacionId: org.organizacionId,
          ),
        );

        setState(() {
          _affiliatedOrganizacionId = org.organizacionId;
          _activeAffiliacionId = created.afiliacionId;
        });
        _showMessage('Afiliación registrada en ${org.nombre}');
      } else {
        if (_activeAffiliacionId == null) {
          _showMessage('No existe afiliación activa para anular',
              isError: true);
          return;
        }

        await _afiliacionService.cancel(_activeAffiliacionId!);
        setState(() {
          _activeAffiliacionId = null;
          _affiliatedOrganizacionId = null;
        });
        _showMessage('Afiliación anulada para ${org.nombre}');
      }
    } catch (e) {
      _showMessage(e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _organizaciones.where((o) =>
        o.nombre.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        o.tipo.toLowerCase().contains(_searchQuery.toLowerCase()));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Afiliación Política',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: TextField(
              enabled: !_loading,
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Buscar organización...',
                prefixIcon:
                    const Icon(Icons.search, color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.all(24),
                    children: filtered.toList().asMap().entries.map((entry) {
                      final idx = entry.key;
                      final org = entry.value;
                      final color = _palette[idx % _palette.length];
                      final icon = _icons[idx % _icons.length];
                      final isAffiliated =
                          _affiliatedOrganizacionId == org.organizacionId;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: isAffiliated
                              ? Border.all(
                                  color: color.withValues(alpha: 0.5), width: 2)
                              : null,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(icon, color: color, size: 28),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        org.nombre,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        'Tipo: ${org.tipo}',
                                        style: const TextStyle(
                                            fontSize: 13,
                                            color: AppColors.textSecondary),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isAffiliated)
                                  const Icon(Icons.check_circle,
                                      color: AppColors.success, size: 20),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: isAffiliated
                                  ? OutlinedButton(
                                      onPressed: () =>
                                          _showConfirmationDialog(org, false),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.error,
                                        side: const BorderSide(
                                            color: AppColors.error),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                      ),
                                      child: const Text('Desafiliarse',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    )
                                  : ElevatedButton(
                                      onPressed: _affiliatedOrganizacionId ==
                                              null
                                          ? () =>
                                              _showConfirmationDialog(org, true)
                                          : null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: color,
                                        foregroundColor: Colors.white,
                                        disabledBackgroundColor:
                                            AppColors.surface,
                                        disabledForegroundColor: AppColors
                                            .textSecondary
                                            .withValues(alpha: 0.5),
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                      ),
                                      child: const Text('Afiliarse',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    ),
                            )
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}
