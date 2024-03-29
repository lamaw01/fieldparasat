import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

import '../model/department_model.dart';
import '../model/version_model.dart';
import '../model/selfie_model.dart';
import '../view/selfie_page.dart';

class HttpService {
  static const String _serverUrl = 'http://103.62.153.74:53000';
  // static const String downloadLink =
  //     'http://103.62.153.74:53000/download/orion.apk';

  static const String downloadLink =
      'http://103.62.153.74:53000/download/orion.html';

  static final _dio = Dio(
    BaseOptions(
      baseUrl: '$_serverUrl/field_api',
      headers: <String, String>{
        'Accept': '*/*',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    ),
  );

  static Future<SelfieModel> uploadImage({
    required List<String> employeeId,
    required String latlng,
    required String address,
    required String department,
    required String team,
    required String selfieTimestamp,
    required String logType,
    required String deviceId,
    required String app,
    required String version,
    required String imagePath,
  }) async {
    final day = DateFormat('EEEE').format(DateTime.now()).toLowerCase();

    final response = await _dio.post(
      '/upload_image.php',
      data: {
        'employee_id': employeeId,
        'latlng': latlng,
        'address': address,
        'is_selfie': true,
        'department': department,
        'team': team,
        'selfie_timestamp': selfieTimestamp,
        'log_type': logType,
        'device_id': deviceId,
        'app': app,
        'version': version,
        'image_path': imagePath,
        'day': day,
      },
      onSendProgress: (int sent, int total) {
        double kbSent = sent / 1024;
        double kbTotal = total / 1024;
        sentProgress.value = kbSent.roundToDouble();
        totalProgress.value = kbTotal.roundToDouble();
      },
    );
    log('${json.encode(response.data)} uploadImage2');
    return selfieModelFromJson(json.encode(response.data));
  }

  static Future<void> insertDeviceLog({
    required String id,
    required String logTime,
    required String address,
    required String latlng,
    required String version,
  }) async {
    final response = await _dio.post(
      '/insert_device_log.php',
      data: {
        "device_id": id,
        "log_time": logTime,
        "address": address,
        "latlng": latlng,
        "version": version,
        "app_name": 'orion'
      },
      options: Options(
        sendTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
    log('${json.encode(response.data)} insertDeviceLog2');
  }

  static Future<VersionModel> getAppVersion() async {
    Response<Map<String, dynamic>> response = await _dio.get(
      '/get_app_version.php',
      options: Options(
        sendTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
    log('${json.encode(response.data)} getAppVersion2');
    return versionModelFromJson(json.encode(response.data));
  }

  static Future<List<DepartmentModel>> getDepartment() async {
    final response = await _dio.get(
      '/get_department.php',
      options: Options(
        sendTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
    // log('${json.encode(response.data)} getDepartment2');
    return departmentModelFromJson(json.encode(response.data));
  }

  static Future<void> uploadFileImage({
    required String imageName,
    required String imagePath,
    required List<String> employeeId,
  }) async {
    String employeeIdToExplode = '';
    for (int i = 0; i < employeeId.length; i++) {
      if (i != employeeId.length - 1) {
        employeeIdToExplode = '$employeeIdToExplode${employeeId[i]},';
      } else {
        employeeIdToExplode = '$employeeIdToExplode${employeeId[i]}';
      }
    }
    log('$employeeIdToExplode explode');

    final formData = FormData.fromMap({
      'employee_id': employeeIdToExplode,
      'image': await MultipartFile.fromFile(imagePath, filename: imageName),
    }, ListFormat.multi);

    final response = await _dio.post(
      '/upload_file_image.php',
      data: formData,
      options: Options(
        sendTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
    log('${response.data} uploadFileImage');
  }
}
