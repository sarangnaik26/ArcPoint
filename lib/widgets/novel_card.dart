import 'dart:io';
import 'package:flutter/material.dart';
import '../models/novel.dart';
import '../models/novel_status.dart';

class NovelCard extends StatelessWidget {
  final Novel novel;
  final VoidCallback onTap;
  final Widget? actionButton;

  const NovelCard({
    super.key,
    required this.novel,
    required this.onTap,
    this.actionButton,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withAlpha(128),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Cover Image
              SizedBox(
                width: 100,
                child: novel.coverPath != null
                    ? Image.file(File(novel.coverPath!), fit: BoxFit.cover)
                    : Container(
                        color: colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.book_rounded,
                          color: colorScheme.onSurfaceVariant.withAlpha(128),
                          size: 32,
                        ),
                      ),
              ),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        novel.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (novel.author != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          novel.author!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStatusChip(context),
                          if (actionButton != null) actionButton!,
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    final theme = Theme.of(context);
    Color chipColor;

    switch (novel.status) {
      case NovelStatus.reading:
        chipColor = theme.colorScheme.primary;
        break;
      case NovelStatus.onHold:
        chipColor = theme.colorScheme.tertiary;
        break;
      case NovelStatus.bucketList:
        chipColor = theme.colorScheme.secondary;
        break;
      case NovelStatus.completed:
        chipColor = Colors.green;
        break;
      case NovelStatus.dropped:
        chipColor = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withAlpha(51),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: chipColor.withAlpha(128)),
      ),
      child: Text(
        novel.status.displayName,
        style: theme.textTheme.labelSmall?.copyWith(
          color: chipColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
