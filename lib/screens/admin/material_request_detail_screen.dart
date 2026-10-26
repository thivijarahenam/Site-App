import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../providers/app_data_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class MaterialRequestDetailScreen extends StatelessWidget {
  const MaterialRequestDetailScreen({super.key, required this.requestId});

  final String requestId;

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AppDataProvider>();
    final req = data.requests.firstWhere((r) => r.id == requestId);
    final site = data.siteById(req.siteId);
    final supplier = req.assignedSupplierId == null
        ? null
        : data.supplierById(req.assignedSupplierId!);
    final response = req.response;

    return Scaffold(
      appBar: AppBar(title: const Text('Request details')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  req.materialName,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              StatusChip.request(req.status),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  InfoTile(label: 'Site', value: site?.siteName ?? '-'),
                  InfoTile(label: 'Supplier', value: supplier?.companyName ?? '-'),
                  InfoTile(
                    label: 'Quantity',
                    value: '${req.requiredQuantity} ${req.unit}',
                  ),
                  InfoTile(label: 'Category', value: req.category),
                  InfoTile(
                    label: 'Required date',
                    value: dateFmt.format(req.requiredDate),
                  ),
                  InfoTile(
                    label: 'Request date',
                    value: dateFmt.format(req.requestDate),
                  ),
                  if (req.description.isNotEmpty)
                    InfoTile(label: 'Description', value: req.description),
                  if (req.notes.isNotEmpty)
                    InfoTile(label: 'Notes', value: req.notes),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Supplier response',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          if (response == null)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No supplier response submitted yet.'),
              ),
            )
          else
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    InfoTile(
                      label: 'Available quantity',
                      value: '${response.availableQuantity} ${req.unit}',
                    ),
                    InfoTile(
                      label: 'Unit price',
                      value: 'LKR ${response.unitPrice.toStringAsFixed(0)}',
                    ),
                    InfoTile(
                      label: 'Total price',
                      value: 'LKR ${response.totalPrice.toStringAsFixed(0)}',
                    ),
                    InfoTile(
                      label: 'Delivery date',
                      value: dateFmt.format(response.deliveryDate),
                    ),
                    InfoTile(
                      label: 'Availability',
                      value: response.availabilityStatus.name,
                    ),
                    if (response.notes.isNotEmpty)
                      InfoTile(label: 'Supplier notes', value: response.notes),
                    InfoTile(
                      label: 'Submitted',
                      value: dateTimeFmt.format(response.submittedAt),
                    ),
                  ],
                ),
              ),
            ),
          if (response != null) ...[
            const SizedBox(height: 16),
            Text('Manage request',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () {
                data.updateRequestStatus(
                  req.id,
                  MaterialRequestStatus.approved,
                );
              },
              child: const Text('Approve response'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () {
                data.updateRequestStatus(
                  req.id,
                  MaterialRequestStatus.rejected,
                );
              },
              child: const Text('Reject response'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                data.updateRequestStatus(
                  req.id,
                  MaterialRequestStatus.completed,
                );
              },
              child: const Text('Mark completed'),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            'Only Admin can create/manage requests. Suppliers submit quotations.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.slate,
                ),
          ),
        ],
      ),
    );
  }
}
