import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../notifications_screen.dart';
import '../profile/unified_profile_screen.dart';
import 'request_history_screen.dart';
import 'supplier_dashboard.dart';
import 'supplier_requests_screen.dart';

class SupplierShell extends StatefulWidget {
  const SupplierShell({super.key});

  @override
  State<SupplierShell> createState() => _SupplierShellState();
}

class _SupplierShellState extends State<SupplierShell> {
  int _index = 0;

  final _pages = const [
    SupplierDashboard(),
    SupplierRequestsScreen(),
    RequestHistoryScreen(),
    UnifiedProfileScreen(),
    NotificationsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.cardBorder, width: 0.8)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavBarItem(
                  icon: Icons.dashboard_outlined,
                  activeIcon: Icons.dashboard_rounded,
                  label: 'Home',
                  isSelected: _index == 0,
                  onTap: () => setState(() => _index = 0),
                ),
                _NavBarItem(
                  icon: Icons.inbox_outlined,
                  activeIcon: Icons.inbox_rounded,
                  label: 'RFQs',
                  isSelected: _index == 1,
                  onTap: () => setState(() => _index = 1),
                ),
                _NavBarItem(
                  icon: Icons.history_rounded,
                  activeIcon: Icons.history_rounded,
                  label: 'History',
                  isSelected: _index == 2,
                  onTap: () => setState(() => _index = 2),
                ),
                _NavBarItem(
                  icon: Icons.person_outline_rounded,
                  activeIcon: Icons.person_rounded,
                  label: 'Profile',
                  isSelected: _index == 3,
                  onTap: () => setState(() => _index = 3),
                ),
                _NavBarItem(
                  icon: Icons.notifications_none_rounded,
                  activeIcon: Icons.notifications_rounded,
                  label: 'Alerts',
                  isSelected: _index == 4,
                  onTap: () => setState(() => _index = 4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppColors.primaryOrange : AppColors.textSecondary,
              size: 22,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? AppColors.primaryOrange : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
