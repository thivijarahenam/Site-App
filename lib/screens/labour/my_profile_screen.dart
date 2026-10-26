import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../providers/app_data_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common_widgets.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  late TextEditingController _phone;
  late TextEditingController _address;
  late TextEditingController _skills;
  late TextEditingController _emergency;
  bool _ready = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_ready) return;
    final user = context.read<AuthProvider>().user!;
    final labour =
        context.read<AppDataProvider>().labourById(user.linkedId ?? '');
    _phone = TextEditingController(text: labour?.phone ?? user.phone);
    _address = TextEditingController(text: labour?.address ?? '');
    _skills = TextEditingController(text: labour?.skills.join(', ') ?? '');
    _emergency = TextEditingController(text: labour?.emergencyContact ?? '');
    _ready = true;
  }

  @override
  void dispose() {
    if (_ready) {
      _phone.dispose();
      _address.dispose();
      _skills.dispose();
      _emergency.dispose();
    }
    super.dispose();
  }

  void _save(LabourProfile labour) {
    final updated = labour.copyWith(
      phone: _phone.text.trim(),
      address: _address.text.trim(),
      skills: _skills.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      emergencyContact: _emergency.text.trim(),
    );
    context.read<AppDataProvider>().upsertLabour(updated);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user!;
    final labour =
        context.watch<AppDataProvider>().labourById(user.linkedId ?? '');

    if (labour == null) {
      return const Scaffold(
        body: EmptyState(
          icon: Icons.person_off_outlined,
          title: 'Profile missing',
          message: 'Labour profile is not linked to this account.',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  InfoTile(label: 'Full name', value: labour.fullName),
                  InfoTile(label: 'NIC / ID', value: labour.nic),
                  InfoTile(label: 'Job role', value: labour.jobRole),
                  InfoTile(label: 'Experience', value: labour.experience),
                  InfoTile(
                    label: 'Joining date',
                    value: dateFmt.format(labour.joiningDate),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Update personal information',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          TextField(
            controller: _phone,
            decoration: const InputDecoration(labelText: 'Phone'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _address,
            decoration: const InputDecoration(labelText: 'Address'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _skills,
            decoration: const InputDecoration(labelText: 'Skills'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _emergency,
            decoration: const InputDecoration(labelText: 'Emergency contact'),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () => _save(labour),
            child: const Text('Save profile'),
          ),
        ],
      ),
    );
  }
}
