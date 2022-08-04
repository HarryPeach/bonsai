import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:bonsai/model/task_model.dart';
import 'package:bonsai/model/task_provider.dart';
import 'package:bonsai/components/new_task_card.dart';
import 'package:dart_date/dart_date.dart';
import 'package:bonsai/components/task_list.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin flutterNotifications =
    FlutterLocalNotificationsPlugin();

/// Creates and pushes the reminder notification
Future _showNotification() async {
  log("Showing notification");
  var androidNotificationDetails =
      new AndroidNotificationDetails("reminder_channel", "Daily Reminders", styleInformation: BigTextStyleInformation('', htmlFormatContent: true));
  var notificationDetails =
      new NotificationDetails(android: androidNotificationDetails);

  DateFormat dateFormatter = DateFormat("y/M/d");
  int importantTasks = 0;
  int dueToday = 0;
  int backlogTasks = 0;

  await TaskProvider().tasks().then(
    (tasks) {
      tasks.forEach(
        (element) {
          if (element.due == "${dateFormatter.format(DateTime.now())}" &&
              element.status != "DONE") dueToday++;
          if (element.important && element.status != "DONE") importantTasks++;
          if (element.status != "DONE") backlogTasks++;
        },
      );
    },
  );

  if (backlogTasks == 0) {
    await flutterNotifications.show(
      10, "🎉 You have no tasks today!", "Why not add some to the backlog?", notificationDetails,
      payload: "Task");
    return;
  }

  if (dueToday == 0 && backlogTasks > 0) {
    await flutterNotifications.show(
      10, "🎉 You have no tasks due today!", '''There are still 📥 <b>$backlogTasks</b> total tasks in the backlog, 💢 <b>$importantTasks</b> of which are important.''', notificationDetails,
      payload: "Task");
    return;
  }

  await flutterNotifications.show(
      10, "🎉 You have no tasks due today!", 
      '''📥 <b>$backlogTasks</b> total tasks in the backlog, 💢 <b>$importantTasks</b> of which are important.''',
      notificationDetails,
      payload: "Task");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var androidLocalNotificationInitSettings =
      new AndroidInitializationSettings("ic_launcher_foreground");
  var localNotificationInitSettings =
      new InitializationSettings(android: androidLocalNotificationInitSettings);
  await flutterNotifications.initialize(localNotificationInitSettings);

  tz.initializeTimeZones();

  // TODO: Find a way to put this in the constructor
  await TaskProvider().initdb(".");
  await AndroidAlarmManager.initialize();

  // TODO: Add warning for app killing
  if (Platform.isAndroid) {
   log("Alarm Manager set for: " + DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 9, 0).toHumanString());
   await AndroidAlarmManager.periodic(
      const Duration(hours: 24),
      101, //Different ID for each alarm
      _showNotification,
      wakeup: true,
      startAt: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 8, 0), //Start with the specific time 9:00 am
      rescheduleOnReboot: true,
   );
}

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final ThemeData lightMode = ThemeData(
    colorScheme: ColorScheme.fromSwatch()
        .copyWith(secondary: Colors.yellow[800], brightness: Brightness.light),
    backgroundColor: Colors.white,
    indicatorColor: Colors.black12,
    textTheme: TextTheme(
      headline1: TextStyle(
        fontSize: 36.0,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      headline2: TextStyle(
        fontSize: 24.0,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      headline3: TextStyle(
        fontSize: 18.0,
        color: Colors.black54,
      ),
      headline4: TextStyle(
        fontSize: 18.0,
        color: Colors.black45,
        fontStyle: FontStyle.italic,
      ),
      bodyText1: TextStyle(
        color: Colors.black87,
      ),
    ),
  );

  final ThemeData darkMode = ThemeData(
    colorScheme: ColorScheme.fromSwatch()
        .copyWith(secondary: Colors.yellow[700], brightness: Brightness.dark),
    indicatorColor: Colors.black26,
    backgroundColor: Colors.grey[900],
    textTheme: TextTheme(
      headline1: TextStyle(
        fontSize: 36.0,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      headline2: TextStyle(
        fontSize: 24.0,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      headline3: TextStyle(
        fontSize: 18.0,
        color: Colors.white54,
      ),
      headline4: TextStyle(
        fontSize: 18.0,
        color: Colors.white54,
        fontStyle: FontStyle.italic,
      ),
      bodyText1: TextStyle(
        color: Colors.white,
      ),
    ),
    iconTheme: IconThemeData(color: Colors.white),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'bonsai',
      theme: darkMode,
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
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Theme.of(context).backgroundColor,
      ),
    );

    if (todaysTasks == null ||
        soonTasks == null ||
        completedTodayTasks == null) {
      todaysTasks = <TaskModel>[];
      soonTasks = <TaskModel>[];
      completedTodayTasks = <TaskModel>[];
      updateListViews();
    }
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        toolbarHeight: 80.0,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        titleSpacing: 0.0,
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                "bonsai",
                style: Theme.of(context).textTheme.headline1,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            iconSize: 24.0,
            color: Theme.of(context).iconTheme.color,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("TODO: Implement settings screen")));
              _showNotification();
            },
          ),
          IconButton(
            icon: Icon(Icons.inbox),
            iconSize: 24.0,
            color: Theme.of(context).iconTheme.color,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("TODO: Implement archive screen")));
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            iconSize: 30.0,
            color: Theme.of(context).iconTheme.color,
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
                    calendarStyle: CalendarStyle(
                      selectedTextStyle: TextStyle(
                        color: Theme.of(context).backgroundColor,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      todayDecoration: BoxDecoration(
                        color: Theme.of(context).indicatorColor,
                      ),
                      todayTextStyle: TextStyle(
                        color: Theme.of(context).textTheme.bodyText1!.color,
                      ),
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
                                style: Theme.of(context).textTheme.headline3,
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
                  emptyContainer: Container(
                    child: Text(
                      "you're all out of tasks!",
                      style: Theme.of(context).textTheme.headline3,
                    ),
                  ),
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

  // Gets the title of the current page based on the date
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

    if (currentDate.isBefore(DateTime.now())) {
      return (daysLater - 1).abs().toString() + " days ago";
    }

    return "in " + daysLater.toString() + " days";
  }

  void _addTask(TaskModel task) {
    TaskProvider().insertTask(task);
    updateListViews();
  }

  // Updates all available task listviews
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
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Container(
            color: Theme.of(context).backgroundColor,
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
          ),
        );
      },
    );
  }
}
