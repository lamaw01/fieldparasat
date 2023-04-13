import 'dart:typed_data';
import 'package:hive/hive.dart';

part 'idle_model.g.dart';

@HiveType(typeId: 1)
class IdleModel extends HiveObject {
  IdleModel(
      {required this.image,
      required this.imageName,
      required this.name,
      required this.employeeId,
      required this.latlng,
      required this.address,
      required this.imageScreenshot});

  @HiveField(0)
  String image;

  @HiveField(1)
  String imageName;

  @HiveField(2)
  String name;

  @HiveField(3)
  String employeeId;

  @HiveField(4)
  String latlng;

  @HiveField(5)
  String address;

  @HiveField(6)
  Uint8List imageScreenshot;
}
