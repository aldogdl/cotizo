import 'package:hive/hive.dart';

import '../entity/marca_entity.dart';
import '../entity/modelo_entity.dart';
import 'marcas_repository.dart';
import 'modelos_repository.dart';
import '../entity/autos_entity.dart';
import '../vars/enums.dart';

class AutosRepository {

  final _boxName = HiveBoxs.autos.name;
  final _mkEm = MarcasRepository();
  final _mdEm = ModelosRepository();

  Box<AutosEntity>? _box;
  
  ///
  Map<String, dynamic> result = {'abort':false, 'msg':'ok', 'body':[]};
  void cleanResult() {
    result = {'abort':false, 'msg':'ok', 'body':[]};
  }

  ///
  Future<void> openBox() async {

    if(!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter<AutosEntity>(AutosEntityAdapter());
    }

    if(!Hive.isBoxOpen(_boxName)) {
      _box = await Hive.openBox<AutosEntity>(_boxName, compactionStrategy: (entries, deletedEntries) {
        return deletedEntries > 50;
      });
    }else{
      _box = Hive.box<AutosEntity>(_boxName);
    }
    await _mkEm.openBox();
    await _mdEm.openBox();
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

  /// Revisamos si ya hay un auto registrado con anterioridad
  Future<AutosEntity?> existe(Map<String, dynamic> orden) async {

    final ok = await _isMyOpen();
    if(ok) {
      var res = _box!.values.where((element) => element.marca == orden['marca']['id']).toList();
      if(res.isNotEmpty) {
        res = res.where((element) => element.modelo == orden['modelo']['id']).toList();
        if(res.isNotEmpty) {
          res = res.where((element) => element.anio == orden['anio']).toList();
          if(res.isNotEmpty) {
            res = res.where((element) => element.isNac == orden['isNac']).toList();
            return (res.isEmpty) ? null : res.first;
          }
        }
      }
    }
    return null;
  }

  /// Hidratamos un auto desde datos del servidor
  /// [RETURN] El id del auto guardado
  Future<int> saveAutoInLocal(Map<String, dynamic> orden) async {

    final ok = await _isMyOpen();
    int idN = generateId();
    if(ok) {

      final a = AutosEntity();
      var carr = await _mkEm.existe(orden['marca']);
      if(carr != null) {
        a.marca = carr;
      }else{
        a.marca = await _mkEm.saveMarcaInLocal(orden['marca']);
      }

      orden['modelo']['marca'] = a.marca;
      carr = await _mdEm.existe(orden['modelo']);
      if(carr != null) {
        a.modelo = carr;
      }else{
        a.modelo = await _mdEm.saveModeloInLocal(orden['modelo']);
      }

      a.fromServer(orden, idN);
      _box!.add(a);
    }

    return idN;
  }

  /// Buscamos el ultimo id y le sumamos uno.
  int generateId() {

    int id = 0;
    var idnew = (_box!.values.isEmpty) ? 1 : (_box!.values.last.id) + 1;
    do {
      final has = _box!.values.where((element) => element.id == idnew);
      if(has.isEmpty) {
        id = idnew;
      }else{
        idnew++;
      }
    } while (id == 0);

    return id;
  }

  /// Asegurate de haber inicializado las cajas con anterioridad
  Future<AutosEntity?> getAutoById(int idAuto) async {
    final ok = await _isMyOpen();
    if(ok) {
      final has = _box!.values.where((element) => element.id == idAuto);
      return (has.isNotEmpty) ? has.first : null;
    }
    return null;
  }

  /// Asegurate de haber inicializado las cajas con anterioridad  
  Future<MarcaEntity?> getMarcaById(int idMk) async => await _mkEm.getMarcaById(idMk);

  /// Asegurate de haber inicializado las cajas con anterioridad  
  Future<ModeloEntity?> getModeloById(int idMd) async => await _mdEm.getModelosById(idMd);

}