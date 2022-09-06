import 'package:flutter/foundation.dart' show ChangeNotifier;

import '../entity/orden_entity.dart';
import '../repository/soli_em.dart';

class OrdenesProvider with ChangeNotifier {

  final _solEm = SoliEm();
  final int cantItemsPerPage = 10;
  int numberPage = 0;
  int indexFirsPerPage = 0;
  int indexLastPerPage = 0;
  
  List<OrdenEntity> _items = [];
  List<OrdenEntity> items() => _items;
  setItems(List<OrdenEntity> its) {
    _items = its;
    //notifyListeners();
  }
  set addItem(OrdenEntity itm) {
    _items.add(itm);
    //notifyListeners();
  }
  
  ///
  Future<List<OrdenEntity>> toEntity(List<Map<String, dynamic>> ords) async {

    final response = await _solEm.setOrdenFromServer(ords, _items);
    if(response.isNotEmpty) {
      setItems(response);
      setIndexResult(response.first.id, response.last.id);
    }
    return response;
  }

  ///
  Future<void> setNoTengo(int idOrd, int idPza) async {
    await _solEm.setNoTengo(idOrd, idPza);
  }

  ///
  Future<List<OrdenEntity>> getRange() async {

    // Elimino las piezas de las ordenes que ya estan cotizadas
    List<OrdenEntity> newsOrd = [];

    for (var i = 0; i < _items.length; i++) {
      OrdenEntity? ord = await _solEm.cleanOrdenEmpty(_items[i]);
      if(ord != null) {
        newsOrd.add(ord);
      }
    }

    setItems(newsOrd);

    if(_items.isNotEmpty) {

      // Reguardamos los indices primero y ultimo en caso de haber visto alguna
      // modificacion en las ordenes.
      if(_items.length > cantItemsPerPage) {

        var perPage = _items.length / cantItemsPerPage;
        final res = perPage.toString();
        int? decena = int.tryParse(res.split('.')[0]);
        int? ultimosItems;
        if(res.contains('.')) {
          ultimosItems = int.tryParse(res.split('.')[1]);
        }

        numberPage = decena ?? 1;
        final prim = (numberPage * cantItemsPerPage) + 1;
        bool isSet = false;

        if(ultimosItems != null) {
          numberPage = (ultimosItems > 0) ? (numberPage + 1) : numberPage;
          if(ultimosItems > 0) {
            isSet = true;
            setIndexResult(_items[prim+1].id, _items[ultimosItems-1].id);
          }
        }

        if(!isSet) {
          final lstTmp = _items.getRange(prim+1, cantItemsPerPage+1).toList();
          setIndexResult(lstTmp.first.id, lstTmp.last.id);
        }

      }else{
        setIndexResult(_items.first.id, _items.last.id);
      }

    }else{
      indexFirsPerPage = 0;
      indexLastPerPage = 0;
    }
    if(_items.isNotEmpty) {
      return _items.getRange(indexFirsPerPage, indexLastPerPage+1).toList();
    }
    return [];
  }

  /// Guardamos los datos del primer y ultimo index recuperados para la lista
  setIndexResult(int idOrdenInit, int idOrdenFin) {
    indexFirsPerPage = _items.indexWhere((element) => element.id == idOrdenInit);
    indexLastPerPage = _items.indexWhere((element) => element.id == idOrdenFin);
  }

  /// SECC de ver ordenas por solicitud
  /// Utilizada para saber si es necesario filtrar las ordenes y mostrar solo las
  /// que se indiquen en esta variable.
  Map<String, dynamic> filterBySols = {};
  
  /// Usado para cambiar el icono de ver inventario | ir a home
  bool _isShowHome = false;
  bool get isShowHome => _isShowHome;
  set isShowHome(bool isHome) {
    _isShowHome = isHome;
    notifyListeners();
  }
}