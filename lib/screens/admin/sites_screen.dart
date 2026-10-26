import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_data_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../project/project_logbook_screen.dart';
import 'site_form_screen.dart';

class SitesScreen extends StatelessWidget {
  const SitesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AppDataProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Construction Sites'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SiteFormScreen()),
              );
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: data.sites.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final site = data.sites[index];
          final labourCount = site.assignedLabourIds.length;
          return InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProjectLogbookScreen(project: site),
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
                          site.siteName,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      StatusChip.site(site.status),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(site.projectName),
                  const SizedBox(height: 8),
                  Text(site.address,
                      style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _MetaChip(
                        icon: Icons.person_outline,
                        label: site.clientName,
                      ),
                      _MetaChip(
                        icon: Icons.groups_outlined,
                        label: '$labourCount labour',
                      ),
                      _MetaChip(
                        icon: Icons.event,
                        label: dateFmt.format(site.expectedCompletion),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'admin-add-site-fab',
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SiteFormScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add site'),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.mist,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.slate),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
