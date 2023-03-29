import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_color.dart';
import '../data/selfie_page_data.dart';
import 'selfie_page.dart';

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
      await context.read<SelfiePageData>().init().then((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => const SelfiePage(),
          ),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.kMainColor,
      body: Center(
        child: Card(
          child: SizedBox(
            height: 75.0,
            width: 200.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
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
