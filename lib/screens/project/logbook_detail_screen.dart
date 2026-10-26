import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../providers/app_data_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

class LogbookDetailScreen extends StatefulWidget {
  final ProjectLogbookEntry entry;

  const LogbookDetailScreen({super.key, required this.entry});

  @override
  State<LogbookDetailScreen> createState() => _LogbookDetailScreenState();
}

class _LogbookDetailScreenState extends State<LogbookDetailScreen> {
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _sendComment(AppDataProvider data, AppUser user) {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final newComment = LogbookComment(
      id: 'c-${DateTime.now().millisecondsSinceEpoch}',
      authorName: user.name,
      authorRole: user.role.label,
      text: text,
      timestamp: DateTime.now(),
      avatarUrl: user.avatarUrl,
    );

    data.addLogbookComment(widget.entry.id, newComment);
    _commentController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AppDataProvider>();
    final user = context.watch<AuthProvider>().user!;

    // Retrieve fresh entry from provider
    final entry = data.logbookEntries.firstWhere(
      (e) => e.id == widget.entry.id,
      orElse: () => widget.entry,
    );

    final dateFormat = DateFormat('d MMM yyyy, hh:mm a');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Log #${entry.id.replaceAll('log-', '')}'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Log entry shared with site team.')),
              );
            },
            icon: const Icon(Icons.share_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Author Card & Category
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundImage: entry.authorAvatar != null
                                  ? NetworkImage(entry.authorAvatar!)
                                  : null,
                              backgroundColor: AppColors.pastelBlueBg,
                              child: entry.authorAvatar == null
                                  ? Text(entry.authorName[0])
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entry.authorName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                      color: AppColors.primaryNavy,
                                    ),
                                  ),
                                  Text(
                                    '${entry.authorRole} • ${dateFormat.format(entry.date)}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.pastelPurpleBg,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                entry.category.label,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.pastelPurpleText,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          entry.title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryNavy,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          entry.description,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Site Photos Gallery
                  if (entry.photoUrls.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Site Photos',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 110,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: entry.photoUrls.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, i) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.network(
                              entry.photoUrls[i],
                              width: 130,
                              height: 110,
                              fit: BoxFit.cover,
                            ),
                          );
                        },
                      ),
                    ),
                  ],

                  // Attachments Section
                  if (entry.attachments.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    const Text(
                      'Attachments',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...entry.attachments.map((att) {
                      final isPdf = att.extension.toLowerCase() == 'pdf';
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: isPdf
                                    ? AppColors.pastelRedBg
                                    : AppColors.pastelBlueBg,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                isPdf
                                    ? Icons.picture_as_pdf_rounded
                                    : Icons.image_rounded,
                                color: isPdf
                                    ? AppColors.pastelRedText
                                    : AppColors.pastelBlueText,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    att.name,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryNavy,
                                    ),
                                  ),
                                  Text(
                                    att.size,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Downloading ${att.name}...')),
                                );
                              },
                              icon: const Icon(Icons.download_rounded, size: 20),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],

                  // Linked Items
                  if (entry.linkedItems.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceTint,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.link_rounded, size: 18, color: AppColors.primaryOrange),
                          const SizedBox(width: 8),
                          const Text(
                            'Linked: ',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryNavy,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              entry.linkedItems.join(', '),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Owner Acknowledgment Card
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: entry.isAcknowledged
                          ? const Color(0xFFF0FDF4)
                          : const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: entry.isAcknowledged
                            ? const Color(0xFFBBF7D0)
                            : const Color(0xFFFDE68A),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          entry.isAcknowledged
                              ? Icons.check_circle_rounded
                              : Icons.pending_actions_rounded,
                          color: entry.isAcknowledged
                              ? const Color(0xFF16A34A)
                              : const Color(0xFFD97706),
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.isAcknowledged
                                    ? 'Acknowledged ✓'
                                    : 'Awaiting Owner Acknowledgment',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: entry.isAcknowledged
                                      ? const Color(0xFF166534)
                                      : const Color(0xFF92400E),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                entry.isAcknowledged
                                    ? 'Signed by ${entry.acknowledgedBy} on ${dateFormat.format(entry.acknowledgedAt ?? entry.date)}'
                                    : 'Sign-off required before contractor proceeds with change.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: entry.isAcknowledged
                                      ? const Color(0xFF166534)
                                      : const Color(0xFF92400E),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!entry.isAcknowledged)
                          FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primaryOrange,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              minimumSize: const Size(80, 36),
                            ),
                            onPressed: () {
                              data.acknowledgeLogbookEntry(
                                entry.id,
                                '${user.name} (${user.role.label})',
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Logbook entry successfully acknowledged!'),
                                ),
                              );
                            },
                            child: const Text('Sign Off', style: TextStyle(fontSize: 12)),
                          ),
                      ],
                    ),
                  ),

                  // Discussion / Comments Thread
                  const SizedBox(height: 22),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Discussion (${entry.comments.length})',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryNavy,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...entry.comments.map((comm) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundImage: comm.avatarUrl != null
                                    ? NetworkImage(comm.avatarUrl!)
                                    : null,
                                backgroundColor: AppColors.surfaceTint,
                                child: comm.avatarUrl == null
                                    ? Text(comm.authorName[0],
                                        style: const TextStyle(fontSize: 10))
                                    : null,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                comm.authorName,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryNavy,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceTint,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  comm.authorRole,
                                  style: const TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                DateFormat('hh:mm a').format(comm.timestamp),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            comm.text,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // Bottom Reply Input Field
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.cardBorder)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Write a note or reply...',
                      fillColor: AppColors.background,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton.filled(
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(48, 48),
                  ),
                  onPressed: () => _sendComment(data, user),
                  icon: const Icon(Icons.send_rounded, size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
