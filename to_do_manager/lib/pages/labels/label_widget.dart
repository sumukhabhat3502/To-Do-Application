import 'package:flutter/material.dart';
import 'package:to_do_manager/utils/extension.dart';

import '../../bloc/bloc_provider.dart';
import '../../utils/keys.dart';
import '../home/home_bloc.dart';
import '../tasks/bloc/task_bloc.dart';
import 'add_label.dart';
import 'label.dart';
import 'label_bloc.dart';
import 'label_db.dart';

class LabelPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    LabelBloc labelBloc = BlocProvider.of(context);
    return StreamBuilder<List<Label>>(
      stream: labelBloc.labels,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return LabelExpansionTileWidget(snapshot.data!);
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}

class LabelExpansionTileWidget extends StatelessWidget {
  final List<Label> _labels;

  LabelExpansionTileWidget(this._labels);

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      key: const ValueKey(SideDrawerKeys.DRAWER_LABELS),
      leading: const Icon(Icons.label),
      title: const Text("Labels",
          style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold)),
      children: buildLabels(context),
    );
  }

  List<Widget> buildLabels(BuildContext context) {
    final _labelBloc = context.bloc<LabelBloc>();
    List<Widget> projectWidgetList = [];
    for (var label in _labels) {
      projectWidgetList.add(LabelRow(label));
    }
    projectWidgetList.add(ListTile(
        leading: const Icon(Icons.add),
        title: const Text(
          "Add Label",
          key: ValueKey(SideDrawerKeys.ADD_LABEL),
        ),
        onTap: () async {
          await context.adaptiveNavigate(SCREEN.ADD_LABEL, AddLabelPage());
          _labelBloc.refresh();
        }));
    return projectWidgetList;
  }
}

class LabelRow extends StatelessWidget {
  final Label label;

  LabelRow(this.label);

  @override
  Widget build(BuildContext context) {
    final homeBloc = context.bloc<HomeBloc>();
    return ListTile(
      key: ValueKey("tile_${label.name}_${label.id}"),
      onTap: () {
        homeBloc.applyFilter("@ ${label.name}", Filter.byLabel(label.name));
        context.safePop();
      },
      leading: Container(
        width: 24.0,
        height: 24.0,
        key: ValueKey("space_${label.name}_${label.id}"),
      ),
      title: Text(
        "@ ${label.name}",
        key: ValueKey("${label.name}_${label.id}"),
      ),
      trailing: Container(
        height: 10.0,
        width: 10.0,
        child: Icon(
          Icons.label,
          size: 16.0,
          key: ValueKey("icon_${label.name}_${label.id}"),
          color: Color(label.colorValue),
        ),
      ),
    );
  }
}

class AddLabelPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      bloc: LabelBloc(LabelDB.get()),
      child: AddLabel(),
    );
  }
}
