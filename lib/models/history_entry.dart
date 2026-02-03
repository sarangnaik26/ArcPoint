import 'package:isar/isar.dart';

part 'history_entry.g.dart';

@Collection()
class HistoryEntry {
  Id id = Isar.autoIncrement;

  late DateTime timestamp;
  late String
  actionType; // e.g., 'Status Change', 'Chapter Update', 'Note Added'
  late String details;
}
