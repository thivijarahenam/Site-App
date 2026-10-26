import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../providers/app_data_provider.dart';
import '../../theme/app_theme.dart';

class LabourFormScreen extends StatefulWidget {
  const LabourFormScreen({super.key, this.labour});

  final LabourProfile? labour;

  @override
  State<LabourFormScreen> createState() => _LabourFormScreenState();
}

class _LabourFormScreenState extends State<LabourFormScreen> {
  late final TextEditingController _name;
  late final TextEditingController _nic;
  late final TextEditingController _phone;
  late final TextEditingController _address;
  late final TextEditingController _jobRole;
  late final TextEditingController _skills;
  late final TextEditingController _experience;
  late final TextEditingController _emergency;
  late final TextEditingController _dailyWage;
  String? _siteId;
  LabourStatus _status = LabourStatus.active;

  final List<String> _commonRoles = [
    'Mason / Bricklayer',
    'Carpenter',
    'Steel Fixer',
    'Electrician',
    'Plumber',
    'Painter',
    'Tile Layer',
    'Helper / General Labour',
  ];

  final List<String> _skillSuggestions = [
    'Block Work',
    'Plastering',
    'Formwork',
    'Rebar Bending',
    'Roof Timber',
    'Conduit Wiring',
    'PVC Piping',
    'Concrete Mixing',
    'Wall Putty',
    'Tiling',
  ];

  @override
  void initState() {
    super.initState();
    final l = widget.labour;
    _name = TextEditingController(text: l?.fullName ?? '');
    _nic = TextEditingController(text: l?.nic ?? '');
    _phone = TextEditingController(text: l?.phone ?? '');
    _address = TextEditingController(text: l?.address ?? '');
    _jobRole = TextEditingController(text: l?.jobRole ?? '');
    _skills = TextEditingController(text: l?.skills.join(', ') ?? '');
    _experience = TextEditingController(text: l?.experience ?? '5 Years');
    _emergency = TextEditingController(text: l?.emergencyContact ?? '');
    _dailyWage = TextEditingController(text: l != null ? l.dailyWage.toStringAsFixed(0) : '3800');
    _siteId = l?.currentSiteId;
    _status = l?.status ?? LabourStatus.active;
  }

  @override
  void dispose() {
    _name.dispose();
    _nic.dispose();
    _phone.dispose();
    _address.dispose();
    _jobRole.dispose();
    _skills.dispose();
    _experience.dispose();
    _emergency.dispose();
    _dailyWage.dispose();
    super.dispose();
  }

  void _toggleSkill(String skill) {
    final current = _skills.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (current.contains(skill)) {
      current.remove(skill);
    } else {
      current.add(skill);
    }
    setState(() {
      _skills.text = current.join(', ');
    });
  }

  void _save() {
    if (_name.text.trim().isEmpty || _phone.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your full name and phone number')),
      );
      return;
    }

    final wage = double.tryParse(_dailyWage.text.trim()) ?? 3500.0;

    final labour = LabourProfile(
      id: widget.labour?.id ?? 'lab-${DateTime.now().millisecondsSinceEpoch}',
      fullName: _name.text.trim(),
      nic: _nic.text.trim().isNotEmpty ? _nic.text.trim() : '199012345678',
      phone: _phone.text.trim(),
      address: _address.text.trim().isNotEmpty ? _address.text.trim() : 'Jaffna, Northern Province',
      jobRole: _jobRole.text.trim().isNotEmpty ? _jobRole.text.trim() : 'General Labour',
      skills: _skills.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      experience: _experience.text.trim().isNotEmpty ? _experience.text.trim() : '3 Years',
      joiningDate: widget.labour?.joiningDate ?? DateTime.now(),
      emergencyContact: _emergency.text.trim(),
      currentSiteId: _siteId,
      status: _status,
      dailyWage: wage,
      avatarUrl: widget.labour?.avatarUrl ?? 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
    );

    context.read<AppDataProvider>().upsertLabour(labour);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF16A34A),
        content: Text('Profile for ${labour.fullName} saved! Visible to supervisors for direct calling.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sites = context.watch<AppDataProvider>().sites;
    final editing = widget.labour != null;

    final currentSkills = _skills.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(editing ? 'Edit Worker Profile' : 'Create Labour Profile'),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.pastelGreenBg,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.badge_outlined, color: AppColors.pastelGreenText, size: 26),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Workforce Registration',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.primaryNavy),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Provide your contact and trade skills so site supervisors can call you for work.',
                            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Full Name
              TextField(
                controller: _name,
                decoration: const InputDecoration(
                  labelText: 'Full Name *',
                  hintText: 'e.g. S. Thavarasa',
                  prefixIcon: Icon(Icons.person_outline, size: 20),
                ),
              ),
              const SizedBox(height: 14),

              // Phone Number (Required for supervisor to call)
              TextField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number (For Supervisor Calls) *',
                  hintText: '077 123 4567',
                  prefixIcon: Icon(Icons.phone_outlined, size: 20),
                ),
              ),
              const SizedBox(height: 14),

              // NIC
              TextField(
                controller: _nic,
                decoration: const InputDecoration(
                  labelText: 'NIC / National Identity Number',
                  hintText: '198423456789',
                  prefixIcon: Icon(Icons.credit_card_outlined, size: 20),
                ),
              ),
              const SizedBox(height: 14),

              // Address / Town
              TextField(
                controller: _address,
                decoration: const InputDecoration(
                  labelText: 'Town / Residential Area',
                  hintText: 'e.g. Nallur, Jaffna',
                  prefixIcon: Icon(Icons.location_on_outlined, size: 20),
                ),
              ),
              const SizedBox(height: 18),

              // Job Role Quick Selector
              const Text(
                'Trade / Primary Job Role',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primaryNavy),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _commonRoles.map((role) {
                  final isSel = _jobRole.text == role;
                  return ChoiceChip(
                    label: Text(role),
                    selected: isSel,
                    selectedColor: AppColors.pastelOrangeBg,
                    labelStyle: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isSel ? AppColors.primaryOrange : AppColors.primaryNavy,
                    ),
                    side: BorderSide(color: isSel ? AppColors.primaryOrange : AppColors.cardBorder),
                    onSelected: (val) {
                      if (val) setState(() => _jobRole.text = role);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _jobRole,
                decoration: const InputDecoration(
                  labelText: 'Custom Trade / Job Role',
                  hintText: 'Enter your trade role',
                ),
              ),

              const SizedBox(height: 18),

              // Skills & Competencies
              const Text(
                'Skills & Trade Competencies',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primaryNavy),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _skillSuggestions.map((skill) {
                  final has = currentSkills.contains(skill);
                  return FilterChip(
                    label: Text(skill),
                    selected: has,
                    selectedColor: AppColors.pastelBlueBg,
                    labelStyle: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: has ? AppColors.pastelBlueText : AppColors.primaryNavy,
                    ),
                    side: BorderSide(color: has ? AppColors.pastelBlueText : AppColors.cardBorder),
                    onSelected: (_) => _toggleSkill(skill),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _skills,
                decoration: const InputDecoration(
                  labelText: 'Selected Skills (Comma separated)',
                  hintText: 'Block Work, Plastering, Formwork',
                ),
              ),

              const SizedBox(height: 18),

              // Experience & Daily Wage
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _experience,
                      decoration: const InputDecoration(
                        labelText: 'Experience',
                        hintText: 'e.g. 6 Years',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _dailyWage,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Daily Wage (LKR)',
                        hintText: '3800',
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Emergency Contact
              TextField(
                controller: _emergency,
                decoration: const InputDecoration(
                  labelText: 'Emergency Contact Person & Phone',
                  hintText: 'e.g. 0779988776 (Wife)',
                  prefixIcon: Icon(Icons.contact_emergency_outlined, size: 20),
                ),
              ),

              const SizedBox(height: 14),

              // Site Assignment & Status
              DropdownButtonFormField<String?>(
                initialValue: _siteId,
                decoration: const InputDecoration(
                  labelText: 'Assign to Site (Optional)',
                  prefixIcon: Icon(Icons.apartment_rounded, size: 20),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Available for Hire (No site)')),
                  ...sites.map(
                    (s) => DropdownMenuItem(value: s.id, child: Text(s.siteName)),
                  ),
                ],
                onChanged: (v) => setState(() => _siteId = v),
              ),

              const SizedBox(height: 24),

              FilledButton(
                onPressed: _save,
                child: Text(editing ? 'Save Profile Changes' : 'Complete Profile & Register'),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
