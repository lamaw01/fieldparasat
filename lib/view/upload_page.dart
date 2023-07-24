import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import '../app_color.dart';
import '../data/selfie_page_data.dart';
import '../model/department_model.dart';
import '../model/preset_model.dart';
import '../widget/app_dialogs.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final teamController = TextEditingController();
  var idControllerList = <TextEditingController>[
    TextEditingController(),
  ];
  bool logType = true;

  var departmentList = <DepartmentModel>[];
  var dropdownValue2 = 'Select';
  var departmentList2 = <String>[];

  @override
  void initState() {
    super.initState();
    var box = Hive.box<PresetModel>('previous');
    PresetModel? last = box.get('last');
    var instance = Provider.of<SelfiePageData>(context, listen: false);
    if (last != null) {
      dropdownValue2 = last.department;
      teamController.text = last.team;
      idControllerList.clear();
      for (var idText in last.employeeId) {
        idControllerList.add(TextEditingController(text: idText));
      }
    }
    // departmentList.add(dropdownValue);
    departmentList2.add(dropdownValue2);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      var result = await instance.getDepartment();
      departmentList.addAll(result);
      for (var department in departmentList) {
        if (dropdownValue2 != department.departmentName) {
          departmentList2.add(department.departmentName);
        }
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    teamController.dispose();
    for (var idController in idControllerList) {
      idController.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Future<void> goToAddPresetPage() async {
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //       builder: (BuildContext context) => const AddPresetPage(),
    //     ),
    //   );
    // }

    // Future<bool?> showDialogDeletePreset(String presetName) async {
    //   return showDialog<bool>(
    //     context: context,
    //     barrierDismissible: false,
    //     builder: (BuildContext context) {
    //       return AlertDialog(
    //         title: const Text('Delete Preset'),
    //         content: Text(
    //           'Delete this preset $presetName?',
    //         ),
    //         actions: <Widget>[
    //           TextButton(
    //             child: const Text('Ok'),
    //             onPressed: () {
    //               Navigator.of(context).pop(true);
    //             },
    //           ),
    //           TextButton(
    //             child: const Text('Cancel'),
    //             onPressed: () {
    //               Navigator.of(context).pop(false);
    //             },
    //           ),
    //         ],
    //       );
    //     },
    //   );
    // }

    // Future<void> showPresetDialog() async {
    //   return showDialog<void>(
    //     context: context,
    //     barrierDismissible: true,
    //     builder: (BuildContext context) {
    //       var box = Hive.box<PresetModel>('preset');
    //       return AlertDialog(
    //         title: const Text('Preset'),
    //         content: ValueListenableBuilder<Box<PresetModel>>(
    //           valueListenable: box.listenable(),
    //           builder: (ctx, box, child) {
    //             final preset = box.values.toList().cast<PresetModel>().toList();
    //             if (preset.isNotEmpty) {
    //               return ListView.builder(
    //                 itemCount: preset.length,
    //                 itemBuilder: (ctx, i) {
    //                   return Column(
    //                     mainAxisSize: MainAxisSize.min,
    //                     children: [
    //                       Card(
    //                         child: ListTile(
    //                           dense: false,
    //                           title: Text(
    //                             preset[i].presetName,
    //                             maxLines: 1,
    //                             overflow: TextOverflow.ellipsis,
    //                           ),
    //                           onTap: () {
    //                             idControllerList.clear();
    //                             for (int j = 0;
    //                                 j < preset[i].employeeId.length;
    //                                 j++) {
    //                               idControllerList.add(
    //                                 TextEditingController(
    //                                     text: preset[i].employeeId[j]),
    //                               );
    //                             }
    //                             departmentController.text =
    //                                 preset[i].department;
    //                             Navigator.of(context).pop();
    //                             setState(() {});
    //                           },
    //                           onLongPress: () {
    //                             showDialogDeletePreset(preset[i].presetName)
    //                                 .then((result) {
    //                               if (result!) {
    //                                 preset[i].delete();
    //                               }
    //                             });
    //                           },
    //                         ),
    //                       ),
    //                     ],
    //                   );
    //                 },
    //               );
    //             } else {
    //               return const Center(
    //                 child: Text(
    //                   'Empty Preset.',
    //                   style: TextStyle(
    //                     fontSize: 17.0,
    //                     fontWeight: FontWeight.w600,
    //                   ),
    //                 ),
    //               );
    //             }
    //           },
    //         ),
    //         actions: <Widget>[
    //           TextButton(
    //             child: const Text('Cancel'),
    //             onPressed: () {
    //               Navigator.of(context).pop(false);
    //             },
    //           ),
    //         ],
    //       );
    //     },
    //   );
    // }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Info'),
        // actions: [
        // PopupMenuButton<String>(
        //   child: Container(
        //     margin: const EdgeInsets.all(10),
        //     child: const Icon(Icons.settings),
        //   ),
        //   onSelected: (value) async {
        //     switch (value) {
        //       case 'open_preset':
        //         return showPresetDialog();
        //       case 'open_add_preset':
        //         return goToAddPresetPage();
        //       default:
        //         throw UnimplementedError();
        //     }
        //   },
        //   itemBuilder: (context) => [
        //     PopupMenuItem(
        //       value: 'open_preset',
        //       onTap: () {},
        //       child: const Text('Preset'),
        //     ),
        //     PopupMenuItem(
        //       value: 'open_add_preset',
        //       onTap: () {},
        //       child: const Text('Add preset'),
        //     ),
        //   ],
        // )
        // ],
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
                  style: const TextStyle(fontSize: 20.0),
                  decoration: InputDecoration(
                    label: const Text('*ID number'),
                    border: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1.0),
                    ),
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
                const SizedBox(height: 10.0),
              ],
              // TextField(
              //   style: const TextStyle(fontSize: 20.0),
              //   decoration: const InputDecoration(
              //     label: Text('*Department'),
              //     border: OutlineInputBorder(
              //       borderSide: BorderSide(color: Colors.grey, width: 1.0),
              //     ),
              //     contentPadding: EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 12.0),
              //   ),
              //   textCapitalization: TextCapitalization.words,
              //   controller: departmentController,
              //   keyboardType: TextInputType.text,
              //   textInputAction: TextInputAction.done,
              // ),
              Consumer<SelfiePageData>(
                builder: (context, provider, child) {
                  return Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Department: ',
                        style: TextStyle(fontSize: 20),
                      ),
                      Container(
                        width: 200.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: Colors.blue,
                            style: BorderStyle.solid,
                            width: 1.0,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            borderRadius: BorderRadius.circular(5),
                            value: dropdownValue2,
                            onChanged: (value) async {
                              if (value != null) {
                                setState(() {
                                  dropdownValue2 = value;
                                });
                              }
                            },
                            items: departmentList2
                                .map<DropdownMenuItem<String>>((value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 10.0),
              TextField(
                style: const TextStyle(fontSize: 20.0),
                decoration: const InputDecoration(
                  label: Text('Team'),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1.0),
                  ),
                  contentPadding: EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 12.0),
                ),
                textCapitalization: TextCapitalization.words,
                controller: teamController,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
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
        child: const Text('Add ID'),
      ),
      bottomNavigationBar: Container(
        color: AppColor.kMainColor,
        width: double.infinity,
        height: 90.0,
        child: TextButton.icon(
          onPressed: () {
            var box = Hive.box<PresetModel>('previous');
            // box.get('last')!.delete();
            bool isEmpty = false;
            for (int i = 0; i < idControllerList.length; i++) {
              if (idControllerList[i].text.isEmpty ||
                  dropdownValue2 == 'Select') {
                AppDialogs.showMyToast('Missing Fields..', context);
                isEmpty = true;
                break;
              }
            }
            if (!isEmpty) {
              box.put(
                'last',
                PresetModel(
                  presetName: 'last',
                  department: dropdownValue2,
                  team: teamController.text.trim(),
                  employeeId: <String>[
                    for (var id in idControllerList) id.text,
                  ],
                ),
              );
              AppDialogs.showMyToast('Saved', context);
            }
          },
          icon: const Icon(
            Icons.save,
            color: Colors.white,
            size: 30.0,
          ),
          label: const Text(
            'Save',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24.0,
            ),
          ),
        ),
      ),
    );
  }
}
