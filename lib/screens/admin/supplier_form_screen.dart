import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../providers/app_data_provider.dart';

class SupplierFormScreen extends StatefulWidget {
  const SupplierFormScreen({super.key, this.supplier});

  final SupplierProfile? supplier;

  @override
  State<SupplierFormScreen> createState() => _SupplierFormScreenState();
}

class _SupplierFormScreenState extends State<SupplierFormScreen> {
  late final TextEditingController _company;
  late final TextEditingController _contact;
  late final TextEditingController _phone;
  late final TextEditingController _email;
  late final TextEditingController _address;
  late final TextEditingController _reg;
  late final TextEditingController _materials;
  late final TextEditingController _bank;
  CompanyStatus _status = CompanyStatus.active;

  @override
  void initState() {
    super.initState();
    final s = widget.supplier;
    _company = TextEditingController(text: s?.companyName ?? '');
    _contact = TextEditingController(text: s?.contactPerson ?? '');
    _phone = TextEditingController(text: s?.phone ?? '');
    _email = TextEditingController(text: s?.email ?? '');
    _address = TextEditingController(text: s?.address ?? '');
    _reg = TextEditingController(text: s?.registrationDetails ?? '');
    _materials =
        TextEditingController(text: s?.materialsSupplied.join(', ') ?? '');
    _bank = TextEditingController(text: s?.bankInfo ?? '');
    _status = s?.status ?? CompanyStatus.active;
  }

  @override
  void dispose() {
    _company.dispose();
    _contact.dispose();
    _phone.dispose();
    _email.dispose();
    _address.dispose();
    _reg.dispose();
    _materials.dispose();
    _bank.dispose();
    super.dispose();
  }

  void _save() {
    if (_company.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Company name is required')),
      );
      return;
    }

    final supplier = SupplierProfile(
      id: widget.supplier?.id ??
          'sup-${DateTime.now().millisecondsSinceEpoch}',
      companyName: _company.text.trim(),
      contactPerson: _contact.text.trim(),
      phone: _phone.text.trim(),
      email: _email.text.trim(),
      address: _address.text.trim(),
      registrationDetails: _reg.text.trim(),
      materialsSupplied: _materials.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      bankInfo: _bank.text.trim(),
      status: _status,
    );
    context.read<AppDataProvider>().upsertSupplier(supplier);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.supplier != null;
    return Scaffold(
      appBar: AppBar(title: Text(editing ? 'Edit supplier' : 'Add supplier')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: _company, decoration: const InputDecoration(labelText: 'Company name')),
          const SizedBox(height: 12),
          TextField(controller: _contact, decoration: const InputDecoration(labelText: 'Contact person')),
          const SizedBox(height: 12),
          TextField(controller: _phone, decoration: const InputDecoration(labelText: 'Phone')),
          const SizedBox(height: 12),
          TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
          const SizedBox(height: 12),
          TextField(controller: _address, decoration: const InputDecoration(labelText: 'Address')),
          const SizedBox(height: 12),
          TextField(
            controller: _reg,
            decoration: const InputDecoration(labelText: 'Registration details'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _materials,
            decoration: const InputDecoration(
              labelText: 'Materials supplied',
              hintText: 'Cement, Sand, Steel',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _bank,
            decoration: const InputDecoration(labelText: 'Bank / payment info'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<CompanyStatus>(
            initialValue: _status,
            decoration: const InputDecoration(labelText: 'Company status'),
            items: CompanyStatus.values
                .map((s) => DropdownMenuItem(value: s, child: Text(s.name)))
                .toList(),
            onChanged: (v) => setState(() => _status = v ?? _status),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _save,
            child: Text(editing ? 'Save changes' : 'Create supplier'),
          ),
        ],
      ),
    );
  }
}
