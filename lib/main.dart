import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app_color.dart';
import 'data/selfie_page_data.dart';
import 'model/history_model.dart';
import 'view/loading_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await Hive.initFlutter();
  Hive.registerAdapter(HistoryModelAdapter());
  await Hive.openBox<HistoryModel>('history');
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SelfiePageData>(
          create: (_) => SelfiePageData(),
        ),
        Provider<InternetConnectionChecker>(
          create: (_) => InternetConnectionChecker.createInstance(
            checkTimeout: const Duration(seconds: 5),
            checkInterval: const Duration(seconds: 5),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Orion',
      theme: ThemeData(
        primarySwatch: AppColor.kMainColor,
      ),
      home: const LoadingPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
