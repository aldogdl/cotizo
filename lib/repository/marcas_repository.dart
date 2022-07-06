import 'package:cotizo/entity/marca_entity.dart';
import 'package:hive/hive.dart';

import '../vars/enums.dart';

class MarcasRepository {

  
  final _boxName = HiveBoxs.marca.name;
  Box<MarcaEntity>? _box;
  
  ///
  Map<String, dynamic> result = {'abort':false, 'msg':'ok', 'body':[]};
  void cleanResult() {
    result = {'abort':false, 'msg':'ok', 'body':[]};
  }

  ///
  Future<void> openBox() async {

    if(!Hive.isAdapterRegistered(6)) {
      Hive.registerAdapter<MarcaEntity>(MarcaEntityAdapter());
    }

    if(!Hive.isBoxOpen(_boxName)) {
      _box = await Hive.openBox<MarcaEntity>(_boxName, compactionStrategy: (entries, deletedEntries) {
        return deletedEntries > 50;
      });
    }else{
      _box = Hive.box<MarcaEntity>(_boxName);
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
  Future<int?> existe(Map<String, dynamic> marca) async {

    final ok = await _isMyOpen();
    if(ok) {
      final has = _box!.values.where((element) => element.id == marca['id']);
      if(has.isNotEmpty) {
        return has.first.id;
      }
    }
    return null;
  }

  ///
  Future<int> saveMarcaInLocal(Map<String, dynamic> marca) async {

    final ok = await _isMyOpen();
    if(ok) {
      final m = MarcaEntity();
      m.fromServer(marca);
      _box!.add(m);
    }
    return marca['id'];
  }

  ///
  Future<MarcaEntity?> getMarcaById(int id) async {

    final ok = await _isMyOpen();
    if(ok) {
      final has = _box!.values.where((element) => element.id == id);
      return (has.isNotEmpty) ? has.first : null;
    }
    return null;
  }

  ///
  String getLogo(int id) {

    if(_box != null && _box!.isOpen) {
      final marca = _box!.values.where((element) => element.id == id);
      if(marca.isNotEmpty){
        return marca.first.logo;
      }
    }

    return 'no-logo.png';
  }
}