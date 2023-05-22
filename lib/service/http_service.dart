import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../model/selfie_model.dart';

class HttpService {
  static const String _serverUrl = 'http://uc-1.dnsalias.net:55083';
  static Future<SelfieModel> uploadImage(
      String image,
      List<String> employeeId,
      String latlng,
      String address,
      String department,
      String team,
      String selfieTimestamp,
      String logType) async {
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
              'log_type': logType
            }))
        .timeout(const Duration(seconds: 10));
    debugPrint('insertLog ${response.statusCode} ${response.body}');
    var result = selfieModelFromJson(response.body);
    return result;
  }

  static Future<void> insertDeviceLog(String id, String logTime, String address,
      String latlng, String version) async {
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
}
