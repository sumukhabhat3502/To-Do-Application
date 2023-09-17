import 'package:flutter/material.dart';

import '../../../bloc/bloc_provider.dart';
import '../bloc/task_bloc.dart';
import '../models/tasks.dart';
import '../task_db.dart';
import 'row_task_completed.dart';

class TaskCompletedPage extends StatelessWidget {
  final TaskBloc _taskBloc = TaskBloc(TaskDB.get());

  @override
  Widget build(BuildContext context) {
    _taskBloc.filterByStatus(TaskStatus.COMPLETE);
    return BlocProvider(
      bloc: _taskBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Task Completed"),
        ),
        body: StreamBuilder<List<Tasks>>(
            stream: _taskBloc.tasks,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return ClipRect(
                        child: Dismissible(
                            key: ValueKey(
                                "swipe_completed_${snapshot.data![index].id}_$index"),
                            direction: DismissDirection.endToStart,
                            background: Container(),
                            onDismissed: (DismissDirection directions) {
                              if (directions == DismissDirection.endToStart) {
                                final taskID = snapshot.data![index].id!;
                                _taskBloc.updateStatus(
                                    taskID, TaskStatus.PENDING);
                                SnackBar snackbar =
                                    const SnackBar(content: Text("Task Undo"));
                                ScaffoldMessenger.of(context).showSnackBar(snackbar);
                              }
                            },
                            secondaryBackground: Container(
                              color: Colors.grey,
                              child: const Align(
                                alignment: Alignment(0.95, 0.0),
                                child: Text("UNDO",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                            child: TaskCompletedRow(snapshot.data![index])),
                      );
                    });
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            }),
      ),
    );
  }
}
