import 'package:sqflite/sqflite.dart';

import '../../db/app_db.dart';
import 'label.dart';

class LabelDB {
  static final LabelDB _labelDb = LabelDB._internal(AppDatabase.get());

  AppDatabase _appDatabase;

  //private internal constructor to make it singleton
  LabelDB._internal(this._appDatabase);

  static LabelDB get() {
    return _labelDb;
  }

  Future<bool> isLabelExits(Label label) async {
    var db = await _appDatabase.getDb();
    var result = await db.rawQuery(
        "SELECT * FROM ${Label.tblLabel} WHERE ${Label.dbName} LIKE '${label.name}'");
    if (result.isEmpty) {
      return await updateLabels(label).then((value) {
        return false;
      });
    } else {
      return true;
    }
  }

  Future updateLabels(Label label) async {
    var db = await _appDatabase.getDb();
    await db.transaction((Transaction txn) async {
      await txn.rawInsert('INSERT OR REPLACE INTO '
          '${Label.tblLabel}(${Label.dbName},${Label.dbColorCode},${Label.dbColorName})'
          ' VALUES("${label.name}", ${label.colorValue}, "${label.colorName}")');
    });
  }

  Future<List<Label>> getLabels() async {
    var db = await _appDatabase.getDb();
    var result = await db.rawQuery('SELECT * FROM ${Label.tblLabel}');
    List<Label> labels = [];
    for (Map<String, dynamic> item in result) {
      var myLabels = Label.fromMap(item);
      labels.add(myLabels);
    }
    return labels;
  }

  Future deleteLabel(int labelId) async {
    var db = await _appDatabase.getDb();
    await db.transaction((Transaction txn) async {
      await txn.rawDelete(
          'DELETE FROM ${Label.tblLabel} WHERE ${Label.dbId}==$labelId;');
    });
  }
}
