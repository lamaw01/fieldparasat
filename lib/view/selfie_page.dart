import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

import '../app_color.dart';
import '../data/selfie_page_data.dart';
import '../model/preset_model.dart';

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
    var box = Hive.box<PresetModel>('previous');
    var size = MediaQuery.of(context).size;
    if (instance.image == null && instance.imageScreenshot == null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: 150.0,
                height: 100.0,
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: instance.logIn ? Colors.green : null,
                  ),
                  onPressed: () {
                    instance.changeLogType(true);
                  },
                  child: Text(
                    'IN',
                    style: TextStyle(
                      fontSize: 32.0,
                      fontWeight: FontWeight.w600,
                      color: instance.logIn ? Colors.white : null,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 150.0,
                height: 100.0,
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: !instance.logIn ? Colors.green : null,
                  ),
                  onPressed: () {
                    instance.changeLogType(false);
                  },
                  child: Text(
                    'OUT',
                    style: TextStyle(
                      fontSize: 32.0,
                      fontWeight: FontWeight.w600,
                      color: !instance.logIn ? Colors.white : null,
                    ),
                  ),
                ),
              ),
            ],
          ),
          ValueListenableBuilder<Box<PresetModel>>(
              valueListenable: box.listenable(),
              builder: (ctx, box, child) {
                PresetModel? last = box.get('last');
                if (last == null) {
                  return const SizedBox();
                } else {
                  return Container(
                    color: AppColor.kMainColor,
                    width: double.infinity,
                    height: 60.0,
                    child: TextButton.icon(
                      onPressed: () async {
                        await instance.getImage().then((result) async {
                          if (result) {
                            instance.uploading();
                            await instance.captureImage();
                            if (instance.tabController.index == 0) {
                              instance.tabController.animateTo(1);
                            }
                            await instance.uploadImage(
                              employeeId: last.employeeId,
                              department: last.department,
                              team: last.team,
                              logType: instance.logIn ? 'IN' : 'OUT',
                            );
                            instance.uploading();
                          }
                        });
                      },
                      icon: const Icon(
                        Icons.camera,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Take Photo',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                }
              }),
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
