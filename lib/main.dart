import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:bonsai/model/task_model.dart';
import 'package:bonsai/model/task_provider.dart';
import 'package:bonsai/components/new_task_card.dart';
import 'package:dart_date/dart_date.dart';
import 'package:bonsai/components/task_list.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

void _reminderNotification() async {
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
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 10,
        channelKey: 'reminder_channel',
        title: Emojis.activites_party_popper + ' You have no tasks today!',
        summary: "Daily Task reminder",
        body: '''
      Why not add some to the backlog?
      ''',
        notificationLayout: NotificationLayout.BigText,
      ),
    );
    return;
  }

  if (dueToday == 0 && backlogTasks > 0) {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 10,
        channelKey: 'reminder_channel',
        title: Emojis.activites_party_popper + ' You have no tasks due today!',
        summary: "Daily Task reminder",
        body: '''
      There are still ${Emojis.mail_inbox_tray} <b>$backlogTasks</b> total tasks in the backlog, ${Emojis.icon_anger_symbol} <b>$importantTasks</b> of which are important.
      ''',
        notificationLayout: NotificationLayout.BigText,
      ),
    );
    return;
  }

  AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: 10,
      channelKey: 'reminder_channel',
      title: Emojis.activites_ticket +
          ' You have <b>$dueToday</b> tasks due today',
      summary: "Daily Task reminder",
      body: '''
      ${Emojis.mail_inbox_tray} <b>$backlogTasks</b> total tasks in the backlog, ${Emojis.icon_anger_symbol} <b>$importantTasks</b> of which are important.
      ''',
      notificationLayout: NotificationLayout.BigText,
    ),
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // TODO: Find a way to put this in the constructor
  await TaskProvider().initdb(".");
  await AndroidAlarmManager.initialize();

  print(await TaskProvider().tasks());

  AwesomeNotifications().initialize(
    // set the icon to null if you want to use the default app icon
    // 'resource://drawable/res_app_icon',
    null,
    [
      NotificationChannel(
        channelKey: 'reminder_channel',
        channelName: 'Reminder notifications',
        channelDescription: 'Notification channel for daily reminders',
        defaultColor: Color(0xFF9D50DD),
        ledColor: Colors.white,
      ),
    ],
  );

  runApp(MyApp());

  if (Platform.isAndroid) {
    await AndroidAlarmManager.periodic(
      const Duration(hours: 24), //Do the same every 24 hours
      0, //Different ID for each alarm
      _reminderNotification,
      wakeup: false, //the device will be woken up when the alarm fires
      startAt: DateTime(DateTime.now().year, DateTime.now().month,
          DateTime.now().day, 08, 00), //Start whit the specific time 5:00 am
      rescheduleOnReboot: true, //Work after reboot
    );
  }
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final ThemeData lightMode = ThemeData(
    brightness: Brightness.light,
    backgroundColor: Colors.white,
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
    ),
  );

  final ThemeData darkMode = ThemeData(
    brightness: Brightness.dark,
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

    AwesomeNotifications().isNotificationAllowed().then(
      (isAllowed) {
        if (!isAllowed) {
          // Insert here your friendly dialog box before call the request method
          // This is very important to not harm the user experience
          AwesomeNotifications().requestPermissionToSendNotifications();
        }
      },
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
              _reminderNotification();
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
