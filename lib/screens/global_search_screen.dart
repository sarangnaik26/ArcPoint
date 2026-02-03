import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/novel_provider.dart';
import '../models/novel.dart';
import 'novel_dashboard.dart';

class GlobalSearchScreen extends StatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Novel> _searchResults = [];
  String _query = '';

  @override
  void initState() {
    super.initState();
    // Initialize with all novels or empty? Let's start empty or recent.
    // Usually empty state with "Start typing..." is better.
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query, List<Novel> allNovels) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _query = '';
      });
      return;
    }

    final lowerQuery = query.toLowerCase();
    final results = allNovels.where((novel) {
      final name = novel.name.toLowerCase();
      final author = novel.author?.toLowerCase() ?? '';
      final tags = novel.genreTags?.toLowerCase() ?? '';

      return name.contains(lowerQuery) ||
          author.contains(lowerQuery) ||
          tags.contains(lowerQuery);
    }).toList();

    setState(() {
      _searchResults = results;
      _query = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    // We access the provider here.
    // Ideally we shouldn't fetch *all* novels on every build if the list is huge,
    // but for now it's fine.
    final novelProvider = context.watch<NovelProvider>();
    final allNovels =
        novelProvider.novels; // This list is already sorted by priority/date
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search novels, authors, tags...',
            border: InputBorder.none,
            hintStyle: TextStyle(
              color: theme.colorScheme.onSurfaceVariant.withAlpha(150),
            ),
          ),
          style: theme.textTheme.titleMedium,
          onChanged: (value) => _performSearch(value, allNovels),
        ),
        actions: [
          if (_query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                _performSearch('', allNovels);
              },
            ),
        ],
      ),
      body: _query.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_rounded,
                    size: 64,
                    color: theme.colorScheme.onSurfaceVariant.withAlpha(128),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Search for your novels',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          : _searchResults.isEmpty
          ? Center(
              child: Text(
                'No results found for "$_query"',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              itemCount: _searchResults.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final novel = _searchResults[index];
                // Using NovelCard might be too big if we just want a simple list.
                // But NovelCard is nice. Let's reuse it but maybe stripped down?
                // Or just standard ListTile for search results.
                // Let's use ListTile for compactness as requested "Search novels...".
                // Actually user didn't specify compact, but search results usually look better compact.
                // However, consistency is key. Let's use a Card but maybe smaller?
                // Let's stick to ListTile for now, or a custom SearchResultCard.
                // Let's us ListTile to match standard search UI patterns.

                return Card(
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(8),
                    leading: Container(
                      width: 48,
                      height: 64,
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
                              size: 24,
                              color: theme.colorScheme.onSurfaceVariant,
                            )
                          : null,
                    ),
                    title: Text(
                      novel.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (novel.author != null)
                          Text(
                            novel.author!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer.withAlpha(
                              100,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            novel.status.displayName,
                            style: TextStyle(
                              fontSize: 10,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NovelDashboard(novel: novel),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
