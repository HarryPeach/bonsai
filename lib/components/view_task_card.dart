import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bonsai/model/task_model.dart';

class ViewTaskCard extends StatelessWidget {
  final TaskModel task;

  ViewTaskCard({Key? key, required this.task}) : super(key: key);

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
                "task",
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.edit,
                    ),
                    iconSize: 24.0,
                    onPressed: () {
                      print("Edit item");
                      Navigator.pop(context);
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                    ),
                    iconSize: 24.0,
                    onPressed: () {
                      print("Delete item");
                      Navigator.pop(context);
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.check,
                    ),
                    iconSize: 24.0,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ],
          ),
          Text(task.name),
          Text(task.desc),
          Text(task.due),
          Text(task.important ? "Not important" : "Important"),
        ],
      ),
    );
  }
}
