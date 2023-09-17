import 'package:flutter/material.dart';
import 'package:to_do_manager/utils/extension.dart';

import '../../bloc/bloc_provider.dart';
import '../../utils/collapsable_expand_tile.dart';
import '../../utils/color_utils.dart';
import '../../utils/keys.dart';
import '../home/home_bloc.dart';
import 'project.dart';
import 'project_bloc.dart';

class AddProject extends StatelessWidget {
  final expansionTile = GlobalKey<CollapsibleExpansionTileState>();
  final GlobalKey<FormState> _formState = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    ProjectBloc _projectBloc = BlocProvider.of(context);
    late ColorPalette currentSelectedPalette;
    String projectName = "";
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Add Project",
          key: ValueKey(AddProjectKeys.TITLE_ADD_PROJECT),
        ),
      ),
      floatingActionButton: FloatingActionButton(
          key: const ValueKey(AddProjectKeys.ADD_PROJECT_BUTTON),
          child: const Icon(
            Icons.send,
            color: Colors.white,
          ),
          onPressed: () {
            if (_formState.currentState!.validate()) {
              _formState.currentState!.save();
              var project = Project.create(
                  projectName,
                  currentSelectedPalette.colorValue,
                  currentSelectedPalette.colorName);
              _projectBloc.createProject(project);
              if (context.isWiderScreen()) {
                context.bloc<HomeBloc>().updateScreen(SCREEN.HOME);
              }
              context.safePop();
              _projectBloc.refresh();
            }
          }),
      body: ListView(
        children: <Widget>[
          Form(
            key: _formState,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                key: const ValueKey(AddProjectKeys.TEXT_FORM_PROJECT_NAME),
                decoration: const InputDecoration(hintText: "Project Name"),
                maxLength: 20,
                validator: (value) {
                  return value!.isEmpty ? "Project name cannot be empty" : null;
                },
                onSaved: (value) {
                  projectName = value!;
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: StreamBuilder<ColorPalette>(
              stream: _projectBloc.colorSelection,
              initialData: ColorPalette("Grey", Colors.grey.value),
              builder: (context, snapshot) {
                currentSelectedPalette = snapshot.data!;
                return CollapsibleExpansionTile(
                  key: expansionTile,
                  leading: Container(
                    width: 12.0,
                    height: 12.0,
                    child: CircleAvatar(
                      backgroundColor: Color(snapshot.data!.colorValue),
                    ),
                  ),
                  title: Text(snapshot.data!.colorName),
                  children: buildMaterialColors(_projectBloc),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  List<Widget> buildMaterialColors(ProjectBloc projectBloc) {
    List<Widget> projectWidgetList = [];
    for (var colors in colorsPalettes) {
      projectWidgetList.add(ListTile(
        leading: SizedBox(
          width: 12.0,
          height: 12.0,
          child: CircleAvatar(
            backgroundColor: Color(colors.colorValue),
          ),
        ),
        title: Text(colors.colorName),
        onTap: () {
          expansionTile.currentState!.collapse();
          projectBloc.updateColorSelection(
            ColorPalette(colors.colorName, colors.colorValue),
          );
        },
      ));
    }
    return projectWidgetList;
  }
}
