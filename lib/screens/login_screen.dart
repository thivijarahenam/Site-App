import 'package:flutter/material.dart';

import 'auth/role_landing_screen.dart';

/// App Entry Authentication Screen
/// Displays the modern role selection landing screen:
/// "Work as a Labour", "Work as a Supervisor", "Work as a Supplier", "Work as an Admin"
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const RoleLandingScreen();
  }
}
