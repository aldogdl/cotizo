import 'package:hive/hive.dart';

import '../entity/pieza_entity.dart';
import '../vars/enums.dart';

class PiezasRepository {

  final _boxName = HiveBoxs.pieza.name;
  Box<PiezaEntity>? _box;
  Box<PiezaEntity> get box => _box!;

  ///
  Map<String, dynamic> result = {'abort':false, 'msg':'ok', 'body':[]};
  void cleanResult() {
    result = {'abort':false, 'msg':'ok', 'body':[]};
  }

  ///
  Future<void> openBox() async {

    if(!Hive.isAdapterRegistered(9)) {
      Hive.registerAdapter<PiezaEntity>(PiezaEntityAdapter());
    }

    if(!Hive.isBoxOpen(_boxName)) {
      _box = await Hive.openBox<PiezaEntity>(_boxName, compactionStrategy: (entries, deletedEntries) {
        return deletedEntries > 50;
      });
    }else{
      _box = Hive.box<PiezaEntity>(_boxName);
    }
  }

  ///
  Future<PiezaEntity?> existe(String pieza) async {
    
    bool ok = false;
    if(_box != null && _box!.isOpen) {
      ok = true;
    }else{
      await openBox();
      ok = true;
    }
    if(ok) {
      final res = _box!.values.where((element) => element.piezaName == pieza);
      return (res.isNotEmpty) ? res.first : null;
    }
    return null;
  }

  ///
  Future<PiezaEntity?> getPzaById(int id) async {
    
    bool ok = false;
    if(_box != null && _box!.isOpen) {
      ok = true;
    }else{
      await openBox();
      ok = true;
    }
    if(ok) {
      final res = _box!.values.where((element) => element.id == id);
      return (res.isNotEmpty) ? res.first : null;
    }
    return null;
  }

  ///
  Future<List<int>> buscarPiezas(String txt) async {

    List<int> lst = [];
    await openBox();
    if(_box != null) {
      _box!.values.map((element) {
          if(element.piezaName.toLowerCase().startsWith(txt.toLowerCase())) {
            lst.add(element.id);
          }
        }
      ).toList();
    }
    return lst;
  }
}