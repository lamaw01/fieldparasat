import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_color.dart';
import '../data/selfie_page_data.dart';

class BottomNavBarWidget extends StatelessWidget {
  const BottomNavBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var instance = Provider.of<SelfiePageData>(context);
    return Container(
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
    );
  }
}
