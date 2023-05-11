import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';

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

class _TabBarPageState extends State<TabBarPage> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    var instance = Provider.of<SelfiePageData>(context, listen: false);
    var internetChecker =
        Provider.of<InternetConnectionChecker>(context, listen: false);
    instance.tabController = TabController(length: 2, vsync: this);
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
          bottom: TabBar(
            controller: instance.tabController,
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
            // child: const Text('Parasat Selfie DTR'),
            child: ValueListenableBuilder<bool>(
              valueListenable: instance.hasInternet,
              builder: (ctx, value, child) {
                if (value) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: const [
                      Text('Online'),
                      Icon(
                        Icons.signal_wifi_statusbar_4_bar,
                        color: Colors.green,
                      ),
                    ],
                  );
                } else {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: const [
                      Text('Offline'),
                      Icon(
                        Icons.signal_wifi_off,
                        color: Colors.red,
                      ),
                    ],
                  );
                }
              },
            ),
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
          controller: instance.tabController,
          children: const [
            SelfiePage(),
            SavesPage(),
          ],
        ),
      ),
    );
  }
}
