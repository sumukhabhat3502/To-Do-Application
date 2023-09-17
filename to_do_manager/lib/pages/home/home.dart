// ignore_for_file: constant_identifier_names

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:to_do_manager/pages/home/side_drawer.dart';
import 'package:to_do_manager/utils/extension.dart';

import '../../bloc/bloc_provider.dart';
import '../../utils/keys.dart';
import '../tasks/add_task.dart';
import '../tasks/bloc/task_bloc.dart';
import '../tasks/task_completed/task_complted.dart';
import '../tasks/task_db.dart';
import '../tasks/task_widgets.dart';
import 'home_bloc.dart';


class HomePage extends StatelessWidget {
  final TaskBloc _taskBloc = TaskBloc(TaskDB.get());
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final bool isWiderScreen = context.isWiderScreen();
    final homeBloc = context.bloc<HomeBloc>();
    scheduleMicrotask(() {
      StreamSubscription? _filterSubscription;
      _filterSubscription = homeBloc.filter.listen((filter) {
        _taskBloc.updateFilters(filter);
        //_filterSubscription?.cancel();
      });
    });
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: StreamBuilder<String>(
            initialData: 'Today',
            stream: homeBloc.title,
            builder: (context, snapshot) {
              return Text(
                snapshot.data!,
                key: const ValueKey(HomePageKeys.HOME_TITLE),
              );
            }),
        actions: <Widget>[buildPopupMenu(context)],
        leading: isWiderScreen
            ? null
            : new IconButton(
                icon: new Icon(
                  Icons.menu,
                  key: const ValueKey(SideDrawerKeys.DRAWER),
                ),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        key: const ValueKey(HomePageKeys.ADD_NEW_TASK_BUTTON),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
        backgroundColor: Colors.orange,
        onPressed: () async {
          await context.adaptiveNavigate(SCREEN.ADD_TASK, AddTaskProvider());
          _taskBloc.refresh();
        },
      ),
      drawer: isWiderScreen ? null : SideDrawer(),
      body: BlocProvider(
        bloc: _taskBloc,
        child: TasksPage(),
      ),
    );
  }

// This menu button widget updates a _selection field (of type WhyFarther,
// not shown here).
  Widget buildPopupMenu(BuildContext context) {
    return PopupMenuButton<MenuItem>(
      icon: Icon(Icons.adaptive.more),
      key: const ValueKey(CompletedTaskPageKeys.POPUP_ACTION),
      onSelected: (MenuItem result) async {
        switch (result) {
          case MenuItem.TASK_COMPLETED:
            await context.adaptiveNavigate(
                SCREEN.COMPLETED_TASK, TaskCompletedPage());
            _taskBloc.refresh();
            break;
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<MenuItem>>[
        const PopupMenuItem<MenuItem>(
          value: MenuItem.TASK_COMPLETED,
          child:  Text(
            'Completed Tasks',
            key: ValueKey(CompletedTaskPageKeys.COMPLETED_TASKS),
          ),
        )
      ],
    );
  }
}

// This is the type used by the popup menu below.
enum MenuItem { TASK_COMPLETED }
