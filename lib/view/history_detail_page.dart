import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:orion/model/history_model.dart';
import 'package:orion/widget/app_dialogs.dart';
import 'package:provider/provider.dart';

import '../data/selfie_page_data.dart';

class HistoryDetailPage extends StatelessWidget {
  const HistoryDetailPage({super.key, required this.model});
  final HistoryModel model;

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(fontSize: 16.0);
    return Scaffold(
      appBar: AppBar(
        title: const Text('History Detail'),
        actions: [
          if (!model.uploaded) ...[
            InkWell(
              onTap: () async {
                var instance =
                    Provider.of<SelfiePageData>(context, listen: false);
                instance.changeUploadingState(true);
                await Future.delayed(const Duration(seconds: 1));
                await instance.uploadHistory(model: model).then((result) {
                  instance.changeUploadingState(false);
                  if (result) {
                    AppDialogs.showMyToast(
                        'Success selfie log uploaded', context);
                  } else {
                    AppDialogs.showMyToast(
                        'Error uploading selfie log', context);
                  }
                  Navigator.of(context).pop();
                });
              },
              child: Ink(
                height: 50.0,
                width: 75.0,
                child: const Center(
                  child: Text(
                    're-Upload',
                    style: TextStyle(fontSize: 16.0),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Id(s) : ',
                        style: style,
                      ),
                      for (var id in model.employeeId) ...[
                        Text(
                          '$id, ',
                          style: style,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Department : ',
                        style: style,
                      ),
                      Text(
                        model.department,
                        style: style,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Team : ',
                        style: style,
                      ),
                      Text(
                        model.team,
                        style: style,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Timestamp : ',
                        style: style,
                      ),
                      Text(
                        model.selfieTimestamp,
                        style: style,
                      ),
                    ],
                  ),
                  const SizedBox(height: 5.0),
                  SizedBox(
                    child: Image.memory(
                      model.imageScreenshot,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
            Consumer<SelfiePageData>(
              builder: (context, provider, child) {
                return ValueListenableBuilder<bool>(
                  valueListenable: provider.isUploading,
                  builder: (context, value, child) {
                    if (value) {
                      return const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Uploading..',
                            textAlign: TextAlign.center,
                            maxLines: 4,
                            style: TextStyle(
                              fontSize: 30.0,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 2.5),
                          SpinKitFadingCircle(
                            color: Colors.white,
                            size: 75.0,
                          ),
                        ],
                      );
                    }
                    return child!;
                  },
                  child: const SizedBox(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
