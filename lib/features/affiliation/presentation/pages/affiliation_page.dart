import 'package:eulalia_app/core/constants/app_colors.dart';
import 'package:eulalia_app/core/store/user_session.dart';
import 'package:eulalia_app/features/affiliation/data/models/afiliacion_model.dart';
import 'package:eulalia_app/features/affiliation/data/models/organizacion_model.dart';
import 'package:eulalia_app/features/affiliation/data/services/afiliacion_service.dart';
import 'package:eulalia_app/features/affiliation/data/services/organizacion_service.dart';
import 'package:eulalia_app/features/auth/data/models/registro_estado_model.dart';
import 'package:eulalia_app/features/auth/data/services/registro_estado_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class AffiliationPage extends StatefulWidget {
  const AffiliationPage({super.key});

  @override
  State<AffiliationPage> createState() => _AffiliationPageState();
}

class _AffiliationPageState extends State<AffiliationPage> {
  final TextEditingController _searchController = TextEditingController();
  final AfiliacionService _afiliacionService = AfiliacionService();
  final OrganizacionService _organizacionService = OrganizacionService();
  final RegistroEstadoService _registroEstadoService = RegistroEstadoService();

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
  bool _submitting = false;
  String? _submissionLabel;
  String? _error;
  RegistroEstadoDto? _estadoRegistro;
  int? _activeAffiliacionId;
  int? _affiliatedOrganizacionId;
  List<OrganizacionDto> _organizaciones = [];
  List<AfiliacionDto> _afiliaciones = [];

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
        _registroEstadoService.getStatus(dni),
      ]);

      final organizaciones = results[0] as List<OrganizacionDto>;
      final afiliaciones = results[1] as List<AfiliacionDto>;
      final estado = results[2] as RegistroEstadoDto;

      final activa =
          afiliaciones.where((a) => a.cedula == dni && a.estado != 'Anulado');

      setState(() {
        _organizaciones = organizaciones
            .where((o) => o.estado.toLowerCase() == 'aprobado')
            .toList();
        _afiliaciones = afiliaciones.where((a) => a.cedula == dni).toList();
        _estadoRegistro = estado;
        _error = null;
        if (activa.isNotEmpty) {
          _activeAffiliacionId = activa.first.afiliacionId;
          _affiliatedOrganizacionId = activa.first.organizacionId;
        }
      });
    } catch (e) {
      setState(() => _error = _cleanError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _cleanError(Object error) {
    final message = error.toString();
    return message.startsWith('Exception: ')
        ? message.substring('Exception: '.length)
        : message;
  }

  bool get _readyForAffiliation => _estadoRegistro?.readyForAffiliation == true;

  String _missingPrerequisites() {
    final estado = _estadoRegistro;
    if (estado == null) return 'No se pudo confirmar el estado del registro.';
    final missing = <String>[];
    if (!estado.baseOk) missing.add('registro base');
    if (!estado.ssiOk) missing.add('wallet SSI');
    if (!estado.bioOk) missing.add('biometría');
    return missing.isEmpty
        ? 'El registro aún no está habilitado para afiliación.'
        : 'Complete: ${missing.join(', ')}.';
  }

  void _showConfirmationDialog(OrganizacionDto org, bool isAffiliating) {
    if (isAffiliating && !_readyForAffiliation) {
      _showMessage(_missingPrerequisites(), isError: true);
      return;
    }
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
    if (isAffiliating && !_readyForAffiliation) {
      _showMessage(_missingPrerequisites(), isError: true);
      return;
    }

    if (_submitting) return;
    setState(() {
      _submitting = true;
      _submissionLabel = isAffiliating
          ? 'Registrando afiliación...'
          : 'Anulando afiliación...';
    });
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
          _afiliaciones = [
            ..._afiliaciones
                .where((a) => a.afiliacionId != created.afiliacionId),
            created,
          ];
        });
        _showMessage(
            _successMessage('Afiliación registrada en ${org.nombre}', created));
      } else {
        if (_activeAffiliacionId == null) {
          _showMessage('No existe afiliación activa para anular',
              isError: true);
          return;
        }

        final cancelled =
            await _afiliacionService.cancel(_activeAffiliacionId!);
        setState(() {
          _activeAffiliacionId = null;
          _affiliatedOrganizacionId = null;
          _afiliaciones = [
            ..._afiliaciones.map((a) =>
                a.afiliacionId == cancelled.afiliacionId ? cancelled : a),
          ];
        });
        _showMessage(_successMessage(
            'Afiliación anulada para ${org.nombre}', cancelled));
      }
    } catch (e) {
      _showMessage(_cleanError(e), isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
          _submissionLabel = null;
        });
      }
    }
  }

  String _successMessage(String message, AfiliacionDto affiliation) {
    final status = affiliation.cardanoStatus;
    if (status == null) return message;
    final blockchain = status == 'confirmed'
        ? 'Cardano: confirmado'
        : status == 'submitted'
            ? 'Cardano: enviado, pendiente de confirmación'
            : status == 'failed'
                ? 'Cardano: no disponible, operación local conservada'
                : 'Cardano: pendiente de confirmación';
    final tx = affiliation.cardanoTxHash;
    return tx == null
        ? '$message. $blockchain.'
        : '$message. $blockchain. TX: $tx';
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

  void _showOrganizationHistory(OrganizacionDto org) {
    final history = _afiliaciones
        .where((a) => a.organizacionId == org.organizacionId)
        .toList()
      ..sort((a, b) => b.fechaAfiliacion.compareTo(a.fechaAfiliacion));

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.8,
            ),
            child: ListView(
              shrinkWrap: true,
              children: [
                Text(
                  'Historial de ${org.nombre}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Eventos de afiliación de este ciudadano. Red Cardano: Preview.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),
                if (history.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Column(
                      children: [
                        Icon(Icons.history,
                            size: 42, color: AppColors.textSecondary),
                        SizedBox(height: 12),
                        Text('No hay eventos para esta organización.'),
                      ],
                    ),
                  )
                else
                  ...history.map(_buildHistoryEvent),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryEvent(AfiliacionDto affiliation) {
    final eventType = affiliation.cardanoEventType ??
        (affiliation.estado.toLowerCase() == 'anulado'
            ? 'cancellation'
            : 'affiliation');
    final eventLabel =
        eventType == 'cancellation' ? 'Cancelación' : 'Afiliación';
    final cardanoStatus = affiliation.cardanoStatus ?? 'No disponible';
    final txHash = affiliation.cardanoTxHash;
    final explorerUrl = txHash == null
        ? null
        : Uri.parse('https://preview.cardanoscan.io/transaction/$txHash');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(eventLabel,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(_formatDate(affiliation.fechaAfiliacion),
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(height: 12),
            _historyRow('Estado local', affiliation.estado),
            _historyRow('Estado Cardano', cardanoStatus),
            if (txHash != null) ...[
              const SizedBox(height: 8),
              const Text('TX hash',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary)),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SelectableText(
                      txHash,
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Copiar TX hash',
                    icon: const Icon(Icons.copy, size: 18),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: txHash));
                      _showMessage('TX hash copiado');
                    },
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: () async {
                  if (explorerUrl != null &&
                      !await launchUrl(
                        explorerUrl,
                        mode: LaunchMode.externalApplication,
                      )) {
                    if (mounted) {
                      _showMessage('No se pudo abrir Cardanoscan',
                          isError: true);
                    }
                  }
                },
                icon: const Icon(Icons.open_in_new, size: 18),
                label: const Text('Ver en Cardanoscan Preview'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _historyRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 118,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    return '${twoDigits(local.day)}/${twoDigits(local.month)}/${local.year} '
        '${twoDigits(local.hour)}:${twoDigits(local.minute)}';
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
          if (_error != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: MaterialBanner(
                content: Text(_error!),
                leading: const Icon(Icons.error_outline),
                actions: [
                  TextButton(
                      onPressed: _loadData, child: const Text('Reintentar')),
                ],
              ),
            ),
          if (_estadoRegistro != null && !_readyForAffiliation)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, color: AppColors.warning),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Afiliación bloqueada. ${_missingPrerequisites()}',
                      style: const TextStyle(color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: TextField(
              enabled: !_loading && !_submitting,
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
                : _submitting
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 16),
                            Text(_submissionLabel ?? 'Procesando...'),
                          ],
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.all(24),
                        children:
                            filtered.toList().asMap().entries.map((entry) {
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
                                      color: color.withValues(alpha: 0.5),
                                      width: 2)
                                  : null,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Semantics(
                                  button: true,
                                  label: 'Ver historial de ${org.nombre}',
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () => _showOrganizationHistory(org),
                                    child: Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 56,
                                            height: 56,
                                            decoration: BoxDecoration(
                                              color:
                                                  color.withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Icon(icon,
                                                color: color, size: 28),
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
                                                    color:
                                                        AppColors.textPrimary,
                                                  ),
                                                ),
                                                Text(
                                                  'Tipo: ${org.tipo}',
                                                  style: const TextStyle(
                                                      fontSize: 13,
                                                      color: AppColors
                                                          .textSecondary),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (isAffiliated)
                                            const Icon(Icons.check_circle,
                                                color: AppColors.success,
                                                size: 20),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: isAffiliated
                                      ? OutlinedButton(
                                          onPressed: _submitting
                                              ? null
                                              : () => _showConfirmationDialog(
                                                  org, false),
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
                                          onPressed: !_submitting &&
                                                  _affiliatedOrganizacionId ==
                                                      null &&
                                                  _readyForAffiliation
                                              ? () => _showConfirmationDialog(
                                                  org, true)
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
