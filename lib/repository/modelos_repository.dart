import 'package:cotizo/entity/modelo_entity.dart';
import 'package:hive/hive.dart';

import '../vars/enums.dart';

class ModelosRepository {

  
  final _boxName = HiveBoxs.modelo.name;
  Box<ModeloEntity>? _box;
  
  ///
  Map<String, dynamic> result = {'abort':false, 'msg':'ok', 'body':[]};
  void cleanResult() {
    result = {'abort':false, 'msg':'ok', 'body':[]};
  }

  ///
  Future<void> openBox() async {

    if(!Hive.isAdapterRegistered(modeloHT)) {
      Hive.registerAdapter<ModeloEntity>(ModeloEntityAdapter());
    }

    if(!Hive.isBoxOpen(_boxName)) {
      _box = await Hive.openBox<ModeloEntity>(_boxName, compactionStrategy: (entries, deletedEntries) {
        return deletedEntries > 50;
      });
    }else{
      _box = Hive.box<ModeloEntity>(_boxName);
    }
  }


  /// Hacemos una revision si esta inicializada la variable box y abierta la caja
  Future<bool> _isMyOpen() async {

    bool ok = false;
    if(_box != null && _box!.isOpen) {
      ok = true;
    }else{
      await openBox();
      ok = true;
    }
    return ok;
  }

  ///
  Future<int?> existe(Map<String, dynamic> modelo) async {

    final ok = await _isMyOpen();
    if(ok) {
      final has = _box!.values.where((element) => element.id == modelo['id']);
      if(has.isNotEmpty) {
        return has.first.id;
      }
    }
    return null;
  }

  ///
  Future<int> saveModeloInLocal(Map<String, dynamic> modelo) async {

    final ok = await _isMyOpen();
    if(ok) {
      final m = ModeloEntity();
      m.fromServer(modelo);
      _box!.add(m);
    }
    return modelo['id'];
  }

  ///
  Future<ModeloEntity?> getModelosById(int id) async {

    final ok = await _isMyOpen();
    if(ok) {
      final has = _box!.values.where((element) => element.id == id);
      return (has.isNotEmpty) ? has.first : null;
    }
    return null;
  }
}