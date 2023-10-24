import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:orion/model/history_model.dart';
import 'package:orion/widget/app_dialogs.dart';
import 'package:provider/provider.dart';

import '../data/selfie_page_data.dart';
import 'selfie_page.dart';

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
                if (provider.isUploading) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Uploading...',
                            textAlign: TextAlign.center,
                            maxLines: 4,
                            style: TextStyle(
                              fontSize: 30.0,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 5),
                          SpinKitFadingCircle(
                            color: Colors.white,
                            size: 50.0,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ValueListenableBuilder<double>(
                            valueListenable: sentProgress,
                            builder: (context, value, widget) {
                              return SizedBox(
                                width: 125.0,
                                child: Text(
                                  'Sent: $value KB',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 18.0,
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 3.0),
                          ValueListenableBuilder<double>(
                            valueListenable: totalProgress,
                            builder: (context, value, widget) {
                              return SizedBox(
                                width: 125.0,
                                child: Text(
                                  'Total: $value KB',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 18.0,
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      )
                    ],
                  );
                } else {
                  return const SizedBox();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
