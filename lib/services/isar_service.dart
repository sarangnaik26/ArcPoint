import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/novel.dart';
import '../models/character.dart';
import '../models/chapter_marker.dart';
import '../models/history_entry.dart';

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = openDB();
  }

  Future<Isar> openDB() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      return await Isar.open(
        [NovelSchema, CharacterSchema, ChapterMarkerSchema, HistoryEntrySchema],
        directory: dir.path,
        inspector: true,
      );
    }
    return Isar.getInstance()!;
  }

  Future<void> cleanDB() async {
    final isar = await db;
    await isar.writeTxn(() => isar.clear());
  }
}
