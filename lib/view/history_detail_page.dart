import 'package:flutter/material.dart';
import 'package:orion/model/history_model.dart';

class HistoryDetailPage extends StatelessWidget {
  const HistoryDetailPage({super.key, required this.model});
  final HistoryModel model;

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(fontSize: 16.0);
    return Scaffold(
      appBar: AppBar(
        title: const Text('History Detail'),
      ),
      body: SingleChildScrollView(
        child: Padding(
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
      ),
    );
  }
}
