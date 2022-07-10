
import 'package:cotizo/entity/autos_entity.dart';
import 'package:cotizo/entity/marca_entity.dart';
import 'package:cotizo/entity/modelo_entity.dart';

import 'autos_repository.dart';
import 'ordenes_repository.dart';
import 'piezas_repository.dart';
import '../entity/orden_entity.dart';
import '../entity/pieza_entity.dart';

class SoliEm {

  final oem = OrdenesRepository();
  final _pem = PiezasRepository();
  final _aem = AutosRepository();

  // Usado para determinar si una orden fue hidratada y no estaba
  // incluida en la lista de cache. si es true, hay que agregarla.
  bool addToList = false;

  ///
  Future<void> initBoxes() async {

    await oem.openBox();
    await _pem.openBox();
    await _aem.openBox();
  }

  /// Hidratamos la orden venida desde el servidor
  Future<List<OrdenEntity>> setOrdenFromServer(
    List<Map<String, dynamic>> data, List<OrdenEntity> currents
  ) async {

    await oem.openBox();
    await _pem.openBox();
    List<OrdenEntity> ords = [];

    for (var i = 0; i < data.length; i++) {
      final ord = await hidratarOrdenFull(data[i], currents);
      ords.add(ord);
    }

    return ords;
  }

  ///
  Future<OrdenEntity> hidratarOrdenFull(Map<String, dynamic> orden, List<OrdenEntity> currents) async {

    var ord = OrdenEntity();
    final has = currents.where((element) => element.id == orden['id']);
    if(has.isEmpty) {
      // Cuenta con piezas?
      if(orden.containsKey('piezas') && orden['piezas'].isNotEmpty) {
        ord = await hidratarPiezasFS(List<Map<String, dynamic>>.from(orden['piezas']), ord);
      }
      // Proceguimos con el auto
      if(ord.auto == 0) {
        ord = await hidratarAutoFS(orden, ord);
      }
      ord.fromServer(orden);
      addToList = true;
      return ord;
    }else{
      addToList = false;
      return has.first;
    }
  }

  /// Hidratamos los datos retornados desde el servidor
  Future<OrdenEntity> hidratarPiezasFS(List<Map<String, dynamic>> piezas, OrdenEntity ord) async {

    List<int> pzas = [];
    Map<int, List<String>> pzasFotos = {};
    Map<int, String> pzasObs = {};

    for (var p = 0; p < piezas.length; p++) {
  
      // Necesito pasarlo por los filtro para ver si el cotizador maneja esta pieza
      // TODO
      bool isPass = true; // esta sera la que indica si paso el filtro o no
      if(isPass) {
        var has = await _pem.existe(piezas[p]['piezaName']);
        if(has != null) {
          // Si existe pieza solo incrementamos su cantidad
          has.cant = has.cant +1;
          has.save();
        }else{
          has = PiezaEntity();
          has.fromServer(piezas[p]);
          _pem.box.add(has);
        }
        pzas.add(has.id);
        pzasFotos.putIfAbsent(has.id, () => List<String>.from(piezas[p]['fotos']));
        pzasObs.putIfAbsent(has.id, () => piezas[p]['obs']);
      }
    }

    if(pzas.isNotEmpty) { ord.piezas = pzas; }
    if(pzasFotos.isNotEmpty) { ord.fotos = pzasFotos; }
    if(pzasObs.isNotEmpty) { ord.obs = pzasObs; }

    pzas = []; pzasFotos = {}; pzasObs = {};

    return ord;
  }

  /// Hidratamos los datos del auto de la orden
  Future<OrdenEntity> hidratarAutoFS(Map<String, dynamic> orden, OrdenEntity ord) async {

    await _aem.openBox();
    final has = await _aem.existe(orden);
    if(has != null) {
      has.cant = has.cant +1;
      has.save();
      ord.auto = has.id;
    }else{
      ord.auto = await _aem.saveAutoInLocal(orden);
    }
    return ord;
  }

  ///
  Future<PiezaEntity?> getPiezaById(int idPza) async => await _pem.getPzaById(idPza);

  ///
  Future<AutosEntity?> getAutoById(int idAuto) async => await _aem.getAutoById(idAuto);

  ///
  Future<MarcaEntity?> getMarcaById(int idMk) async => await _aem.getMarcaById(idMk);

  ///
  Future<ModeloEntity?> getModeloById(int idMd) async => await _aem.getModeloById(idMd);

}