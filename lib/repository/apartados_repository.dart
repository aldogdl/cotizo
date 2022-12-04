import 'package:hive/hive.dart';

import '../entity/apartados_entity.dart';
import '../services/my_http.dart';
import '../vars/enums.dart';

class ApartadosRepository {

  final _http = MyHttp();

  final _boxName = HiveBoxs.apartados.name;
  Box<ApartadosEntity>? _boxAp;

  ///
  Future<void> openBox() async {

    if(!Hive.isAdapterRegistered(apartadosHT)) {
      Hive.registerAdapter<ApartadosEntity>(ApartadosEntityAdapter());
    }

    if(!Hive.isBoxOpen(_boxName)) {
      _boxAp = await Hive.openBox<ApartadosEntity>(_boxName);
    }else{
      _boxAp = Hive.box<ApartadosEntity>(_boxName);
    }
  }

  ///
  Future<void> setBox(int idOrden, int idPza) async {

    await openBox();

    if(_boxAp != null) {

      final has = _boxAp!.values.where((i) => i.idOrd == idOrden);
      if(has.isNotEmpty) {
        if(!has.first.idPza.contains(idPza)) {
          has.first.idPza.add(idPza);
          await _boxAp!.put(has.first.key, has.first);
        }
      }else{
        final nt = ApartadosEntity()
        ..idOrd = idOrden
        ..idPza.add(idPza);
        await _boxAp!.add(nt);
      }
    }
  }

  ///
  Future<List<ApartadosEntity>> getAllApartado() async {

    await openBox();
    if(_boxAp != null) {      
      return (_boxAp!.values.isNotEmpty) ? _boxAp!.values.toList() : [];
    }
    return [];
  }

  ///
  Future<bool> existeInBox(int idOrd, int idPza) async {

    await openBox();
    if(_boxAp != null) {
      final has = _boxAp!.values.where((i) => i.idOrd == idOrd && i.idPza.contains(idPza));
      return (has.isEmpty) ? false : true;
    }
    return false;
  }

  /// Recuperamos todos los no tengo del usuario y actualizamos
  /// su base de datos local
  Future<void> recoveryFromServer(String idCot) async {

    await _http.get('get_all_my_ntg', params: '/$idCot');
    if(!_http.result['abort']) {

      final filtros = Map<String, dynamic>.from(_http.result['body']);
      
      if(filtros.isNotEmpty) {

        await openBox();
        if(_boxAp != null) {

          if(_boxAp!.values.isNotEmpty) {
            if(!await resetTable()){ return; }
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
                  final ntE = ApartadosEntity();
                  ntE.idOrd = idO;
                  ntE.idPza = pzas;
                  _boxAp!.add(ntE);
                }
                listasOrd.add(idO);
              }
            }
          });
        }
      }
    }
  }

  /// Eliminamos por completo la tabla y la volvemos a crear
  Future<bool> resetTable() async {

    await openBox();
    await _boxAp!.clear();
    await _boxAp!.deleteFromDisk();
    await openBox();
    if(_boxAp != null) { return true; }
    return false;
  }

  /// Eliminamos la pieza de apartados
  Future<void> deletePiezaApartadosById(int idOrden, int idP) async {

    await openBox();
    if(_boxAp != null) {

      if(idOrden > 0 && idP > 0) {
        final ent = _boxAp!.values.where((ap) => ap.idOrd == idOrden);
        if(ent.isNotEmpty) {
          ent.first.idPza.remove(idP);
          if(ent.first.idPza.isEmpty) {
            ent.first.delete();
          }
          _boxAp!.flush();
        }
      }
    }
  }

  /// Eliminamos la pieza de apartados
  Future<int> getCantApartados() async {

    int total = 0;
    await openBox();
    if(_boxAp != null) {
      if(_boxAp!.values.isNotEmpty) {
        _boxAp!.values.map((a){
          total = total + a.idPza.length;
        }).toList();
      }
    }
    return total;
  }

  /// Eliminamos la orden completa de apartados
  Future<void> deleteOrdenApartadosById(int idOrden) async {

    await openBox();
    if(_boxAp != null) {      
      if(idOrden > 0) {
        final ent = _boxAp!.values.where((ap) => ap.idOrd == idOrden);
        if(ent.isNotEmpty) {
          ent.first.delete();
          _boxAp!.flush();
        }
      }
    }
  }
}