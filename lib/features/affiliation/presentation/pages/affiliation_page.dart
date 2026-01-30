import 'package:flutter/material.dart';
import 'package:eulalia_app/core/constants/app_colors.dart';

class AffiliationPage extends StatefulWidget {
  const AffiliationPage({super.key});

  @override
  State<AffiliationPage> createState() => _AffiliationPageState();
}

class _AffiliationPageState extends State<AffiliationPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Static data for demonstration
  final List<Map<String, dynamic>> _allParties = [
    {
      'id': '1',
      'name': 'Partido Demócrata',
      'description': 'Libertad y progreso para todos los ciudadanos.',
      'color': AppColors.primaryBlue,
      'imagePath': 'assets/images/logos/logo_democrata.png',
      'icon': Icons.shield,
    },
    {
      'id': '2',
      'name': 'Unión Nacional',
      'description': 'Comprometidos con la unidad y el desarrollo sostenible.',
      'color': AppColors.success,
      'icon': Icons.eco,
    },
    {
      'id': '3',
      'name': 'Frente Progresista',
      'description': 'Innovación social y justicia para el pueblo.',
      'color': AppColors.error,
      'icon': Icons.account_balance_rounded,
    },
    {
      'id': '4',
      'name': 'Alianza Ciudadana',
      'description': 'Transparencia y rendición de cuentas.',
      'color': AppColors.warning,
      'icon': Icons.groups,
    },
    {
      'id': '5',
      'name': 'Movimiento Futuro',
      'description': 'Tecnología y ecología para las nuevas generaciones.',
      'color': Colors.purple,
      'icon': Icons.auto_awesome,
    },
  ];

  String? _affiliatedPartyId = '1'; // Initially affiliated to '1'

  void _showConfirmationDialog(Map<String, dynamic> party, bool isAffiliating) {
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
                  ? '¿Está seguro que desea afiliarse a ${party['name']}?'
                  : '¿Está seguro que desea desafiliarse de ${party['name']}?',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            const Text(
              'Contraseña de Transacción',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Ingrese su PIN',
                filled: true,
                fillColor: Colors.black.withOpacity(0.05),
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
              if (passwordController.text == '1234') {
                Navigator.pop(context);
                _executeAction(party['id'], isAffiliating);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Contraseña incorrecta. Intente con 1234'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isAffiliating ? party['color'] : AppColors.error,
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

  void _executeAction(String partyId, bool isAffiliating) {
    setState(() {
      if (isAffiliating) {
        _affiliatedPartyId = partyId;
      } else {
        _affiliatedPartyId = null;
      }
    });

    final partyName = _allParties.firstWhere((p) => p['id'] == partyId)['name'];
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isAffiliating
            ? 'Te has afiliado exitosamente a $partyName'
            : 'Has cancelado tu afiliación a $partyName'),
        backgroundColor:
            isAffiliating ? AppColors.success : AppColors.textSecondary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredParties = _allParties.where((party) {
      return party['name'].toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

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
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Buscar partido...',
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
            child: ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: filteredParties.length,
              itemBuilder: (context, index) {
                final party = filteredParties[index];
                return _buildPartyCard(party);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartyCard(Map<String, dynamic> party) {
    final bool isThisAffiliated = _affiliatedPartyId == party['id'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: isThisAffiliated
            ? Border.all(color: party['color'].withOpacity(0.5), width: 2)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: party['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: party['imagePath'] != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          party['imagePath'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                              party['icon'],
                              color: party['color'],
                              size: 30),
                        ),
                      )
                    : Icon(party['icon'], color: party['color'], size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            party['name'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (isThisAffiliated) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.check_circle,
                              color: AppColors.success, size: 18),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      party['description'],
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: isThisAffiliated
                ? OutlinedButton(
                    onPressed: () => _showConfirmationDialog(party, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Desafiliarse',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  )
                : ElevatedButton(
                    onPressed: _affiliatedPartyId == null
                        ? () => _showConfirmationDialog(party, true)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: party['color'],
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppColors.surface,
                      disabledForegroundColor:
                          AppColors.textSecondary.withOpacity(0.5),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Afiliarse',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
          ),
        ],
      ),
    );
  }
}
