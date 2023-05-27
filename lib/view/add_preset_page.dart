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
  final presetTeamController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    presetNameController.dispose();
    for (var idPresetController in idPresetControllerList) {
      idPresetController.dispose();
    }
    presetDepartmentController.dispose();
    presetTeamController.dispose();
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
                style: const TextStyle(fontSize: 20.0),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1.0),
                  ),
                  label: Text('*Preset name'),
                  contentPadding: EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 12.0),
                ),
                controller: presetNameController,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 10.0),
              for (int i = 0; i < idPresetControllerList.length; i++) ...[
                TextField(
                  style: const TextStyle(fontSize: 20.0),
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1.0),
                    ),
                    label: const Text('*ID number'),
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
                const SizedBox(height: 10.0),
              ],
              TextField(
                style: const TextStyle(fontSize: 20.0),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1.0),
                  ),
                  label: Text('*Department'),
                  contentPadding: EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 12.0),
                ),
                textCapitalization: TextCapitalization.words,
                controller: presetDepartmentController,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
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
                controller: presetTeamController,
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
        child: const Text('Add ID'),
      ),
      bottomNavigationBar: Container(
        color: AppColor.kMainColor,
        width: double.infinity,
        height: 90.0,
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
                team: presetTeamController.text.trim(),
              ));
              Navigator.of(context).pop();
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
