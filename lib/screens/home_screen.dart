import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/novel_provider.dart';
import '../models/novel_status.dart';
import '../widgets/grid_novel_card.dart';
import 'novel_dashboard.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final novelProvider = context.watch<NovelProvider>();
    final theme = Theme.of(context);

    final readingNovels = novelProvider.novels
        .where((n) => n.status == NovelStatus.reading)
        .toList();
    final onHoldNovels = novelProvider.novels
        .where((n) => n.status == NovelStatus.onHold)
        .toList();

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _SectionCard(
          title: 'Currently Reading',
          novels: readingNovels,
          emptyMessage: 'No novels in progress. Start something new!',
          accentColor: theme.colorScheme.primary,
        ),

        const SizedBox(height: 24),
        _SectionCard(
          title: 'On Hold',
          novels: onHoldNovels,
          emptyMessage: 'No novels on hold.',
          accentColor: theme.colorScheme.secondary,
        ),
        const SizedBox(height: 80), // Space for FAB
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List novels;
  final String emptyMessage;
  final Color accentColor;

  const _SectionCard({
    required this.title,
    required this.novels,
    required this.emptyMessage,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${novels.length}',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: accentColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (novels.isEmpty)
          Card(
            elevation: 0,
            color: theme.colorScheme.surfaceContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
              child: Center(
                child: Text(
                  emptyMessage,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.75, // Adjust based on card design
            ),
            itemCount: novels.length,
            itemBuilder: (context, index) {
              final novel = novels[index];
              return GridNovelCard(
                novel: novel,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NovelDashboard(novel: novel),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
