import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../providers/app_data_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common_widgets.dart';

class CompanyProfileScreen extends StatefulWidget {
  const CompanyProfileScreen({super.key});

  @override
  State<CompanyProfileScreen> createState() => _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends State<CompanyProfileScreen> {
  late TextEditingController _contact;
  late TextEditingController _phone;
  late TextEditingController _email;
  late TextEditingController _address;
  late TextEditingController _materials;
  late TextEditingController _bank;
  bool _ready = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_ready) return;
    final user = context.read<AuthProvider>().user!;
    final company =
        context.read<AppDataProvider>().supplierById(user.linkedId ?? '');
    _contact = TextEditingController(text: company?.contactPerson ?? '');
    _phone = TextEditingController(text: company?.phone ?? '');
    _email = TextEditingController(text: company?.email ?? '');
    _address = TextEditingController(text: company?.address ?? '');
    _materials = TextEditingController(
      text: company?.materialsSupplied.join(', ') ?? '',
    );
    _bank = TextEditingController(text: company?.bankInfo ?? '');
    _ready = true;
  }

  @override
  void dispose() {
    if (_ready) {
      _contact.dispose();
      _phone.dispose();
      _email.dispose();
      _address.dispose();
      _materials.dispose();
      _bank.dispose();
    }
    super.dispose();
  }

  void _save(SupplierProfile company) {
    final updated = company.copyWith(
      contactPerson: _contact.text.trim(),
      phone: _phone.text.trim(),
      email: _email.text.trim(),
      address: _address.text.trim(),
      materialsSupplied: _materials.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      bankInfo: _bank.text.trim(),
    );
    context.read<AppDataProvider>().upsertSupplier(updated);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Company profile updated')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user!;
    final company =
        context.watch<AppDataProvider>().supplierById(user.linkedId ?? '');

    if (company == null) {
      return const Scaffold(
        body: EmptyState(
          icon: Icons.store_mall_directory_outlined,
          title: 'Company missing',
          message: 'Supplier company profile is not linked.',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Company profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  InfoTile(label: 'Company', value: company.companyName),
                  InfoTile(
                    label: 'Registration',
                    value: company.registrationDetails,
                  ),
                  InfoTile(label: 'Status', value: company.status.name),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _contact,
            decoration: const InputDecoration(labelText: 'Contact person'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phone,
            decoration: const InputDecoration(labelText: 'Phone'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _email,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _address,
            decoration: const InputDecoration(labelText: 'Address'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _materials,
            decoration: const InputDecoration(labelText: 'Materials supplied'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _bank,
            decoration: const InputDecoration(labelText: 'Bank / payment info'),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () => _save(company),
            child: const Text('Save company profile'),
          ),
        ],
      ),
    );
  }
}
