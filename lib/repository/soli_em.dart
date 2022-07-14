


import 'package:cotizo/entity/inventario_entity.dart';

import 'inventario_repository.dart';
import 'autos_repository.dart';
import 'ordenes_repository.dart';
import 'piezas_repository.dart';
import '../entity/orden_entity.dart';
import '../entity/autos_entity.dart';
import '../entity/marca_entity.dart';
import '../entity/modelo_entity.dart';
import '../entity/pieza_entity.dart';

class SoliEm {

  final oem = OrdenesRepository();
  final _pem = PiezasRepository();
  final _aem = AutosRepository();
  final _iem = InventarioRepository();

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
        // Hidratar piezas from server.
        ord = await hidratarPiezasFS(List<Map<String, dynamic>>.from(orden['piezas']), ord);
      }
      // Proceguimos con el auto
      if(ord.auto == 0) {
        // Hidratar auto from server.
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

  ///
  Future<List<Map<String, dynamic>>> sortPerMark(List<OrdenEntity> ords) async {

    List<Map<String, dynamic>> sort = [];
    List<int> metidas = [];

    if(ords.isNotEmpty) {
      for (var i = 0; i < ords.length; i++) {
        final auto = await getAutoById(ords[i].auto);
        if(auto != null) {

          if(metidas.contains(auto.marca)) {
            
            int indx = sort.indexWhere((element) => element['mrk'] == auto.marca);
            if(indx != -1) {
              final tite = Map<String, dynamic>.from(sort[indx]['tile']);
              tite['cPzas'] = tite['cPzas'] + ords[i].piezas.length;
              var ordenes = List<int>.from(tite['ords']);
              ordenes.add(ords[i].id);
              tite['ords'] = ordenes;
              sort[indx]['tile'] = tite;
            }
          }else{

            final marca = await getMarcaById(auto.marca);
            Map<String, dynamic> tile = {
              'logo':marca!.logo, 'marca':marca.nombre, 'idMrk': auto.marca,
              'cPzas': ords[i].piezas.length, 'isNac': auto.isNac,
              'ords': [ords[i].id], 'created': ords[i].createdAt
            };
            metidas.add(auto.marca);
            Map<String, dynamic> mrk = {'mrk':auto.marca, 'tile':tile};
            sort.add(mrk);
          }
        }
      }
    }
    metidas = [];
    return sort;
  }

  ///
  Future<InventarioEntity> getInvById(int id) async => await _iem.getInventarioById(id);
}