import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class DioService {
  static const String _serverUrl = 'http://uc-1.dnsalias.net:55083';
  static final _dio = Dio();

  static Future<void> uploadImage(Uint8List image) async {
    final formData = FormData.fromMap({
      'image': MultipartFile.fromBytes(image, filename: '123.jpg'),
    });
    var response = await _dio.post(
      '$_serverUrl/upload_image.php',
      data: formData,
    );
    debugPrint('uploadImage ${response.statusCode} ${response.data}');
  }
}
