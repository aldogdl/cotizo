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

    if(!Hive.isAdapterRegistered(piezaHT)) {
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
  Future<int> setPizaInBox(PiezaEntity pza) async {

    final res = await existe(pza);
    if(res.id == 0) {
      _box!.add(pza);
    }else{
      pza = res;
    }
    return pza.id;
  }

  ///
  Future<PiezaEntity> existe(PiezaEntity pieza) async {
    
    bool ok = false;
    if(_box != null && _box!.isOpen) {
      ok = true;
    }else{
      await openBox();
      ok = true;
    }
    if(ok) {

      final perName = _box!.values.where(
        (element) => element.piezaName.toLowerCase() == pieza.piezaName.toLowerCase()
      ).toList();

      if(perName.isNotEmpty){
        final perLado = perName.where(
          (element) => element.lado.toLowerCase() == pieza.lado.toLowerCase()
        ).toList();
        if(perLado.isNotEmpty){
          final perPos = perLado.where(
            (element) => element.posicion.toLowerCase() == pieza.posicion.toLowerCase()
          ).toList();
          if(perPos.isNotEmpty) {
            return perPos.first;
          }
        }
      }
    }

    return PiezaEntity();
  }

  ///
  PiezaEntity getPzaById(int id) {
    final res = _box!.values.where((element) => element.id == id);
    return (res.isNotEmpty) ? res.first : PiezaEntity();
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