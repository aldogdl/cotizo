import 'package:cotizo/entity/orden_entity.dart';
import 'package:cotizo/services/my_http.dart';
import 'package:hive/hive.dart';

import '../vars/enums.dart';

class OrdenesRepository {

  final http = MyHttp();

  final _boxName = HiveBoxs.orden.name;
  Box<OrdenEntity>? _box;

  ///
  Map<String, dynamic> result = {'abort':false, 'msg':'ok', 'body':[]};
  void cleanResult() {
    result = {'abort':false, 'msg':'ok', 'body':[]};
  }

  ///
  Future<void> openBox() async {

    if(!Hive.isAdapterRegistered(8)) {
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
  Future<List<Map<String, dynamic>>> getAllOrdenesAndPiezas(int page) async {

    result = await http.get('get_ordenes_and_piezas', params: '/$page/');
    if(!result['abort']) {
      if(result['body'].isNotEmpty) {
        return List<Map<String, dynamic>>.from(result['body']);
      }
    }
    return [];
  }

  /// Recuperamos todas las ordenes y sus piezas paginadas
  Future<Map<String, dynamic>> getAOrdenAndPieza(int idOrd, String nameFile) async {

    result = await http.get('get_orden_and_pieza', params: '/$idOrd&$nameFile/');
    if(!result['abort']) {
      if(result['body'].isNotEmpty) {
        return Map<String, dynamic>.from(result['body']);
      }
    }
    return {};
  }
}