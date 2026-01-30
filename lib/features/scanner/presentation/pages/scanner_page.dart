import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ScannerPage extends StatelessWidget {
  const ScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Simulated Scanner View
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primaryBlue, width: 4),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Center(
                    child: Container(
                      width: 200,
                      height: 2,
                      color: AppColors.primaryBlue.withOpacity(0.5),
                      // This could be animated in a real implementation
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                const Text(
                  'Escanea el código QR',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Alinea el código dentro del recuadro',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          // Back Button
          Positioned(
            top: 64,
            left: 24,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close, color: Colors.white, size: 32),
            ),
          ),
          // Flash Button
          Positioned(
            bottom: 64,
            left: 0,
            right: 0,
            child: Center(
              child: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.flash_on, color: Colors.white, size: 32),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
