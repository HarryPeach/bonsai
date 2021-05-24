import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bonsai/components/task.dart';
import 'package:bonsai/model/task_model.dart';

class TaskList extends StatelessWidget {
  final String title;
  final List<TaskModel> tasks;
  final int taskCount;
  final Container? emptyContainer;
  final VoidCallback onTaskChange;

  const TaskList(
      {Key? key,
      required this.title,
      required this.tasks,
      required this.taskCount,
      required this.emptyContainer,
      required this.onTaskChange})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (emptyContainer == null && taskCount == 0) {
      return Container();
    } else {
      return Padding(
        padding: const EdgeInsets.only(
          left: 8.0,
          right: 8.0,
          top: 16.0,
        ),
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
                // TODO: Implement list expansion vvv
                Text(
                  "+2 more",
                  style: Theme.of(context).textTheme.headline4,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: (() {
                if (taskCount > 0) {
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
                }

                return emptyContainer!;
              }()),
            )
          ],
        ),
      );
    }
  }
}
