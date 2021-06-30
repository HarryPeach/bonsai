class TaskModel {
  final int id;
  final String name;
  final String desc;
  final String status;
  final String completedOn;
  final String due;
  final bool important;

  TaskModel({
    required this.id,
    required this.name,
    required this.desc,
    required this.status,
    required this.completedOn,
    required this.due,
    required this.important,
  });

  /// Get task to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'desc': desc,
      'status': status,
      'completedOn': completedOn,
      'due': due,
      'important': important == true ? 1 : 0,
    };
  }

  /// Get string representation of a task
  @override
  String toString() {
    return 'Task {id: $id, name: $name, desc: $desc, status: $status, completedOn: $completedOn, due: $due, important: $important}';
  }
}
