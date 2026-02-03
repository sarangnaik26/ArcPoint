import 'package:isar/isar.dart';

part 'chapter_marker.g.dart';

@Collection()
class ChapterMarker {
  Id id = Isar.autoIncrement;

  late int chapterNumber;
  late String description;
  String? externalLink;

  DateTime createdAt = DateTime.now();
}
