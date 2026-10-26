import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../providers/app_data_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

class AddLogbookEntryScreen extends StatefulWidget {
  final String projectId;

  const AddLogbookEntryScreen({super.key, required this.projectId});

  @override
  State<AddLogbookEntryScreen> createState() => _AddLogbookEntryScreenState();
}

class _AddLogbookEntryScreenState extends State<AddLogbookEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  LogbookCategory _selectedCategory = LogbookCategory.siteInstruction;
  final List<String> _selectedStakeholders = ['Architect', 'Structural Engineer'];
  final List<LogbookAttachment> _attachments = [];

  final List<String> _stakeholders = [
    'Architect',
    'Structural Engineer',
    'Client',
    'Owner',
    'Contractor',
    'MEP Engineer',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _addSampleAttachment() {
    setState(() {
      _attachments.add(
        LogbookAttachment(
          name: 'Site-Inspection-Photo-${_attachments.length + 1}.jpg',
          size: '2.1 MB',
          extension: 'jpg',
        ),
      );
    });
  }

  void _save(AppDataProvider data, AppUser user) {
    if (!_formKey.currentState!.validate()) return;

    final newEntry = ProjectLogbookEntry(
      id: 'log-${DateTime.now().millisecondsSinceEpoch}',
      projectId: widget.projectId,
      date: DateTime.now(),
      authorName: user.name,
      authorRole: user.role.label,
      authorAvatar: user.avatarUrl,
      category: _selectedCategory,
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      attachments: _attachments,
      linkedItems: _selectedStakeholders.isNotEmpty
          ? ['Notified: ${_selectedStakeholders.join(", ")}']
          : const [],
      isAcknowledged: false,
    );

    data.addLogbookEntry(newEntry);
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Logbook entry created and synced with project stakeholders!'),
      ),
    );
  }

  IconData _iconForCategory(LogbookCategory cat) {
    switch (cat) {
      case LogbookCategory.generalNote:
        return Icons.note_alt_outlined;
      case LogbookCategory.designChange:
        return Icons.architecture_rounded;
      case LogbookCategory.siteInstruction:
        return Icons.assignment_outlined;
      case LogbookCategory.siteObservation:
        return Icons.visibility_outlined;
      case LogbookCategory.costVariation:
        return Icons.monetization_on_outlined;
      case LogbookCategory.clientRequest:
        return Icons.support_agent_rounded;
      case LogbookCategory.inspectionQA:
        return Icons.verified_outlined;
      case LogbookCategory.meetingNote:
        return Icons.groups_outlined;
      case LogbookCategory.other:
        return Icons.more_horiz_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = context.read<AppDataProvider>();
    final user = context.watch<AuthProvider>().user!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('New Logbook Entry'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Category',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryNavy,
                ),
              ),
              const SizedBox(height: 10),

              // 9-Category Grid Selector
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.15,
                ),
                itemCount: LogbookCategory.values.length,
                itemBuilder: (context, index) {
                  final cat = LogbookCategory.values[index];
                  final isSelected = cat == _selectedCategory;
                  return InkWell(
                    onTap: () => setState(() => _selectedCategory = cat),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryOrange
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryOrange
                              : AppColors.cardBorder,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _iconForCategory(cat),
                            size: 22,
                            color: isSelected ? Colors.white : AppColors.primaryNavy,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            cat.label,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? Colors.white : AppColors.primaryNavy,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Title
              const Text(
                'Title',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryNavy,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'e.g. Window Size Variation or Concrete Blinding',
                ),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Please enter a title' : null,
              ),

              const SizedBox(height: 18),

              // Description
              const Text(
                'Description & Instructions',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryNavy,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Provide complete details, instructions, or observations for the project logbook...',
                ),
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'Please enter a description'
                    : null,
              ),

              const SizedBox(height: 18),

              // Attachments Container
              const Text(
                'Attachments',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryNavy,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _addSampleAttachment,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primaryOrange.withValues(alpha: 0.5),
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Column(
                    children: const [
                      Icon(Icons.cloud_upload_outlined,
                          size: 32, color: AppColors.primaryOrange),
                      SizedBox(height: 6),
                      Text(
                        'Tap to upload drawing or site photo',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryOrange,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Supports PDF, JPG, PNG up to 25MB',
                        style: TextStyle(fontSize: 10, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ),

              if (_attachments.isNotEmpty) ...[
                const SizedBox(height: 10),
                ..._attachments.map((a) => Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.attachment, size: 16, color: AppColors.primaryNavy),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              a.name,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ),
                          Text(a.size, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                        ],
                      ),
                    )),
              ],

              const SizedBox(height: 18),

              // Stakeholder Tagging
              const Text(
                'Notify Stakeholders',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryNavy,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _stakeholders.map((role) {
                  final isTag = _selectedStakeholders.contains(role);
                  return FilterChip(
                    selected: isTag,
                    label: Text(role),
                    selectedColor: AppColors.pastelOrangeBg,
                    labelStyle: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isTag ? AppColors.primaryOrange : AppColors.primaryNavy,
                    ),
                    checkmarkColor: AppColors.primaryOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isTag ? AppColors.primaryOrange : AppColors.cardBorder,
                      ),
                    ),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedStakeholders.add(role);
                        } else {
                          _selectedStakeholders.remove(role);
                        }
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 30),

              // Save CTA
              FilledButton(
                onPressed: () => _save(data, user),
                child: const Text('Save Logbook Entry'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
