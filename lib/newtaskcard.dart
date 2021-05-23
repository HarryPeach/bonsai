import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'model/task_model.dart';
import 'model/task_provider.dart';

class NewTaskCard extends StatefulWidget {
  final VoidCallback onNewTask;

  NewTaskCard({Key? key, required this.onNewTask}) : super(key: key);

  @override
  _NewTaskCardState createState() => _NewTaskCardState();
}

class _NewTaskCardState extends State<NewTaskCard> {
  DateFormat dateFormmater = DateFormat("y/M/d");
  final TextEditingController _taskNameCtl = TextEditingController();
  final TextEditingController _taskDescCtl = TextEditingController();
  final TextEditingController _dateCtl = TextEditingController();
  bool _important = false;

  // TODO: Async this
  void _addNewTask() {
    var tp = TaskProvider();
    var task = TaskModel(
      id: DateTime.now().microsecondsSinceEpoch,
      name: _taskNameCtl.text,
      desc: _taskDescCtl.text,
      status: "ACTIVE",
      completedOn: "",
      due: _dateCtl.text,
      important: _important,
    );
    tp.insertTask(task);
    widget.onNewTask();
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
                "new task",
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.check,
                ),
                iconSize: 32.0,
                onPressed: () {
                  _addNewTask();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          // TODO: Validate this
          Form(
            child: Wrap(
              runSpacing: 10,
              children: [
                TextFormField(
                  controller: _taskNameCtl,
                  decoration: InputDecoration(hintText: "task name"),
                ),
                TextFormField(
                  minLines: 4,
                  maxLines: 4,
                  controller: _taskDescCtl,
                  decoration: InputDecoration(hintText: "task description"),
                ),
                TextFormField(
                  controller: _dateCtl,
                  decoration: InputDecoration(hintText: "no completion date"),
                  onTap: () async {
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
                  onChanged: (val) => setState(() => _important = val!),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
