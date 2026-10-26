import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_data_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import 'material_request_detail_screen.dart';
import 'material_request_form_screen.dart';

class MaterialRequestsScreen extends StatelessWidget {
  const MaterialRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AppDataProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Material Requests')),
      body: data.requests.isEmpty
          ? const EmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'No requests yet',
              message: 'Create a material request for a construction site.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: data.requests.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final req = data.requests[index];
                final site = data.siteById(req.siteId);
                final supplier = req.assignedSupplierId == null
                    ? null
                    : data.supplierById(req.assignedSupplierId!);
                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            MaterialRequestDetailScreen(requestId: req.id),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                req.materialName,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                            StatusChip.request(req.status),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${req.requiredQuantity} ${req.unit} • ${req.category}',
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${site?.siteName ?? 'Site'} → ${supplier?.companyName ?? 'Unassigned'}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Required ${dateFmt.format(req.requiredDate)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'admin-add-request-fab',
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const MaterialRequestFormScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('New request'),
      ),
    );
  }
}
