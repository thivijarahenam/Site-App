import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../marketplace/marketplace_screen.dart';
import '../more/more_screen.dart';
import 'admin_dashboard.dart';
import 'labour_form_screen.dart';
import 'material_request_form_screen.dart';
import 'site_form_screen.dart';
import 'sites_screen.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _index = 0;

  final _pages = const [
    AdminDashboard(),
    SitesScreen(),
    MarketplaceScreen(),
    MoreScreen(),
  ];

  void _showQuickCreateModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.cardBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryNavy,
                ),
              ),
              const SizedBox(height: 14),
              ListTile(
                leading: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.pastelOrangeBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.note_add_outlined,
                      color: AppColors.primaryOrange),
                ),
                title: const Text('New Material Request (RFQ)',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                subtitle: const Text('Request quotations from local suppliers',
                    style: TextStyle(fontSize: 11)),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const MaterialRequestFormScreen()),
                  );
                },
              ),
              ListTile(
                leading: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.pastelGreenBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.person_add_alt_outlined,
                      color: AppColors.pastelGreenText),
                ),
                title: const Text('Register New Labour',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                subtitle: const Text('Add mason, carpenter, or helper to workforce',
                    style: TextStyle(fontSize: 11)),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LabourFormScreen()),
                  );
                },
              ),
              ListTile(
                leading: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.pastelBlueBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.add_business_outlined,
                      color: AppColors.pastelBlueText),
                ),
                title: const Text('Create Construction Site',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                subtitle: const Text('Start new project ledger, budget & tracking',
                    style: TextStyle(fontSize: 11)),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SiteFormScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                  icon: Icons.apartment_outlined,
                  activeIcon: Icons.apartment_rounded,
                  label: 'Projects',
                  isSelected: _index == 1,
                  onTap: () => setState(() => _index = 1),
                ),
                // Center Elevated '+' Action
                InkWell(
                  onTap: () => _showQuickCreateModal(context),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primaryOrange,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryOrange.withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
                  ),
                ),
                _NavBarItem(
                  icon: Icons.storefront_outlined,
                  activeIcon: Icons.storefront_rounded,
                  label: 'Market',
                  isSelected: _index == 2,
                  onTap: () => setState(() => _index = 2),
                ),
                _NavBarItem(
                  icon: Icons.more_horiz_rounded,
                  activeIcon: Icons.more_horiz_rounded,
                  label: 'More',
                  isSelected: _index == 3,
                  onTap: () => setState(() => _index = 3),
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppColors.primaryOrange : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
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
