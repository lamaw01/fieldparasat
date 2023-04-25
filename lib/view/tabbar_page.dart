import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';

import '../data/selfie_page_data.dart';
import '../widget.dart/app_dialogs.dart';
import '../widget.dart/bottomnavbar_widget.dart';
import 'history_page.dart';
import 'selfie_page.dart';
import 'upload_page.dart';

class TabBarPage extends StatefulWidget {
  const TabBarPage({super.key});

  @override
  State<TabBarPage> createState() => _TabBarPageState();
}

class _TabBarPageState extends State<TabBarPage> {
  final departmentController = TextEditingController();
  var idControllerList = <TextEditingController>[
    TextEditingController(),
  ];

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
    departmentController.dispose();
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
                  // _showMyDialog();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => const UploadPage(),
                    ),
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
        bottomNavigationBar: const BottomNavBarWidget(),
      ),
    );
  }
}
