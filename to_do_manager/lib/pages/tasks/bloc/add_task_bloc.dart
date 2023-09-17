import 'dart:async';

import 'package:rxdart/rxdart.dart';

import '../../../bloc/bloc_provider.dart';
import '../../../models/priority.dart';
import '../../labels/label.dart';
import '../../labels/label_db.dart';
import '../../projects/project.dart';
import '../../projects/project_db.dart';
import '../models/tasks.dart';
import '../task_db.dart';

class AddTaskBloc implements BlocBase {
  final TaskDB _taskDB;
  final ProjectDB _projectDB;
  final LabelDB _labelDB;
  Status lastPrioritySelection = Status.PRIORITY_4;

  AddTaskBloc(this._taskDB, this._projectDB, this._labelDB) {
    _loadProjects();
    _loadLabels();
    updateDueDate(DateTime.now().millisecondsSinceEpoch);
    _projectSelection.add(Project.getInbox());
    _prioritySelected.add(lastPrioritySelection);
  }

  final BehaviorSubject<List<Project>> _projectController =
      BehaviorSubject<List<Project>>();

  Stream<List<Project>> get projects => _projectController.stream;

  final BehaviorSubject<List<Label>> _labelController =
      BehaviorSubject<List<Label>>();

  Stream<List<Label>> get labels => _labelController.stream;

  final BehaviorSubject<Project> _projectSelection = BehaviorSubject<Project>();

  Stream<Project> get selectedProject => _projectSelection.stream;

  final BehaviorSubject<String> _labelSelected = BehaviorSubject<String>();

  Stream<String> get labelSelection => _labelSelected.stream;

  final List<Label> _selectedLabelList = [];

  List<Label> get selectedLabels => _selectedLabelList;

  final BehaviorSubject<Status> _prioritySelected = BehaviorSubject<Status>();

  Stream<Status> get prioritySelected => _prioritySelected.stream;

  final BehaviorSubject<int> _dueDateSelected = BehaviorSubject<int>();

  Stream<int> get dueDateSelected => _dueDateSelected.stream;

  String updateTitle = "";

  @override
  void dispose() {
    _projectController.close();
    _labelController.close();
    _projectSelection.close();
    _labelSelected.close();
    _prioritySelected.close();
    _dueDateSelected.close();
  }

  void _loadProjects() {
    _projectDB.getProjects(isInboxVisible: true).then((projects) {
      _projectController.add(List.unmodifiable(projects));
    });
  }

  void _loadLabels() {
    _labelDB.getLabels().then((labels) {
      _labelController.add(List.unmodifiable(labels));
    });
  }

  void projectSelected(Project project) {
    _projectSelection.add(project);
  }

  void labelAddOrRemove(Label label) {
    if (_selectedLabelList.contains(label)) {
      _selectedLabelList.remove(label);
    } else {
      _selectedLabelList.add(label);
    }
    _buildLabelsString();
  }

  void _buildLabelsString() {
    List<String> selectedLabelNameList = [];
    for (var label in _selectedLabelList) {
      selectedLabelNameList.add("@${label.name}");
    }
    String labelJoinString = selectedLabelNameList.join("  ");
    String displayLabels =
        labelJoinString.isEmpty ? "No Labels" : labelJoinString;
    _labelSelected.add(displayLabels);
  }

  void updatePriority(Status priority) {
    _prioritySelected.add(priority);
    lastPrioritySelection = priority;
  }

  Stream createTask() {
    return ZipStream.zip3(selectedProject, dueDateSelected, prioritySelected,
        (Project project, int dueDateSelected, Status status) {
      List<int> labelIds = [];
      for (var label in _selectedLabelList) {
        labelIds.add(label.id!);
      }

      var task = Tasks.create(
        title: updateTitle,
        dueDate: dueDateSelected,
        priority: status,
        projectId: project.id!,
      );

      _taskDB.updateTask(task, labelIDs: labelIds).then((task) {
        Notification.onDone();
      });
    });
  }

  void updateDueDate(int millisecondsSinceEpoch) {
    _dueDateSelected.add(millisecondsSinceEpoch);
  }
}
