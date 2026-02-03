import 'package:flutter/material.dart';
import '../models/novel.dart';
import '../models/novel_status.dart';
import '../services/isar_service.dart';
import 'package:isar/isar.dart';

class NovelProvider with ChangeNotifier {
  final IsarService _isarService;
  List<Novel> _novels = [];

  NovelProvider(this._isarService) {
    _fetchNovels();
  }

  List<Novel> get novels => _novels;

  List<Novel> getNovelsByStatus(List<NovelStatus> statuses) {
    return _novels.where((n) => statuses.contains(n.status)).toList();
  }

  Future<void> _fetchNovels() async {
    final isar = await _isarService.db;
    _novels = await isar.novels
        .where()
        .sortByPriorityDesc()
        .thenByLastUpdatedDesc()
        .findAll();
    notifyListeners();
  }

  Future<void> togglePriority(Novel novel) async {
    final isar = await _isarService.db;
    final newPriority = novel.priority == 0 ? 1 : 0;

    // We update the local object immediately for UI responsiveness if needed,
    // but the fetch will refresh it from DB.
    novel.priority = newPriority;

    await isar.writeTxn(() async {
      await isar.novels.put(novel);
    });
    await _fetchNovels();
  }

  Future<void> addNovel(Novel novel) async {
    final isar = await _isarService.db;
    await isar.writeTxn(() async {
      await isar.novels.put(novel);
    });
    await _fetchNovels();
  }

  Future<void> updateNovel(Novel novel) async {
    final isar = await _isarService.db;
    novel.lastUpdated = DateTime.now();
    await isar.writeTxn(() async {
      await isar.novels.put(novel);
    });
    await _fetchNovels();
  }

  Future<void> deleteNovel(int id) async {
    final isar = await _isarService.db;
    await isar.writeTxn(() async {
      await isar.novels.delete(id);
    });
    await _fetchNovels();
  }

  // Filtering for Sections
  List<Novel> get reading => getNovelsByStatus([NovelStatus.reading]);
  List<Novel> get onHold => getNovelsByStatus([NovelStatus.onHold]);
  List<Novel> get bucketList => getNovelsByStatus([NovelStatus.bucketList]);
  List<Novel> get completed => getNovelsByStatus([NovelStatus.completed]);
  List<Novel> get dropped => getNovelsByStatus([NovelStatus.dropped]);
}
