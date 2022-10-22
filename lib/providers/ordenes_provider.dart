import 'dart:math';

import 'package:flutter/foundation.dart' show ChangeNotifier;

import '../entity/pieza_entity.dart';
import '../entity/orden_entity.dart';
import '../repository/soli_em.dart';

class OrdenesProvider with ChangeNotifier {

  final solEm = SoliEm();
  final int cantItemsPerPage = 2;
  int numberPage = 0;
  String typeFilter = '';
  // Usado para mostrar un aviso de cotizacion en el estanque
  bool showAviso = false;
  // usado para saber de donde se saco la carnada (Marca, Modelos u Otros)
  String avisoFrom = '';
  /// La info. recuperada para atrapar al cotizador y no dejarlo salir del estanque
  Map<String, dynamic> carnada = {};
  // Es la info. necesaria para poder recuperar la carnada
  Map<String, dynamic> ansuelo = {};

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
  Future<OrdenEntity?> getParaNotificFromRange() async {

    // Elimino las piezas de las ordenes que ya estan cotizadas
    List<OrdenEntity> newsOrd = [];
    for (var i = 0; i < _items.length; i++) {
      OrdenEntity? ord = await solEm.cleanOrdenEmpty(_items[i]);
      if(ord != null) {
        newsOrd.add(ord);
      }
    }
    final ran = Random();
    final ind = ran.nextInt(newsOrd.length);
    OrdenEntity? ord;
    try {
      ord = newsOrd[ind];
    } catch (e) {
      return null;
    }
    return ord;
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
  Future<void> setNoTengo(int idOrd, int idPza, int idUser, {String fileSee = ''}) async
    => await solEm.setNoTengo(idOrd, idPza, idUser, fileSee: fileSee);

  /// SECC de ver ordenas por solicitud
  /// Utilizada para saber si es necesario filtrar las ordenes y mostrar solo las
  /// que se indiquen en esta variable.
  Map<String, dynamic> filterBySols = {};

  /// 
  Future<Map<String, dynamic>> fetchCarnada({
    required Map<String, dynamic> auto,
    required int idOrdCurrent, required int user}) async
  {

    String findedIn = '';
    OrdenEntity? hasOne;

    // Convertimos las ordenes en cache a Map. SIN TOMAR LA ORDEN ACTUAL
    //TODO Tambien necesitamos ver los filtros, si esta en inventario

    for (var i = 0; i < items().length; i++) {
      if(items()[i].id != idOrdCurrent) {
        final carr = await solEm.getAutoById(items()[i].auto);
        if(carr != null) {
          if('${carr.modelo}' == '${auto['md']}') {
            hasOne = items()[i];
            findedIn = 'Modelo';
            break;
          }
          if('${carr.marca}' == '${auto['mk']}') {
            hasOne = items()[i];
            findedIn = 'Marca';
            break;
          }
        }
      }
    }

    if(hasOne == null) {
      hasOne = items().firstWhere(
        (element) => element.id != idOrdCurrent, orElse: () => OrdenEntity()
      );
      if(hasOne.id == 0) {
        return {};
      }
      findedIn = 'Otros';
    }

    PiezaEntity? p;
    if(hasOne.piezas.isNotEmpty) {
      p = hasOne.piezas.first;
    }

    if(p != null) {

      String foto = '0';
      if(hasOne.fotos.containsKey(p.id)) {
        foto = hasOne.fotos[p.id]!.first;
      }
      return {
        'findedIn': findedIn,
        'pza': toMapPzaOfOrden(p, foto),
        'link': '${hasOne.id}-$user-${hasOne.avo}-pch'
      };
    }
    return {};
  }

  /// 
  Future<Map<String, dynamic>> fetchCarnadaSameOrden({
    required int idOrdCurrent, required int user, required int idPCurrent}) async
  {

    OrdenEntity hasOne = items().firstWhere(
      (element) => element.id == idOrdCurrent, orElse: () => OrdenEntity()
    );

    if(hasOne.id == idOrdCurrent) {

      PiezaEntity? p;
      final pzas = hasOne.piezas.where((element) => element.id != idPCurrent);
      if(pzas.isNotEmpty) {
        p = pzas.first;
      }

      if(p != null) {

        String foto = '0';
        if(hasOne.fotos.containsKey(p.id)) {
          if(hasOne.fotos[p.id] != null) {
            if(hasOne.fotos[p.id]!.isNotEmpty) {
              foto = hasOne.fotos[p.id]!.first;
            }
          }
        }
        return {
          'findedIn': 'Orden',
          'pza': toMapPzaOfOrden(p, foto),
          'link': '${hasOne.id}-$user-${hasOne.avo}-pch'
        };
      }
    }

    return {};
  }

  ///
  Map<String, dynamic> toMapPzaOfOrden(PiezaEntity pza, String foto) {
    return {
      'id': pza.id,
      'titulo': '${pza.piezaName} ${pza.posicion}',
      'subtitulo': '¿Tendrás esta pieza para vender?',
      'imgBig': foto
    };
  }
}