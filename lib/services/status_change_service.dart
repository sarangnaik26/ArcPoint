import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/novel.dart';
import '../models/novel_status.dart';
import '../models/history_entry.dart';
import '../providers/novel_provider.dart';
import 'package:isar/isar.dart';

class StatusChangeService {
  static Future<void> changeStatus(
    BuildContext context,
    Novel novel,
    NovelStatus newStatus,
  ) async {
    final oldStatus = novel.status;
    if (oldStatus == newStatus) return;

    bool proceed = true;
    String? transitionNote;

    // Contextual Popups
    if (newStatus == NovelStatus.onHold && oldStatus == NovelStatus.reading) {
      transitionNote = await _showOnHoldPopup(context);
      if (transitionNote == null) proceed = false;
    } else if (newStatus == NovelStatus.completed) {
      transitionNote = await _showCompletedPopup(context);
      if (transitionNote == null) proceed = false;
    }

    if (proceed) {
      final isar = Isar.getInstance()!;
      final history = HistoryEntry()
        ..timestamp = DateTime.now()
        ..actionType = 'Status Change'
        ..details =
            'Changed from ${oldStatus.displayName} to ${newStatus.displayName}${transitionNote != null ? ": $transitionNote" : ""}';

      await isar.writeTxn(() async {
        await isar.historyEntrys.put(history);
        novel.status = newStatus;
        if (newStatus == NovelStatus.onHold) {
          novel.lastOnHoldNote = transitionNote;
        }
        novel.historyEntries.add(history);
        await novel.historyEntries.save();
      });

      // ignore: use_build_context_synchronously
      context.read<NovelProvider>().updateNovel(novel);
    }
  }

  static Future<String?> _showOnHoldPopup(BuildContext context) async {
    String? note;
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Putting on Hold'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Why are you pausing? This note will help you resume later.',
            ),
            const SizedBox(height: 16),
            TextField(
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'e.g., Arc finished, waiting for stack...',
              ),
              onChanged: (v) => note = v,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(context, note ?? 'No reason provided'),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  static Future<String?> _showCompletedPopup(BuildContext context) async {
    String? note;
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as Completed'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Congratulations! Any final thoughts or rating?'),
            const SizedBox(height: 16),
            TextField(
              autofocus: true,
              decoration: const InputDecoration(hintText: 'Optional note...'),
              onChanged: (v) => note = v,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, note ?? 'Completed'),
            child: const Text('Finish'),
          ),
        ],
      ),
    );
  }
}
