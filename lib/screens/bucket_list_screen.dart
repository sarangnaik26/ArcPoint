import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/novel_provider.dart';
import '../widgets/grid_novel_card.dart';
import '../models/novel_status.dart';
import 'novel_dashboard.dart';
import '../services/status_change_service.dart';

class BucketListScreen extends StatelessWidget {
  const BucketListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final novelProvider = context.watch<NovelProvider>();
    final bucketList = novelProvider.bucketList;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bucket List',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: bucketList.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_outline_rounded,
                    size: 64,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withAlpha(128),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your bucket list is empty.',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.70, // Adjusted aspect ratio for better fit
              ),
              itemCount: bucketList.length,
              itemBuilder: (context, index) {
                final novel = bucketList[index];
                return GridNovelCard(
                  novel: novel,
                  isPinned: novel.priority == 1,
                  onPinToggle: () => novelProvider.togglePriority(novel),
                  onPlay: () => StatusChangeService.changeStatus(
                    context,
                    novel,
                    NovelStatus.reading,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NovelDashboard(novel: novel),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
