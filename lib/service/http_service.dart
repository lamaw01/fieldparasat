import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../model/orion_version_model.dart';
import '../model/selfie_model.dart';

class HttpService {
  static const String _serverUrl = 'http://103.62.153.74:53000/field_api';
  static Future<SelfieModel> uploadImage({
    required String image,
    required List<String> employeeId,
    required String latlng,
    required String address,
    required String department,
    required String team,
    required String selfieTimestamp,
    required String logType,
    required String deviceId,
  }) async {
    var response = await http
        .post(Uri.parse('$_serverUrl/upload_image.php'),
            headers: <String, String>{
              'Accept': '*/*',
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: json.encode(<String, dynamic>{
              'image': image,
              'employee_id': employeeId,
              'latlng': latlng,
              'address': address,
              'is_selfie': true,
              'department': department,
              'team': team,
              'selfie_timestamp': selfieTimestamp,
              'log_type': logType,
              'device_id': deviceId
            }))
        .timeout(const Duration(seconds: 10));
    debugPrint('uploadImage ${response.statusCode} ${response.body}');
    return selfieModelFromJson(response.body);
  }

  static Future<void> insertDeviceLog({
    required String id,
    required String logTime,
    required String address,
    required String latlng,
    required String version,
  }) async {
    var response = await http
        .post(Uri.parse('$_serverUrl/insert_device_log.php'),
            headers: <String, String>{
              'Accept': '*/*',
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: json.encode(<String, dynamic>{
              "device_id": id,
              "log_time": logTime,
              "address": address,
              "latlng": latlng,
              "version": version,
              "app_name": 'Orion'
            }))
        .timeout(const Duration(seconds: 5));
    debugPrint('insertDeviceLog ${response.statusCode} ${response.body}');
  }

  static Future<OrionVersionModel> getAppVersion() async {
    var response = await http.get(
      Uri.parse('$_serverUrl/get_app_version.php'),
      headers: <String, String>{
        'Accept': '*/*',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    ).timeout(const Duration(seconds: 10));
    debugPrint('getAppVersion ${response.body}');
    return orionVersionModelFromJson(response.body);
  }
}
