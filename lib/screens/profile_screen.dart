import 'package:flutter/material.dart';

import 'profile/unified_profile_screen.dart';

/// Legacy alias forwarding directly to the modern UnifiedProfileScreen
/// to ensure 100% unified profile experience across all user roles.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    return const UnifiedProfileScreen();
  }
}
