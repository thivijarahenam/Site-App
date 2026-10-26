import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../providers/app_data_provider.dart';
import '../../theme/app_theme.dart';
import 'labour_form_screen.dart';

class LaboursScreen extends StatefulWidget {
  const LaboursScreen({super.key});

  @override
  State<LaboursScreen> createState() => _LaboursScreenState();
}

class _LaboursScreenState extends State<LaboursScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'All';

  final List<String> _filters = [
    'All',
    'Available for Hire',
    'Mason',
    'Carpenter',
    'Steel Fixer',
    'Electrician',
    'Plumber',
    'Painter',
    'Helper',
  ];

  void _showContactModal(BuildContext context, LabourProfile labour) {
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
                    radius: 26,
                    backgroundImage: labour.avatarUrl != null
                        ? NetworkImage(labour.avatarUrl!)
                        : null,
                    backgroundColor: AppColors.pastelGreenBg,
                    child: labour.avatarUrl == null
                        ? Text(labour.fullName[0],
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          labour.fullName,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryNavy,
                          ),
                        ),
                        Text(
                          '${labour.jobRole} • ${labour.experience}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          labour.phone,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF16A34A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Call Action Button
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: const Color(0xFF16A34A),
                      content: Row(
                        children: [
                          const Icon(Icons.phone_forwarded, color: Colors.white, size: 20),
                          const SizedBox(width: 10),
                          Text('Dialing ${labour.phone} (${labour.fullName})...'),
                        ],
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.phone_rounded, color: Colors.white),
                label: Text(
                  'Call ${labour.phone}',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                ),
              ),
              const SizedBox(height: 10),
              // WhatsApp / Message Action
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF25D366),
                  side: const BorderSide(color: Color(0xFF25D366), width: 1.5),
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Opening WhatsApp chat with ${labour.fullName} (${labour.phone})...'),
                    ),
                  );
                },
                icon: const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF25D366)),
                label: const Text(
                  'Send WhatsApp Message',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
              ),
              const SizedBox(height: 10),
              // Copy Phone Number
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryNavy,
                  side: const BorderSide(color: AppColors.cardBorder),
                  minimumSize: const Size.fromHeight(46),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: labour.phone));
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Copied ${labour.phone} to clipboard!'),
                    ),
                  );
                },
                icon: const Icon(Icons.copy_rounded, size: 18),
                label: const Text('Copy Phone Number', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAssignSiteDialog(BuildContext context, LabourProfile labour, AppDataProvider data) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Assign ${labour.fullName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select active site for assignment:'),
            const SizedBox(height: 12),
            ...data.sites.map((s) => ListTile(
              dense: true,
              leading: const Icon(Icons.apartment_rounded, color: AppColors.pastelBlueText),
              title: Text(s.siteName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              subtitle: Text(s.address, style: const TextStyle(fontSize: 11)),
              onTap: () {
                final updated = labour.copyWith(currentSiteId: s.id);
                data.upsertLabour(updated);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Assigned ${labour.fullName} to ${s.siteName}!')),
                );
              },
            )),
            if (labour.currentSiteId != null)
              ListTile(
                dense: true,
                leading: const Icon(Icons.close_rounded, color: Color(0xFFE11D48)),
                title: const Text('Unassign from current site', style: TextStyle(color: Color(0xFFE11D48), fontWeight: FontWeight.w700, fontSize: 13)),
                onTap: () {
                  final updated = labour.copyWith(clearSite: true);
                  data.upsertLabour(updated);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${labour.fullName} is now available for hire.')),
                  );
                },
              ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AppDataProvider>();

    final filtered = data.labours.where((l) {
      if (_selectedFilter == 'Available for Hire') {
        if (l.currentSiteId != null) return false;
      } else if (_selectedFilter != 'All') {
        if (!l.jobRole.toLowerCase().contains(_selectedFilter.toLowerCase()) &&
            !l.skills.any((s) => s.toLowerCase().contains(_selectedFilter.toLowerCase()))) {
          return false;
        }
      }

      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return l.fullName.toLowerCase().contains(q) ||
            l.jobRole.toLowerCase().contains(q) ||
            l.phone.contains(q) ||
            l.address.toLowerCase().contains(q) ||
            l.skills.any((s) => s.toLowerCase().contains(q));
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Workforce & Labour Directory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_rounded),
            tooltip: 'Register New Labour',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LabourFormScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              // Search Field
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
                child: TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Search by worker name, skill, phone, or trade...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () => setState(() => _searchQuery = ''),
                          )
                        : null,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),

              // Filter Chips
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  itemCount: _filters.length,
                  itemBuilder: (context, i) {
                    final f = _filters[i];
                    final isSel = f == _selectedFilter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        selected: isSel,
                        label: Text(f),
                        selectedColor: AppColors.primaryNavy,
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isSel ? Colors.white : AppColors.textSecondary,
                        ),
                        checkmarkColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: isSel ? AppColors.primaryNavy : AppColors.cardBorder),
                        ),
                        onSelected: (_) => setState(() => _selectedFilter = f),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 10),

              // Labourers List
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.search_off_rounded, size: 48, color: AppColors.textMuted),
                            SizedBox(height: 12),
                            Text(
                              'No labourers matching your criteria',
                              style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(18, 4, 18, 80),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final labour = filtered[index];
                          final assignedSite = labour.currentSiteId != null
                              ? data.siteById(labour.currentSiteId!)
                              : null;
                          final isAvailable = labour.currentSiteId == null;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
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
                                // Top row: Avatar, Name, Job Role, Status Pill
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Stack(
                                      children: [
                                        CircleAvatar(
                                          radius: 24,
                                          backgroundImage: labour.avatarUrl != null
                                              ? NetworkImage(labour.avatarUrl!)
                                              : null,
                                          backgroundColor: AppColors.pastelBlueBg,
                                          child: labour.avatarUrl == null
                                              ? Text(labour.fullName[0],
                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))
                                              : null,
                                        ),
                                        Positioned(
                                          bottom: 0,
                                          right: 0,
                                          child: Container(
                                            width: 12,
                                            height: 12,
                                            decoration: BoxDecoration(
                                              color: isAvailable
                                                  ? const Color(0xFF10B981)
                                                  : const Color(0xFF2563EB),
                                              shape: BoxShape.circle,
                                              border: Border.all(color: Colors.white, width: 2),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            labour.fullName,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.primaryNavy,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${labour.jobRole} • ${labour.experience}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            '📍 ${labour.address}',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: isAvailable
                                            ? const Color(0xFFECFDF5)
                                            : const Color(0xFFEFF6FF),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        isAvailable ? 'Available' : 'On Site',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: isAvailable
                                              ? const Color(0xFF059669)
                                              : const Color(0xFF2563EB),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 10),

                                // Skills tags
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: labour.skills.map((skill) => Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceTint,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      skill,
                                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                                    ),
                                  )).toList(),
                                ),

                                const SizedBox(height: 12),
                                const Divider(height: 1),
                                const SizedBox(height: 10),

                                // Bottom Row: Wage, Assignment info, Direct CALL button
                                Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Daily Wage',
                                          style: TextStyle(fontSize: 10, color: AppColors.textMuted),
                                        ),
                                        Text(
                                          'LKR ${labour.dailyWage.toStringAsFixed(0)}',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF16A34A),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    // Assign Site Button
                                    TextButton.icon(
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppColors.primaryNavy,
                                        padding: const EdgeInsets.symmetric(horizontal: 10),
                                        minimumSize: const Size(60, 36),
                                      ),
                                      onPressed: () => _showAssignSiteDialog(context, labour, data),
                                      icon: const Icon(Icons.assignment_ind_outlined, size: 16),
                                      label: Text(
                                        assignedSite != null ? 'Reassign' : 'Assign Site',
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    // Direct CALL button
                                    FilledButton.icon(
                                      style: FilledButton.styleFrom(
                                        backgroundColor: const Color(0xFF16A34A),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 14),
                                        minimumSize: const Size(80, 38),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      onPressed: () => _showContactModal(context, labour),
                                      icon: const Icon(Icons.phone_rounded, size: 16),
                                      label: const Text('Call', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add-labour-fab',
        backgroundColor: AppColors.primaryOrange,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const LabourFormScreen()),
          );
        },
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Register Labour', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}
