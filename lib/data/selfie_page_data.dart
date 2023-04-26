import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:image_picker/image_picker.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';

import '../model/history_model.dart';
import '../service/http_service.dart';
import '../service/position_service.dart';

class SelfiePageData with ChangeNotifier {
  final _picker = ImagePicker();
  Position? _position;
  XFile? _image;
  XFile? get image => _image;
  Uint8List? _imageScreenshot;
  Uint8List? get imageScreenshot => _imageScreenshot;
  var _latlng = "error getting latlng";
  String get latlng => _latlng;
  var _address = "error getting address";
  String get address => _address;
  var _heading = "";
  String get heading => _heading;
  var _altitude = "";
  String get altitude => _altitude;
  var _speed = "";
  String get speed => _speed;
  var _timestamp = "00:00:00";
  var _dateTimeDisplay = "00:00:00";
  String get dateTimeDisplay => _dateTimeDisplay;
  var _isUploading = false;
  bool get isUploading => _isUploading;
  final _errorList = <String>[];
  List<String> get errorList => _errorList;
  //Create an instance of ScreenshotController
  final screenshotController = ScreenshotController();
  final _hasInternet = ValueNotifier(true);
  ValueNotifier<bool> get hasInternet => _hasInternet;

  void uploading() {
    _isUploading = !_isUploading;
    notifyListeners();
  }

  // listens to internet status
  void internetStatus(InternetConnectionStatus status) async {
    if (status == InternetConnectionStatus.connected) {
      hasInternet.value = true;
    } else {
      hasInternet.value = false;
    }
    debugPrint("hasInternet ${hasInternet.value}");
    var box = Hive.box<HistoryModel>('history');
    // if re-connected to internet check if theres failed upload then try to re-upload
    for (var history in box.values) {
      if (!history.uploaded) {
        uploadHistory(history);
      }
    }
  }

  // get image
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
    if (_imageScreenshot != null) {
      _imageScreenshot = null;
    }
    await screenshotController
        .capture(delay: const Duration(seconds: 3))
        .then((Uint8List? result) {
      debugPrint(result.toString());
      _imageScreenshot = result;
    }).catchError((Object err) {
      debugPrint(err.toString());
      _errorList.add('initDeviceInfo $err');
    });
    notifyListeners();
  }

  void printData() {
    debugPrint("_address $_address _latlng $_latlng");
  }

  // initialize all functions
  Future<void> init() async {
    await initPosition();
    await initTranslateLatLng();
    printData();
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

  Future<bool> uploadImage(
      {required List<String> employeeId,
      required String department,
      required String logType}) async {
    bool success = false;
    try {
      uploading();
      String base64 = base64Encode(_imageScreenshot!);
      debugPrint(base64);
      var response = await HttpService.uploadImage(base64, employeeId, _latlng,
          _address, department, _timestamp, logType);
      if (response.success) {
        success = true;
      } else {
        _errorList.add(response.message);
      }
    } catch (e) {
      debugPrint('$e');
      _errorList.add(e.toString());
    } finally {
      uploading();
      // save to history
      saveToHistory(
          employeeId: employeeId,
          department: department,
          logType: logType,
          uploaded: success);
      _image = null;
      _imageScreenshot = null;
      notifyListeners();
    }
    return success;
  }

  Future<bool> uploadHistory(HistoryModel model) async {
    bool success = false;
    try {
      var response = await HttpService.uploadImage(
          model.image,
          model.employeeId,
          model.latlng,
          model.address,
          model.department,
          model.selfieTimestamp,
          model.logType);
      if (response.success) {
        success = true;
        // delete and add history if successfully uploaded
        model.delete();
        var box = Hive.box<HistoryModel>('history');
        await box.add(model..uploaded = true);
      } else {
        _errorList.add(response.message);
      }
    } catch (e) {
      debugPrint('$e');
      _errorList.add(e.toString());
    }
    return success;
  }

  Future<void> saveToHistory(
      {required List<String> employeeId,
      required String department,
      required String logType,
      required bool uploaded}) async {
    try {
      var box = Hive.box<HistoryModel>('history');
      String base64 = base64Encode(_imageScreenshot!);
      await box.add(HistoryModel(
          image: base64,
          employeeId: employeeId,
          latlng: latlng,
          address: address,
          imageScreenshot: _imageScreenshot!,
          department: department,
          selfieTimestamp: _timestamp,
          logType: logType,
          uploaded: uploaded));
    } catch (e) {
      debugPrint('$e');
      _errorList.add(e.toString());
    }
  }
}
