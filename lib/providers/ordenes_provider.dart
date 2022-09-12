import 'package:flutter/foundation.dart' show ChangeNotifier;

import '../entity/orden_entity.dart';
import '../repository/soli_em.dart';

class OrdenesProvider with ChangeNotifier {

  final solEm = SoliEm();
  final int cantItemsPerPage = 2;
  int numberPage = 0;
  String typeFilter = '';
  List<OrdenEntity> _items = [];
  List<OrdenEntity> items() => _items;
  setItems(List<OrdenEntity> its) {
    _items = its;
  }
  set addItem(OrdenEntity itm) {
    _items.add(itm);
  }
  
  ///
  Future<List<OrdenEntity>> fetchData(int page) async {

    if(page == 1 && items().isEmpty) {
      return await _fromServer();
    }

    if(numberPage != page) {
      if(page > numberPage) {
        return await _fromServer();
      }else{
        return await getRange(page: page);
      }
    }else{
      return await getRange(page: page);
    }
  }

  ///
  Future<List<OrdenEntity>> _fromServer() async {

    final result = await solEm.oem.getAllOrdenesAndPiezas(numberPage);
    solEm.oem.cleanResult();
    
    if(result.isNotEmpty) {
      return await toEntity(result);
    }
    return [];
  }

  ///
  Future<List<OrdenEntity>> getRange({int page = 1}) async {

    // Elimino las piezas de las ordenes que ya estan cotizadas
    List<OrdenEntity> newsOrd = [];
    for (var i = 0; i < _items.length; i++) {
      OrdenEntity? ord = await solEm.cleanOrdenEmpty(_items[i]);
      if(ord != null) {
        newsOrd.add(ord);
      }
    }
    return newsOrd;
  }

  ///
  Future<List<OrdenEntity>> toEntity(List<Map<String, dynamic>> ords) async {

    final response = await solEm.setOrdenFromServer(ords, _items);
    if(response.isNotEmpty) {
      setItems(response);
    }
    return response;
  }

  ///
  Future<void> setNoTengo(int idOrd, int idPza) async {
    await solEm.setNoTengo(idOrd, idPza);
  }

  /// SECC de ver ordenas por solicitud
  /// Utilizada para saber si es necesario filtrar las ordenes y mostrar solo las
  /// que se indiquen en esta variable.
  Map<String, dynamic> filterBySols = {};
  
}