import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:bonsai/model/task_model.dart';
import 'package:bonsai/model/task_provider.dart';
import 'package:bonsai/components/new_task_card.dart';
import 'package:dart_date/dart_date.dart';
import 'package:bonsai/components/task_list.dart';
import 'package:table_calendar/table_calendar.dart';

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
      title: 'bonsai',
      theme: ThemeData(
        primaryColor: Colors.yellow[800],
        accentColor: Colors.black,
        backgroundColor: Colors.white,
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
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.white, //or set color with: Color(0xFF0000FF)
    ));

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
        toolbarHeight: 60.0,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        titleSpacing: 0.0,
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                "bonsai",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  fontSize: 36,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            iconSize: 24.0,
            color: Colors.black87,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("TODO: Implement settings screen")));
            },
          ),
          IconButton(
            icon: Icon(Icons.inbox),
            iconSize: 24.0,
            color: Colors.black87,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("TODO: Implement archive screen")));
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            iconSize: 30.0,
            color: Colors.black87,
            onPressed: _showAddTaskSheet,
          ),
        ],
      ),
      body: ListView(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 24.0, right: 24.0),
            child: Column(
              children: <Widget>[
                // TODO: Add dots for how many tasks planned on each day
                TableCalendar(
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      leftChevronMargin: EdgeInsets.zero,
                      rightChevronMargin: EdgeInsets.zero,
                    ),
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    calendarFormat: CalendarFormat.week,
                    focusedDay: currentDate,
                    selectedDayPredicate: (day) {
                      return day.isSameDay(currentDate);
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() => currentDate = selectedDay);
                      updateListViews();
                    },
                    firstDay: DateTime.now().subYears(100),
                    lastDay: DateTime.now().addYears(100)),
                TaskList(
                  title: "complete " + getTitle(),
                  tasks: todaysTasks!,
                  taskCount: todaysTasksCount,
                  onTaskChange: updateListViews,
                  emptyContainer: (currentDate
                          .isBefore(DateTime.now().startOfDay))
                      ? null
                      : Container(
                          child: Column(
                            children: [
                              Image(
                                image: AssetImage("assets/think_hearts.png"),
                              ),
                              Text(
                                "no tasks, why not start on the backlog?",
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
                TaskList(
                  title: "backlog",
                  tasks: soonTasks!,
                  taskCount: soonTasksCount,
                  onTaskChange: updateListViews,
                  emptyContainer: Container(),
                ),
                TaskList(
                  title: "completed " + getTitle(),
                  tasks: completedTodayTasks!,
                  taskCount: completedTasksCount,
                  onTaskChange: updateListViews,
                  emptyContainer: null,
                ),
              ],
            ),
          ),
        ],
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

    int daysLater = currentDate.differenceInDays(DateTime.now()) + 1;

    if (daysLater > 7) {
      return "on " + dateFormatter.format(currentDate);
    }

    return "in " + daysLater.toString() + " days";
  }

  void _addTask(TaskModel task) {
    TaskProvider().insertTask(task);
    updateListViews();
  }

  void updateListViews() {
    var tp = TaskProvider();
    tp.tasks().then((tasks) {
      setState(() {
        // TODO: Cleanup this block / make more efficient
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
              title: "new task",
              returnTask: (task) => _addTask(task),
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
