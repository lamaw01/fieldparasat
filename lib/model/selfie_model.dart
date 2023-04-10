// To parse this JSON data, do
//
//     final selfieModel = selfieModelFromJson(jsonString);

import 'dart:convert';

SelfieModel selfieModelFromJson(String str) =>
    SelfieModel.fromJson(json.decode(str));

String selfieModelToJson(SelfieModel data) => json.encode(data.toJson());

class SelfieModel {
  SelfieModel({
    required this.success,
    required this.message,
  });

  bool success;
  String message;

  factory SelfieModel.fromJson(Map<String, dynamic> json) => SelfieModel(
        success: json["success"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
      };
}
