import 'dart:io';

import 'dart:typed_data';

import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    idController.dispose();
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
          // content: Image.memory(image),
          content: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                textCapitalization: TextCapitalization.words,
                controller: nameController,
                autofocus: true,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
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
                textCapitalization: TextCapitalization.words,
                controller: idController,
                autofocus: true,
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
              onPressed: () {
                if (nameController.text.isEmpty || idController.text.isEmpty) {
                  _showMyToast('Missing Fields..');
                } else {
                  Navigator.of(context).pop();
                }
                instance.uploadImage();
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

  @override
  Widget build(BuildContext context) {
    var instance = Provider.of<SelfiePageData>(context);
    var size = MediaQuery.of(context).size;
    if (instance.image == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Parasat Selfie DTR'),
        ),
        body: const Center(
          child: Text(
            'No Image',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        bottomNavigationBar: const BottomNavBarWidget(),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Parasat Selfie DTR'),
          actions: [
            TextButton(
              onPressed: () async {
                debugPrint('send');
                if (instance.imageScreenshot == null) {
                  await instance.captureImage();
                }
                _showMyDialog(instance.imageScreenshot!);
              },
              child: const Text(
                'Send',
                style: TextStyle(color: Colors.white),
              ),
            ),
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
                        fontSize: 16.0,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "Altitude: ${instance.altitude}m",
                      style: const TextStyle(
                        fontSize: 16.0,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "Heading ${instance.heading}°",
                      style: const TextStyle(
                        fontSize: 16.0,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      instance.dateTimeDisplay,
                      style: const TextStyle(
                        fontSize: 16.0,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      instance.latlng,
                      style: const TextStyle(
                        fontSize: 16.0,
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
                          fontSize: 16.0,
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
