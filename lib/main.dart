import 'package:flutter/material.dart';
import 'package:eulalia_app/core/constants/app_colors.dart';
import 'package:eulalia_app/features/auth/presentation/pages/login_page.dart';
import 'package:eulalia_app/features/wallet/presentation/pages/wallet_page.dart';
import 'package:eulalia_app/features/scanner/presentation/pages/scanner_page.dart';
import 'package:eulalia_app/features/auth/presentation/pages/register_page.dart';
import 'package:eulalia_app/features/affiliation/presentation/pages/affiliation_page.dart';

void main() {
  runApp(const EulaliaApp());
}

class EulaliaApp extends StatelessWidget {
  const EulaliaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eulalia',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryBlue,
          primary: AppColors.primaryBlue,
          background: AppColors.background,
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/wallet': (context) => const WalletPage(),
        '/scanner': (context) => const ScannerPage(),
        '/affiliation': (context) => const AffiliationPage(),
      },
    );
  }
}
