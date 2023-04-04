import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HttpService {
  static const String _serverUrl = 'http://uc-1.dnsalias.net:55083';
  static Future<void> uploadImage(String image, String name) async {
    var response = await http
        .post(Uri.parse('$_serverUrl/upload_image.php'),
            headers: <String, String>{
              'Accept': '*/*',
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: json.encode(<String, dynamic>{
              'image': image,
              'name': name,
            }))
        .timeout(const Duration(seconds: 5));
    debugPrint('insertLog ${response.statusCode} ${response.body}');
  }
}
