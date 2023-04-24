// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import '../data/selfie_page_data.dart';
import '../model/idle_model.dart';
import '../widget.dart/app_dialogs.dart';

class SavesPage extends StatefulWidget {
  const SavesPage({super.key});

  @override
  State<SavesPage> createState() => _SavesPageState();
}

class _SavesPageState extends State<SavesPage> {
  Future<bool?> _showDialogDeleteSave() async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Delete this log?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    var instance = Provider.of<SelfiePageData>(context);
    var box = Hive.box<IdleModel>('idles');
    return ValueListenableBuilder<Box<IdleModel>>(
      valueListenable: box.listenable(),
      builder: (ctx, box, child) {
        final idle = box.values.toList().cast<IdleModel>();
        if (idle.isNotEmpty) {
          return ListView.separated(
            itemCount: idle.length,
            separatorBuilder: (context, index) => const Divider(
              color: Colors.black,
            ),
            itemBuilder: (ctx, i) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    child: Image.memory(
                      idle[i].imageScreenshot,
                      fit: BoxFit.fill,
                    ),
                  ),
                  Positioned(
                    top: 3.0,
                    right: 7.0,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text(
                        'Upload',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () async {
                        // await instance
                        //     .uploadSavedImage(idle[i].image, idle[i].employeeId,
                        //         idle[i].latlng, idle[i].address)
                        //     .then((result) {
                        //   if (!instance.hasInternet.value) {
                        //     AppDialogs.showMyToast(
                        //         'Not connected to internet', context);
                        //   } else {
                        //     if (result) {
                        //       AppDialogs.showMyToast(
                        //           'Successfully log', context);
                        //       idle[i].delete();
                        //     } else {
                        //       AppDialogs.showMyToast(
                        //           'Error uploading log', context);
                        //     }
                        //   }
                        // });
                      },
                    ),
                  ),
                  Positioned(
                    top: 3.0,
                    left: 7.0,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () async {
                        await _showDialogDeleteSave().then((result) {
                          if (result!) {
                            idle[i].delete();
                          }
                        });
                      },
                    ),
                  ),
                ],
              );
            },
          );
        } else {
          return const Center(
            child: Text(
              'No Saved.',
              style: TextStyle(
                fontSize: 17.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }
      },
    );
  }
}
