import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../model/history_model.dart';
import 'history_detail_page.dart';

class SavesPage extends StatefulWidget {
  const SavesPage({super.key});

  @override
  State<SavesPage> createState() => _SavesPageState();
}

class _SavesPageState extends State<SavesPage> {
  Future<bool?> showDialogDeleteCache() async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear History'),
          content: const Text(
              'This action will delete all history saved on this device'),
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
    var box = Hive.box<HistoryModel>('history');
    return ValueListenableBuilder<Box<HistoryModel>>(
      valueListenable: box.listenable(),
      builder: (ctx, box, child) {
        final history =
            box.values.toList().cast<HistoryModel>().reversed.toList();
        if (history.isNotEmpty) {
          return ListView.builder(
            itemCount: history.length,
            itemBuilder: (ctx, i) {
              return Card(
                child: ListTile(
                  dense: false,
                  leading: history[i].uploaded
                      ? const Icon(
                          Icons.check,
                          color: Colors.green,
                          size: 30,
                        )
                      : const Icon(
                          Icons.close,
                          color: Colors.red,
                          size: 30,
                        ),
                  title: Text(
                      '${history[i].logType} ${history[i].selfieTimestamp}'),
                  onLongPress: () async {
                    await showDialogDeleteCache().then((result) {
                      if (result!) {
                        box.clear();
                        // history[i].delete();
                      }
                    });
                  },
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) =>
                            HistoryDetailPage(model: history[i]),
                      ),
                    );
                  },
                ),
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
    );
  }
}
