import 'package:hive/hive.dart';

part 'preset_model.g.dart';

@HiveType(typeId: 3)
class PresetModel extends HiveObject {
  PresetModel({
    required this.presetName,
    required this.employeeId,
    required this.department,
    required this.team,
  });

  @HiveField(0)
  String presetName;

  @HiveField(1)
  List<String> employeeId;

  @HiveField(2)
  String department;

  @HiveField(3)
  String team;
}
