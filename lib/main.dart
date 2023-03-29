import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'app_color.dart';
import 'data/selfie_page_data.dart';
import 'view/loading_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SelfiePageData>(
          create: (_) => SelfiePageData(),
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
