import 'package:flutter/material.dart';

import '../../bloc/bloc_provider.dart';
import '../../utils/app_util.dart';
import 'bloc/task_bloc.dart';
import 'models/tasks.dart';
import 'row_task.dart';

class TasksPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final TaskBloc _tasksBloc = BlocProvider.of(context);
    return StreamBuilder<List<Tasks>>(
      stream: _tasksBloc.tasks,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return _buildTaskList(snapshot.data!);
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  Widget _buildTaskList(List<Tasks> list) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: list.isEmpty
          ? MessageInCenterWidget("No Task Added")
          : ListView.builder(
              itemCount: list.length,
              itemBuilder: (BuildContext context, int index) {
                return ClipRect(
                  child: Dismissible(
                      key: ValueKey("swipe_${list[index].id}_$index"),
                      onDismissed: (DismissDirection direction) {
                        var taskID = list[index].id!;
                        final TaskBloc tasksBloc =
                            BlocProvider.of<TaskBloc>(context);
                        String message = "";
                        if (direction == DismissDirection.endToStart) {
                          tasksBloc.updateStatus(
                              taskID, TaskStatus.COMPLETE);
                          message = "Task completed";
                        } else {
                          tasksBloc.delete(taskID);
                          message = "Task deleted";
                        }
                        SnackBar snackbar =
                            SnackBar(content: Text(message));
                        ScaffoldMessenger.of(context)
                            .showSnackBar(snackbar);
                      },
                      background: Container(
                        color: Colors.red,
                        child: const Align(
                          alignment: Alignment(-0.95, 0.0),
                          child: Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      secondaryBackground: Container(
                        color: Colors.green,
                        child: const Align(
                          alignment: Alignment(0.95, 0.0),
                          child: Icon(Icons.check, color: Colors.white),
                        ),
                      ),
                      child: TaskRow(list[index])),
                );
              }),
    );
  }
}
