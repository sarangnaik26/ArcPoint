import 'package:isar/isar.dart';

part 'character.g.dart';

@Collection()
class Character {
  Id id = Isar.autoIncrement;

  late String name;
  String? imagePath;
  String? role; // user-defined categories
  String? description;

  /// Flexible status panel stored as a JSON string.
  /// Structure: `Map<String, List<Map<String, String>>>`
  /// representing Groups -> Key -> Values
  String? statusPanelJson;
}
