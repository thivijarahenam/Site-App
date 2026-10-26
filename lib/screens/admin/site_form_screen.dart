import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../providers/app_data_provider.dart';
import '../../widgets/common_widgets.dart';

class SiteFormScreen extends StatefulWidget {
  const SiteFormScreen({super.key, this.site});

  final ConstructionSite? site;

  @override
  State<SiteFormScreen> createState() => _SiteFormScreenState();
}

class _SiteFormScreenState extends State<SiteFormScreen> {
  late final TextEditingController _siteName;
  late final TextEditingController _projectName;
  late final TextEditingController _address;
  late final TextEditingController _client;
  late final TextEditingController _description;
  late SiteStatus _status;
  late DateTime _start;
  late DateTime _end;
  late List<String> _assigned;

  @override
  void initState() {
    super.initState();
    final s = widget.site;
    _siteName = TextEditingController(text: s?.siteName ?? '');
    _projectName = TextEditingController(text: s?.projectName ?? '');
    _address = TextEditingController(text: s?.address ?? '');
    _client = TextEditingController(text: s?.clientName ?? '');
    _description = TextEditingController(text: s?.description ?? '');
    _status = s?.status ?? SiteStatus.active;
    _start = s?.startDate ?? DateTime.now();
    _end = s?.expectedCompletion ?? DateTime.now().add(const Duration(days: 180));
    _assigned = [...(s?.assignedLabourIds ?? [])];
  }

  @override
  void dispose() {
    _siteName.dispose();
    _projectName.dispose();
    _address.dispose();
    _client.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool start}) async {
    final initial = start ? _start : _end;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked == null) return;
    setState(() {
      if (start) {
        _start = picked;
      } else {
        _end = picked;
      }
    });
  }

  void _save() {
    if (_siteName.text.trim().isEmpty || _projectName.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Site name and project name are required')),
      );
      return;
    }

    final data = context.read<AppDataProvider>();
    final id = widget.site?.id ?? 'site-${DateTime.now().millisecondsSinceEpoch}';
    final site = ConstructionSite(
      id: id,
      siteName: _siteName.text.trim(),
      projectName: _projectName.text.trim(),
      address: _address.text.trim(),
      clientName: _client.text.trim(),
      startDate: _start,
      expectedCompletion: _end,
      status: _status,
      description: _description.text.trim(),
      assignedLabourIds: _assigned,
    );
    data.upsertSite(site);

    // Sync labour currentSiteId for selected labours.
    for (final labour in data.labours) {
      final shouldAssign = _assigned.contains(labour.id);
      if (shouldAssign && labour.currentSiteId != id) {
        data.upsertLabour(labour.copyWith(currentSiteId: id));
      } else if (!shouldAssign && labour.currentSiteId == id) {
        data.upsertLabour(labour.copyWith(clearSite: true));
      }
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final labours = context.watch<AppDataProvider>().labours;
    final editing = widget.site != null;

    return Scaffold(
      appBar: AppBar(title: Text(editing ? 'Edit site' : 'Create site')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _siteName,
            decoration: const InputDecoration(labelText: 'Site name'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _projectName,
            decoration: const InputDecoration(labelText: 'Project name'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _address,
            decoration: const InputDecoration(labelText: 'Site address'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _client,
            decoration: const InputDecoration(labelText: 'Client name'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<SiteStatus>(
            initialValue: _status,
            decoration: const InputDecoration(labelText: 'Site status'),
            items: SiteStatus.values
                .map(
                  (s) => DropdownMenuItem(
                    value: s,
                    child: Text(s.name),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => _status = v ?? _status),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _pickDate(start: true),
                  child: Text('Start: ${dateFmt.format(_start)}'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _pickDate(start: false),
                  child: Text('End: ${dateFmt.format(_end)}'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _description,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Description'),
          ),
          const SizedBox(height: 16),
          Text('Assigned labourers',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...labours.map((labour) {
            final checked = _assigned.contains(labour.id);
            return CheckboxListTile(
              value: checked,
              contentPadding: EdgeInsets.zero,
              title: Text(labour.fullName),
              subtitle: Text(labour.jobRole),
              onChanged: (v) {
                setState(() {
                  if (v == true) {
                    _assigned.add(labour.id);
                  } else {
                    _assigned.remove(labour.id);
                  }
                });
              },
            );
          }),
          const SizedBox(height: 20),
          FilledButton(onPressed: _save, child: Text(editing ? 'Save changes' : 'Create site')),
        ],
      ),
    );
  }
}
