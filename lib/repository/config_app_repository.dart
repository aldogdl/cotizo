import 'package:hive/hive.dart';

import '../entity/config_app.dart';
import '../vars/enums.dart';

class ConfigAppRepository {

  final _boxName = HiveBoxs.configapp.name;
  Box<ConfigApp>? box;
  
  ///
  Map<String, dynamic> result = {'abort':false, 'msg':'ok', 'body':[]};
  
  void cleanResult() {
    result = {'abort':false, 'msg':'ok', 'body':[]};
  }

  ///
  Future<void> openBox() async {

    if(!Hive.isAdapterRegistered(configappHT)) {
      Hive.registerAdapter<ConfigApp>(ConfigAppAdapter());
    }

    if(!Hive.isBoxOpen(_boxName)) {
      box = await Hive.openBox<ConfigApp>(_boxName, compactionStrategy: (entries, deletedEntries) {
        return deletedEntries > 50;
      });
    }else{
      box = Hive.box<ConfigApp>(_boxName);
    }
  }

  ///
  Future<DateTime?> hasData() async {

    await openBox();
    if(box != null) {
      if(box!.values.isNotEmpty) {
        return DateTime.parse(box!.values.first.inLast);
      }
    }
    return null;
  }

  ///
  Future<bool> isValidToken() async {

    await openBox();
    if(box != null) {
      if(box!.values.isNotEmpty) {
        return box!.values.first.invalidToken;
      }
    }
    return false;
  }

  ///
  Future<void> setTokenInvalido() async {

    await openBox();
    if(box != null) {
      if(box!.values.isNotEmpty) {
        box!.values.first.invalidToken = true;
        box!.values.first.save();
      }
    }
    return;
  }

  ///
  Future<int> getModoCotiza() async {

    await openBox();
    if(box != null) {
      if(box!.values.isNotEmpty) {
        return box!.values.first.modoCot;
      }
    }
    return 0;
  }

  ///
  Future<int> setModoCotiza(int modo) async {

    await openBox();
    if(box != null) {
      if(box!.values.isNotEmpty) {
        box!.values.first.modoCot = modo;
        box!.values.first.save();
      }
    }
    return 0;
  }

  ///
  Future<int> setNextModoCotiza() async {

    await openBox();
    if(box != null) {

      int modo = 0;
      int modoCurrent = await getModoCotiza();
      if(modoCurrent < 3) {
        switch (modoCurrent) {
          case 1:
            modo = 2;
            break;
          case 2:
            modo = 3;
            break;
          default:
            modo = 1;
        }
        if(box!.values.isNotEmpty) {
          box!.values.first.modoCot = modo;
          box!.values.first.save();
        }
      }
    }
    return 0;
  }

  ///
  Future<bool> getStatusNotiff() async {

    await openBox();
    if(box != null) {
      if(box!.values.isNotEmpty) {
        return box!.values.first.desaPushInt;
      }
    }
    return false;
  }

  ///
  Future<void> setStatusNotiff(bool stt) async {

    await openBox();
    if(box != null) {
      if(box!.values.isNotEmpty) {
        box!.values.first.desaPushInt = stt;
        box!.values.first.save();
      }
    }
  }

  ///
  Future<bool> getShowDialogApartar() async {

    await openBox();
    if(box != null) {
      if(box!.values.isNotEmpty) {
        return box!.values.first.showAvisoAparta;
      }
    }
    return false;
  }

  ///
  Future<void> setShowDialogApartar(bool stt) async {

    await openBox();
    if(box != null) {
      if(box!.values.isNotEmpty) {
        box!.values.first.showAvisoAparta = stt;
        box!.values.first.save();
      }
    }
  }

  ///
  Future<void> setDateTimeNtg() async {

    await openBox();
    if(box != null) {
      if(box!.values.isNotEmpty) {
        box!.values.first.lastCheckNt = DateTime.now().toIso8601String();
        box!.values.first.save();
      }
    }
  }

  /// Revisamos si ya es tiempo de actualizar la tabla de filtros No tengo
  Future<bool> isTimeUpdateNtg() async {

    await openBox();
    if(box != null) {
      if(box!.values.isNotEmpty) {
        if(box!.values.first.lastCheckNt.isNotEmpty) {
          final last = DateTime.parse(box!.values.first.lastCheckNt);
          final hoy = DateTime.now();
          final diff = hoy.difference(last);
          return (diff.inDays > 2) ? true : false;
        }else{
          return true;
        }
      }
    }
    return false;
  }

  ///
  Future<void> updateIfNotEmpty() async {

    await openBox();
    if(box != null) {
      if(box!.values.isNotEmpty) {
        box!.values.first.inLast = DateTime.now().toIso8601String();
        box!.values.first.invalidToken = true;
        box!.values.first.save();
      }else{
        final ob = ConfigApp();
        ob.inLast = DateTime.now().toIso8601String();
        ob.invalidToken = true;
        ob.isInit = true;
        box!.add(ob);
      }
    }
    return;
  }

}