import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../providers/app_data_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import 'quotation_form_screen.dart';

class SupplierRequestsScreen extends StatelessWidget {
  const SupplierRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user!;
    final data = context.watch<AppDataProvider>();
    final requests = data
        .requestsForSupplier(user.linkedId ?? '')
        .where((r) =>
            r.status == MaterialRequestStatus.awaitingResponse ||
            r.status == MaterialRequestStatus.pending ||
            r.status == MaterialRequestStatus.responseReceived)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Material Requests')),
      body: requests.isEmpty
          ? const EmptyState(
              icon: Icons.inbox_outlined,
              title: 'No active requests',
              message: 'Assigned material requests from Admin appear here.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: requests.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final req = requests[index];
                final site = data.siteById(req.siteId);
                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            QuotationFormScreen(requestId: req.id),
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
                          '${req.requiredQuantity} ${req.unit} • ${site?.siteName ?? 'Site'}',
                        ),
                        const SizedBox(height: 4),
                        Text(
                          req.response == null
                              ? 'Tap to submit quotation'
                              : 'Response submitted • view / update',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
