import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/novel_provider.dart';

class NovelSelectorDialog extends StatelessWidget {
  final String title;

  const NovelSelectorDialog({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final novelProvider = context.watch<NovelProvider>();
    final novels = novelProvider.novels; // Assumes sorted

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (novels.isEmpty)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'No novels found. Add a novel first.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: novels.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1, indent: 16, endIndent: 16),
                  itemBuilder: (context, index) {
                    final novel = novels[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      leading: Container(
                        width: 40,
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: theme.colorScheme.surfaceContainerHighest,
                          image: novel.coverPath != null
                              ? DecorationImage(
                                  image: FileImage(File(novel.coverPath!)),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: novel.coverPath == null
                            ? Icon(
                                Icons.book,
                                size: 20,
                                color: theme.colorScheme.onSurfaceVariant,
                              )
                            : null,
                      ),
                      title: Text(
                        novel.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      onTap: () => Navigator.pop(context, novel),
                    );
                  },
                ),
              ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
