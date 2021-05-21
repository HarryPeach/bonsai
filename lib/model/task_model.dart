class TaskModel {
  final int id;
  final String name;
  final String desc;
  final String status;
  final String due;
  final bool important;

  TaskModel({
    required this.id,
    required this.name,
    required this.desc,
    required this.status,
    required this.due,
    required this.important,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'desc': desc,
      'status': status,
      'due': due,
      'important': important == true ? 1 : 0,
    };
  }

  @override
  String toString() {
    return 'Task {id: $id, name: $name, desc: $desc, status: $status, due: $due, important: $important}';
  }
}
