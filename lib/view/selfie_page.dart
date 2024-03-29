import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

import '../app_color.dart';
import '../data/selfie_page_data.dart';
import '../model/preset_model.dart';
import '../widget/app_dialogs.dart';

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

    return Consumer<SelfiePageData>(
      builder: (context, provider, child) {
        if (provider.image == null && provider.imageScreenshot == null) {
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
                        backgroundColor:
                            instance.logIn ? Colors.green : Colors.grey[400],
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
                        backgroundColor:
                            !instance.logIn ? Colors.green : Colors.grey[400],
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
                      width: size.width,
                      height: 90.0,
                      child: instance.gettingAddress
                          ? const Center(
                              child: SizedBox(
                                width: 50.0,
                                height: 50.0,
                                child: CircularProgressIndicator(
                                    color: Colors.white),
                              ),
                            )
                          : TextButton.icon(
                              onPressed: () async {
                                await instance.checkGalleryPermission();
                                instance.changeGettingAddressState(true);
                                await instance.getPosition();
                                await instance.translateLatLng();
                                instance.changeGettingAddressState(false);
                                instance.disableTouch(true);
                                await instance.getImage().then((result) async {
                                  if (result) {
                                    await instance.captureImage();
                                    instance.changeUploadingState(true);
                                    await Future.delayed(
                                        const Duration(seconds: 1));
                                    await instance
                                        .uploadImage(
                                            employeeId: last.employeeId,
                                            department: last.department,
                                            team: last.team)
                                        .then((result) async {
                                      instance.changeUploadingState(false);
                                      if (result) {
                                        AppDialogs.showMyToast(
                                            'Success selfie log uploaded',
                                            context);
                                      } else {
                                        AppDialogs.showMyToast(
                                            'Error uploading selfie log',
                                            context);
                                      }
                                      await Future.delayed(
                                          const Duration(seconds: 1));
                                      if (instance.tabController.index == 0) {
                                        instance.tabController.animateTo(1);
                                      }
                                    });
                                  }
                                });
                                instance.disableTouch(false);
                              },
                              icon: const Icon(
                                Icons.camera,
                                color: Colors.white,
                                size: 30.0,
                              ),
                              label: const Text(
                                'Take Photo',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24.0,
                                ),
                              ),
                            ),
                    );
                  }
                },
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
                if (instance.isUploading) ...[
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Uploading...',
                            textAlign: TextAlign.center,
                            maxLines: 4,
                            style: TextStyle(
                              fontSize: 30.0,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 5),
                          SpinKitFadingCircle(
                            color: Colors.white,
                            size: 50.0,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ValueListenableBuilder<double>(
                            valueListenable: sentProgress,
                            builder: (context, value, widget) {
                              return SizedBox(
                                width: 125.0,
                                child: Text(
                                  'Sent: $value KB',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 18.0,
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 3.0),
                          ValueListenableBuilder<double>(
                            valueListenable: totalProgress,
                            builder: (context, value, widget) {
                              return SizedBox(
                                width: 125.0,
                                child: Text(
                                  'Total: $value KB',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 18.0,
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ],
            ),
          );
        }
      },
    );
  }
}

final ValueNotifier<double> sentProgress = ValueNotifier<double>(0);
final ValueNotifier<double> totalProgress = ValueNotifier<double>(0);
