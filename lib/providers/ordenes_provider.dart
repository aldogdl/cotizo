import 'package:cotizo/entity/orden_entity.dart';
import 'package:flutter/foundation.dart' show ChangeNotifier;

class OrdenesProvider with ChangeNotifier {

  final int cantItemsPerPage = 10;
  int numberPage = 0;
  int indexFirsPerPage = 0;
  int indexLastPerPage = 0;

  List<OrdenEntity> _items = [];
  List<OrdenEntity> get items => _items;
  set items(List<OrdenEntity> its) {
    _items = its;
    //notifyListeners();
  }

  /// Guardamos los datos del primer y ultimo index recuperados para la lista
  setIndexResult(int idOrdenInit, int idOrdenFin) {
    indexFirsPerPage = items.indexWhere((element) => element.id == idOrdenInit);
    indexLastPerPage = items.indexWhere((element) => element.id == idOrdenFin);
  }
}