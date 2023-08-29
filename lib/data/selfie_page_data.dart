import 'dart:convert';
import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/intl.dart';
import 'package:ntp/ntp.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/department_model.dart';
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

  var _sixDigitCode = 000000;

  var _heading = "";
  String get heading => _heading;

  var _altitude = "";
  String get altitude => _altitude;

  var _speed = "";
  String get speed => _speed;

  var _selfieTimestamp = "";
  String get selfieTimestamp => _selfieTimestamp;

  var _dateTimeDisplay = "";
  String get dateTimeDisplay => _dateTimeDisplay;

  var _isUploading = false;
  bool get isUploading => _isUploading;

  var _hasVerifiedVersion = false;
  bool get hasVerifiedVersion => _hasVerifiedVersion;

  final _errorList = <String>[];
  List<String> get errorList => _errorList;

  // List<DepartmentModel> get departmentList => _departmentList;

  //Create an instance of ScreenshotController
  final screenshotController = ScreenshotController();
  late TabController tabController;

  final _hasInternet = ValueNotifier(true);
  ValueNotifier<bool> get hasInternet => _hasInternet;

  var _logIn = true;
  bool get logIn => _logIn;

  var _appVersion = "";
  String get appVersion => _appVersion;

  var _appVersionDatabase = "";
  String get appVersionDatabase => _appVersionDatabase;

  var _deviceId = "";
  String get deviceId => _deviceId;

  var _gettingAddress = false;
  bool get gettingAddress => _gettingAddress;

  final _dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

  void changeLogType(bool state) {
    _logIn = state;
    notifyListeners();
  }

  void changeUploadingState(bool state) {
    _isUploading = state;
    notifyListeners();
  }

  void changeGettingAddressState(bool state) {
    _gettingAddress = state;
    notifyListeners();
  }

  // listens to internet status
  void internetStatus({
    required InternetConnectionStatus status,
    required BuildContext context,
  }) async {
    if (status == InternetConnectionStatus.connected) {
      _hasInternet.value = true;
    } else {
      _hasInternet.value = false;
    }
    debugPrint("hasInternet ${hasInternet.value}");
    // check if gotten an app version in database
    if (!_hasVerifiedVersion) {
      await getAppVersion().then((_) {
        showVersionAppDialog(context);
      });
    }
    var box = Hive.box<HistoryModel>('history');
    // if re-connected to internet check if theres failed upload then try to re-upload
    for (var history in box.values) {
      if (!history.uploaded) {
        uploadHistory(model: history);
      }
    }
  }

  // get image
  Future<bool> getImage() async {
    var hasImage = false;
    try {
      var result = await _picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 70,
          preferredCameraDevice: CameraDevice.front);
      if (result != null) {
        _image = result;
        hasImage = true;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('getImage $e');
    } finally {
      var networkTime = await getNetworkTime();
      _selfieTimestamp = _dateFormat.format(networkTime);
      _dateTimeDisplay = DateFormat.yMEd().add_jms().format(networkTime);
    }
    return hasImage;
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
      _errorList.add('getDeviceInfo $err');
    });
    notifyListeners();
  }

  // check location service
  Future<void> checkLocationService(BuildContext context) async {
    try {
      await Geolocator.isLocationServiceEnabled().then((result) async {
        if (!result) {
          await showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Location service disabled'),
                content: const Text(
                    'Please enable the location service. After enabling press Continue.'),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Settings'),
                    onPressed: () {
                      Geolocator.openLocationSettings();
                    },
                  ),
                  TextButton(
                    child: const Text('Continue'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        }
      });
    } catch (e) {
      debugPrint('checkLocationService $e');
      _errorList.add('checkLocationService $e');
    }
  }

  Future<void> showVersionAppDialog(BuildContext context) async {
    var intAppVersion = _appVersion.replaceAll(".", "").trim();
    var intAppVersionDatabase = _appVersionDatabase.replaceAll(".", "").trim();
    try {
      if (int.parse(intAppVersion) < int.parse(intAppVersionDatabase)) {
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('App Out of date'),
              content: Text(
                  'Current version $_appVersion is out of date. Please update to version $_appVersionDatabase.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Exit app'),
                  onPressed: () {
                    SystemNavigator.pop();
                  },
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      debugPrint('showVersionAppDialog $e');
      _errorList.add('showVersionAppDialog $e');
    }
  }

  void showHasLatLngNoAddressDialog(BuildContext context) {
    if (_latlng != "error getting latlng" &&
        _address == "error getting address") {
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Has Coordinates Missing Address'),
            content:
                const Text('App has coordinates but doesnt have valid address'),
            actions: <Widget>[
              TextButton(
                child: const Text('Proceed'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child: const Text('Exit app'),
                onPressed: () {
                  SystemNavigator.pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  void showErrorAddressDialog(BuildContext context) {
    if (_latlng == "error getting latlng" &&
        _address == "error getting address") {
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error Getting Address'),
            content: const Text(
                'Please enable location service and/or enable internet access to get valid address and try initializing app again.'),
            actions: <Widget>[
              TextButton(
                child: const Text('Exit app'),
                onPressed: () {
                  SystemNavigator.pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  // initialize all functions
  Future<String> init() async {
    await getDeviceInfo();
    await checkCode();
    await getPosition();
    await translateLatLng();
    if (_latlng != "error getting latlng" &&
        _address != "error getting address") {
      await insertDeviceLog();
    }
    return _address;
  }

  Future<void> checkVersion() async {
    await getPackageInfo();
    await getAppVersion();
  }

  // get device version
  Future<void> getPackageInfo() async {
    try {
      await PackageInfo.fromPlatform().then((result) {
        _appVersion = result.version;
        debugPrint(_appVersion);
      });
    } catch (e) {
      debugPrint('getPackageInfo $e');
      _errorList.add('getDeviceInfo $e');
    }
  }

  // get app version in database
  Future<void> getAppVersion() async {
    try {
      await HttpService.getAppVersion().then((result) {
        _appVersionDatabase = result.orionVersion;
        _hasVerifiedVersion = true;
      });
    } catch (e) {
      debugPrint('getAppVersion $e');
      _errorList.add('getAppVersion $e');
    }
  }

  // generate 6 digit code and store in sharedpref
  Future<void> generateCode() async {
    try {
      var random = Random();
      var generatedCode = random.nextInt(900000) + 100000;
      _sixDigitCode = generatedCode;
      debugPrint("$_sixDigitCode");
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('code', _sixDigitCode);
      _deviceId = "$_deviceId:$_sixDigitCode";
    } catch (e) {
      debugPrint('$e');
      _errorList.add('initDeviceInfo $e');
    }
  }

  // check if device has generate code
  Future<void> checkCode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final int? code = prefs.getInt('code');
      if (code != null) {
        _sixDigitCode = code;
        _deviceId = "$_deviceId:$_sixDigitCode";
      } else {
        generateCode();
      }
    } catch (e) {
      debugPrint('$e');
      _errorList.add('initDeviceInfo $e');
    }
  }

  // get device info
  Future<void> getDeviceInfo() async {
    try {
      await DeviceInfoPlugin().androidInfo.then((result) {
        _deviceId = "${result.brand}:${result.product}:${result.id}";
      });
      debugPrint(_deviceId);
    } catch (e) {
      debugPrint('getDeviceInfo $e');
      _errorList.add('getDeviceInfo $e');
    }
  }

  // get lat lng of device
  Future<void> getPosition() async {
    try {
      await PositionService.getPosition().then((result) {
        _position = result;
        _latlng = "${result.latitude} ${result.longitude}";
        _speed = result.speed.toString();
        _heading = result.heading.toString();
        _altitude = result.altitude.toStringAsFixed(2);
      });
      debugPrint("latlng $_latlng");
    } catch (e) {
      debugPrint('getPosition $e');
      _errorList.add('initPosition $e');
    }
  }

  // translate latlng to address
  Future<void> translateLatLng() async {
    try {
      await placemarkFromCoordinates(_position!.latitude, _position!.longitude)
          .then((result) {
        _address =
            "${result.first.subAdministrativeArea} ${result.first.locality} ${result.first.thoroughfare} ${result.first.street}";
      });
      debugPrint(_address);
    } catch (e) {
      debugPrint('translateLatLng $e');
      _errorList.add('initTranslateLatLng $e');
    }
  }

  // insert device log to database
  Future<void> insertDeviceLog() async {
    try {
      await HttpService.insertDeviceLog(
        id: _deviceId,
        logTime: _dateFormat.format(DateTime.now()),
        address: _address,
        latlng: _latlng,
        version: _appVersion,
      );
    } catch (e) {
      debugPrint('insertDeviceLog $e');
      _errorList.add('insertDeviceLog $e');
    }
  }

  Future<void> uploadImage({
    required List<String> employeeId,
    required String department,
    required String team,
  }) async {
    var success = false;
    try {
      var base64 = base64Encode(_imageScreenshot!);
      debugPrint(base64);
      var response = await HttpService.uploadImage(
        image: base64,
        employeeId: employeeId,
        latlng: _latlng,
        address: _address,
        department: department,
        team: team,
        selfieTimestamp: _selfieTimestamp,
        logType: _logIn ? 'IN' : 'OUT',
        deviceId: _deviceId,
      );
      if (response.success) {
        success = true;
      } else {
        _errorList.add(response.message);
      }
    } catch (e) {
      debugPrint('uploadImage $e');
      _errorList.add(e.toString());
    } finally {
      // save to history
      await saveToHistory(
        employeeId: employeeId,
        department: department,
        team: team,
        uploaded: success,
      );
      _image = null;
      _imageScreenshot = null;
      notifyListeners();
    }
  }

  Future<void> uploadHistory({required HistoryModel model}) async {
    try {
      final correctTime =
          await correctSelfieTime(timestamp: model.selfieTimestamp);
      final correctSelfieTimestamp = _dateFormat.format(correctTime);
      var response = await HttpService.uploadImage(
        image: model.image,
        employeeId: model.employeeId,
        latlng: model.latlng,
        address: model.address,
        department: model.department,
        team: model.team,
        selfieTimestamp: correctSelfieTimestamp,
        logType: model.logType,
        deviceId: _deviceId,
      );
      if (response.success) {
        // delete and add history if successfully uploaded
        model.delete();
        var box = Hive.box<HistoryModel>('history');
        await box.add(
          model
            ..uploaded = true
            ..selfieTimestamp = correctSelfieTimestamp,
        );
      } else {
        _errorList.add(response.message);
      }
    } catch (e) {
      debugPrint('uploadHistory $e');
      _errorList.add(e.toString());
    }
  }

  Future<void> saveToHistory({
    required List<String> employeeId,
    required String department,
    required String team,
    required bool uploaded,
  }) async {
    try {
      var box = Hive.box<HistoryModel>('history');
      var base64 = base64Encode(_imageScreenshot!);
      await box.add(HistoryModel(
          image: base64,
          employeeId: employeeId,
          latlng: latlng,
          address: address,
          imageScreenshot: _imageScreenshot!,
          department: department,
          team: team,
          selfieTimestamp: _selfieTimestamp,
          logType: _logIn ? 'IN' : 'OUT',
          uploaded: uploaded));
    } catch (e) {
      debugPrint('saveToHistory $e');
      _errorList.add(e.toString());
    } finally {
      var logType = _logIn ? 'IN' : 'OUT';
      await saveImageToGallery(fileName: "$logType $_selfieTimestamp");
    }
  }

  Future<void> checkGalleryPermission() async {
    try {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        var result = await Permission.storage.request();
        debugPrint(result.name);
      }
    } catch (e) {
      debugPrint('checkGalleryPermission $e');
      _errorList.add(e.toString());
    }
  }

  Future<void> saveImageToGallery({required String fileName}) async {
    try {
      final result = await ImageGallerySaver.saveImage(
        _imageScreenshot!,
        name: fileName,
      );
      debugPrint(result.toString());
    } catch (e) {
      debugPrint('saveImageToGallery $e');
      _errorList.add(e.toString());
    }
  }

  // fetch network time because device time not reliable
  Future<DateTime> getNetworkTime() async {
    var nptTime = DateTime.now();
    try {
      nptTime = await NTP.now();
      debugPrint('Network time: $nptTime');
    } catch (e) {
      debugPrint('getNetworkTime $e');
      _errorList.add(e.toString());
    }
    return nptTime;
  }

  // correct time by setting offset
  Future<DateTime> correctSelfieTime({required String timestamp}) async {
    var selfieTimestamp = _dateFormat.parse(timestamp);
    var networkTime = DateTime.now();
    try {
      final int offset = await NTP.getNtpOffset(localTime: networkTime);
      networkTime = selfieTimestamp.add(Duration(milliseconds: offset));
      debugPrint('Selfie time: $selfieTimestamp');
      debugPrint('Network time: $networkTime');
      debugPrint(
          'Difference: ${selfieTimestamp.difference(networkTime).inMilliseconds}ms');
    } catch (e) {
      debugPrint('correctSelfieTime $e');
      _errorList.add(e.toString());
    }
    return networkTime;
  }

  Future<List<DepartmentModel>> getDepartment() async {
    var list = <DepartmentModel>[];
    try {
      list = await HttpService.getDepartment();
    } catch (e) {
      debugPrint('$e');
    }
    return list;
  }
}
