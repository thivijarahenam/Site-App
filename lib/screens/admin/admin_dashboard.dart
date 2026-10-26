import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_data_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/dashboard_widgets.dart';
import '../marketplace/marketplace_screen.dart';
import '../notifications_screen.dart';
import '../profile/unified_profile_screen.dart';
import '../project/project_logbook_screen.dart';
import 'labour_form_screen.dart';
import 'labours_screen.dart';
import 'material_request_form_screen.dart';
import 'site_form_screen.dart';
import 'sites_screen.dart';
import 'supplier_form_screen.dart';
import 'suppliers_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user!;
    final data = context.watch<AppDataProvider>();
    final primarySite = data.sites.isNotEmpty ? data.sites.first : null;
    final unreadNotifs = data.notificationsFor(user).where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Top Bar with Greeting, Logo, Notifications, and Profile Avatar
              SliverToBoxAdapter(
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Greeting and Name
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
                                      unreadNotifs > 0 ? '$unreadNotifs' : '3',
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
                                    ? Text(user.name[0], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))
                                    : null,
                              ),
                              const SizedBox(width: 2),
                              const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Color(0xFF64748B)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 6 Metric Cards (3 Columns × 2 Rows)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
                sliver: SliverGrid.count(
                  crossAxisCount: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.05,
                  children: [
                    PastelMetricCard(
                      title: 'Projects',
                      value: '${data.sites.length}',
                      icon: Icons.apartment_rounded,
                      iconColor: const Color(0xFF2563EB),
                      iconBgColor: const Color(0xFFEFF6FF),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SitesScreen()),
                        );
                      },
                    ),
                    PastelMetricCard(
                      title: 'Employees',
                      value: '${data.labours.length}',
                      icon: Icons.person_rounded,
                      iconColor: const Color(0xFF10B981),
                      iconBgColor: const Color(0xFFECFDF5),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const LaboursScreen()),
                        );
                      },
                    ),
                    PastelMetricCard(
                      title: 'Sub Contractors',
                      value: '${data.suppliers.length}',
                      icon: Icons.groups_rounded,
                      iconColor: const Color(0xFF8B5CF6),
                      iconBgColor: const Color(0xFFF5F3FF),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SuppliersScreen()),
                        );
                      },
                    ),
                    PastelMetricCard(
                      title: 'Material Suppliers',
                      value: '${data.suppliers.length}',
                      icon: Icons.local_shipping_rounded,
                      iconColor: const Color(0xFFF97316),
                      iconBgColor: const Color(0xFFFFF7ED),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SuppliersScreen()),
                        );
                      },
                    ),
                    PastelMetricCard(
                      title: 'Rental Providers',
                      value: '${data.rentals.length}',
                      icon: Icons.precision_manufacturing_rounded,
                      iconColor: const Color(0xFFF59E0B),
                      iconBgColor: const Color(0xFFFEF3C7),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const MarketplaceScreen()),
                        );
                      },
                    ),
                    PastelMetricCard(
                      title: 'Active Sites',
                      value: '${data.activeSites}',
                      icon: Icons.construction_rounded,
                      iconColor: const Color(0xFF0D9488),
                      iconBgColor: const Color(0xFFCCFBF1),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SitesScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Ongoing Projects Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Ongoing Projects',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const SitesScreen()),
                          );
                        },
                        child: Row(
                          children: const [
                            Text(
                              'View All',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward_rounded, size: 14, color: Color(0xFF2563EB)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Ongoing Project Card (Jaffna School Project - 42%)
              if (primarySite != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: OngoingProjectCard(
                      project: primarySite,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ProjectLogbookScreen(project: primarySite),
                          ),
                        );
                      },
                    ),
                  ),
                ),

              // Quick Actions Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Quick Actions',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      InkWell(
                        onTap: () {},
                        child: Row(
                          children: const [
                            Icon(Icons.settings_outlined, size: 14, color: Color(0xFF2563EB)),
                            SizedBox(width: 4),
                            Text(
                              'Customize',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Quick Actions (2 Rows × 5 Tiles)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid.count(
                  crossAxisCount: 5,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 6,
                  childAspectRatio: 0.68,
                  children: [
                    QuickActionTile(
                      label: 'Create\nProject',
                      icon: Icons.add_rounded,
                      color: const Color(0xFF1D4ED8),
                      backgroundColor: const Color(0xFFEFF6FF),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SiteFormScreen()),
                        );
                      },
                    ),
                    QuickActionTile(
                      label: 'Add\nEmployee',
                      icon: Icons.person_add_alt_1_rounded,
                      color: const Color(0xFF059669),
                      backgroundColor: const Color(0xFFECFDF5),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const LabourFormScreen()),
                        );
                      },
                    ),
                    QuickActionTile(
                      label: 'Invite\nConsultant',
                      icon: Icons.person_outline_rounded,
                      color: const Color(0xFF7C3AED),
                      backgroundColor: const Color(0xFFF5F3FF),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Consultant invitation link generated!')),
                        );
                      },
                    ),
                    QuickActionTile(
                      label: 'Add Sub\nContractor',
                      icon: Icons.engineering_rounded,
                      color: const Color(0xFFD97706),
                      backgroundColor: const Color(0xFFFFFBEB),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SupplierFormScreen()),
                        );
                      },
                    ),
                    QuickActionTile(
                      label: 'Request\nMaterials',
                      icon: Icons.local_shipping_rounded,
                      color: const Color(0xFFEA580C),
                      backgroundColor: const Color(0xFFFFF7ED),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const MaterialRequestFormScreen()),
                        );
                      },
                    ),
                    QuickActionTile(
                      label: 'Book\nEquipment',
                      icon: Icons.precision_manufacturing_rounded,
                      color: const Color(0xFFD97706),
                      backgroundColor: const Color(0xFFFEF9C3),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const MarketplaceScreen()),
                        );
                      },
                    ),
                    QuickActionTile(
                      label: 'Find\nLabour',
                      icon: Icons.groups_rounded,
                      color: const Color(0xFF059669),
                      backgroundColor: const Color(0xFFECFDF5),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const LaboursScreen()),
                        );
                      },
                    ),
                    QuickActionTile(
                      label: 'View\nReports',
                      icon: Icons.bar_chart_rounded,
                      color: const Color(0xFF2563EB),
                      backgroundColor: const Color(0xFFEFF6FF),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Site reports ledger exported to PDF.')),
                        );
                      },
                    ),
                    QuickActionTile(
                      label: 'Site\nLogbook',
                      icon: Icons.menu_book_rounded,
                      color: const Color(0xFF0D9488),
                      backgroundColor: const Color(0xFFCCFBF1),
                      onTap: () {
                        if (primarySite != null) {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => ProjectLogbookScreen(project: primarySite)),
                          );
                        }
                      },
                    ),
                    QuickActionTile(
                      label: 'Market-\nplace',
                      icon: Icons.storefront_rounded,
                      color: const Color(0xFF7C3AED),
                      backgroundColor: const Color(0xFFFAF5FF),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const MarketplaceScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Today's Activities Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Today's Activities",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      InkWell(
                        onTap: () {},
                        child: Row(
                          children: const [
                            Text(
                              'View All',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Color(0xFF2563EB)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Today's Activities (4 Pastel Cards in 1 Row)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: const [
                      Expanded(
                        child: _ActivitySummaryCard(
                          icon: Icons.groups_rounded,
                          value: '8',
                          label: 'Attendance',
                          color: Color(0xFF059669),
                          bgColor: Color(0xFFECFDF5),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: _ActivitySummaryCard(
                          icon: Icons.local_shipping_rounded,
                          value: '2',
                          label: 'Deliveries',
                          color: Color(0xFF2563EB),
                          bgColor: Color(0xFFEFF6FF),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: _ActivitySummaryCard(
                          icon: Icons.assignment_rounded,
                          value: '3',
                          label: 'Tasks',
                          color: Color(0xFF9333EA),
                          bgColor: Color(0xFFFAF5FF),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: _ActivitySummaryCard(
                          icon: Icons.access_time_rounded,
                          value: '1',
                          label: 'Approval',
                          color: Color(0xFFEA580C),
                          bgColor: Color(0xFFFFF7ED),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Team at Sites Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Team at Sites',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const LaboursScreen()),
                          );
                        },
                        child: Row(
                          children: const [
                            Text(
                              'View All',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Color(0xFF2563EB)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Team at Sites Horizontal Avatars
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 94,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    children: [
                      _TeamAvatarBubble(
                        name: 'Supervisor',
                        subtext: '8 on site',
                        avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
                      ),
                      const SizedBox(width: 14),
                      _TeamAvatarBubble(
                        name: 'Engineer',
                        subtext: '3 on site',
                        avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
                      ),
                      const SizedBox(width: 14),
                      _TeamAvatarBubble(
                        name: 'Technical Officer',
                        subtext: '2 on site',
                        avatarUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
                      ),
                      const SizedBox(width: 14),
                      _TeamAvatarBubble(
                        name: 'Employees',
                        subtext: '22 on site',
                        avatarUrl: 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=150',
                      ),
                      const SizedBox(width: 14),
                      Center(
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '+18',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF2563EB),
                                ),
                              ),
                              Icon(Icons.keyboard_arrow_right, size: 14, color: Color(0xFF2563EB)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Recent Activities Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Activities',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          if (primarySite != null) {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => ProjectLogbookScreen(project: primarySite)),
                            );
                          }
                        },
                        child: Row(
                          children: const [
                            Text(
                              'View All',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Color(0xFF2563EB)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Recent Activities List
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final act = data.recentActivities[index];
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: index % 2 == 0 ? const Color(0xFFECFDF5) : const Color(0xFFEFF6FF),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                index % 2 == 0 ? Icons.check_circle_rounded : Icons.local_shipping_rounded,
                                size: 18,
                                color: index % 2 == 0 ? const Color(0xFF059669) : const Color(0xFF2563EB),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    act.title,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    act.subtitle,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              act.timeAgo,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF94A3B8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: data.recentActivities.length,
                ),
              ),

              // Today's Tasks & Pending Approvals
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    children: [
                      // Tasks Section
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text(
                                  "Today's Tasks",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ...data.todayTasks.map((t) => Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.cardBorder),
                              ),
                              child: Row(
                                children: [
                                  InkWell(
                                    onTap: () => data.toggleTask(t.id),
                                    child: Icon(
                                      t.isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                                      size: 18,
                                      color: t.isCompleted ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      t.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        decoration: t.isCompleted ? TextDecoration.lineThrough : null,
                                        color: t.isCompleted ? const Color(0xFF94A3B8) : const Color(0xFF0F172A),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Approvals Section
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text(
                                  "Pending Approvals",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ...data.pendingApprovals.take(3).map((a) => Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.cardBorder),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      a.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFEF4444),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      '${a.count}',
                                      style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Cost Overview Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
                  child: Container(
                    padding: const EdgeInsets.all(16),
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
                          children: const [
                            Text(
                              'Cost Overview',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              'This Month v',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            _CostCol(label: 'Budget', value: 'LKR 25,000,000'),
                            _CostCol(label: 'Spent', value: 'LKR 12,500,000'),
                            _CostCol(label: 'Remaining', value: 'LKR 12,500,000'),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: const LinearProgressIndicator(
                                  value: 0.50,
                                  minHeight: 8,
                                  backgroundColor: Color(0xFFF1F5F9),
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              '50%',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivitySummaryCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final Color bgColor;

  const _ActivitySummaryCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamAvatarBubble extends StatelessWidget {
  final String name;
  final String subtext;
  final String avatarUrl;

  const _TeamAvatarBubble({
    required this.name,
    required this.subtext,
    required this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundImage: NetworkImage(avatarUrl),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        Text(
          subtext,
          style: const TextStyle(
            fontSize: 9,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}

class _CostCol extends StatelessWidget {
  final String label;
  final String value;

  const _CostCol({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}
