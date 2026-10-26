import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../providers/app_data_provider.dart';
import '../../widgets/common_widgets.dart';

class MaterialRequestFormScreen extends StatefulWidget {
  const MaterialRequestFormScreen({super.key});

  @override
  State<MaterialRequestFormScreen> createState() =>
      _MaterialRequestFormScreenState();
}

class _MaterialRequestFormScreenState extends State<MaterialRequestFormScreen> {
  final _material = TextEditingController();
  final _category = TextEditingController();
  final _qty = TextEditingController();
  final _unit = TextEditingController(text: 'Bags');
  final _description = TextEditingController();
  final _notes = TextEditingController();
  String? _siteId;
  String? _supplierId;
  DateTime _requiredDate = DateTime.now().add(const Duration(days: 7));

  @override
  void dispose() {
    _material.dispose();
    _category.dispose();
    _qty.dispose();
    _unit.dispose();
    _description.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _save() {
    final qty = double.tryParse(_qty.text.trim());
    if (_siteId == null ||
        _supplierId == null ||
        _material.text.trim().isEmpty ||
        qty == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Site, supplier, material and quantity are required'),
        ),
      );
      return;
    }

    final request = MaterialRequest(
      id: 'req-${DateTime.now().millisecondsSinceEpoch}',
      siteId: _siteId!,
      materialName: _material.text.trim(),
      category: _category.text.trim().isEmpty ? 'General' : _category.text.trim(),
      requiredQuantity: qty,
      unit: _unit.text.trim(),
      requiredDate: _requiredDate,
      description: _description.text.trim(),
      notes: _notes.text.trim(),
      requestDate: DateTime.now(),
      status: MaterialRequestStatus.awaitingResponse,
      assignedSupplierId: _supplierId,
    );
    context.read<AppDataProvider>().addMaterialRequest(request);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AppDataProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Create material request')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String>(
            initialValue: _siteId,
            decoration: const InputDecoration(labelText: 'Site'),
            items: data.sites
                .map((s) => DropdownMenuItem(value: s.id, child: Text(s.siteName)))
                .toList(),
            onChanged: (v) => setState(() => _siteId = v),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _supplierId,
            decoration: const InputDecoration(labelText: 'Supplier'),
            items: data.suppliers
                .map(
                  (s) => DropdownMenuItem(
                    value: s.id,
                    child: Text(s.companyName),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => _supplierId = v),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _material,
            decoration: const InputDecoration(labelText: 'Material name'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _category,
            decoration: const InputDecoration(labelText: 'Category'),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _qty,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Quantity'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _unit,
                  decoration: const InputDecoration(labelText: 'Unit'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _requiredDate,
                firstDate: DateTime.now(),
                lastDate: DateTime(2035),
              );
              if (picked != null) setState(() => _requiredDate = picked);
            },
            child: Text('Required date: ${dateFmt.format(_requiredDate)}'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _description,
            maxLines: 3,
            decoration:
                const InputDecoration(labelText: 'Description / specification'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notes,
            maxLines: 2,
            decoration: const InputDecoration(labelText: 'Additional notes'),
          ),
          const SizedBox(height: 20),
          FilledButton(onPressed: _save, child: const Text('Create request')),
        ],
      ),
    );
  }
}
