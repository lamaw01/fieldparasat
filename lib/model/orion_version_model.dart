// To parse this JSON data, do
//
//     final orionVersionModel = orionVersionModelFromJson(jsonString);

import 'dart:convert';

OrionVersionModel orionVersionModelFromJson(String str) =>
    OrionVersionModel.fromJson(json.decode(str));

String orionVersionModelToJson(OrionVersionModel data) =>
    json.encode(data.toJson());

class OrionVersionModel {
  String orionVersion;
  DateTime orionUpdated;

  OrionVersionModel({
    required this.orionVersion,
    required this.orionUpdated,
  });

  factory OrionVersionModel.fromJson(Map<String, dynamic> json) =>
      OrionVersionModel(
        orionVersion: json["orion_version"],
        orionUpdated: DateTime.parse(json["orion_updated"]),
      );

  Map<String, dynamic> toJson() => {
        "orion_version": orionVersion,
        "orion_updated": orionUpdated.toIso8601String(),
      };
}
