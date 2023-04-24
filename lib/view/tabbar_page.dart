import 'dart:async';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';

import '../app_color.dart';
import '../data/selfie_page_data.dart';
import '../widget.dart/app_dialogs.dart';
import '../widget.dart/bottomnavbar_widget.dart';
import 'saves_page.dart';
import 'selfie_page.dart';
import 'upload_page.dart';

class TabBarPage extends StatefulWidget {
  const TabBarPage({super.key});

  @override
  State<TabBarPage> createState() => _TabBarPageState();
}

class _TabBarPageState extends State<TabBarPage> {
  final departmentController = TextEditingController();
  var idControllerList = <TextEditingController>[
    TextEditingController(),
  ];

  @override
  void initState() {
    super.initState();
    var internetChecker =
        Provider.of<InternetConnectionChecker>(context, listen: false);
    var instance = Provider.of<SelfiePageData>(context, listen: false);
    internetChecker.onStatusChange.listen((status) async {
      instance.internetStatus(status);
    });
  }

  @override
  void dispose() {
    super.dispose();
    departmentController.dispose();
  }

  // ignore: unused_element
  Future<void> _showMyDialog() async {
    // ignore: unused_local_variable
    var instance = Provider.of<SelfiePageData>(context, listen: false);
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsetsDirectional.symmetric(
              vertical: 12.0, horizontal: 8.0),
          title: const Text('Employee Info'),
          content: StatefulBuilder(
            builder: (context, setState) => SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = 0; i < idControllerList.length; i++) ...[
                    TextField(
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.grey, width: 1.0),
                        ),
                        hintText: 'Id number..',
                        contentPadding:
                            const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 12.0),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              idControllerList.removeAt(i);
                            });
                          },
                          icon: const Icon(Icons.delete),
                        ),
                      ),
                      controller: idControllerList[i],
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      onEditingComplete: () {
                        FocusScope.of(context).unfocus();
                      },
                    ),
                    const SizedBox(
                      height: 5.0,
                    ),
                  ],
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: AppColor.kMainColor,
                    ),
                    child: const Text(
                      'Add Id',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      setState(() {
                        idControllerList.add(TextEditingController());
                      });
                    },
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  TextField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      ),
                      hintText: 'Department..',
                      contentPadding:
                          EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 12.0),
                    ),
                    textCapitalization: TextCapitalization.words,
                    controller: departmentController,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    onEditingComplete: () {
                      FocusScope.of(context).unfocus();
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            // TextButton(
            //   child: const Text('Save'),
            //   onPressed: () async {
            //     if (departmentController.text.isEmpty ||
            //         idController.text.isEmpty) {
            //       FocusScope.of(context).unfocus();
            //       AppDialogs.showMyToast('Missing Fields..', context);
            //     } else {
            //       await instance
            //           .saveData(departmentController.text.trim(),
            //               idController.text.trim())
            //           .then((_) {
            //         Navigator.of(context).pop();
            //         departmentController.clear();
            //         idController.clear();
            //         AppDialogs.showMyToast('Saved', context);
            //       });
            //     }
            //   },
            // ),
            // TextButton(
            //   child: const Text('Send'),
            //   onPressed: () async {
            //     if (idControllerList[0].text.isEmpty) {
            //       FocusScope.of(context).unfocus();
            //       AppDialogs.showMyToast('Missing Fields..', context);
            //     } else {
            //       await instance
            //           .uploadImage(idControllerList[0].text.trim())
            //           .then((result) {
            //         Navigator.of(context).pop();
            //         if (!instance.hasInternet.value) {
            //           AppDialogs.showMyToast(
            //               'Not connected to internet', context);
            //         } else {
            //           if (result) {
            //             AppDialogs.showMyToast('Successfully log', context);
            //             departmentController.clear();
            //             idControllerList[0].clear();
            //           } else {
            //             AppDialogs.showMyToast('Error uploading log', context);
            //           }
            //         }
            //       });
            //     }
            //   },
            // ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var instance = Provider.of<SelfiePageData>(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(
                text: 'Home',
              ),
              Tab(
                text: 'Saved',
              ),
            ],
          ),
          title: GestureDetector(
            child: const Text('Parasat Selfie DTR'),
            onDoubleTap: () {
              AppDialogs.showErrorLogsDialog(instance.errorList, context);
            },
          ),
          actions: [
            if (instance.imageScreenshot != null) ...[
              TextButton(
                onPressed: () {
                  // _showMyDialog();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => const UploadPage(),
                    ),
                  );
                },
                child: const Text(
                  'Upload',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ],
        ),
        body: const TabBarView(
          children: [
            SelfiePage(),
            SavesPage(),
          ],
        ),
        bottomNavigationBar: const BottomNavBarWidget(),
      ),
    );
  }
}
