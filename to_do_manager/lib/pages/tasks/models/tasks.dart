

// ignore_for_file: constant_identifier_names, annotate_overrides, hash_and_equals, avoid_renaming_method_parameters

import '../../../models/priority.dart';

class Tasks {
  static const tblTask = "Tasks";
  static const dbId = "id";
  static const dbTitle = "title";
  static const dbComment = "comment";
  static const dbDueDate = "dueDate";
  static const dbPriority = "priority";
  static const dbStatus = "status";
  static const dbProjectID = "projectId";

  String title, comment;
  String? projectName;
  int? id, projectColor;
  int dueDate, projectId;
  Status priority;
  TaskStatus? tasksStatus;
  List<String> labelList = [];

  Tasks.create({
    required this.title,
    required this.projectId,
    this.comment = "",
    this.dueDate = -1,
    this.priority = Status.PRIORITY_4,
  }) {
    if (dueDate == -1) {
      dueDate = DateTime.now().millisecondsSinceEpoch;
    }
    tasksStatus = TaskStatus.PENDING;
  }

  bool operator ==(o) => o is Tasks && o.id == id;

  Tasks.update({
    required this.id,
    required this.title,
    required this.projectId,
    this.comment = "",
    this.dueDate = -1,
    this.priority = Status.PRIORITY_4,
    this.tasksStatus = TaskStatus.PENDING,
  }) {
    if (dueDate == -1) {
      dueDate = DateTime.now().millisecondsSinceEpoch;
    }
  }

  Tasks.fromMap(Map<String, dynamic> map)
      : this.update(
          id: map[dbId],
          title: map[dbTitle],
          projectId: map[dbProjectID],
          comment: map[dbComment],
          dueDate: map[dbDueDate],
          priority: Status.values[map[dbPriority]],
          tasksStatus: TaskStatus.values[map[dbStatus]],
        );
}

enum TaskStatus {
  PENDING,
  COMPLETE,
}
