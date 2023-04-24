import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_color.dart';
import '../data/selfie_page_data.dart';
import '../widget.dart/app_dialogs.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final departmentController = TextEditingController();
  var idControllerList = <TextEditingController>[
    TextEditingController(),
  ];
  bool logType = true;

  @override
  Widget build(BuildContext context) {
    var instance = Provider.of<SelfiePageData>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload info'),
        actions: [
          TextButton(
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
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < idControllerList.length; i++) ...[
                TextField(
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1.0),
                    ),
                    hintText: 'Id number..',
                    contentPadding:
                        const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 12.0),
                    suffixIcon: IconButton(
                      onPressed: () {
                        debugPrint(i.toString());
                        if (idControllerList.length != 1) {
                          setState(() {
                            idControllerList.removeAt(i);
                          });
                        }
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
                const SizedBox(height: 5.0),
              ],
              const SizedBox(height: 5.0),
              TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1.0),
                  ),
                  hintText: 'Department..',
                  contentPadding: EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 12.0),
                ),
                textCapitalization: TextCapitalization.words,
                controller: departmentController,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
                onEditingComplete: () {
                  FocusScope.of(context).unfocus();
                },
              ),
              const SizedBox(height: 5.0),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CupertinoSwitch(
                    activeColor: AppColor.kMainColor,
                    value: logType,
                    onChanged: (bool value) {
                      setState(() {
                        logType = value;
                      });
                    },
                  ),
                  Text(logType ? 'IN' : 'OUT'),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: AppColor.kMainColor,
        width: double.infinity,
        height: 60.0,
        child: instance.isUploading
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'Uploading..',
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(width: 5.0),
                  CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ],
              )
            : TextButton.icon(
                onPressed: () async {
                  bool isEmpty = false;
                  for (int i = 0; i < idControllerList.length; i++) {
                    if (idControllerList[i].text.isEmpty ||
                        departmentController.text.isEmpty) {
                      AppDialogs.showMyToast('Missing Fields..', context);
                      isEmpty = true;
                      break;
                    }
                  }

                  if (!isEmpty) {
                    if (!instance.hasInternet.value) {
                      AppDialogs.showMyToast(
                          'Not connected to internet', context);
                    } else {
                      await instance.uploadImage(
                          employeeId: <String>[
                            for (var id in idControllerList) id.text,
                          ],
                          department: departmentController.text.trim(),
                          logType: logType ? 'IN' : 'OUT').then((result) async {
                        if (result) {
                          AppDialogs.showMyToast('Successfully log', context);
                          await Future.delayed(const Duration(seconds: 3))
                              .then((_) {
                            Navigator.of(context).pop();
                          });
                        } else {
                          AppDialogs.showMyToast(
                              'Error uploading log', context);
                        }
                      });
                    }
                  }
                },
                icon: const Icon(
                  Icons.upload,
                  color: Colors.white,
                ),
                label: const Text(
                  'Upload',
                  style: TextStyle(color: Colors.white),
                ),
              ),
      ),
    );
  }
}
