import 'dart:async';
import 'dart:io';

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';

import '../app_color.dart';
import '../data/selfie_page_data.dart';
import '../widget.dart/bottomnavbar_widget.dart';

class SelfiePage extends StatefulWidget {
  const SelfiePage({super.key});

  @override
  State<SelfiePage> createState() => _SelfiePageState();
}

class _SelfiePageState extends State<SelfiePage> {
  final nameController = TextEditingController();
  final idController = TextEditingController();
  StreamSubscription<InternetConnectionStatus>? listener;
  bool hasInternet = false;

  @override
  void initState() {
    super.initState();
    listener = InternetConnectionChecker().onStatusChange.listen((status) {
      switch (status) {
        case InternetConnectionStatus.connected:
          hasInternet = true;
          break;
        case InternetConnectionStatus.disconnected:
          hasInternet = false;
          break;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    idController.dispose();
    listener!.cancel();
  }

  Future<void> _showMyDialog(Uint8List image) async {
    var instance = Provider.of<SelfiePageData>(context, listen: false);
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsetsDirectional.symmetric(
              vertical: 12.0, horizontal: 8.0),
          title: const Text('Employee Info'),
          content: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                textCapitalization: TextCapitalization.words,
                controller: nameController,
                autofocus: true,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  focusColor: Colors.white,
                  hintText: 'Name..',
                  contentPadding: EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 12.0),
                ),
                onEditingComplete: () {
                  FocusScope.of(context).unfocus();
                },
              ),
              TextField(
                controller: idController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  focusColor: Colors.white,
                  hintText: 'ID number..',
                  contentPadding: EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 12.0),
                ),
                onEditingComplete: () {
                  FocusScope.of(context).unfocus();
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () async {
                if (nameController.text.isEmpty || idController.text.isEmpty) {
                  _showMyToast('Missing Fields..');
                } else {
                  await instance
                      .uploadImage(
                          nameController.text.trim(), idController.text.trim())
                      .then((result) {
                    Navigator.of(context).pop();
                    if (!hasInternet) {
                      _showMyToast('Not connected to internet');
                    } else {
                      if (result) {
                        _showMyToast('Successfully log');
                        nameController.clear();
                        idController.clear();
                      } else {
                        _showMyToast('Error uploading log');
                      }
                    }
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showMyToast(String message) {
    showToastWidget(
      Container(
        height: 150.0,
        width: 300.0,
        padding: const EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          color: AppColor.kMainColor,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                message,
                textAlign: TextAlign.center,
                maxLines: 4,
                style: const TextStyle(
                  fontSize: 24.0,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
      context: context,
      animation: StyledToastAnimation.scale,
      reverseAnimation: StyledToastAnimation.fade,
      position: StyledToastPosition.center,
      animDuration: const Duration(seconds: 1),
      duration: const Duration(seconds: 5),
      curve: Curves.elasticOut,
      reverseCurve: Curves.linear,
    );
  }

  void _showErrorLogsDialog(List<String> list) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error logs'),
          content: ListView.builder(
            itemCount: list.length,
            itemBuilder: (ctx, i) {
              return Text(list[i]);
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var instance = Provider.of<SelfiePageData>(context);
    var size = MediaQuery.of(context).size;
    if (instance.image == null && instance.imageScreenshot == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Parasat Selfie DTR'),
        ),
        body: const Center(
          child: Text(
            'No Image.',
            style: TextStyle(
              fontSize: 17.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        bottomNavigationBar: const BottomNavBarWidget(),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: GestureDetector(
            child: const Text('Parasat Selfie DTR'),
            onDoubleTap: () {
              _showErrorLogsDialog(instance.errorList);
            },
          ),
          actions: [
            if (instance.imageScreenshot != null) ...[
              TextButton(
                onPressed: () {
                  _showMyDialog(instance.imageScreenshot!);
                },
                child: const Text(
                  'Send',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ],
        ),
        body: Screenshot(
          controller: instance.screenshotController,
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: [
              Center(
                child: SizedBox(
                  height: size.height,
                  width: size.width,
                  child: Image.file(
                    File(instance.image!.path),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                right: 5.0,
                bottom: 5.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Speed: ${instance.speed}",
                      style: const TextStyle(
                        fontSize: 17.0,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "Altitude: ${instance.altitude}m",
                      style: const TextStyle(
                        fontSize: 17.0,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "Heading ${instance.heading}°",
                      style: const TextStyle(
                        fontSize: 17.0,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      instance.dateTimeDisplay,
                      style: const TextStyle(
                        fontSize: 17.0,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      instance.latlng,
                      style: const TextStyle(
                        fontSize: 17.0,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(
                      height: 50.0,
                      width: size.width - 10.0,
                      child: Text(
                        instance.address,
                        textAlign: TextAlign.end,
                        maxLines: 2,
                        style: const TextStyle(
                          fontSize: 17.0,
                          color: Colors.white,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const BottomNavBarWidget(),
      );
    }
  }
}
