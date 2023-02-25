import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart';

import 'custom_color.dart';

class SelfiePage extends StatefulWidget {
  const SelfiePage(
      {super.key, required this.position, required this.placemarks});
  final Position position;
  final List<Placemark> placemarks;

  @override
  State<SelfiePage> createState() => _SelfiePageState();
}

class _SelfiePageState extends State<SelfiePage> {
  final ImagePicker _picker = ImagePicker();
  XFile? image;
  XFile? photo;
  String date = DateFormat('yyyy-MM-dd - HH:mm:ss').format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selfie'),
      ),
      body: Center(
        child: Stack(
          children: [
            if (image == null) ...[
              const Center(child: Text('No Image'))
            ] else ...[
              Image.file(File(image!.path)),
              Positioned(
                right: 5.0,
                bottom: 5.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.placemarks.first.subAdministrativeArea!,
                      style:
                          const TextStyle(fontSize: 16.0, color: Colors.white),
                    ),
                    Text(
                      date,
                      style:
                          const TextStyle(fontSize: 16.0, color: Colors.white),
                    ),
                    Text(
                      widget.position.latitude.toString(),
                      style:
                          const TextStyle(fontSize: 16.0, color: Colors.white),
                    ),
                    Text(
                      widget.position.longitude.toString(),
                      style:
                          const TextStyle(fontSize: 16.0, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ]
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: Palette.kToDark,
        width: double.infinity,
        height: 60.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              onPressed: () async {
                var imageFromCamera =
                    await _picker.pickImage(source: ImageSource.camera);
                setState(() {
                  image = imageFromCamera;
                });
              },
              icon: const Icon(Icons.photo),
              label: const Text(
                'Take Photo',
                style: TextStyle(color: Colors.white),
              ),
            ),
            TextButton.icon(
              onPressed: () async {
                var imageFromGallery =
                    await _picker.pickImage(source: ImageSource.gallery);
                setState(() {
                  image = imageFromGallery;
                });
              },
              icon: const Icon(Icons.photo_camera),
              label: const Text(
                'Select Photo',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
