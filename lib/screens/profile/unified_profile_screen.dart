import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../providers/app_data_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../admin/labours_screen.dart';
import '../admin/sites_screen.dart';
import '../admin/suppliers_screen.dart';
import '../notifications_screen.dart';

class UnifiedProfileScreen extends StatelessWidget {
  const UnifiedProfileScreen({super.key});

  void _showProfileUpdatesSheet(
    BuildContext context,
    AppUser user,
    AppDataProvider data,
    AuthProvider auth,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _ProfileUpdateModal(
        user: user,
        data: data,
        auth: auth,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final data = context.watch<AppDataProvider>();

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Not logged in')),
      );
    }

    // If Labour, get linked profile
    final labourProfile = user.role == UserRole.labour
        ? (user.linkedId != null ? data.labourById(user.linkedId!) : data.labours.firstOrNull)
        : null;

    // If Supplier, get linked supplier profile
    final supplierProfile = user.role == UserRole.supplier
        ? (user.linkedId != null ? data.supplierById(user.linkedId!) : data.suppliers.firstOrNull)
        : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile & Settings'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              // Company Header Card with Company Logo
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.cardBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          'assets/images/company_logo.jpeg',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: AppColors.primaryOrange,
                            child: const Icon(Icons.business_rounded, color: Colors.white, size: 30),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ahenam Technology',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryNavy,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user.companyName,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.pastelGreenBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Verified Platform • Northern Province',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.pastelGreenText,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // INCOMPLETE PROFILE / PROFILE UPDATES ALERT BANNER
              if (user.isProfileIncomplete) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.pastelAmberBg,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFFDE68A), width: 1.2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.error_outline_rounded,
                                color: AppColors.pastelAmberText, size: 18),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Profile Incomplete (40%)',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF78350F),
                                  ),
                                ),
                                Text(
                                  'You skipped your skills & experience details during sign up.',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF92400E),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD97706),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.edit_note_rounded, size: 16),
                        label: const Text(
                          'Update & Complete Profile Now',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                        ),
                        onPressed: () => _showProfileUpdatesSheet(context, user, data, auth),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // User Info Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundImage: user.avatarUrl != null
                              ? NetworkImage(user.avatarUrl!)
                              : null,
                          backgroundColor: AppColors.pastelBlueBg,
                          child: user.avatarUrl == null
                              ? Text(user.name.isNotEmpty ? user.name[0] : 'U',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))
                              : null,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryNavy,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${user.email} • ${user.phone}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.pastelOrangeBg,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  user.role.label,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryOrange,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Labour-Specific Profile Details
                    if (labourProfile != null) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(height: 1),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Labour Skill Card',
                            style: TextStyle(
                              fontSize: 13,
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
                            label: const Text('Profile Updates', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                            onPressed: () => _showProfileUpdatesSheet(context, user, data, auth),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.handyman_outlined, size: 16, color: AppColors.pastelBlueText),
                          const SizedBox(width: 8),
                          Text(
                            labourProfile.jobRole,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                          const Spacer(),
                          Text(
                            'LKR ${labourProfile.dailyWage.toStringAsFixed(0)} / day',
                            style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF16A34A), fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: labourProfile.skills.map((s) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceTint,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(s, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                        )).toList(),
                      ),
                    ],

                    // Supplier-Specific Profile Details
                    if (supplierProfile != null) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(height: 1),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.storefront_rounded, size: 16, color: AppColors.pastelOrangeText),
                              const SizedBox(width: 8),
                              Text(
                                supplierProfile.companyName,
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                              ),
                            ],
                          ),
                          TextButton.icon(
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF16A34A),
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            icon: const Icon(Icons.edit_outlined, size: 14),
                            label: const Text('Update Shop', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                            onPressed: () => _showProfileUpdatesSheet(context, user, data, auth),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Materials: ${supplierProfile.materialsSupplied.join(", ")}',
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Quick Role Switcher (For Demo & Testing)
              const Text(
                'Switch Demo Role',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryNavy,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  children: [
                    _RoleTile(
                      role: UserRole.admin,
                      title: 'Owner / Contractor (Jana Kumaran)',
                      isCurrent: user.role == UserRole.admin,
                      onTap: () => auth.switchRole(UserRole.admin),
                    ),
                    const Divider(height: 1),
                    _RoleTile(
                      role: UserRole.supervisor,
                      title: 'Site Supervisor (K. Niroshan)',
                      isCurrent: user.role == UserRole.supervisor,
                      onTap: () => auth.switchRole(UserRole.supervisor),
                    ),
                    const Divider(height: 1),
                    _RoleTile(
                      role: UserRole.labour,
                      title: 'Labour / Worker (S. Thavarasa)',
                      isCurrent: user.role == UserRole.labour,
                      onTap: () => auth.switchRole(UserRole.labour),
                    ),
                    const Divider(height: 1),
                    _RoleTile(
                      role: UserRole.supplier,
                      title: 'Material Supplier (Nimal Fernando)',
                      isCurrent: user.role == UserRole.supplier,
                      onTap: () => auth.switchRole(UserRole.supplier),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // System Navigation
              const Text(
                'Quick Navigation',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryNavy,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.apartment_rounded, color: AppColors.pastelBlueText),
                      title: const Text('All Construction Sites', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SitesScreen())),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.groups_rounded, color: AppColors.pastelGreenText),
                      title: const Text('Workforce & Labour Directory', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      subtitle: const Text('Search skills and call workers directly', style: TextStyle(fontSize: 11)),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const LaboursScreen()),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.local_shipping_rounded, color: AppColors.pastelAmberText),
                      title: const Text('Material Suppliers & RFQs', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SuppliersScreen())),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Sign Out Button
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFE11D48),
                  side: const BorderSide(color: Color(0xFFFECDD3)),
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () => auth.logout(),
                child: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleTile extends StatelessWidget {
  final UserRole role;
  final String title;
  final bool isCurrent;
  final VoidCallback onTap;

  const _RoleTile({
    required this.role,
    required this.title,
    required this.isCurrent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
          color: isCurrent ? AppColors.primaryOrange : AppColors.primaryNavy,
        ),
      ),
      trailing: isCurrent
          ? const Icon(Icons.check_circle_rounded, color: AppColors.primaryOrange, size: 20)
          : const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
      onTap: onTap,
    );
  }
}

/// Profile Updates Modal Bottom Sheet
class _ProfileUpdateModal extends StatefulWidget {
  final AppUser user;
  final AppDataProvider data;
  final AuthProvider auth;

  const _ProfileUpdateModal({
    required this.user,
    required this.data,
    required this.auth,
  });

  @override
  State<_ProfileUpdateModal> createState() => _ProfileUpdateModalState();
}

class _ProfileUpdateModalState extends State<_ProfileUpdateModal> {
  // Labour fields
  late String _trade;
  late String _experience;
  late double _wage;
  late List<String> _skills;

  // Supplier fields
  late TextEditingController _shopNameCtrl;
  late TextEditingController _shopAddressCtrl;
  late List<String> _materials;

  final List<String> _trades = [
    'Mason',
    'Carpenter',
    'Steel Fixer',
    'Electrician',
    'Plumber',
    'Painter',
    'Helper',
    'Welder',
  ];

  final List<String> _allSkills = [
    'Bricklaying',
    'Plastering',
    'Scaffolding',
    'Concrete Pouring',
    'Tiling',
    'Roofing',
    'Steel Binding',
    'Electrical Wiring',
    'Pipe Fitting',
    'Waterproofing',
  ];

  final List<String> _allMaterials = [
    'Cement',
    'Sand',
    'Metal / Gravel',
    'Steel Rebars',
    'Red Bricks',
    'Hollow Blocks',
    'Paint & Primer',
    'PVC Pipes',
  ];

  @override
  void initState() {
    super.initState();
    final labour = widget.data.labourById(widget.user.linkedId ?? '');
    _trade = labour?.jobRole ?? 'Mason';
    const validExp = ['1-2 years', '3-5 years', '5-10 years', '10+ years'];
    final rawExp = labour?.experience;
    _experience = (rawExp != null && validExp.contains(rawExp)) ? rawExp : '3-5 years';
    _wage = labour?.dailyWage ?? 3500;
    _skills = List.from(labour?.skills ?? ['Bricklaying', 'Plastering']);

    final supplier = widget.data.supplierById(widget.user.linkedId ?? '');
    _shopNameCtrl = TextEditingController(text: supplier?.companyName ?? widget.user.companyName);
    _shopAddressCtrl = TextEditingController(text: supplier?.address ?? 'Jaffna');
    _materials = List.from(supplier?.materialsSupplied ?? ['Cement', 'Sand', 'Steel Rebars']);
  }

  @override
  void dispose() {
    _shopNameCtrl.dispose();
    _shopAddressCtrl.dispose();
    super.dispose();
  }

  void _saveUpdates() {
    if (widget.user.role == UserRole.labour) {
      final linkedId = widget.user.linkedId ?? 'lab-${DateTime.now().millisecondsSinceEpoch}';
      final labour = LabourProfile(
        id: linkedId,
        fullName: widget.user.name,
        nic: '199012345678',
        phone: widget.user.phone,
        address: widget.user.address ?? 'Jaffna',
        jobRole: _trade,
        skills: _skills,
        experience: _experience,
        joiningDate: DateTime.now(),
        emergencyContact: widget.user.phone,
        status: LabourStatus.active,
        dailyWage: _wage,
      );
      widget.data.upsertLabour(labour);

      widget.auth.updateUser(
        widget.user.copyWith(
          linkedId: linkedId,
          isProfileIncomplete: false,
          experience: _experience,
          skills: _skills,
          dailyWage: _wage,
        ),
      );
    } else if (widget.user.role == UserRole.supplier) {
      final linkedId = widget.user.linkedId ?? 'sup-${DateTime.now().millisecondsSinceEpoch}';
      final supplier = SupplierProfile(
        id: linkedId,
        companyName: _shopNameCtrl.text.trim(),
        contactPerson: widget.user.name,
        phone: widget.user.phone,
        email: widget.user.email,
        address: _shopAddressCtrl.text.trim(),
        registrationDetails: 'Business Reg • Northern Province',
        materialsSupplied: _materials,
        bankInfo: 'Commercial Bank - Verified Account',
        status: CompanyStatus.active,
      );
      widget.data.upsertSupplier(supplier);

      widget.auth.updateUser(
        widget.user.copyWith(
          linkedId: linkedId,
          isProfileIncomplete: false,
          companyName: _shopNameCtrl.text.trim(),
          materialsSupplied: _materials,
        ),
      );
    } else {
      widget.auth.updateUser(
        widget.user.copyWith(isProfileIncomplete: false),
      );
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updates saved successfully!'),
        backgroundColor: Color(0xFF16A34A),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
                const Icon(Icons.edit_note_rounded, color: AppColors.primaryOrange, size: 22),
                const SizedBox(width: 8),
                Text(
                  'Profile Updates (${widget.user.role.label})',
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.primaryNavy),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Update your skills, trade details, and pricing anytime',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),

            if (widget.user.role == UserRole.labour) ...[
              const Text('Trade Role', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _trades.map((t) {
                  final isSelected = _trade == t;
                  return ChoiceChip(
                    label: Text(t),
                    selected: isSelected,
                    selectedColor: AppColors.pastelOrangeBg,
                    labelStyle: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                      color: isSelected ? AppColors.primaryOrange : AppColors.primaryNavy,
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _trade = t);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _experience,
                      decoration: const InputDecoration(labelText: 'Experience'),
                      items: ['1-2 years', '3-5 years', '5-10 years', '10+ years']
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _experience = val);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      initialValue: _wage.toStringAsFixed(0),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Daily Wage (LKR)', prefixText: 'Rs. '),
                      onChanged: (val) {
                        final n = double.tryParse(val);
                        if (n != null) _wage = n;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              const Text('Skills Known', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _allSkills.map((s) {
                  final isSelected = _skills.contains(s);
                  return FilterChip(
                    label: Text(s),
                    selected: isSelected,
                    selectedColor: AppColors.pastelOrangeBg,
                    labelStyle: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                      color: isSelected ? AppColors.primaryOrange : AppColors.primaryNavy,
                    ),
                    onSelected: (val) {
                      setState(() {
                        if (val) {
                          _skills.add(s);
                        } else {
                          _skills.remove(s);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ] else if (widget.user.role == UserRole.supplier) ...[
              TextField(
                controller: _shopNameCtrl,
                decoration: const InputDecoration(labelText: 'Company / Shop Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _shopAddressCtrl,
                decoration: const InputDecoration(labelText: 'Warehouse Address'),
              ),
              const SizedBox(height: 14),
              const Text('Materials Supplied', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _allMaterials.map((m) {
                  final isSelected = _materials.contains(m);
                  return FilterChip(
                    label: Text(m),
                    selected: isSelected,
                    selectedColor: AppColors.pastelGreenBg,
                    labelStyle: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                      color: isSelected ? const Color(0xFF16A34A) : AppColors.primaryNavy,
                    ),
                    onSelected: (val) {
                      setState(() {
                        if (val) {
                          _materials.add(m);
                        } else {
                          _materials.remove(m);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 22),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _saveUpdates,
              child: const Text('Save Profile Updates', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
  }
}
