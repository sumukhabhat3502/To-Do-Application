import 'dart:async';

import 'package:rxdart/rxdart.dart';

import '../../bloc/bloc_provider.dart';
import '../../utils/color_utils.dart';
import 'label.dart';
import 'label_db.dart';

class LabelBloc implements BlocBase {
  StreamController<List<Label>> _labelController =
      BehaviorSubject<List<Label>>();

  Stream<List<Label>> get labels => _labelController.stream;

  StreamController<bool> _labelExistController =
      StreamController<bool>.broadcast();

  Stream<bool> get labelsExist => _labelExistController.stream;

  StreamController<ColorPalette> _colorController =
      StreamController<ColorPalette>.broadcast();

  Stream<ColorPalette> get colorSelection => _colorController.stream;

  LabelDB _labelDB;

  LabelBloc(this._labelDB) {
    _loadLabels();
  }

  @override
  void dispose() {
    _labelController.close();
    _labelExistController.close();
    _colorController.close();
  }

  void _loadLabels() {
    _labelDB.getLabels().then((labels) {
      if (!_labelController.isClosed) {
        _labelController.sink.add(List.unmodifiable(labels));
      }
    });
  }

  void refresh() {
    _loadLabels();
  }

  void checkIfLabelExist(Label label) async {
    _labelDB.isLabelExits(label).then((isExist) {
      _labelExistController.sink.add(isExist);
    });
  }

  void updateColorSelection(ColorPalette colorPalette) {
    _colorController.sink.add(colorPalette);
  }
}
