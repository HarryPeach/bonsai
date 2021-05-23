import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:todo/model/task_model.dart';
import 'package:todo/model/task_provider.dart';
import 'package:vibration/vibration.dart';

class Task extends StatefulWidget {
  final TaskModel tm;
  final VoidCallback onStateChange;

  Task({Key? key, required this.tm, required this.onStateChange})
      : super(key: key);

  @override
  _TaskState createState() => _TaskState();
}

class _TaskState extends State<Task> {
  bool _selected = false;

  void _vibrate() async {
    var hasVibrate = await Vibration.hasVibrator();
    if (hasVibrate != null && hasVibrate) {
      Vibration.vibrate(duration: 50);
    }
  }

  @override
  Widget build(BuildContext context) {
    _selected = widget.tm.status == "DONE";

    return Row(
      children: [
        Checkbox(
          value: _selected,
          activeColor: Colors.black87,
          onChanged: (val) async {
            if (widget.tm.status == "ACTIVE") {
              TaskProvider().completeTask(widget.tm.id);
            } else {
              TaskProvider().unCompleteTask(widget.tm.id);
            }
            widget.onStateChange();
            _vibrate();
          },
        ),
        Text(
          widget.tm.name,
          style: TextStyle(
            fontSize: 18,
          ),
        ),
      ],
    );
  }
}
