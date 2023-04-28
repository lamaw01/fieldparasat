import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../app_color.dart';
import '../model/preset_model.dart';
import '../data/selfie_page_data.dart';
import '../widget.dart/app_dialogs.dart';
import 'add_preset_page.dart';

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
  void dispose() {
    super.dispose();
    departmentController.dispose();
    for (var idController in idControllerList) {
      idController.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    var instance = Provider.of<SelfiePageData>(context);

    Future<void> goToAddPresetPage() async {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const AddPresetPage(),
        ),
      );
    }

    Future<bool?> showDialogDeletePreset(String presetName) async {
      return showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Delete Preset'),
            content: Text(
              'Delete this preset $presetName?',
            ),
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

    Future<void> showPresetDialog() async {
      return showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          var box = Hive.box<PresetModel>('preset');
          return AlertDialog(
            title: const Text('Preset'),
            content: ValueListenableBuilder<Box<PresetModel>>(
              valueListenable: box.listenable(),
              builder: (ctx, box, child) {
                final preset = box.values.toList().cast<PresetModel>().toList();
                if (preset.isNotEmpty) {
                  return ListView.builder(
                    itemCount: preset.length,
                    itemBuilder: (ctx, i) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Card(
                            child: ListTile(
                              dense: false,
                              title: Text(
                                preset[i].presetName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onTap: () {
                                idControllerList.clear();
                                for (int j = 0;
                                    j < preset[i].employeeId.length;
                                    j++) {
                                  idControllerList.add(
                                    TextEditingController(
                                        text: preset[i].employeeId[j]),
                                  );
                                }
                                departmentController.text =
                                    preset[i].department;
                                Navigator.of(context).pop();
                                setState(() {});
                              },
                              onLongPress: () {
                                showDialogDeletePreset(preset[i].presetName)
                                    .then((result) {
                                  if (result!) {
                                    preset[i].delete();
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
                      'Empty History.',
                      style: TextStyle(
                        fontSize: 17.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }
              },
            ),
            actions: <Widget>[
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload info'),
        actions: [
          PopupMenuButton<String>(
            child: Container(
              margin: const EdgeInsets.all(10),
              child: const Icon(Icons.settings),
            ),
            onSelected: (value) async {
              switch (value) {
                case 'open_preset':
                  return showPresetDialog();
                case 'open_add_preset':
                  return goToAddPresetPage();
                default:
                  throw UnimplementedError();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'open_preset',
                onTap: () {},
                child: const Text('Preset'),
              ),
              PopupMenuItem(
                value: 'open_add_preset',
                onTap: () {},
                child: const Text('Add preset'),
              ),
            ],
          )
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
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                    ),
                  ),
                  controller: idControllerList[i],
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
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
              ),
              const SizedBox(height: 5.0),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CupertinoSwitch(
                    activeColor: Colors.green,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            idControllerList.add(TextEditingController());
          });
        },
        backgroundColor: Colors.green,
        child: const Text('Add Id'),
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
                    await instance.uploadImage(
                        employeeId: <String>[
                          for (var id in idControllerList) id.text,
                        ],
                        department: departmentController.text.trim(),
                        logType: logType ? 'IN' : 'OUT').then((result) async {
                      if (result) {
                        AppDialogs.showMyToast('Successfully log', context);
                      } else {
                        if (!instance.hasInternet.value) {
                          AppDialogs.showMyToast(
                              'Not connected to internet', context);
                        } else {
                          AppDialogs.showMyToast(
                              'Error uploading log', context);
                        }
                      }
                      await Future.delayed(const Duration(seconds: 3))
                          .then((_) {
                        Navigator.of(context).pop();
                      });
                    });
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
