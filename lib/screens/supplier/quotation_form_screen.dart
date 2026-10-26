import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../providers/app_data_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common_widgets.dart';

class QuotationFormScreen extends StatefulWidget {
  const QuotationFormScreen({super.key, required this.requestId});

  final String requestId;

  @override
  State<QuotationFormScreen> createState() => _QuotationFormScreenState();
}

class _QuotationFormScreenState extends State<QuotationFormScreen> {
  late final TextEditingController _qty;
  late final TextEditingController _price;
  late final TextEditingController _notes;
  late AvailabilityStatus _availability;
  late DateTime _delivery;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    final req = context
        .read<AppDataProvider>()
        .requests
        .firstWhere((r) => r.id == widget.requestId);
    final existing = req.response;
    _qty = TextEditingController(
      text: (existing?.availableQuantity ?? req.requiredQuantity).toString(),
    );
    _price = TextEditingController(
      text: existing?.unitPrice.toStringAsFixed(0) ?? '',
    );
    _notes = TextEditingController(text: existing?.notes ?? '');
    _availability = existing?.availabilityStatus ?? AvailabilityStatus.available;
    _delivery = existing?.deliveryDate ??
        req.requiredDate.subtract(const Duration(days: 1));
    _initialized = true;
  }

  @override
  void dispose() {
    if (_initialized) {
      _qty.dispose();
      _price.dispose();
      _notes.dispose();
    }
    super.dispose();
  }

  void _submit(MaterialRequest req) {
    final qty = double.tryParse(_qty.text.trim());
    final price = double.tryParse(_price.text.trim());
    if (qty == null || price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter available quantity and unit price')),
      );
      return;
    }

    final user = context.read<AuthProvider>().user!;
    final response = SupplierResponse(
      id: 'resp-${DateTime.now().millisecondsSinceEpoch}',
      supplierId: user.linkedId ?? '',
      materialName: req.materialName,
      availableQuantity: qty,
      unitPrice: price,
      deliveryDate: _delivery,
      availabilityStatus: _availability,
      notes: _notes.text.trim(),
      submittedAt: DateTime.now(),
    );
    context.read<AppDataProvider>().submitSupplierResponse(
          requestId: req.id,
          response: response,
        );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Quotation submitted to Admin')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AppDataProvider>();
    final req = data.requests.firstWhere((r) => r.id == widget.requestId);
    final site = data.siteById(req.siteId);
    final total = (double.tryParse(_qty.text) ?? 0) *
        (double.tryParse(_price.text) ?? 0);

    return Scaffold(
      appBar: AppBar(title: const Text('Submit quotation')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(req.materialName,
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  InfoTile(label: 'Site / Project', value: site?.projectName ?? '-'),
                  InfoTile(
                    label: 'Requested',
                    value: '${req.requiredQuantity} ${req.unit}',
                  ),
                  InfoTile(
                    label: 'Required date',
                    value: dateFmt.format(req.requiredDate),
                  ),
                  if (req.description.isNotEmpty)
                    InfoTile(label: 'Specification', value: req.description),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _qty,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Available quantity (${req.unit})',
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _price,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Unit price (LKR)'),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 8),
          Text(
            'Total price: LKR ${total.toStringAsFixed(0)}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<AvailabilityStatus>(
            initialValue: _availability,
            decoration: const InputDecoration(labelText: 'Availability status'),
            items: AvailabilityStatus.values
                .map((s) => DropdownMenuItem(value: s, child: Text(s.name)))
                .toList(),
            onChanged: (v) =>
                setState(() => _availability = v ?? _availability),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _delivery,
                firstDate: DateTime.now(),
                lastDate: DateTime(2035),
              );
              if (picked != null) setState(() => _delivery = picked);
            },
            child: Text('Delivery date: ${dateFmt.format(_delivery)}'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notes,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Additional notes'),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () => _submit(req),
            child: const Text('Submit to Admin'),
          ),
        ],
      ),
    );
  }
}
