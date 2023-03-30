import 'dart:io';

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

import '../data/selfie_page_data.dart';
import '../widget.dart/bottomnavbar_widget.dart';

class SelfiePage extends StatefulWidget {
  const SelfiePage({super.key});

  @override
  State<SelfiePage> createState() => _SelfiePageState();
}

class _SelfiePageState extends State<SelfiePage> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> _showMyDialog(Uint8List image) async {
    var instance = Provider.of<SelfiePageData>(context, listen: false);
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsetsDirectional.symmetric(
              vertical: 12.0, horizontal: 8.0),
          title: const Text('Confirm Image'),
          content: Image.memory(
            image,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
                instance.uploadImage();
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
              onPressed: () {
                debugPrint('send');
                if (instance.imageScreenshot != null) {
                  _showMyDialog(instance.imageScreenshot!);
                }
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
