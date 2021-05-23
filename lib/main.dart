import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo/model/task_model.dart';
import 'package:todo/model/task_provider.dart';
import 'package:todo/components/newtaskcard.dart';
import 'package:todo/components/task.dart';
import 'package:dart_date/dart_date.dart';
import 'package:todo/components/task_list.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var tp = TaskProvider();
  // TODO: Find a way to put this in the constructor
  await tp.initdb(".");

  print(await tp.tasks());

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'todo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DateTime currentDate = DateTime.now();
  DateFormat dateFormatter = DateFormat("y/M/d");

  int todaysTasksCount = 0;
  List<TaskModel>? todaysTasks;
  int soonTasksCount = 0;
  List<TaskModel>? soonTasks;
  int completedTasksCount = 0;
  List<TaskModel>? completedTodayTasks;

  @override
  Widget build(BuildContext context) {
    if (todaysTasks == null ||
        soonTasks == null ||
        completedTodayTasks == null) {
      todaysTasks = <TaskModel>[];
      soonTasks = <TaskModel>[];
      completedTodayTasks = <TaskModel>[];
      updateListViews();
    }
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80.0,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        titleSpacing: 0.0,
        title: Row(
          children: [
            IconButton(
              icon: Icon(Icons.chevron_left),
              iconSize: 36.0,
              color: Colors.black87,
              onPressed: () {
                setState(() => {currentDate = currentDate.subDays(1)});
                updateListViews();
              },
            ),
            Text(
              "bonsai",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontSize: 36,
              ),
            ),
            IconButton(
              icon: Icon(Icons.chevron_right),
              iconSize: 36.0,
              color: Colors.black87,
              onPressed: () {
                setState(() => {currentDate = currentDate.addDays(1)});
                updateListViews();
              },
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            iconSize: 36.0,
            color: Colors.black87,
            onPressed: _showAddTaskSheet,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TaskList(
              title: "complete " + getTitle(),
              tasks: todaysTasks!,
              taskCount: todaysTasksCount,
              onTaskChange: updateListViews,
            ),
            TaskList(
              title: "backlog",
              tasks: soonTasks!,
              taskCount: soonTasksCount,
              onTaskChange: updateListViews,
            ),
            TaskList(
              title: "completed " + getTitle(),
              tasks: completedTodayTasks!,
              taskCount: completedTasksCount,
              onTaskChange: updateListViews,
            ),
          ],
        ),
      ),
    );
  }

  String getTitle() {
    if (currentDate.isToday) {
      return "today";
    } else if (currentDate.isTomorrow) {
      return "tomorrow";
    } else if (currentDate.isYesterday) {
      return "yesterday";
    }

    return dateFormatter.format(currentDate);
  }

  void updateListViews() {
    var tp = TaskProvider();
    tp.tasks().then((tasks) {
      setState(() {
        List<TaskModel> filteredTodaysTasks = tasks
            .where((task) =>
                task.due == "${dateFormatter.format(currentDate)}" &&
                task.status != "DONE")
            .toList();
        this.todaysTasks = filteredTodaysTasks;
        this.todaysTasksCount = filteredTodaysTasks.length;

        List<TaskModel> filteredSoonTasks = tasks
            .where((task) =>
                task.due != "${dateFormatter.format(currentDate)}" &&
                task.status == "ACTIVE")
            .toList();
        this.soonTasks = filteredSoonTasks;
        this.soonTasksCount = filteredSoonTasks.length;

        List<TaskModel> filteredCompletedTodayTasks = tasks
            .where((task) =>
                task.completedOn == "${dateFormatter.format(currentDate)}" &&
                task.status == "DONE")
            .toList();
        this.completedTodayTasks = filteredCompletedTodayTasks;
        this.completedTasksCount = filteredCompletedTodayTasks.length;
      });
    });
  }

  /// Show the "add new task" bottom sheet
  void _showAddTaskSheet() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return Container(
          color: Color(0xFF737373),
          height: 420,
          child: Container(
            child: NewTaskCard(
              onNewTask: () => updateListViews(),
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
