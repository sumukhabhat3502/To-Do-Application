import 'package:flutter/material.dart';
import 'package:to_do_manager/utils/extension.dart';
import 'bloc/bloc_provider.dart';
import 'pages/home/home.dart';
import 'pages/home/home_bloc.dart';
import 'pages/home/side_drawer.dart';
import 'pages/labels/label_widget.dart';
import 'pages/projects/project_widget.dart';
import 'pages/tasks/add_task.dart';
import 'pages/tasks/task_completed/task_complted.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFDE4435);
    final theme = ThemeData(
      primaryColor: primaryColor,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme.copyWith(
        colorScheme: theme.colorScheme.copyWith(
          secondary: Colors.orange,
          primary: primaryColor,
        ),
      ),
      home: BlocProvider(
        bloc: HomeBloc(),
        child: const AdaptiveHome(),
      ),
    );
  }
}

class AdaptiveHome extends StatelessWidget {
  const AdaptiveHome({super.key});

  @override
  Widget build(BuildContext context) {
    return context.isWiderScreen() ? const WiderHomePage() : HomePage();
  }
}

class WiderHomePage extends StatelessWidget {
  const WiderHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final homeBloc = context.bloc<HomeBloc>();
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: StreamBuilder<SCREEN>(
              stream: homeBloc.screens,
              builder: (context, snapshot) {
                //Refresh side drawer whenever screen is updated
                return SideDrawer();
              }),
        ),
        const SizedBox(
          width: 0.5,
        ),
        Expanded(
          flex: 5,
          child: StreamBuilder<SCREEN>(
              stream: homeBloc.screens,
              builder: (context, snapshot) {
                if (snapshot.data != null) {
                  // ignore: missing_enum_constant_in_switch
                  switch (snapshot.data) {
                    case SCREEN.ADD_TASK:
                      return AddTaskProvider();
                    case SCREEN.COMPLETED_TASK:
                      return TaskCompletedPage();
                    case SCREEN.ADD_PROJECT:
                      return AddProjectPage();
                    case SCREEN.ADD_LABEL:
                      return AddLabelPage();
                    case SCREEN.HOME:
                      return HomePage();
                  }
                }
                return HomePage();
              }),
        )
      ],
    );
  }
}
