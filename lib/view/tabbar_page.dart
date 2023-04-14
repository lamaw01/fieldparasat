import 'dart:async';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';

import '../data/selfie_page_data.dart';
import '../widget.dart/app_dialogs.dart';
import '../widget.dart/bottomnavbar_widget.dart';
import 'saves_page.dart';
import 'selfie_page.dart';

class TabBarPage extends StatefulWidget {
  const TabBarPage({super.key});

  @override
  State<TabBarPage> createState() => _TabBarPageState();
}

class _TabBarPageState extends State<TabBarPage> {
  final nameController = TextEditingController();
  final idController = TextEditingController();

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
    nameController.dispose();
    idController.dispose();
  }

  Future<void> _showMyDialog() async {
    var instance = Provider.of<SelfiePageData>(context, listen: false);
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsetsDirectional.symmetric(
              vertical: 12.0, horizontal: 8.0),
          title: const Text('Employee Info'),
          content: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                textCapitalization: TextCapitalization.words,
                controller: nameController,
                autofocus: true,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  focusColor: Colors.white,
                  hintText: 'Name..',
                  contentPadding: EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 12.0),
                ),
                onEditingComplete: () {
                  FocusScope.of(context).unfocus();
                },
              ),
              TextField(
                controller: idController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  focusColor: Colors.white,
                  hintText: 'ID number..',
                  contentPadding: EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 12.0),
                ),
                onEditingComplete: () {
                  FocusScope.of(context).unfocus();
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                if (nameController.text.isEmpty || idController.text.isEmpty) {
                  FocusScope.of(context).unfocus();
                  AppDialogs.showMyToast('Missing Fields..', context);
                } else {
                  await instance
                      .saveData(
                          nameController.text.trim(), idController.text.trim())
                      .then((_) {
                    Navigator.of(context).pop();
                    nameController.clear();
                    idController.clear();
                    AppDialogs.showMyToast('Saved', context);
                  });
                }
              },
            ),
            TextButton(
              child: const Text('Send'),
              onPressed: () async {
                if (nameController.text.isEmpty || idController.text.isEmpty) {
                  FocusScope.of(context).unfocus();
                  AppDialogs.showMyToast('Missing Fields..', context);
                } else {
                  await instance
                      .uploadImage(
                          nameController.text.trim(), idController.text.trim())
                      .then((result) {
                    Navigator.of(context).pop();
                    if (!instance.hasInternet.value) {
                      AppDialogs.showMyToast(
                          'Not connected to internet', context);
                    } else {
                      if (result) {
                        AppDialogs.showMyToast('Successfully log', context);
                        nameController.clear();
                        idController.clear();
                      } else {
                        AppDialogs.showMyToast('Error uploading log', context);
                      }
                    }
                  });
                }
              },
            ),
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
                  _showMyDialog();
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
