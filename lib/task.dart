import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:circular_check_box/circular_check_box.dart';
import 'package:todo/model/task_model.dart';

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

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircularCheckBox(
          value: _selected,
          activeColor: Colors.black87,
          onChanged: (val) {
            setState(() => _selected = val!);
            widget.onStateChange();
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
