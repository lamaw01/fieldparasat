import 'dart:typed_data';
import 'package:hive/hive.dart';

part 'history_model.g.dart';

@HiveType(typeId: 4)
class HistoryModel extends HiveObject {
  HistoryModel({
    required this.image,
    required this.employeeId,
    required this.latlng,
    required this.address,
    required this.imageScreenshot,
    required this.department,
    required this.selfieTimestamp,
    required this.logType,
    required this.uploaded,
    required this.team,
    required this.fileUint8List,
    required this.fileServerName,
  });

  @HiveField(0)
  String image;

  @HiveField(1)
  List<String> employeeId;

  @HiveField(2)
  String latlng;

  @HiveField(3)
  String address;

  @HiveField(4)
  Uint8List imageScreenshot;

  @HiveField(5)
  String department;

  @HiveField(6)
  String selfieTimestamp;

  @HiveField(7)
  String logType;

  @HiveField(8)
  bool uploaded;

  @HiveField(9)
  String team;

  @HiveField(10)
  Uint8List fileUint8List;

  @HiveField(11)
  String fileServerName;
}
