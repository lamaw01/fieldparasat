// To parse this JSON data, do
//
//     final departmentModel = departmentModelFromJson(jsonString);

import 'dart:convert';

List<DepartmentModel> departmentModelFromJson(String str) =>
    List<DepartmentModel>.from(
        json.decode(str).map((x) => DepartmentModel.fromJson(x)));

String departmentModelToJson(List<DepartmentModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DepartmentModel {
  String departmentId;
  String departmentName;

  DepartmentModel({
    required this.departmentId,
    required this.departmentName,
  });

  factory DepartmentModel.fromJson(Map<String, dynamic> json) =>
      DepartmentModel(
        departmentId: json["department_id"],
        departmentName: json["department_name"],
      );

  Map<String, dynamic> toJson() => {
        "department_id": departmentId,
        "department_name": departmentName,
      };
}
