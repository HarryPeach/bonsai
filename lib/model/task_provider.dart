import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:todo/model/task_model.dart';

class TaskProvider {
  // static TaskProvider? _instance;
  late Database db;

  // TaskProvider._internal() {
  //   _instance = this;
  // }

  // factory TaskProvider() => _instance ?? TaskProvider._internal();

  Future open(String path) async {
    db = await openDatabase(
      join(await getDatabasesPath(), 'task_db_001.db'),
      onCreate: (db, version) {
        return db.execute('''CREATE TABLE tasks(
					id INTEGER PRIMARY KEY AUTOINCREMENT,
					name TEXT NOT NULL,
					desc TEXT NOT NULL,
					status TEXT NOT NULL,
					due TEXT NOT NULL,
					important int NOT NULL
					);''');
      },
      version: 1,
    );
  }

  Future<void> insertTask(TaskModel task) async {
    await db.insert(
      'tasks',
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<TaskModel>> tasks() async {
    final List<Map<String, dynamic>> maps = await db.query('tasks');

    return List.generate(maps.length, (i) {
      return TaskModel(
        id: maps[i]['id'],
        name: maps[i]['name'],
        desc: maps[i]['desc'],
        status: maps[i]['status'],
        due: maps[i]['due'],
        important: maps[i]['important'] == 1 ? true : false,
      );
    });
  }
}
