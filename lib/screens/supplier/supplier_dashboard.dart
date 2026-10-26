import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../providers/app_data_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../notifications_screen.dart';
import '../profile/unified_profile_screen.dart';
import 'quotation_form_screen.dart';

class SupplierDashboard extends StatelessWidget {
  const SupplierDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user!;
    final data = context.watch<AppDataProvider>();
    final supplierId = user.linkedId ?? '';
    final company = data.supplierById(supplierId);
    final mine = data.requestsForSupplier(supplierId);
    final newOnes = mine
        .where((r) =>
            r.status == MaterialRequestStatus.awaitingResponse &&
            r.response == null)
        .toList();
    final submitted = mine.where((r) => r.response != null).toList();
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

                // Supplier Business Card
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
                              color: AppColors.pastelGreenBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.verified_rounded, size: 13, color: AppColors.pastelGreenText),
                                SizedBox(width: 5),
                                Text(
                                  'REGISTERED MATERIAL SUPPLIER',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.pastelGreenText,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            company?.contactPerson ?? 'Nimal Fernando',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        company?.companyName ?? 'Lanka Cement & Steel Trading',
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
                              company?.address ?? 'KKS Road, Chunnakam, Jaffna',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                      if (company != null && company.materialsSupplied.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: company.materialsSupplied
                              .map((m) => Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceTint,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: AppColors.cardBorder),
                                    ),
                                    child: Text(m, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                                  ))
                              .toList(),
                        ),
                      ],
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
                                Icon(Icons.mark_email_unread_outlined, color: AppColors.primaryOrange, size: 16),
                                SizedBox(width: 6),
                                Text('New RFQs', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF9A3412))),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${newOnes.length}',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF7C2D12)),
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
                                Icon(Icons.task_alt_rounded, color: AppColors.pastelGreenText, size: 16),
                                SizedBox(width: 6),
                                Text('Quotes Sent', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.pastelGreenText)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${submitted.length}',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF065F46)),
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
                                Icon(Icons.inventory_2_outlined, color: AppColors.pastelBlueText, size: 16),
                                SizedBox(width: 6),
                                Text('Total RFQs', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.pastelBlueText)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${mine.length}',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1E40AF)),
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
                                Icon(Icons.local_shipping_outlined, color: AppColors.pastelPurpleText, size: 16),
                                SizedBox(width: 6),
                                Text('Active Orders', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.pastelPurpleText)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              '3 Active',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF5B21B6)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // RFQs Needing Quotation Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Needs Your Quotation',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.pastelOrangeBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${newOnes.length} Pending',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primaryOrange),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (newOnes.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: const Center(
                      child: Text('No open material RFQs right now.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    ),
                  )
                else
                  ...newOnes.map((req) {
                    final site = data.siteById(req.siteId);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.cardBorder),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.pastelAmberBg,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.category_outlined, color: AppColors.pastelAmberText, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      req.materialName,
                                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.primaryNavy),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Quantity: ${req.requiredQuantity} ${req.unit}',
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF16A34A)),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.pastelOrangeBg,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'Awaiting Quote',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primaryOrange),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceTint,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.apartment_rounded, size: 14, color: AppColors.textSecondary),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    site?.siteName ?? 'Construction Site',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryNavy),
                                  ),
                                ),
                                const Icon(Icons.event_outlined, size: 14, color: AppColors.textSecondary),
                                const SizedBox(width: 4),
                                Text(
                                  'Req: ${dateFmt.format(req.requiredDate)}',
                                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryOrange,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 11),
                                elevation: 0,
                              ),
                              icon: const Icon(Icons.send_rounded, size: 15),
                              label: const Text('Submit Quotation', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => QuotationFormScreen(requestId: req.id),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
