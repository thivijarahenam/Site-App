import 'package:flutter/material.dart';

import '../../models/models.dart';
import 'role_auth_screen.dart';

class RoleLandingScreen extends StatelessWidget {
  const RoleLandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                const SizedBox(height: 12),

                // Company Logo & Brand Header
                Center(
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.asset(
                        'assets/images/company_logo.jpeg',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFF0F172A),
                          child: const Icon(
                            Icons.apartment_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Ahenam Technology',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Civil Engineering & Site Operations',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF475569),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 26),

                // Main Section Heading
                const Text(
                  'Choose How You Want to Work',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Select your role to sign in or create an account with your trade profile',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 18),

                // 1. Work as Labour Card
                _RoleOptionCard(
                  role: UserRole.labour,
                  title: 'Work as a Labour',
                  badgeText: 'Workers & Trades',
                  description:
                      'Find site work, log daily attendance, track wages, and get assigned by site supervisors.',
                  icon: Icons.handyman_rounded,
                  accentColor: const Color(0xFFEA580C),
                  onTap: () => _openRoleAuth(context, UserRole.labour),
                ),

                const SizedBox(height: 12),

                // 2. Work as Supervisor Card
                _RoleOptionCard(
                  role: UserRole.supervisor,
                  title: 'Work as a Supervisor',
                  badgeText: 'Site Oversight & Diary',
                  description:
                      'Manage construction progress, log daily site diary entries, record materials, and call workforce.',
                  icon: Icons.assignment_ind_rounded,
                  accentColor: const Color(0xFF2563EB),
                  onTap: () => _openRoleAuth(context, UserRole.supervisor),
                ),

                const SizedBox(height: 12),

                // 3. Work as Supplier Card
                _RoleOptionCard(
                  role: UserRole.supplier,
                  title: 'Work as a Supplier',
                  badgeText: 'Materials & Equipment',
                  description:
                      'Receive live RFQs from contractors, submit instant price quotations, and schedule site deliveries.',
                  icon: Icons.local_shipping_rounded,
                  accentColor: const Color(0xFF0D9488),
                  onTap: () => _openRoleAuth(context, UserRole.supplier),
                ),

                const SizedBox(height: 12),

                // 4. Work as Admin Card
                _RoleOptionCard(
                  role: UserRole.admin,
                  title: 'Work as an Admin',
                  badgeText: 'Owner & Contractor',
                  description:
                      'Master project dashboard across all active sites, sub-contractors, budgets, and workforce approvals.',
                  icon: Icons.admin_panel_settings_rounded,
                  accentColor: const Color(0xFF0F172A),
                  onTap: () => _openRoleAuth(context, UserRole.admin),
                ),

                const SizedBox(height: 24),

                // Footer Trust Indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.shield_outlined,
                        size: 14, color: Color(0xFF94A3B8)),
                    SizedBox(width: 6),
                    Text(
                      'Secure Site Access • Northern & Western Province',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openRoleAuth(BuildContext context, UserRole role) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RoleAuthScreen(selectedRole: role),
      ),
    );
  }
}

class _RoleOptionCard extends StatelessWidget {
  final UserRole role;
  final String title;
  final String badgeText;
  final String description;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;

  const _RoleOptionCard({
    required this.role,
    required this.title,
    required this.badgeText,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              children: [
                // Clean subtle left accent bar (3.5px)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 3.5,
                    color: accentColor,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: const Color(0xFFE2E8F0)),
                            ),
                            child: Icon(icon, color: accentColor, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0F172A),
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    badgeText,
                                    style: const TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF475569),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: const Color(0xFFE2E8F0)),
                            ),
                            child: const Icon(
                              Icons.chevron_right_rounded,
                              size: 18,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF64748B),
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
