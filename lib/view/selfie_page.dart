import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

import '../data/selfie_page_data.dart';
import '../widget.dart/app_dialogs.dart';
import '../widget.dart/bottomnavbar_widget.dart';
import 'saves_page.dart';

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
    var internetChecker =
        Provider.of<InternetConnectionChecker>(context, listen: false);
    var instance = Provider.of<SelfiePageData>(context, listen: false);
    internetChecker.onStatusChange.listen((status) async {
      instance.internetStatus(status);
    });
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    idController.dispose();
  }

  Future<void> _showMyDialog() async {
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
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                if (nameController.text.isEmpty || idController.text.isEmpty) {
                  FocusScope.of(context).unfocus();
                  AppDialogs.showMyToast('Missing Fields..', context);
                } else {
                  await instance
                      .saveData(
                          nameController.text.trim(), idController.text.trim())
                      .then((_) {
                    Navigator.of(context).pop();
                    AppDialogs.showMyToast('Saved', context);
                  });
                }
              },
            ),
            TextButton(
              child: const Text('Send'),
              onPressed: () async {
                if (nameController.text.isEmpty || idController.text.isEmpty) {
                  FocusScope.of(context).unfocus();
                  AppDialogs.showMyToast('Missing Fields..', context);
                } else {
                  await instance
                      .uploadImage(
                          nameController.text.trim(), idController.text.trim())
                      .then((result) {
                    Navigator.of(context).pop();
                    if (instance.hasInternet.value) {
                      AppDialogs.showMyToast(
                          'Not connected to internet', context);
                    } else {
                      if (result) {
                        AppDialogs.showMyToast('Successfully log', context);
                        nameController.clear();
                        idController.clear();
                      } else {
                        AppDialogs.showMyToast('Error uploading log', context);
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

  @override
  Widget build(BuildContext context) {
    var instance = Provider.of<SelfiePageData>(context);
    var size = MediaQuery.of(context).size;
    if (instance.image == null && instance.imageScreenshot == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Parasat Selfie DTR'),
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              ListTile(
                title: const Text('Saves'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => const SavesPage(),
                    ),
                  );
                },
              ),
            ],
          ),
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
              AppDialogs.showErrorLogsDialog(instance.errorList, context);
            },
          ),
          actions: [
            if (instance.imageScreenshot != null) ...[
              TextButton(
                onPressed: () {
                  _showMyDialog();
                },
                child: const Text(
                  'Upload',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ],
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              ListTile(
                title: const Text('Saves'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => const SavesPage(),
                    ),
                  );
                },
              ),
            ],
          ),
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
