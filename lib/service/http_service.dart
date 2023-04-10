import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../model/selfie_model.dart';

class HttpService {
  static const String _serverUrl = 'http://uc-1.dnsalias.net:55083';
  static Future<SelfieModel> uploadImage(String image, String imageName,
      String name, String employeeId, String latlng, String address) async {
    var response = await http
        .post(Uri.parse('$_serverUrl/upload_image.php'),
            headers: <String, String>{
              'Accept': '*/*',
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: json.encode(<String, dynamic>{
              'name': name,
              'employee_id': employeeId,
              'latlng': latlng,
              'address': address,
              'image_name': imageName,
              'image': image
            }))
        .timeout(const Duration(seconds: 5));
    debugPrint('insertLog ${response.statusCode} ${response.body}');
    var result = selfieModelFromJson(response.body);
    return result;
  }
}
