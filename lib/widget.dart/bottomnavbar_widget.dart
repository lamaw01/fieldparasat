import 'package:flutter/material.dart';

import '../app_color.dart';

class BottomNavBarWidget extends StatelessWidget {
  const BottomNavBarWidget({super.key, required this.callback});
  final VoidCallback callback;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColor.kMainColor,
      width: double.infinity,
      height: 60.0,
      child: TextButton.icon(
        onPressed: callback,
        icon: const Icon(
          Icons.camera,
          color: Colors.white,
        ),
        label: const Text(
          'Take Photo',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
