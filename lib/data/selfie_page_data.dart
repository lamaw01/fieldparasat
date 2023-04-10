import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';

import '../model/selfie_model.dart';
import '../service/http_service.dart';
import '../service/position_service.dart';

class SelfiePageData with ChangeNotifier {
  final _picker = ImagePicker();
  XFile? _image;
  XFile? get image => _image;
  Uint8List? _imageScreenshot;
  Uint8List? get imageScreenshot => _imageScreenshot;
  Position? _position;
  final _deviceInfo = DeviceInfoPlugin();
  var _latlng = "error getting latlng";
  String get latlng => _latlng;
  var _address = "error getting address";
  String get address => _address;
  var _heading = "";
  String get heading => _heading;
  var _altitude = "";
  String get altitude => _altitude;
  var _deviceId = "";
  String get deviceId => _deviceId;
  var _speed = "";
  String get speed => _speed;
  var _timestamp = "00:00:00";
  var _dateTimeDisplay = "00:00:00";
  String get dateTimeDisplay => _dateTimeDisplay;
  final _errorList = <String>[];
  List<String> get errorList => _errorList;
  //Create an instance of ScreenshotController
  final screenshotController = ScreenshotController();
  SelfieModel? _response;
  SelfieModel? get response => _response;

  // get imageuploadImage
  Future<void> getImage() async {
    try {
      await _picker
          .pickImage(source: ImageSource.camera, imageQuality: 80)
          .then((XFile? result) {
        _image = result;
        notifyListeners();
      });
    } catch (e) {
      debugPrint('getImage $e');
    } finally {
      _timestamp = DateFormat('yyyy-MM-dd-HH:mm:ss').format(DateTime.now());
      _dateTimeDisplay = DateFormat.yMEd().add_jms().format(DateTime.now());
    }
  }

  Future<void> captureImage() async {
    await screenshotController
        .capture(delay: const Duration(seconds: 3))
        .then((Uint8List? result) {
      debugPrint(result.toString());
      _imageScreenshot = result;
    }).catchError((Object err) {
      debugPrint(err.toString());
    });
    notifyListeners();
  }

  void printData() {
    debugPrint("_address $_address _latlng $_latlng _deviceId $_deviceId");
  }

  // initialize all functions
  Future<void> init() async {
    await initDeviceInfo();
    await initPosition();
    await initTranslateLatLng();
    printData();
  }

  // get device info
  Future<void> initDeviceInfo() async {
    try {
      await _deviceInfo.androidInfo.then((result) {
        _deviceId = "${result.brand}:${result.product}:${result.id}";
      });
      debugPrint(_deviceId);
    } catch (e) {
      debugPrint('$e');
      _errorList.add('initDeviceInfo $e');
    }
  }

  // get lat lng of device
  Future<void> initPosition() async {
    try {
      await PositionService.getPosition().then((result) {
        _position = result;
        _latlng = "${result.latitude} ${result.longitude}";
        _speed = result.speed.toString();
        _heading = result.heading.toString();
        _altitude = result.altitude.toStringAsFixed(2);
        log(result.toJson().toString());
      });
      debugPrint("latlng $_latlng");
    } catch (e) {
      debugPrint('$e');
      _errorList.add('initPosition $e');
    }
  }

  // translate latlng to address
  Future<void> initTranslateLatLng() async {
    try {
      await placemarkFromCoordinates(_position!.latitude, _position!.longitude)
          .then((result) {
        _address =
            "${result.first.subAdministrativeArea} ${result.first.locality} ${result.first.thoroughfare} ${result.first.street}";
      });
      debugPrint(_address);
    } catch (e) {
      debugPrint('$e');
      _errorList.add('initTranslateLatLng $e');
    }
  }

  Future<bool> uploadImage(String name, String employeeId) async {
    bool success = false;
    try {
      String base64 = base64Encode(_imageScreenshot!);
      debugPrint(base64);
      _response = await HttpService.uploadImage(base64,
          "$_timestamp-$employeeId.jpg", name, employeeId, _latlng, _address);
      if (_response!.success) {
        success = true;
      } else {
        _errorList.add(_response!.message);
      }
    } catch (e) {
      debugPrint('$e');
      _errorList.add(_response!.message);
    }
    return success;
  }
}
