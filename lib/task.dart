import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:circular_check_box/circular_check_box.dart';

class Task extends StatefulWidget {
  Task({Key? key}) : super(key: key);

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
          onChanged: (val) => setState(() => _selected = val!),
        ),
        Text(
          "I am an example task",
          style: TextStyle(
            fontSize: 18,
          ),
        ),
      ],
    );
  }
}
