import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/models.dart';
import 'providers/app_data_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/admin/admin_shell.dart';
import 'screens/labour/labour_shell.dart';
import 'screens/login_screen.dart';
import 'screens/supplier/supplier_shell.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SiteApp());
}

class SiteApp extends StatelessWidget {
  const SiteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AppDataProvider()),
      ],
      child: MaterialApp(
        title: 'Ahenam',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const RootGate(),
      ),
    );
  }
}

/// Routes to the correct dashboard from the logged-in user's role.
class RootGate extends StatelessWidget {
  const RootGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.isLoggedIn || auth.user == null) {
      return const LoginScreen(key: ValueKey('login'));
    }

    final user = auth.user!;
    switch (user.role) {
      case UserRole.admin:
      case UserRole.supervisor:
        return AdminShell(key: ValueKey('shell-${user.id}'));
      case UserRole.labour:
        return LabourShell(key: ValueKey('shell-${user.id}'));
      case UserRole.supplier:
      case UserRole.foodSupplier:
        return SupplierShell(key: ValueKey('shell-${user.id}'));
    }
  }
}
