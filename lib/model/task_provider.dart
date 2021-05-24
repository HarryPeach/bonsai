import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:bonsai/model/task_model.dart';

class TaskProvider {
  static TaskProvider? _instance;
  static Database? _db;
  DateFormat dateFormatter = DateFormat("y/M/d");

  TaskProvider._internal() {
    _instance = this;
  }

  factory TaskProvider() => _instance ?? TaskProvider._internal();

  Future<Database> get db async {
    if (_db != null) return _db!;

    _db = await initdb(".");
    return _db!;
  }

  Future<Database> initdb(String path) async {
    return await openDatabase(
      join(await getDatabasesPath(), 'tasksdb.db'),
      onCreate: (db, version) {
        return db.execute('''CREATE TABLE tasks(
					id INTEGER PRIMARY KEY AUTOINCREMENT,
					name TEXT NOT NULL,
					desc TEXT NOT NULL,
					status TEXT NOT NULL,
          completedOn TEXT NOT NULL,
					due TEXT NOT NULL,
					important int NOT NULL
					);''');
      },
      version: 1,
    );
    // return _db;
  }

  Future<void> unCompleteTask(int id) async {
    final Database db = await this.db;
    await db.rawUpdate('''
    UPDATE tasks
    SET status = 'ACTIVE', completedOn = ''
    WHERE id = ?
    ''', [id]);
  }

  Future<void> completeTask(int id) async {
    final Database db = await this.db;
    await db.rawUpdate('''
    UPDATE tasks
    SET status = 'DONE', completedOn = ?
    WHERE id = ?
    ''', ["${dateFormatter.format(DateTime.now())}", id]);
  }

  Future<void> insertTask(TaskModel task) async {
    final Database db = await this.db;
    await db.insert(
      'tasks',
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteTask(int id) async {
    final Database db = await this.db;
    await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<TaskModel>> tasks() async {
    final Database db = await this.db;
    final List<Map<String, dynamic>> maps = await db.query('tasks');

    return List.generate(
      maps.length,
      (i) {
        return TaskModel(
          id: maps[i]['id'],
          name: maps[i]['name'],
          desc: maps[i]['desc'],
          status: maps[i]['status'],
          completedOn: maps[i]['completedOn'],
          due: maps[i]['due'],
          important: maps[i]['important'] == 1 ? true : false,
        );
      },
    );
  }
}
