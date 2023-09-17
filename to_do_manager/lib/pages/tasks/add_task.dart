import 'dart:async';
import 'package:flutter/material.dart';
import 'package:to_do_manager/utils/extension.dart';
import '../../bloc/bloc_provider.dart';
import '../../models/priority.dart';
import '../../utils/app_util.dart';
import '../../utils/color_utils.dart';
import '../../utils/date_util.dart';
import '../../utils/keys.dart';
import '../home/home_bloc.dart';
import '../labels/label.dart';
import '../labels/label_db.dart';
import '../projects/project.dart';
import '../projects/project_db.dart';
import 'bloc/add_task_bloc.dart';
import 'bloc/task_bloc.dart';
import 'task_db.dart';

class AddTaskScreen extends StatelessWidget {
  final GlobalKey<FormState> _formState = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    AddTaskBloc createTaskBloc = BlocProvider.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Add Task",
          key: ValueKey(AddTaskKeys.ADD_TASK_TITLE),
        ),
      ),
      body: ListView(
        children: <Widget>[
          Form(
            key: _formState,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                  key: const ValueKey(AddTaskKeys.ADD_TITLE),
                  validator: (value) {
                    var msg = value!.isEmpty ? "Title Cannot be Empty" : null;
                    return msg;
                  },
                  onSaved: (value) {
                    createTaskBloc.updateTitle = value!;
                  },
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(hintText: "Title")),
            ),
          ),
          ListTile(
            key: const ValueKey("addProject"),
            leading: const Icon(Icons.book),
            title: const Text("Project"),
            subtitle: StreamBuilder<Project>(
              stream: createTaskBloc.selectedProject,
              initialData: Project.getInbox(),
              builder: (context, snapshot) => Text(snapshot.data!.name),
            ),
            onTap: () {
              _showProjectsDialog(createTaskBloc, context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text("Due Date"),
            subtitle: StreamBuilder<int>(
              stream: createTaskBloc.dueDateSelected,
              initialData: DateTime.now().millisecondsSinceEpoch,
              builder: (context, snapshot) =>
                  Text(getFormattedDate(snapshot.data!)),
            ),
            onTap: () {
              _selectDate(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.flag),
            title: const Text("Priority"),
            subtitle: StreamBuilder<Status>(
              stream: createTaskBloc.prioritySelected,
              initialData: Status.PRIORITY_4,
              builder: (context, snapshot) =>
                  Text(priorityText[snapshot.data!.index]),
            ),
            onTap: () {
              _showPriorityDialog(createTaskBloc, context);
            },
          ),
          ListTile(
              leading: const Icon(Icons.label),
              title: const Text("Labels"),
              subtitle: StreamBuilder<String>(
                stream: createTaskBloc.labelSelection,
                initialData: "No Labels",
                builder: (context, snapshot) => Text(snapshot.data!),
              ),
              onTap: () {
                _showLabelsDialog(context);
              }),
          ListTile(
            leading: const Icon(Icons.mode_comment),
            title: const Text("Comments"),
            subtitle: const Text("No Comments"),
            onTap: () {
              showSnackbar(context, "Coming Soon");
            },
          ),
          ListTile(
            leading: const Icon(Icons.timer),
            title: const Text("Reminder"),
            subtitle: const Text("No Reminder"),
            onTap: () {
              showSnackbar(context, "Coming Soon");
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
          key: const ValueKey(AddTaskKeys.ADD_TASK),
          child: const Icon(Icons.send, color: Colors.white),
          onPressed: () {
            if (_formState.currentState!.validate()) {
              _formState.currentState!.save();
              createTaskBloc.createTask().listen((value) {
                if (context.isWiderScreen()) {
                  context
                      .bloc<HomeBloc>()
                      .applyFilter("Today", Filter.byToday());
                } else {
                  context.safePop();
                }
              });
            }
          }),
    );
  }

  Future<Null> _selectDate(BuildContext context) async {
    AddTaskBloc createTaskBloc = BlocProvider.of(context);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      createTaskBloc.updateDueDate(picked.millisecondsSinceEpoch);
    }
  }

  Future<Status?> _showPriorityDialog(
      AddTaskBloc createTaskBloc, BuildContext context) async {
    return await showDialog<Status>(
        context: context,
        builder: (BuildContext dialogContext) {
          return SimpleDialog(
            title: const Text('Select Priority'),
            children: <Widget>[
              buildContainer(context, Status.PRIORITY_1),
              buildContainer(context, Status.PRIORITY_2),
              buildContainer(context, Status.PRIORITY_3),
              buildContainer(context, Status.PRIORITY_4),
            ],
          );
        });
  }

  Future<Status?> _showProjectsDialog(
      AddTaskBloc createTaskBloc, BuildContext context) async {
    return showDialog<Status>(
        context: context,
        builder: (BuildContext dialogContext) {
          return StreamBuilder<List<Project>>(
              stream: createTaskBloc.projects,
              initialData: const <Project>[],
              builder: (context, snapshot) {
                return SimpleDialog(
                  title: const Text('Select Project'),
                  children:
                      buildProjects(createTaskBloc, context, snapshot.data!),
                );
              });
        });
  }

  Future<Status?> _showLabelsDialog(BuildContext context) async {
    AddTaskBloc createTaskBloc = BlocProvider.of(context);
    return showDialog<Status>(
        context: context,
        builder: (BuildContext context) {
          return StreamBuilder<List<Label>>(
              stream: createTaskBloc.labels,
              initialData: const <Label>[],
              builder: (context, snapshot) {
                return SimpleDialog(
                  title: const Text('Select Labels'),
                  children:
                      buildLabels(createTaskBloc, context, snapshot.data!),
                );
              });
        });
  }

  List<Widget> buildProjects(
    AddTaskBloc createTaskBloc,
    BuildContext context,
    List<Project> projectList,
  ) {
    List<Widget> projects = [];
    for (var project in projectList) {
      projects.add(ListTile(
        leading: SizedBox(
          width: 12.0,
          height: 12.0,
          child: CircleAvatar(
            backgroundColor: Color(project.colorValue),
          ),
        ),
        title: Text(project.name),
        onTap: () {
          createTaskBloc.projectSelected(project);
          Navigator.pop(context);
        },
      ));
    }
    return projects;
  }

  List<Widget> buildLabels(
    AddTaskBloc createTaskBloc,
    BuildContext context,
    List<Label> labelList,
  ) {
    List<Widget> labels = [];
    for (var label in labelList) {
      labels.add(ListTile(
        leading: Icon(Icons.label, color: Color(label.colorValue), size: 18.0),
        title: Text(label.name),
        trailing: createTaskBloc.selectedLabels.contains(label)
            ? const Icon(Icons.close)
            : const SizedBox(width: 18.0, height: 18.0),
        onTap: () {
          createTaskBloc.labelAddOrRemove(label);
          Navigator.pop(context);
        },
      ));
    }
    return labels;
  }

  GestureDetector buildContainer(BuildContext context, Status status) {
    AddTaskBloc createTaskBloc = BlocProvider.of(context);
    return GestureDetector(
        onTap: () {
          createTaskBloc.updatePriority(status);
          Navigator.pop(context, status);
        },
        child: Container(
            color: status == createTaskBloc.lastPrioritySelection
                ? Colors.grey
                : Colors.white,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 2.0),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    width: 6.0,
                    color: priorityColor[status.index],
                  ),
                ),
              ),
              child: Container(
                margin: const EdgeInsets.all(12.0),
                child: Text(priorityText[status.index],
                    style: const TextStyle(fontSize: 18.0)),
              ),
            )));
  }
}

class AddTaskProvider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      bloc: AddTaskBloc(TaskDB.get(), ProjectDB.get(), LabelDB.get()),
      child: AddTaskScreen(),
    );
  }
}
