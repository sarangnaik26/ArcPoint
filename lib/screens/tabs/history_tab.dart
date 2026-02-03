import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import '../../models/novel.dart';
import '../../models/history_entry.dart';
import 'package:intl/intl.dart';

class HistoryTab extends StatelessWidget {
  final Novel novel;

  const HistoryTab({super.key, required this.novel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StreamBuilder<List<HistoryEntry>>(
      stream: novel.historyEntries.filter().watch(fireImmediately: true),
      builder: (context, snapshot) {
        final history = snapshot.data ?? [];
        history.sort(
          (a, b) => b.timestamp.compareTo(a.timestamp),
        ); // Sort by date desc

        return history.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history_rounded,
                      size: 64,
                      color: theme.colorScheme.onSurfaceVariant.withAlpha(128),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No history entries yet.',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final entry = history[index];
                  return Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: IntrinsicHeight(
                      child: Row(
                        children: [
                          Column(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              if (index != history.length - 1)
                                Expanded(
                                  child: Container(
                                    width: 2,
                                    color: theme.colorScheme.outlineVariant,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      entry.actionType,
                                      style: theme.textTheme.titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    Text(
                                      DateFormat(
                                        'MMM dd • HH:mm',
                                      ).format(entry.timestamp),
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            color: theme
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  entry.details,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
      },
    );
  }
}
