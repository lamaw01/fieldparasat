import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';

import '../app_color.dart';
import '../data/selfie_page_data.dart';
import '../widget.dart/app_dialogs.dart';
import 'history_page.dart';
import 'selfie_page.dart';
import 'upload_page.dart';

class TabBarPage extends StatefulWidget {
  const TabBarPage({super.key});

  @override
  State<TabBarPage> createState() => _TabBarPageState();
}

class _TabBarPageState extends State<TabBarPage> {
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
  Widget build(BuildContext context) {
    var instance = Provider.of<SelfiePageData>(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(
                text: 'Home',
              ),
              Tab(
                text: 'History',
              ),
            ],
          ),
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => const UploadPage()),
                  );
                },
                child: const Text(
                  'Upload',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ],
        ),
        body: const TabBarView(
          children: [
            SelfiePage(),
            SavesPage(),
          ],
        ),
        bottomNavigationBar: Container(
          color: AppColor.kMainColor,
          width: double.infinity,
          height: 60.0,
          child: TextButton.icon(
            onPressed: () async {
              await instance.getImage();
              await instance.captureImage();
            },
            icon: const Icon(
              Icons.camera,
              color: Colors.white,
            ),
            label: instance.image != null
                ? const Text(
                    'Retake Photo',
                    style: TextStyle(color: Colors.white),
                  )
                : const Text(
                    'Take Photo',
                    style: TextStyle(color: Colors.white),
                  ),
          ),
        ),
      ),
    );
  }
}
