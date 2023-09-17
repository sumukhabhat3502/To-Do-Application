import 'package:flutter/material.dart';
import 'package:to_do_manager/utils/extension.dart';
import '../../bloc/bloc_provider.dart';
import '../../utils/keys.dart';
import '../labels/label_bloc.dart';
import '../labels/label_db.dart';
import '../labels/label_widget.dart';
import '../projects/project.dart';
import '../projects/project_bloc.dart';
import '../projects/project_db.dart';
import '../projects/project_widget.dart';
import '../tasks/bloc/task_bloc.dart';
import 'home_bloc.dart';

class SideDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    HomeBloc homeBloc = BlocProvider.of(context);
    return Drawer(
      child: ListView(
        padding: const EdgeInsets.all(0.0),
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: const Text("Burhanuddin Rashid"),
            accountEmail: const Text("burhanrashid5253@gmail.com"),
            otherAccountsPictures: <Widget>[
              // IconButton(
              //     icon: const Icon(
              //       Icons.info,
              //       color: Colors.white,
              //       size: 36.0,
              //     ),
              //     onPressed: () async {
              //       await context.adaptiveNavigate(
              //           SCREEN.ABOUT, AboutUsScreen());
              //     })
            ],
            currentAccountPicture: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              backgroundImage: const AssetImage("assets/profile_pic.jpg"),
            ),
          ),
          ListTile(
              leading: const Icon(Icons.inbox),
              title: const Text(
                "Inbox",
                key: ValueKey(SideDrawerKeys.INBOX),
              ),
              onTap: () {
                var project = Project.getInbox();
                homeBloc.applyFilter(
                    project.name, Filter.byProject(project.id!));
                context.safePop();
              }),
          ListTile(
              onTap: () {
                homeBloc.applyFilter("Today", Filter.byToday());
                context.safePop();
              },
              leading: const Icon(Icons.calendar_today),
              title: const Text(
                "Today",
                key: ValueKey(SideDrawerKeys.TODAY),
              )),
          ListTile(
            onTap: () {
              homeBloc.applyFilter("Next 7 Days", Filter.byNextWeek());
              context.safePop();
            },
            leading: const Icon(Icons.calendar_today),
            title: const Text(
              "Next 7 Days",
              key: ValueKey(SideDrawerKeys.NEXT_7_DAYS),
            ),
          ),
          BlocProvider(
            bloc: ProjectBloc(ProjectDB.get()),
            child: ProjectPage(),
          ),
          BlocProvider(
            bloc: LabelBloc(LabelDB.get()),
            child: LabelPage(),
          )
        ],
      ),
    );
  }
}
