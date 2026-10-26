import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../providers/app_data_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class RequestHistoryScreen extends StatelessWidget {
  const RequestHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user!;
    final data = context.watch<AppDataProvider>();
    final history = data
        .requestsForSupplier(user.linkedId ?? '')
        .where((r) =>
            r.status == MaterialRequestStatus.approved ||
            r.status == MaterialRequestStatus.rejected ||
            r.status == MaterialRequestStatus.completed ||
            r.response != null)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Request history')),
      body: history.isEmpty
          ? const EmptyState(
              icon: Icons.history,
              title: 'No history yet',
              message: 'Previous submissions and approvals will show here.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final req = history[index];
                final response = req.response;
                return Container(
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
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          StatusChip.request(req.status),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text('${req.requiredQuantity} ${req.unit}'),
                      if (response != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          'Quoted LKR ${response.totalPrice.toStringAsFixed(0)} • ${dateFmt.format(response.submittedAt)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
    );
  }
}
