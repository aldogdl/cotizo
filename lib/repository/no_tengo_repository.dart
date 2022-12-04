import 'package:hive/hive.dart';

import '../entity/no_tengo_entity.dart';
import '../services/my_http.dart';
import '../vars/enums.dart';

class NoTengoRepository {

  final _http = MyHttp();

  final _boxName = HiveBoxs.noTengo.name;
  Box<NoTengoEntity>? _boxNt;

  ///
  Future<void> openBox() async {

    if(!Hive.isAdapterRegistered(noTengoHT)) {
      Hive.registerAdapter<NoTengoEntity>(NoTengoEntityAdapter());
    }

    if(!Hive.isBoxOpen(_boxName)) {
      _boxNt = await Hive.openBox<NoTengoEntity>(_boxName);
    }else{
      _boxNt = Hive.box<NoTengoEntity>(_boxName);
    }
  }

  ///
  Future<void> setBoxNoTengo(int idOrden, int idPza) async {

    await openBox();

    if(_boxNt != null) {

      final has = _boxNt!.values.where((i) => i.idOrd == idOrden);
      if(has.isNotEmpty) {
        if(!has.first.idPza.contains(idPza)) {
          has.first.idPza.add(idPza);
          await _boxNt!.put(has.first.key, has.first);
        }
      }else{
        final nt = NoTengoEntity()
        ..idOrd = idOrden
        ..idPza.add(idPza);
        await _boxNt!.add(nt);
      }
    }
  }

  ///
  Future<bool> existeInBoxNoTengo(int idOrd, int idPza) async {

    await openBox();
    if(_boxNt != null) {
      final has = _boxNt!.values.where((i) => i.idOrd == idOrd && i.idPza.contains(idPza));
      return (has.isEmpty) ? false : true;
    }
    return false;
  }

  ///
  Future<List<NoTengoEntity>> getAllNoTengo() async {

    await openBox();
    if(_boxNt != null) {
      if(_boxNt!.values.isNotEmpty) {
        return _boxNt!.values.toList();
      }
    }
    return <NoTengoEntity>[];
  }

  /// Recuperamos todos los no tengo del usuario y actualizamos
  /// su base de datos local
  Future<void> recoveryAllNtFromServer(String idCot) async {

    await _http.get('get_all_my_ntg', params: '/$idCot');
    if(!_http.result['abort']) {

      final content = _http.result['body'];
      Map<String, dynamic> filtros = {};
      if(content.isNotEmpty) {
        filtros = Map<String, dynamic>.from(_http.result['body']);
      }
      
      if(filtros.isNotEmpty) {

        await openBox();
        if(_boxNt != null) {

          if(_boxNt!.values.isNotEmpty) {
            if(!await _resetTable()){ return; }
          }

          List<int> listasOrd = [];
          filtros.forEach((idOrden, piezas) {

            List<int> pzas = [];
            final idS = List<String>.from(piezas);
            idS.map((e) {
              int? idN = int.tryParse(e);
              if(idN != null) {
                pzas.add(idN);
              }
            }).toList();

            if(pzas.isNotEmpty) {
              int? idO = int.tryParse(idOrden);
              if(idO != null) {
                if(!listasOrd.contains(idO)) {
                  final ntE = NoTengoEntity();
                  ntE.idOrd = idO;
                  ntE.idPza = pzas;
                  _boxNt!.add(ntE);
                }
                listasOrd.add(idO);
              }
            }
          });
        }
      }
    }
  }

  /// eliminamos por completo la tabla y la volvemos a crear
  Future<bool> _resetTable() async {

    await _boxNt!.clear();
    await _boxNt!.deleteFromDisk();
    await openBox();
    if(_boxNt != null) { return true; }
    return false;
  }

}