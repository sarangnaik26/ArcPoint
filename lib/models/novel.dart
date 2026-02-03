import 'package:isar/isar.dart';
import 'novel_status.dart';
import 'character.dart';
import 'chapter_marker.dart';
import 'history_entry.dart';

part 'novel.g.dart';

@Collection()
class Novel {
  Id id = Isar.autoIncrement;

  late String name;
  String? author;
  String? coverPath;
  String? genreTags; // Comma-separated or serialized

  @Enumerated(EnumType.name)
  late NovelStatus status;

  String? externalLink;

  int priority = 0; // 0: Normal, 1: High (Pinned)

  // Resume Info
  int currentChapter = 0;
  String? storySummary;
  String? lastOnHoldNote;

  DateTime lastUpdated = DateTime.now();

  // Relationships
  final characters = IsarLinks<Character>();
  final chapterMarkers = IsarLinks<ChapterMarker>();
  final historyEntries = IsarLinks<HistoryEntry>();
}
