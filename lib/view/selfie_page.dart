import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

import '../data/selfie_page_data.dart';

class SelfiePage extends StatefulWidget {
  const SelfiePage({super.key});

  @override
  State<SelfiePage> createState() => _SelfiePageState();
}

class _SelfiePageState extends State<SelfiePage> {
  final style = const TextStyle(
    fontSize: 17.0,
    color: Colors.white,
    shadows: [
      Shadow(
        blurRadius: 10.0,
        color: Colors.black,
        offset: Offset(0.0, 1.0),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    var instance = Provider.of<SelfiePageData>(context);
    var size = MediaQuery.of(context).size;
    if (instance.image == null && instance.imageScreenshot == null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: instance.logIn ? Colors.green : null,
                ),
                onPressed: () {
                  instance.changeLogType(true);
                },
                child: const Text(
                  '   IN   ',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: !instance.logIn ? Colors.green : null,
                ),
                onPressed: () {
                  instance.changeLogType(false);
                },
                child: const Text(
                  '   OUT   ',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      return Screenshot(
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
                    style: style,
                  ),
                  Text(
                    "Altitude: ${instance.altitude}m",
                    style: style,
                  ),
                  Text(
                    "Heading ${instance.heading}°",
                    style: style,
                  ),
                  Text(
                    instance.dateTimeDisplay,
                    style: style,
                  ),
                  Text(
                    instance.latlng,
                    style: style,
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
                        shadows: [
                          Shadow(
                            blurRadius: 10.0,
                            color: Colors.black,
                            offset: Offset(0.0, 1.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
}
