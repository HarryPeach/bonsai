import 'package:dart_date/dart_date.dart';
import 'package:flutter/material.dart';
import 'package:bonsai/model/task_model.dart';
import 'package:bonsai/model/task_provider.dart';
import 'package:intl/intl.dart';
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
  DateFormat dateFormatter = DateFormat("y/M/d");

  void _vibrate() async {
    var hasVibrate = await Vibration.hasVibrator();
    if (hasVibrate != null && hasVibrate) {
      Vibration.vibrate(duration: 50);
    }
  }

  @override
  Widget build(BuildContext context) {
    _selected = widget.tm.status == "DONE";
    String inDays = getTaskDays();

    return InkWell(
      onTap: () {
        _showViewTaskSheet(widget.tm);
      },
      child: Row(
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
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.tm.name,
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    (() {
                      if (inDays != "") {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Text(
                            inDays,
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  Theme.of(context).textTheme.headline3!.color,
                            ),
                          ),
                        );
                      } else {
                        return Container();
                      }
                    }()),
                  ],
                ),
                (() {
                  if (widget.tm.important) {
                    return Icon(
                      Icons.circle,
                      color: Theme.of(context).colorScheme.secondary,
                      size: 10.0,
                    );
                  } else {
                    // return Icon(Icons.ac_unit);
                    return Container();
                  }
                }())
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Gets the formatted date string for when the task is due
  String getTaskDays() {
    if (widget.tm.due == "") {
      return "";
    } else {
      DateTime due = DateFormat("yyyy/MM/dd").parse(widget.tm.due);
      if (due.isTomorrow) {
        return "due tomorrow";
      }

      if (due.isYesterday) {
        return "due yesterday";
      }

      if (due.isAfter(DateTime.now().add(Duration(days: 1)))) {
        int daysLater = due.difference(DateTime.now()).inDays;
        return ("in $daysLater days");
      } else {
        int daysAge = due.difference(DateTime.now()).inDays.abs();
        return ("$daysAge days ago");
      }
    }
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
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Container(
            color: Color(0xFF737373),
            height: 420,
            child: Container(
              child: NewTaskCard(
                title: "edit task",
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
          ),
        );
      },
    );
  }
}
