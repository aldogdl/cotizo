import 'package:hive/hive.dart';

import '../entity/inventario_entity.dart';
import '../services/my_http.dart';
import '../services/my_image/my_im.dart';
import '../services/my_paths.dart';
import '../vars/enums.dart';

class InventarioRepository {

  final _http = MyHttp();

  final _boxName = HiveBoxs.inventario.name;
  Box<InventarioEntity>? _boxInv;
  final int perPage = 10;

  ///
  Future<void> openBox() async {

    if(!Hive.isAdapterRegistered(inventarioHT)) {
      Hive.registerAdapter<InventarioEntity>(InventarioEntityAdapter());
    }

    if(!Hive.isBoxOpen(_boxName)) {
      _boxInv = await Hive.openBox<InventarioEntity>(_boxName, compactionStrategy: (entries, deletedEntries) {
        return deletedEntries > 50;
      });
    }else{
      _boxInv = Hive.box<InventarioEntity>(_boxName);
    }
  }

  ///
  Future<void> setBoxInv(InventarioEntity inv) async {

    await openBox();
    if(_boxInv != null) {
      final has = _boxInv!.values.where((element) => element.id == inv.id);
      if(has.isNotEmpty) {
        await _boxInv!.put(has.first.key, inv);
      }else{
        await _boxInv!.add(inv);
      }
    }
  }

  ///
  Future<Map<int, List<int>>> getAllInvToFilter() async {

    Map<int, List<int>> lst = {};
    await openBox();
    if(_boxInv != null) {

      _boxInv!.values.map((i){
        if(lst.containsKey(i.idOrden)) {
          lst[i.idOrden]!.add(i.idPieza);
        }else{
          lst.putIfAbsent(i.idOrden, () => [i.idPieza]);
        }
      }).toList();
    }
    return lst;
  }

  /// 
  Future<Map<String, dynamic>> setRespToServer(Map<String, dynamic> json) async {

    Uri uri = MyPath.getUri('set_resp', '');
    await _http.post(uri, data: json);
    return _http.result;
  }

  ///
  Future<int> getInventarioCount() async {

    await openBox();
    if(_boxInv != null) {
      return List<InventarioEntity>.from(_boxInv!.values).length;
    }
    return 0;
  }

  /// 
  Future<List<InventarioEntity>> getInventario(int page) async {

    List<InventarioEntity> lst = [];
    await openBox();
    if(_boxInv != null) {
      return List<InventarioEntity>.from(_boxInv!.values);
    }
    return lst;
  }

  /// 
  Future<InventarioEntity> getInventarioById(int id) async {

    await openBox();
    if(_boxInv != null) {
      final lstTmp = _boxInv!.values.where((element) => '${element.id}' == '$id').toList();
      if(lstTmp.isNotEmpty) {
        return lstTmp.first;
      }
    }
    return InventarioEntity();
  }

  /// 
  Future<List<InventarioEntity>> buscarInvPorId(String criterio) async {

    List<InventarioEntity> lst = [];
    await openBox();
    if(_boxInv != null) {
      
      List<InventarioEntity> r = _boxInv!.values.where(
        (pza) => '${pza.id}'.startsWith(criterio)
      ).toList();
      if(r.isNotEmpty) { lst.addAll(r); }

      r = _boxInv!.values.where(
        (pza) => '${pza.id}'.startsWith(criterio)
      ).toList();

      r = _boxInv!.values.where((pza) => '${pza.id}'.endsWith(criterio)).toList();
      if(r.isNotEmpty) {
        lst.addAll(r);
      }
    }
    return lst;
  }

  ///
  Future<void> deleteInvById(int id) async {

    await openBox();
    if(_boxInv != null) {
      
      final has = _boxInv!.values.where((element) => element.id == id);
      if(has.isNotEmpty) {

        final fotos = List<Map<String, dynamic>>.from(has.first.fotos);
        _boxInv!.delete(has.first.key);
        for (var i = 0; i < fotos.length; i++) {
          final file = await MyIm.getImageByPath(fotos[i]['path']);
          if(file != null) {
            file.deleteSync();
          }
        }
      }
    }
  }

  ///
  Future<List<InventarioEntity>> getInvByIdsPiezas(List<int> idPiezas) async {

    List<InventarioEntity> lst = [];
    await openBox();
    if(_boxInv != null) {
      final lstTmp = _boxInv!.values.where((element) => idPiezas.contains(element.pieza));
      if(lstTmp.isNotEmpty) {
        lst = lstTmp.toList();
      }
    }
    return lst;
  }

  ///
  Future<InventarioEntity?> getInvByIdOrden(int idOrden) async {

    await openBox();
    if(_boxInv != null) {
      final lstTmp = _boxInv!.values.where((element) => element.idOrden == idOrden);
      if(lstTmp.isNotEmpty) {
        return lstTmp.first;
      }
    }
    return null;
  }

  ///
  Future<Map<String, dynamic>> getInfo() async {

    Map<String, dynamic> info = {
      'pzs': '0', 'fts': '0', 'kb': '0', 'mg':'0'
    };
    int pzas = 0;
    int fotos = 0;
    double kbs = 0.0;
    double mgs = 0;
    await openBox();
    if(_boxInv != null) {
      _boxInv!.values.map((i) {
        pzas++;
        fotos = fotos + i.fotos.length;
        for (var f = 0; f < i.fotos.length; f++) {
          kbs = kbs + double.parse('${i.fotos[f]['kb']}');
        }
      }).toList();

      mgs = (kbs/1000);
      info = {
        'pzs': '$pzas', 'fts': '$fotos',
        'kb': kbs.toStringAsFixed(2), 'mg': mgs.toStringAsFixed(2)
      };
    }

    return info;
  }

}