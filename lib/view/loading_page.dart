import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_color.dart';
import '../data/selfie_page_data.dart';
import 'tabbar_page.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<SelfiePageData>().checkVersion();
      if (context.mounted) {
        await context.read<SelfiePageData>().showVersionAppDialog(context);
      }
      if (context.mounted) {
        await context.read<SelfiePageData>().checkLocationService(context);
      }
      if (context.mounted) {
        await context.read<SelfiePageData>().init().then((_) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => const TabBarPage(),
            ),
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColor.kMainColor,
      body: Center(
        child: Card(
          child: SizedBox(
            height: 75.0,
            width: 200.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('Loading...'),
                CircularProgressIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
