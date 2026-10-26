import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../providers/app_data_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../admin/labour_form_screen.dart';
import '../notifications_screen.dart';
import '../profile/unified_profile_screen.dart';

class LabourDashboard extends StatelessWidget {
  const LabourDashboard({super.key});

  void _showSupervisorContactModal(BuildContext context, String supervisorName, String phone) {
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
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.pastelGreenBg,
                    child: const Icon(Icons.phone_in_talk_rounded, color: AppColors.pastelGreenText),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          supervisorName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryNavy,
                          ),
                        ),
                        Text(
                          'Site Supervisor • $phone',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.pastelGreenBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.call_rounded, color: AppColors.pastelGreenText),
                ),
                title: const Text('Direct Phone Call', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                subtitle: Text(phone, style: const TextStyle(fontSize: 12)),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Dialing $phone...'),
                      backgroundColor: const Color(0xFF16A34A),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF2563EB)),
                ),
                title: const Text('Send SMS / WhatsApp', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                subtitle: const Text('Message your supervisor about tasks or attendance', style: TextStyle(fontSize: 12)),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Opening chat with $supervisorName ($phone)...'),
                      backgroundColor: const Color(0xFF2563EB),
                      behavior: SnackBarBehavior.floating,
                    ),
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
    final user = context.watch<AuthProvider>().user!;
    final data = context.watch<AppDataProvider>();
    final labour = data.labourById(user.linkedId ?? '') ?? data.labours.firstOrNull;
    final site = labour?.currentSiteId == null ? null : data.siteById(labour!.currentSiteId!);
    final alerts = data.notificationsFor(user).take(3).toList();
    final unreadNotifs = alerts.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                // Top Header (Company Logo, Greeting, Notification Bell, User Avatar)
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.asset(
                                  'assets/images/company_logo.jpeg',
                                  width: 18,
                                  height: 18,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.apartment, size: 16),
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'Good Morning,',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${user.name} 👋',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Notification Bell with Red Badge
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const Icon(
                              Icons.notifications_none_rounded,
                              color: Color(0xFF0F172A),
                              size: 22,
                            ),
                            if (unreadNotifs > 0)
                              Positioned(
                                top: 7,
                                right: 7,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFEF4444),
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 14,
                                    minHeight: 14,
                                  ),
                                  child: Text(
                                    '$unreadNotifs',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // User Avatar with dropdown arrow
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const UnifiedProfileScreen()),
                        );
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundImage: user.avatarUrl != null
                                ? NetworkImage(user.avatarUrl!)
                                : null,
                            backgroundColor: AppColors.surfaceTint,
                            child: user.avatarUrl == null
                                ? Text(user.name.isNotEmpty ? user.name[0] : 'U',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))
                                : null,
                          ),
                          const SizedBox(width: 2),
                          const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Color(0xFF64748B)),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Incomplete Profile Reminder Banner (if skipped during signup)
                if (user.isProfileIncomplete) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.pastelAmberBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, color: AppColors.pastelAmberText, size: 18),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Complete your skills & wage details to get called by supervisors.',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF78350F)),
                          ),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const UnifiedProfileScreen()),
                            );
                          },
                          child: const Text(
                            'Update Now →',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primaryOrange),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Active Site Assignment Banner
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.cardBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: site != null ? AppColors.pastelGreenBg : AppColors.pastelOrangeBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  site != null ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                                  size: 13,
                                  color: site != null ? AppColors.pastelGreenText : AppColors.primaryOrange,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  site != null ? 'ACTIVE SITE ASSIGNMENT' : 'AVAILABLE FOR HIRE',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: site != null ? AppColors.pastelGreenText : AppColors.primaryOrange,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            labour != null ? 'LKR ${labour.dailyWage.toStringAsFixed(0)} / day' : 'LKR 3,500 / day',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF16A34A),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        site?.siteName ?? 'Northern Construction Region',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryNavy,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              site?.address ?? 'Jaffna District • Northern Province',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Site Supervisor', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                const SizedBox(height: 2),
                                Text(
                                  site?.supervisorName ?? 'K. Niroshan',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primaryNavy),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF16A34A),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              elevation: 0,
                            ),
                            icon: const Icon(Icons.phone_in_talk_rounded, size: 15),
                            label: const Text('Call Supervisor', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                            onPressed: () => _showSupervisorContactModal(
                              context,
                              site?.supervisorName ?? 'K. Niroshan',
                              site?.supervisorPhone ?? '0771234567',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 4 Metric Badges in 2x2 Grid (Pastel Theme)
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.pastelOrangeBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.handyman_rounded, color: AppColors.primaryOrange, size: 16),
                                SizedBox(width: 6),
                                Text('Trade Role', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF9A3412))),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              labour?.jobRole ?? 'Mason',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF7C2D12)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.pastelGreenBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.payments_outlined, color: AppColors.pastelGreenText, size: 16),
                                SizedBox(width: 6),
                                Text('Daily Wage', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.pastelGreenText)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              labour != null ? 'LKR ${labour.dailyWage.toStringAsFixed(0)}' : 'LKR 3,500',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF065F46)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.pastelBlueBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.verified_outlined, color: AppColors.pastelBlueText, size: 16),
                                SizedBox(width: 6),
                                Text('Status', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.pastelBlueText)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              labour?.status == LabourStatus.active ? 'Available' : 'Assigned',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF1E40AF)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.pastelPurpleBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.apartment_rounded, color: AppColors.pastelPurpleText, size: 16),
                                SizedBox(width: 6),
                                Text('Assigned Site', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.pastelPurpleText)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              site != null ? site.siteName.split(' ').first : 'General',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF5B21B6)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // My Profile & Skills Card with Direct Edit
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'My Trade & Skills Profile',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryNavy,
                            ),
                          ),
                          TextButton.icon(
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primaryOrange,
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            icon: const Icon(Icons.edit_outlined, size: 14),
                            label: const Text('Edit Profile', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => LabourFormScreen(labour: labour),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: (labour?.skills ?? ['Bricklaying', 'Plastering', 'Scaffolding', 'Concrete Works'])
                            .map((skill) => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceTint,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppColors.cardBorder),
                                  ),
                                  child: Text(
                                    skill,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primaryNavy,
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.phone_outlined, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 6),
                          Text(
                            labour?.phone ?? user.phone,
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                          const Spacer(),
                          const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            labour?.assignedLocation ?? 'Jaffna',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Recent Alerts & Site Updates
                const Text(
                  'Site Notices & Updates',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryNavy,
                  ),
                ),
                const SizedBox(height: 8),
                if (alerts.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: const Center(
                      child: Text('No active site alerts.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    ),
                  )
                else
                  ...alerts.map(
                    (n) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.pastelOrangeBg,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.campaign_outlined, size: 18, color: AppColors.primaryOrange),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  n.title,
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.primaryNavy),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  n.body,
                                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
