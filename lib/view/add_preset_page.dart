import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../app_color.dart';
import '../model/preset_model.dart';
import '../widget.dart/app_dialogs.dart';

class AddPresetPage extends StatefulWidget {
  const AddPresetPage({super.key});

  @override
  State<AddPresetPage> createState() => _AddPresetPageState();
}

class _AddPresetPageState extends State<AddPresetPage> {
  final presetNameController = TextEditingController();
  var idPresetControllerList = <TextEditingController>[
    TextEditingController(),
  ];
  final presetDepartmentController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    presetNameController.dispose();
    for (var idPresetController in idPresetControllerList) {
      idPresetController.dispose();
    }
    presetDepartmentController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add preset'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1.0),
                  ),
                  hintText: 'Preset name..',
                  contentPadding: EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 12.0),
                ),
                controller: presetNameController,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 10.0),
              for (int i = 0; i < idPresetControllerList.length; i++) ...[
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
                        if (idPresetControllerList.length != 1) {
                          setState(() {
                            idPresetControllerList.removeAt(i);
                          });
                        }
                      },
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                    ),
                  ),
                  controller: idPresetControllerList[i],
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
                controller: presetDepartmentController,
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
            idPresetControllerList.add(TextEditingController());
          });
        },
        backgroundColor: Colors.green,
        child: const Text('Add Id'),
      ),
      bottomNavigationBar: Container(
        color: AppColor.kMainColor,
        width: double.infinity,
        height: 60.0,
        child: TextButton.icon(
          onPressed: () async {
            var box = Hive.box<PresetModel>('preset');
            bool isEmpty = false;
            for (int i = 0; i < idPresetControllerList.length; i++) {
              if (idPresetControllerList[i].text.isEmpty ||
                  presetDepartmentController.text.isEmpty ||
                  presetNameController.text.isEmpty) {
                AppDialogs.showMyToast('Missing Fields..', context);
                isEmpty = true;
                break;
              }
            }
            if (!isEmpty) {
              box.add(PresetModel(
                presetName: presetNameController.text.trim(),
                employeeId: <String>[
                  for (var id in idPresetControllerList) id.text,
                ],
                department: presetDepartmentController.text.trim(),
              ));
            }
          },
          icon: const Icon(
            Icons.save,
            color: Colors.white,
          ),
          label: const Text(
            'Save',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
