import 'package:bonsai/model/task_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../model/task_model.dart';

class NewTaskCard extends StatefulWidget {
  final void Function(TaskModel) returnTask;
  final String title;
  final bool editable;
  final TaskModel? task;

  NewTaskCard(
      {Key? key,
      required this.returnTask,
      required this.title,
      this.editable = true,
      this.task})
      : super(key: key);

  @override
  _NewTaskCardState createState() => _NewTaskCardState();
}

class _NewTaskCardState extends State<NewTaskCard> {
  DateFormat dateFormmater = DateFormat("y/M/d");
  TextEditingController _taskNameCtl = TextEditingController();
  TextEditingController _taskDescCtl = TextEditingController();
  TextEditingController _dateCtl = TextEditingController();
  bool _important = false;
  bool _editable = true;

  // TODO: Async this
  void _return() {
    var task = TaskModel(
      id: DateTime.now().microsecondsSinceEpoch,
      name: _taskNameCtl.text,
      desc: _taskDescCtl.text,
      status: "ACTIVE",
      completedOn: "",
      due: _dateCtl.text,
      important: _important,
    );
    widget.returnTask(task);
  }

  @override
  void initState() {
    super.initState();
    _editable = widget.editable;
    _setFields();
  }

  Future<void> _showDeleteDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('delete task'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Text('are you sure you want to delete this task?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'delete',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
              onPressed: () {
                TaskProvider().deleteTask(widget.task!.id);
                widget.returnTask(widget.task!);
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text("task deleted")));
              },
            ),
            TextButton(
              child: Text('cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _setFields() {
    if (widget.task == null) return;

    // TODO: Null check these fields
    _taskNameCtl.value = TextEditingValue(text: widget.task!.name);
    _taskDescCtl.value = TextEditingValue(text: widget.task!.desc);
    _dateCtl.value = TextEditingValue(text: widget.task!.due);
    _important = widget.task!.important;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _editable ? widget.title : "view task",
                style: Theme.of(context).textTheme.headline2,
              ),
              Row(
                children: [
                  (() {
                    if (!_editable) {
                      return Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() => _editable = true);
                            },
                            icon: Icon(Icons.edit),
                          ),
                          IconButton(
                            onPressed: () {
                              _showDeleteDialog();
                            },
                            icon: Icon(Icons.delete),
                          )
                        ],
                      );
                    }
                    return Container();
                  }()),
                  IconButton(
                    icon: Icon(
                      Icons.check,
                    ),
                    iconSize: 32.0,
                    onPressed: () {
                      _return();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ],
          ),
          // TODO: Validate this
          Form(
            child: Wrap(
              runSpacing: 10,
              children: [
                TextFormField(
                  focusNode: _editable ? null : AlwaysDisabledFocusNode(),
                  controller: _taskNameCtl,
                  decoration: InputDecoration(hintText: "task name"),
                ),
                TextFormField(
                  focusNode: _editable ? null : AlwaysDisabledFocusNode(),
                  minLines: 4,
                  maxLines: 4,
                  controller: _taskDescCtl,
                  decoration: InputDecoration(hintText: "task description"),
                ),
                TextFormField(
                  focusNode: _editable ? null : AlwaysDisabledFocusNode(),
                  controller: _dateCtl,
                  decoration: InputDecoration(hintText: "no completion date"),
                  onTap: () async {
                    if (!_editable) {
                      return;
                    }
                    FocusScope.of(context).requestFocus(new FocusNode());
                    var date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(DateTime.now().year),
                      lastDate: DateTime(DateTime.now().year + 100),
                    );
                    if (date == null) {
                      _dateCtl.text = "";
                    } else {
                      _dateCtl.text = dateFormmater.format(date);
                    }
                  },
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text("important task"),
                  value: _important,
                  onChanged: _editable
                      ? ((val) => setState(() => _important = val!))
                      : null,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}
