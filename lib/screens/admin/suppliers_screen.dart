import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../providers/app_data_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import 'supplier_form_screen.dart';

class SuppliersScreen extends StatelessWidget {
  const SuppliersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AppDataProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Suppliers')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: data.suppliers.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final supplier = data.suppliers[index];
          final reqCount = data.requests
              .where((r) => r.assignedSupplierId == supplier.id)
              .length;
          return InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SupplierFormScreen(supplier: supplier),
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
                          supplier.companyName,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      StatusChip(
                        label: supplier.status.name,
                        color: supplier.status == CompanyStatus.active
                            ? AppColors.teal
                            : AppColors.slate,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('${supplier.contactPerson} • ${supplier.phone}'),
                  const SizedBox(height: 8),
                  Text(
                    supplier.materialsSupplied.join(' • '),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$reqCount linked material requests',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'admin-add-supplier-fab',
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SupplierFormScreen()),
          );
        },
        icon: const Icon(Icons.add_business),
        label: const Text('Add supplier'),
      ),
    );
  }
}
