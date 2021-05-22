import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo/model/task_model.dart';
import 'package:todo/model/task_provider.dart';
import 'package:todo/newtaskcard.dart';
import 'package:todo/task.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var tp = TaskProvider();
  // TODO: Find a way to put this in the constructor
  await tp.initdb(".");

  var task = TaskModel(
    id: 0,
    name: "Sample Task",
    desc: "A description for said task",
    status: "ACTIVE",
    due: "21/12/2021",
    important: true,
  );

  await tp.insertTask(task);

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
      home: MyHomePage(title: 'today'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int count = 0;
  List<TaskModel>? taskList;

  @override
  Widget build(BuildContext context) {
    if (taskList == null) {
      taskList = <TaskModel>[];
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
              onPressed: () => {},
            ),
            Text(
              widget.title!,
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
              onPressed: () => {},
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "complete today",
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
            getBacklogTaskListView(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "complete soon",
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "completed today",
                  style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black38),
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
          ],
        ),
      ),
    );
  }

  ListView getBacklogTaskListView() {
    return ListView.builder(
      itemCount: count,
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int position) {
        return Task(
          tm: this.taskList![position],
          onStateChange: () => updateListViews(),
        );
      },
    );
  }

  void updateListViews() {
    var tp = TaskProvider();
    tp.tasks().then((tasks) {
      setState(() {
        this.taskList = tasks;
        this.count = tasks.length;
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
