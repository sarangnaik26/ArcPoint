import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/novel_provider.dart';
import '../widgets/grid_novel_card.dart';
import '../models/novel_status.dart';
import 'novel_dashboard.dart';

class CompletedScreen extends StatefulWidget {
  const CompletedScreen({super.key});

  @override
  State<CompletedScreen> createState() => _CompletedScreenState();
}

class _CompletedScreenState extends State<CompletedScreen> {
  bool _showDropped = false;

  @override
  Widget build(BuildContext context) {
    final novelProvider = context.watch<NovelProvider>();
    final theme = Theme.of(context);

    final completedNovels = novelProvider.novels
        .where((n) => n.status == NovelStatus.completed)
        .toList();
    final droppedNovels = novelProvider.novels
        .where((n) => n.status == NovelStatus.dropped)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Past Adventures',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Row(
            children: [
              Text('Show Dropped', style: theme.textTheme.labelSmall),
              Switch(
                value: _showDropped,
                onChanged: (v) => setState(() => _showDropped = v),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: completedNovels.isEmpty && (!_showDropped || droppedNovels.isEmpty)
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.auto_stories_outlined,
                    size: 64,
                    color: theme.colorScheme.onSurfaceVariant.withAlpha(128),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No completed novels yet.',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          : CustomScrollView(
              slivers: [
                if (completedNovels.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.70,
                          ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final novel = completedNovels[index];
                        return GridNovelCard(
                          novel: novel,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  NovelDashboard(novel: novel),
                            ),
                          ),
                        );
                      }, childCount: completedNovels.length),
                    ),
                  ),
                if (_showDropped && droppedNovels.isNotEmpty) ...[
                  if (completedNovels.isNotEmpty)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Divider(height: 32),
                      ),
                    ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 16, 16),
                      child: Text(
                        'Dropped Novels',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.70,
                          ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final novel = droppedNovels[index];
                        return GridNovelCard(
                          novel: novel,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  NovelDashboard(novel: novel),
                            ),
                          ),
                        );
                      }, childCount: droppedNovels.length),
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}
