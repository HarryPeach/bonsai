import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bonsai/model/task_model.dart';
import 'package:bonsai/model/task_provider.dart';
import 'package:vibration/vibration.dart';

import 'new_task_card.dart';

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
        InkWell(
          onLongPress: () {
            _showViewTaskSheet(widget.tm);
          },
          child: Text(
            widget.tm.name,
            style: TextStyle(
              fontSize: 18,
            ),
          ),
        ),
      ],
    );
  }

  void _editTask(TaskModel task) {
    TaskProvider().insertTask(task);
    TaskProvider().deleteTask(widget.tm.id);
    widget.onStateChange();
  }

  /// Show the "add new task" bottom sheet
  void _showViewTaskSheet(TaskModel task) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return Container(
          color: Color(0xFF737373),
          height: 420,
          child: Container(
            child: NewTaskCard(
              task: task,
              editable: false,
              returnTask: (task) => _editTask(task),
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).canvasColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(10),
                topRight: const Radius.circular(10),
              ),
            ),
          ),
        );
      },
    );
  }
}