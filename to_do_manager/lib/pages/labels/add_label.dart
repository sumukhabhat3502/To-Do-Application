import 'dart:async';

import 'package:flutter/material.dart';

class AddLabel extends StatelessWidget {
  final GlobalKey<FormState> _formState = GlobalKey<FormState>();
  final expansionTile = GlobalKey<CollapsibleExpansionTileState>();

  @override
  Widget build(BuildContext context) {
    late ColorPalette currentSelectedPalette;
    LabelBloc labelBloc = BlocProvider.of(context);
    String labelName = "";
    scheduleMicrotask(() {
      labelBloc.labelsExist.listen((isExist) {
        if (isExist) {
          showSnackbar(context, "Label already exists");
        } else {
          context.safePop();
          if (context.isWiderScreen()) {
            context.bloc<HomeBloc>().updateScreen(SCREEN.HOME);
          }
        }
      });
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add Label",
          key: ValueKey(AddLabelKeys.TITLE_ADD_LABEL),
        ),
      ),
      floatingActionButton: FloatingActionButton(
          key: ValueKey(AddLabelKeys.ADD_LABEL_BUTTON),
          child: Icon(
            Icons.send,
            color: Colors.white,
          ),
          onPressed: () async {
            if (_formState.currentState?.validate() ?? false) {
              _formState.currentState?.save();
              var label = Label.create(
                  labelName,
                  currentSelectedPalette.colorValue,
                  currentSelectedPalette.colorName);
              labelBloc.checkIfLabelExist(label);
            }
          }),
      body: ListView(
        children: <Widget>[
          Form(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                key: ValueKey(AddLabelKeys.TEXT_FORM_LABEL_NAME),
                decoration: InputDecoration(hintText: "Label Name"),
                maxLength: 20,
                validator: (value) {
                  return value!.isEmpty ? "Label Cannot be empty" : null;
                },
                onSaved: (value) {
                  labelName = value!;
                },
              ),
            ),
            key: _formState,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: StreamBuilder<ColorPalette>(
              stream: labelBloc.colorSelection,
              initialData: ColorPalette("Grey", Colors.grey.value),
              builder: (context, snapshot) {
                currentSelectedPalette = snapshot.data!;
                return CollapsibleExpansionTile(
                  key: expansionTile,
                  leading: Icon(
                    Icons.label,
                    size: 16.0,
                    color: Color(currentSelectedPalette.colorValue),
                  ),
                  title: Text(currentSelectedPalette.colorName),
                  children: buildMaterialColors(labelBloc),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  List<Widget> buildMaterialColors(LabelBloc labelBloc) {
    List<Widget> projectWidgetList = [];
    colorsPalettes.forEach((colors) {
      projectWidgetList.add(ListTile(
        leading: Icon(
          Icons.label,
          size: 16.0,
          color: Color(colors.colorValue),
        ),
        title: Text(colors.colorName),
        onTap: () {
          expansionTile.currentState!.collapse();
          labelBloc.updateColorSelection(
            ColorPalette(colors.colorName, colors.colorValue),
          );
        },
      ));
    });
    return projectWidgetList;
  }
}
