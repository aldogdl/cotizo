import 'package:hive_flutter/hive_flutter.dart';

import '../entity/orden_entity.dart';
import '../services/my_http.dart';
import '../services/my_paths.dart';
import '../vars/enums.dart';

class OrdenesRepository {

  final http = MyHttp();
  final _boxName = HiveBoxs.orden.name;
  Box<OrdenEntity>? _box;
  Box<OrdenEntity> get box => _box!;

  ///
  Map<String, dynamic> result = {'abort':false, 'msg':'ok', 'body':[]};
  void cleanResult() {
    result = {'abort':false, 'msg':'ok', 'body':[]};
  }

  ///
  Future<void> openBox() async {

    if(!Hive.isAdapterRegistered(ordenHT)) {
      Hive.registerAdapter<OrdenEntity>(OrdenEntityAdapter());
    }

    if(!Hive.isBoxOpen(_boxName)) {
      _box = await Hive.openBox<OrdenEntity>(_boxName, compactionStrategy: (entries, deletedEntries) {
        return deletedEntries > 50;
      });
    }else{
      _box = Hive.box<OrdenEntity>(_boxName);
    }
  }

  /// Recuperamos todas las ordenes y sus piezas paginadas
  Future<List<Map<String, dynamic>>> getAllOrdenesAndPiezas
    (int page, String userWhere, int cantPerPege, {String call = 'otro'}) async
  {
    await http.get('get_ordenes_and_piezas', params: '/$call/$page/$userWhere/$cantPerPege/');
    result = Map<String, dynamic>.from(http.result);
    http.cleanResult();
    if(!result['abort']) {
      if(result['body'].isNotEmpty) {
        return List<Map<String, dynamic>>.from(result['body']);
      }
    }
    return [];
  }

  /// Recuperamos todas las ordenes y sus piezas apartadas por el usuario
  Future<List<Map<String, dynamic>>> getApartadosByData(List<Map<String, dynamic>> ap) async {

    Uri uri = MyPath.getUri('get_piezas_apartadas', '');
    await http.post(uri, data: {'ap':ap});
    result = Map<String, dynamic>.from(http.result);
    http.cleanResult();
    if(!result['abort']) {
      if(result['body'].isNotEmpty) {
        return List<Map<String, dynamic>>.from(result['body']);
      }
    }
    return [];
  }

  /// 
  Future<Map<String, dynamic>> getAOrdenAndPieza(int idOrd, String userWhere) async {

    await http.get('get_orden_and_pieza', params: '/$idOrd/$userWhere');
    result = Map<String, dynamic>.from(http.result);
    http.cleanResult();
    if(!result['abort']) {
      if(result['body'].isNotEmpty) {
        return Map<String, dynamic>.from(result['body']);
      }
    }
    return {};
  }

  /// 
  Future<Map<String, dynamic>> fetchCarnadaFromServer(Map<String, dynamic> ansuelo) async {
    
    Uri uri = MyPath.getUri('fetch_carnada', '');
    await http.post(uri, data: ansuelo);
    result = Map<String, dynamic>.from(http.result);
    http.cleanResult();
    if(!result['abort']) {
      if(result['body'].isNotEmpty) {
        return Map<String, dynamic>.from(result['body']);
      }
    }
    return {};
  }

  ///
  Future<Map<String, dynamic>> uploadImgOfRespuesta(Map<String, dynamic> data) async {

    final uri = MyPath.getUri('upload_img_rsp', '');
    await http.upFileByData(uri, metas: data);
    return http.result;
  }

}