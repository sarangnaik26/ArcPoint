import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/novel.dart';
import '../../models/character.dart';
import 'package:isar/isar.dart';
import 'character_detail_popup.dart';

class CharactersTab extends StatelessWidget {
  final Novel novel;

  const CharactersTab({super.key, required this.novel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StreamBuilder<List<Character>>(
      stream: novel.characters.filter().watch(fireImmediately: true),
      builder: (context, snapshot) {
        final characters = snapshot.data ?? [];

        if (characters.isEmpty) {
          // Fall through to scaffold to show FAB
        }

        // Group by role
        final Map<String, List<Character>> grouped = {};
        for (var c in characters) {
          final role = c.role ?? 'Uncategorized';
          grouped.putIfAbsent(role, () => []).add(c);
        }

        // Sort roles by predefined order
        final roleOrder = [
          'Male Lead',
          'Female Lead',
          'Villain',
          'Ally',
          'Relative',
          'Mentor',
          'Subordinate',
          'Rival',
          'Other',
          'Uncategorized',
        ];

        final sortedKeys = grouped.keys.toList()
          ..sort((a, b) {
            int ia = roleOrder.indexOf(a);
            int ib = roleOrder.indexOf(b);
            if (ia == -1) ia = 999;
            if (ib == -1) ib = 999;
            return ia.compareTo(ib);
          });

        return Scaffold(
          body: characters.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline_rounded,
                        size: 64,
                        color: theme.colorScheme.onSurfaceVariant.withAlpha(
                          128,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No characters added yet.',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 16,
                  ), // Added horizontal padding for better layout
                  itemCount: sortedKeys.length,
                  itemBuilder: (context, index) {
                    final role = sortedKeys[index];
                    final chars = grouped[role]!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 24, 8, 12),
                          child: Text(
                            role.toUpperCase(),
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.8,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                          itemCount: chars.length,
                          itemBuilder: (context, i) {
                            final character = chars[i];
                            return Card(
                              clipBehavior: Clip.antiAlias,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: InkWell(
                                onTap: () => _openDetail(context, character),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: character.imagePath != null
                                          ? Image.file(
                                              File(character.imagePath!),
                                              fit: BoxFit.cover,
                                            )
                                          : Container(
                                              color: theme
                                                  .colorScheme
                                                  .surfaceContainerHighest,
                                              child: Icon(
                                                Icons.person,
                                                size: 48,
                                                color: theme
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                            ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              character.name,
                                              style: theme.textTheme.titleSmall
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            if (character.description != null &&
                                                character
                                                    .description!
                                                    .isNotEmpty)
                                              Text(
                                                character.description!,
                                                style: theme.textTheme.bodySmall
                                                    ?.copyWith(
                                                      color: theme
                                                          .colorScheme
                                                          .onSurfaceVariant,
                                                      fontSize: 11,
                                                    ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _addCharacter(context),
            child: const Icon(Icons.person_add_rounded),
          ),
        );
      },
    );
  }

  void _addCharacter(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CharacterDetailPopup(novel: novel),
    );
  }

  void _openDetail(BuildContext context, Character character) {
    showDialog(
      context: context,
      builder: (context) =>
          CharacterDetailPopup(novel: novel, character: character),
    );
  }
}
