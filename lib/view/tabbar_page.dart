import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';

import '../data/selfie_page_data.dart';
// import '../model/latlng.dart';
import '../widget/app_dialogs.dart';
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
      instance.internetStatus(status: status, context: context);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      instance.showHasLatLngNoAddressDialog(context);
      // instance.showErrorAddressDialog(context);
      var logBox = await Hive.openBox('logBox');
      bool? lastLog = logBox.get('lastLog');
      instance.changeLogType(lastLog ?? true);
      // bool isInArea = instance.checkArea(
      //   // LatLng(8.398795010522031, 124.59675687553661),
      //   instance.latLngCurrent!,
      //   LatLng(8.481100173763172, 124.64984742206732),
      //   13.0,
      // );
      // if (!isInArea) {
      //   // ignore: use_build_context_synchronously
      //   AppDialogs.showAreaNotInRange(instance.latLngCurrent!, context);
      // }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SelfiePageData>(
      builder: ((context, provider, child) {
        return AbsorbPointer(
          absorbing: provider.allowTouch,
          child: DefaultTabController(
            length: 2,
            child: Scaffold(
              appBar: AppBar(
                bottom: TabBar(
                  controller: provider.tabController,
                  indicatorColor: Colors.white,
                  labelStyle: const TextStyle(fontSize: 20.0),
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
                  child: ValueListenableBuilder<bool>(
                    valueListenable: provider.hasInternet,
                    builder: (ctx, value, child) {
                      if (value) {
                        return const Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text('Online'),
                            Icon(
                              Icons.signal_wifi_statusbar_4_bar,
                              color: Colors.green,
                            ),
                          ],
                        );
                      } else {
                        return const Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
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
                    AppDialogs.showErrorLogsDialog(provider.errorList, context);
                  },
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.info),
                    iconSize: 30.0,
                    onPressed: () {
                      AppDialogs.showAppVersionDialog(
                          'Orion ${provider.appVersion}',
                          'Device id: ${provider.deviceId}',
                          context);
                    },
                  ),
                  IconButton(
                    iconSize: 30.0,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => const UploadPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.person),
                  ),
                ],
              ),
              body: TabBarView(
                controller: provider.tabController,
                children: const [
                  SelfiePage(),
                  HistoryPage(),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
