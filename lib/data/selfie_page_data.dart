// ignore_for_file: unused_import

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;

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
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as img;

import '../model/department_model.dart';
import '../model/history_model.dart';
import '../model/latlng.dart';
import '../service/http_service.dart';
import '../service/position_service.dart';
import '../view/selfie_page.dart';

class SelfiePageData with ChangeNotifier {
  final _picker = ImagePicker();

  // Position? _position;

  File? _image;
  File? get image => _image;

  double _lat = 0.0;
  double _lng = 0.0;

  // LatLng? _latLngCurrent;
  // LatLng? get latLngCurrent => _latLngCurrent;

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

  var _fileServername = "";
  String get fileServername => _fileServername;

  var _dateTimeDisplay = "";
  String get dateTimeDisplay => _dateTimeDisplay;

  var _hasVerifiedVersion = false;
  bool get hasVerifiedVersion => _hasVerifiedVersion;

  final _errorList = <String>[];
  List<String> get errorList => _errorList;

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

  var _isUploading = false;
  bool get isUploading => _isUploading;

  var _allowTouch = false;
  bool get allowTouch => _allowTouch;

  void changeLogType(bool state) {
    _logIn = state;
    notifyListeners();
  }

  void changeUploadingState(bool state) {
    _isUploading = state;
    notifyListeners();
  }

  void disableTouch(bool state) {
    _allowTouch = state;
    notifyListeners();
    log('allowTouch $_allowTouch');
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
    // var box = Hive.box<HistoryModel>('history');
    // if re-connected to internet check if theres failed upload then try to re-upload
    // for (var history in box.values) {
    //   if (!history.uploaded) {
    //     uploadHistory(model: history);
    //   }
    // }
  }

  // get image
  Future<bool> getImage() async {
    var hasImage = false;
    try {
      XFile? result = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        preferredCameraDevice: CameraDevice.front,
        maxHeight: 720,
        maxWidth: 1280,
      );
      if (result != null) {
        var imgByte = await result.readAsBytes();
        final img.Image? capturedImage = img.decodeImage(imgByte);
        var decodedImage = await decodeImageFromList(imgByte);
        bool isLandscapeImage = decodedImage.width > decodedImage.height;
        if (isLandscapeImage) {
          final imgRotate = img.copyRotate(capturedImage!, angle: 90);
          _image =
              await File(result.path).writeAsBytes(img.encodeJpg(imgRotate));
        } else {
          _image = File(result.path);
        }
        hasImage = true;
      }
    } catch (e) {
      debugPrint('getImage $e');
    } finally {
      var networkTime = await getNetworkTime();
      _selfieTimestamp = _dateFormat.format(networkTime);
      _fileServername = DateFormat('yyyyMMddHHmmss').format(networkTime);
      _dateTimeDisplay = DateFormat.yMEd().add_jms().format(networkTime);
      notifyListeners();
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
                  child: const Text('Download new version'),
                  onPressed: () {
                    launchUrl(Uri.parse(HttpService.downloadLink),
                        mode: LaunchMode.externalApplication);
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
    } catch (e) {
      debugPrint('showVersionAppDialog $e');
      _errorList.add('showVersionAppDialog $e');
    }
  }

  void showHasLatLngNoAddressDialog(BuildContext context) {
    //_latlng != "error getting latlng" && _address == "error getting address"
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

  // void showErrorAddressDialog(BuildContext context) {
  //   //latlng != "error getting latlng" && _address == "error getting address"
  //   if (_latlng == "error getting latlng") {
  //     showDialog<void>(
  //       context: context,
  //       barrierDismissible: false,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           title: const Text('Error Getting Address'),
  //           content: const Text(
  //               'Please enable location service and/or enable internet access to get valid address and try initializing app again.'),
  //           actions: <Widget>[
  //             TextButton(
  //               child: const Text('Exit app'),
  //               onPressed: () {
  //                 SystemNavigator.pop();
  //               },
  //             ),
  //           ],
  //         );
  //       },
  //     );
  //   }
  // }

  // initialize all functions
  Future<String> init() async {
    await getDeviceInfo();
    await checkCode();
    await getPosition();
    await translateLatLng();
    await insertDeviceLog();
    // return _address;
    log('address $_address latlng $_latlng');
    return _latlng;
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
        _appVersionDatabase = result.version;
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
      var random = math.Random();
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
        // _position = result;
        _latlng = "${result.latitude} ${result.longitude}";
        _lat = result.latitude;
        _lng = result.longitude;
        // _latLngCurrent = LatLng(result.latitude, result.longitude);
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
      if (_lat != 0.0 && _lng != 0.0) {
        await placemarkFromCoordinates(_lat, _lng).then((result) {
          _address =
              "${result.first.subAdministrativeArea} ${result.first.locality} ${result.first.thoroughfare} ${result.first.street}";
        });
      }
      // debugPrint(_address);
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

  Future<bool> uploadImage({
    required List<String> employeeId,
    required String department,
    required String team,
  }) async {
    var success = false;
    try {
      // var base64 = base64Encode(_imageScreenshot!);
      final String filename = "$_fileServername.jpg";
      var response = await HttpService.uploadImage(
        employeeId: employeeId,
        latlng: _latlng,
        address: _address,
        department: department,
        team: team,
        selfieTimestamp: _selfieTimestamp,
        logType: _logIn ? 'IN' : 'OUT',
        deviceId: _deviceId,
        app: 'orion',
        version: _appVersion,
        imagePath: filename,
      );

      if (response.success) {
        success = true;
      } else {
        _errorList.add(response.message);
      }
      // upload screenshot image to server
      await uploadImageToServer(employeeId, _imageScreenshot!, filename);
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
      sentProgress.value = 0.0;
      totalProgress.value = 0.0;
      notifyListeners();
    }
    return success;
  }

  Future<bool> uploadHistory({required HistoryModel model}) async {
    var success = false;
    try {
      final correctTime =
          await correctSelfieTime(timestamp: model.selfieTimestamp);
      final correctSelfieTimestamp = _dateFormat.format(correctTime);
      final String filename = "$_fileServername.jpg";
      var response = await HttpService.uploadImage(
        employeeId: model.employeeId,
        latlng: model.latlng,
        address: model.address,
        department: model.department,
        team: model.team,
        selfieTimestamp: correctSelfieTimestamp,
        logType: model.logType,
        deviceId: _deviceId,
        app: 'orion',
        version: _appVersion,
        imagePath: filename,
      );
      if (response.success) {
        success = true;
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
        success = false;
      }
      // upload offline screenshot image to server
      await uploadImageToServerOffline(
          model.employeeId, model.fileUint8List, model.fileServerName);
    } catch (e) {
      debugPrint('uploadHistory $e');
      _errorList.add(e.toString());
      success = false;
    }
    return success;
  }

  Future<void> saveToHistory({
    required List<String> employeeId,
    required String department,
    required String team,
    required bool uploaded,
  }) async {
    try {
      var box = Hive.box<HistoryModel>('history');
      final compressedImageScreenshot =
          await compressAndGetFile(_imageScreenshot!);
      var base64 = base64Encode(compressedImageScreenshot);
      final String filename = "$_fileServername.jpg";
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
        uploaded: uploaded,
        fileUint8List: compressedImageScreenshot,
        fileServerName: filename,
      ));
      var logBox = await Hive.openBox('logBox');
      logBox.put('lastLog', !_logIn);
      _logIn = !_logIn;
      await saveImageToGallery(filename, compressedImageScreenshot);
    } catch (e) {
      debugPrint('saveToHistory $e');
      _errorList.add(e.toString());
    } finally {}
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

  Future<void> saveImageToGallery(String fileName, Uint8List uint8list) async {
    try {
      final result = await ImageGallerySaver.saveImage(
        uint8list,
        name: fileName,
      );
      log(result.toString());
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
      log('Network time: $nptTime');
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
      debugPrint('$e getDepartment');
    }
    DateTime.now();
    return list;
  }

  Future<Uint8List> compressAndGetFile(Uint8List uint8list) async {
    var result = await FlutterImageCompress.compressWithList(
      uint8list,
      quality: 50,
      minHeight: 720,
      minWidth: 1280,
    );
    return result;
  }

  Future<void> uploadImageToServer(List<String> employeeId, Uint8List uint8list,
      String fileServerName) async {
    try {
      final compressedImageScreenshot = await compressAndGetFile(uint8list);

      // final String filename = "$_fileServername.jpg";

      final futurefileScreenshot =
          File(_image!.path).writeAsBytes(compressedImageScreenshot);

      late File fileScreenshot;
      await futurefileScreenshot.then((value) {
        fileScreenshot = value;
      });

      // final eta =  File.fromRawPath(compressedImageScreenshot);

      await HttpService.uploadFileImage(
          imageName: fileServerName,
          imagePath: fileScreenshot.path,
          employeeId: employeeId);
    } catch (e) {
      debugPrint('$e uploadImageToServer');
    }
  }

  Future<void> uploadImageToServerOffline(List<String> employeeId,
      Uint8List uint8list, String fileServerName) async {
    try {
      // final compressedImageScreenshot = File.fromRawPath(uint8list);

      // late File fileFromUint8list;
      // await File(fileServerName).writeAsBytes(uint8list).then((value) {
      //   fileFromUint8list = value;
      // });

      final tempDir = await getTemporaryDirectory();
      File file = await File('${tempDir.path}/$fileServerName').create();
      file.writeAsBytesSync(uint8list);

      await HttpService.uploadFileImage(
          imageName: fileServerName,
          imagePath: file.path,
          employeeId: employeeId);
    } catch (e) {
      debugPrint('$e uploadImageToServer');
    }
  }

  bool checkArea(LatLng checkPoint, LatLng centerPoint, double km) {
    var ky = 40000 / 360.0;
    var kx = math.cos(math.pi * centerPoint.lat / 180.0) * ky;
    var dx = (centerPoint.lng - checkPoint.lng).abs() * kx;
    var dy = (centerPoint.lat - checkPoint.lat).abs() * ky;
    return math.sqrt(dx * dx + dy * dy) <= km;
  }
}
