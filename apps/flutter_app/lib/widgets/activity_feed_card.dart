import 'package:flutter/material.dart';

enum ActivityCategory {
  all,
  pushes,
  commits,
  prs,
  issues,
  repo,
  peer,
  replication,
}

class ActivityItem {
  final String id;
  final ActivityCategory category;
  final String typeLabel;
  final String title;
  final String repoOrTarget;
  final String timeAgo;
  final String? detail;
  final String? shaOrMeta;

  const ActivityItem({
    required this.id,
    required this.category,
    required this.typeLabel,
    required this.title,
    required this.repoOrTarget,
    required this.timeAgo,
    this.detail,
    this.shaOrMeta,
  });
}

class ActivityFeedCard extends StatelessWidget {
  final ActivityItem item;
  final bool isCompact;

  const ActivityFeedCard({
    super.key,
    required this.item,
    this.isCompact = false,
  });

  Color _getCategoryColor() {
    switch (item.category) {
      case ActivityCategory.pushes:
        return const Color(0xFF2F81F7); // Blue
      case ActivityCategory.commits:
        return const Color(0xFF38BDF8); // Cyan
      case ActivityCategory.prs:
        return const Color(0xFFA371F7); // Purple
      case ActivityCategory.issues:
        return const Color(0xFFF85149); // Red
      case ActivityCategory.repo:
        return const Color(0xFFD29922); // Amber
      case ActivityCategory.peer:
        return const Color(0xFF238636); // Green
      case ActivityCategory.replication:
        return const Color(0xFFF0883E); // Orange
      case ActivityCategory.all:
        return const Color(0xFF58A6FF);
    }
  }

  IconData _getCategoryIcon() {
    switch (item.category) {
      case ActivityCategory.pushes:
        return Icons.upload_rounded;
      case ActivityCategory.commits:
        return Icons.commit_rounded;
      case ActivityCategory.prs:
        return Icons.merge_type_rounded;
      case ActivityCategory.issues:
        return Icons.adjust_rounded;
      case ActivityCategory.repo:
        return Icons.folder_copy_outlined;
      case ActivityCategory.peer:
        return Icons.hub_rounded;
      case ActivityCategory.replication:
        return Icons.cloud_sync_rounded;
      case ActivityCategory.all:
        return Icons.timeline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = _getCategoryColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(isCompact ? 12 : 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B22) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Distinct Category Indicator Circle
          Container(
            width: isCompact ? 32 : 38,
            height: isCompact ? 32 : 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
            ),
            child: Center(
              child: Icon(
                _getCategoryIcon(),
                color: color,
                size: isCompact ? 16 : 20,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Activity Content Body
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Dot Bullet
                    Container(
                      width: 7,
                      height: 7,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 4),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item.title,
                        style: TextStyle(
                          fontSize: isCompact ? 13 : 14,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item.timeAgo,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Repository / Target Name
                Row(
                  children: [
                    Icon(
                      item.category == ActivityCategory.peer
                          ? Icons.devices_outlined
                          : Icons.bookmark_outline_rounded,
                      size: 13,
                      color: const Color(0xFF58A6FF),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        item.repoOrTarget,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF58A6FF),
                          fontFamily: 'monospace',
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                // Optional Detail or SHA Badge
                if (item.detail != null || item.shaOrMeta != null) ...[
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0D1117) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isDark ? const Color(0xFF21262D) : Colors.grey.shade300,
                      ),
                    ),
                    child: Row(
                      children: [
                        if (item.shaOrMeta != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              item.shaOrMeta!,
                              style: TextStyle(
                                fontSize: 11,
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        if (item.detail != null)
                          Expanded(
                            child: Text(
                              item.detail!,
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
