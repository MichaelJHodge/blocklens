import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/wallet/presentation/screens/wallet_input_screen.dart';

class WalletExplainApp extends StatelessWidget {
  const WalletExplainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wallet Explain',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const WalletInputScreen(),
    );
  }
}
