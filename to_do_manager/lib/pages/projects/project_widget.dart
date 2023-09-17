// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:to_do_manager/utils/extension.dart';

import '../../bloc/bloc_provider.dart';
import '../../utils/keys.dart';
import '../home/home_bloc.dart';
import '../tasks/bloc/task_bloc.dart';
import 'add_project.dart';
import 'project.dart';
import 'project_bloc.dart';
import 'project_db.dart';

class ProjectPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ProjectBloc projectBloc = BlocProvider.of<ProjectBloc>(context);
    return StreamBuilder<List<Project>>(
      stream: projectBloc.projects,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ProjectExpansionTileWidget(snapshot.data!);
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}

class ProjectExpansionTileWidget extends StatelessWidget {
  final List<Project> _projects;

  ProjectExpansionTileWidget(this._projects);

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      key: const ValueKey(SideDrawerKeys.DRAWER_PROJECTS),
      leading: const Icon(Icons.book),
      title: const Text("Projects",
          style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold)),
      children: buildProjects(context),
    );
  }

  List<Widget> buildProjects(BuildContext context) {
    List<Widget> projectWidgetList = [];
    for (var project in _projects) {
      projectWidgetList.add(ProjectRow(project));
    }
    projectWidgetList.add(ListTile(
      key: const ValueKey(SideDrawerKeys.ADD_PROJECT),
      leading: const Icon(Icons.add),
      title: const Text("Add Project"),
      onTap: () async {
        await context.adaptiveNavigate(SCREEN.ADD_PROJECT, AddProjectPage());
        context.bloc<ProjectBloc>().refresh();
      },
    ));
    return projectWidgetList;
  }
}

class ProjectRow extends StatelessWidget {
  final Project project;

  ProjectRow(this.project);

  @override
  Widget build(BuildContext context) {
    HomeBloc homeBloc = BlocProvider.of(context);
    return ListTile(
      key: ValueKey("tile_${project.name}_${project.id}"),
      onTap: () {
        homeBloc.applyFilter(project.name, Filter.byProject(project.id!));
        context.safePop();
      },
      leading: SizedBox(
        key: ValueKey("space_${project.name}_${project.id}"),
        width: 24.0,
        height: 24.0,
      ),
      title: Text(
        project.name,
        key: ValueKey("${project.name}_${project.id}"),
      ),
      trailing: SizedBox(
        height: 10.0,
        width: 10.0,
        child: CircleAvatar(
          key: ValueKey("dot_${project.name}_${project.id}"),
          backgroundColor: Color(project.colorValue),
        ),
      ),
    );
  }
}

class AddProjectPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      bloc: ProjectBloc(ProjectDB.get()),
      child: AddProject(),
    );
  }
}
