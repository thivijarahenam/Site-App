import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/app_data_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/dashboard_widgets.dart';
import 'add_logbook_entry_screen.dart';
import 'logbook_detail_screen.dart';

class ProjectLogbookScreen extends StatefulWidget {
  final ConstructionSite project;

  const ProjectLogbookScreen({super.key, required this.project});

  @override
  State<ProjectLogbookScreen> createState() => _ProjectLogbookScreenState();
}

class _ProjectLogbookScreenState extends State<ProjectLogbookScreen> {
  int _selectedTabIndex = 4; // Default to 'Logbook' tab
  String _searchQuery = '';
  LogbookCategory? _selectedCategoryFilter;

  final List<String> _tabs = [
    'Overview',
    'Tasks',
    'Labour',
    'Materials',
    'Logbook',
    'More',
  ];

  Color _categoryBg(LogbookCategory cat) {
    switch (cat) {
      case LogbookCategory.designChange:
        return AppColors.pastelPurpleBg;
      case LogbookCategory.costVariation:
        return AppColors.pastelOrangeBg;
      case LogbookCategory.siteObservation:
        return AppColors.pastelBlueBg;
      case LogbookCategory.clientRequest:
        return AppColors.pastelGreenBg;
      case LogbookCategory.siteInstruction:
        return AppColors.pastelAmberBg;
      case LogbookCategory.inspectionQA:
        return AppColors.pastelTealBg;
      default:
        return AppColors.surfaceTint;
    }
  }

  Color _categoryText(LogbookCategory cat) {
    switch (cat) {
      case LogbookCategory.designChange:
        return AppColors.pastelPurpleText;
      case LogbookCategory.costVariation:
        return AppColors.pastelOrangeText;
      case LogbookCategory.siteObservation:
        return AppColors.pastelBlueText;
      case LogbookCategory.clientRequest:
        return AppColors.pastelGreenText;
      case LogbookCategory.siteInstruction:
        return AppColors.pastelAmberText;
      case LogbookCategory.inspectionQA:
        return AppColors.pastelTealText;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AppDataProvider>();
    final allEntries = data.logbookEntriesForProject(widget.project.id);

    final filteredEntries = allEntries.where((e) {
      if (_selectedCategoryFilter != null && e.category != _selectedCategoryFilter) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return e.title.toLowerCase().contains(query) ||
            e.description.toLowerCase().contains(query) ||
            e.authorName.toLowerCase().contains(query);
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.project.projectName),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            onPressed: () {},
          ),
        ],
      ),
      floatingActionButton: _selectedTabIndex == 4
          ? FloatingActionButton(
              backgroundColor: AppColors.primaryOrange,
              foregroundColor: Colors.white,
              shape: const CircleBorder(),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        AddLogbookEntryScreen(projectId: widget.project.id),
                  ),
                );
              },
              child: const Icon(Icons.add_rounded, size: 28),
            )
          : null,
      body: Column(
        children: [
          // Project Summary Header Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: Colors.white,
            child: Row(
              children: [
                CircularProgressBadge(
                  progress: widget.project.progress,
                  size: 46,
                  strokeWidth: 4.5,
                  progressColor: const Color(0xFF10B981),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAF7EE),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'In Progress',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF16A34A),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.project.contractValue,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryNavy,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        widget.project.address,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Horizontal Navigation Tabs
          Container(
            height: 48,
            color: Colors.white,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: _tabs.length,
              itemBuilder: (context, index) {
                final isSelected = index == _selectedTabIndex;
                return InkWell(
                  onTap: () => setState(() => _selectedTabIndex = index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isSelected
                              ? AppColors.primaryOrange
                              : Colors.transparent,
                          width: 2.5,
                        ),
                      ),
                    ),
                    child: Text(
                      _tabs[index],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected
                            ? AppColors.primaryOrange
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Main Tab Body
          Expanded(
            child: _selectedTabIndex == 4
                ? _buildLogbookTab(filteredEntries)
                : _buildOtherTab(_tabs[_selectedTabIndex]),
          ),
        ],
      ),
    );
  }

  Widget _buildLogbookTab(List<ProjectLogbookEntry> entries) {
    return Column(
      children: [
        // Search & Filter Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Search logbook entries...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    fillColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: IconButton(
                  icon: const Icon(Icons.tune_rounded, size: 20),
                  onPressed: () {
                    // Reset category filter if pressed
                    setState(() {
                      _selectedCategoryFilter = null;
                    });
                  },
                ),
              ),
            ],
          ),
        ),

        // Category Filter Chips
        SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            children: [
              _buildFilterChip('All', null),
              _buildFilterChip('Design Change', LogbookCategory.designChange),
              _buildFilterChip('Cost Approval', LogbookCategory.costVariation),
              _buildFilterChip('Site Observation', LogbookCategory.siteObservation),
              _buildFilterChip('Client Request', LogbookCategory.clientRequest),
              _buildFilterChip('Instruction', LogbookCategory.siteInstruction),
              _buildFilterChip('Inspection / QA', LogbookCategory.inspectionQA),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Entries Timeline List
        Expanded(
          child: entries.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.notes_rounded, size: 48, color: AppColors.textMuted),
                      SizedBox(height: 12),
                      Text(
                        'No logbook entries found',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(18, 6, 18, 80),
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final item = entries[index];
                    return _buildLogbookEntryCard(item);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, LogbookCategory? category) {
    final isSelected = _selectedCategoryFilter == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: AppColors.primaryNavy,
        backgroundColor: Colors.white,
        labelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isSelected ? Colors.white : AppColors.textSecondary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isSelected ? AppColors.primaryNavy : AppColors.cardBorder,
          ),
        ),
        showCheckmark: false,
        onSelected: (_) {
          setState(() {
            _selectedCategoryFilter = category;
          });
        },
      ),
    );
  }

  Widget _buildLogbookEntryCard(ProjectLogbookEntry item) {
    final dateFormat = DateFormat('d MMM, hh:mm a');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => LogbookDetailScreen(entry: item),
              ),
            );
          },
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Author, Role, Date, Category Badge
                Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundImage: item.authorAvatar != null
                          ? NetworkImage(item.authorAvatar!)
                          : null,
                      backgroundColor: AppColors.surfaceTint,
                      child: item.authorAvatar == null
                          ? Text(item.authorName[0], style: const TextStyle(fontSize: 10))
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.authorName,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryNavy,
                            ),
                          ),
                          Text(
                            '${item.authorRole} • ${dateFormat.format(item.date)}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _categoryBg(item.category),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.category.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: _categoryText(item.category),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Title
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryNavy,
                  ),
                ),
                const SizedBox(height: 4),

                // Description
                Text(
                  item.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),

                // Photos Thumbnails preview
                if (item.photoUrls.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 52,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: item.photoUrls.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, i) => ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item.photoUrls[i],
                          width: 64,
                          height: 52,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 8),

                // Bottom Indicators Row
                Row(
                  children: [
                    if (item.attachments.isNotEmpty) ...[
                      const Icon(Icons.attach_file_rounded,
                          size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 3),
                      Text(
                        '${item.attachments.length} files',
                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                      const SizedBox(width: 12),
                    ],
                    if (item.comments.isNotEmpty) ...[
                      const Icon(Icons.chat_bubble_outline_rounded,
                          size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 3),
                      Text(
                        '${item.comments.length} comments',
                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                      const SizedBox(width: 12),
                    ],
                    const Spacer(),
                    if (item.isAcknowledged)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check, size: 12, color: Color(0xFF16A34A)),
                            SizedBox(width: 3),
                            Text(
                              'Acknowledged',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF16A34A),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF9E7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Pending Sign-off',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFD97706),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOtherTab(String title) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title Details',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryNavy,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.project.projectName} • $title',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.project.description,
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Contract: ${widget.project.contractValue}',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                    Text('Margin: ${widget.project.margin}%',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: Color(0xFF16A34A))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
