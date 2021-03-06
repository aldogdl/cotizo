import 'package:cotizo/entity/orden_entity.dart';
import 'package:flutter/foundation.dart' show ChangeNotifier;

class OrdenesProvider with ChangeNotifier {

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

  /// Guardamos los datos del primer y ultimo index recuperados para la lista
  setIndexResult(int idOrdenInit, int idOrdenFin) {
    indexFirsPerPage = items().indexWhere((element) => element.id == idOrdenInit);
    indexLastPerPage = items().indexWhere((element) => element.id == idOrdenFin);
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