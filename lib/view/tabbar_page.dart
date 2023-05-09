import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';

import '../app_color.dart';
import '../data/selfie_page_data.dart';
import '../model/preset_model.dart';
import '../widget.dart/app_dialogs.dart';
import 'history_page.dart';
import 'selfie_page.dart';
import 'upload_page.dart';

class TabBarPage extends StatefulWidget {
  const TabBarPage({super.key});

  @override
  State<TabBarPage> createState() => _TabBarPageState();
}

class _TabBarPageState extends State<TabBarPage> with TickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
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
    var box = Hive.box<PresetModel>('previous');

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            controller: tabController,
            indicatorColor: Colors.white,
            tabs: const [
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
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => const UploadPage()),
                );
              },
              icon: const Icon(Icons.arrow_forward),
            ),
          ],
        ),
        body: TabBarView(
          controller: tabController,
          children: const [
            SelfiePage(),
            SavesPage(),
          ],
        ),
        bottomNavigationBar: ValueListenableBuilder<Box<PresetModel>>(
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
                          await instance.captureImage();
                          if (tabController.index == 0) {
                            tabController.animateTo(1);
                          }
                          await instance.uploadImage(
                            employeeId: last.employeeId,
                            department: last.department,
                            logType: instance.logIn ? 'IN' : 'OUT',
                          );
                        }
                      });
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
                );
              }
            }),
      ),
    );
  }
}
