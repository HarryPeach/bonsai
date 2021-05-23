import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:todo/components/task.dart';
import 'package:todo/model/task_model.dart';

class TaskList extends StatelessWidget {
  final String title;
  final List<TaskModel> tasks;
  final int taskCount;
  final VoidCallback onTaskChange;

  const TaskList(
      {Key? key,
      required this.title,
      required this.tasks,
      required this.taskCount,
      required this.onTaskChange})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "+2 more",
                style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: Colors.black38),
              ),
            ],
          ),
          (() {
            return ListView.builder(
              itemCount: taskCount,
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int position) {
                return Task(
                  tm: this.tasks[position],
                  onStateChange: () => onTaskChange(),
                );
              },
            );
          }())
        ],
      ),
    );
  }
}
