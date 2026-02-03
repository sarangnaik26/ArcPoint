import 'dart:io';
import 'package:flutter/material.dart';
import '../models/novel.dart';
import '../models/novel_status.dart';

class GridNovelCard extends StatelessWidget {
  final bool isPinned;
  final VoidCallback? onPinToggle;
  final VoidCallback? onPlay;
  final Novel novel;
  final VoidCallback onTap;

  const GridNovelCard({
    super.key,
    required this.novel,
    required this.onTap,
    this.isPinned = false,
    this.onPinToggle,
    this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cover Image with Pin Overlay
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  novel.coverPath != null
                      ? Image.file(File(novel.coverPath!), fit: BoxFit.cover)
                      : Container(
                          color: colorScheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.book_rounded,
                            color: colorScheme.onSurfaceVariant.withAlpha(128),
                            size: 48,
                          ),
                        ),
                  if (onPinToggle != null)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: onPinToggle,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: isPinned
                                  ? colorScheme.primary.withAlpha(200)
                                  : Colors.black.withAlpha(100),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isPinned
                                  ? Icons.push_pin_rounded
                                  : Icons.push_pin_outlined,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    novel.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (novel.author != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      novel.author!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatusChip(context),
                      if (onPlay != null)
                        InkWell(
                          onTap: onPlay,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.play_arrow_rounded,
                              size: 16,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: chipColor.withAlpha(40),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        novel.status.displayName,
        style: theme.textTheme.labelSmall?.copyWith(
          color: chipColor,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }
}
