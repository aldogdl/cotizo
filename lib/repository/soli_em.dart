import 'package:cotizo/entity/no_tengo_entity.dart';

import 'acount_user_repository.dart';
import 'autos_repository.dart';
import 'inventario_repository.dart';
import 'no_tengo_repository.dart';
import 'ordenes_repository.dart';
import 'piezas_repository.dart';
import '../config/sngs_manager.dart';
import '../entity/orden_entity.dart';
import '../entity/autos_entity.dart';
import '../entity/marca_entity.dart';
import '../entity/modelo_entity.dart';
import '../entity/pieza_entity.dart';
import '../entity/inventario_entity.dart';
import '../vars/globals.dart';

class SoliEm {

  final _globals = getIt<Globals>();
  final oem  = OrdenesRepository();
  final _pem = PiezasRepository();
  final _aem = AutosRepository();
  final _iem = InventarioRepository();
  final _usEm= AcountUserRepository();
  final _ntEm= NoTengoRepository();

  // Usado para determinar si una orden fue hidratada y no estaba
  // incluida en la lista de cache. si es true, hay que agregarla.
  bool addToList = false;

  ///
  Future<void> initBoxes() async {

    await _pem.openBox();
    await _aem.openBox();
    await _ntEm.openBox();
  }

  /// Hidratamos la orden venida desde el servidor
  Future<List<OrdenEntity>> setOrdenFromServer(
    List<Map<String, dynamic>> data, List<OrdenEntity> currents) async 
  {
    await _pem.openBox();
    List<OrdenEntity> ords = [];
    for (var i = 0; i < data.length; i++) {
      final ord = await hidratarOrdenFull(data[i], currents);
      if(ord != null) {
        if(addToList) {
          ords.add(ord);
        }
      }
    }

    return ords;
  }

  ///
  Future<OrdenEntity?> hidratarOrdenFull(Map<String, dynamic> orden, List<OrdenEntity> currents) async {

    var ord = OrdenEntity();
    ord.id = orden['id'];
    final hasOrden = (currents.isEmpty)
      ? <OrdenEntity>[]
      : currents.where((element) => element.id == ord.id);
    
    if(hasOrden.isEmpty) {
      // Cuenta con piezas?
      if(orden.containsKey('piezas') && orden['piezas'].isNotEmpty) {
        // Hidratar piezas from server.
        ord = await hidratarPiezasFS(List<Map<String, dynamic>>.from(orden['piezas']), ord);
      }

      if(ord.piezas.isEmpty) { return null; }

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
      return hasOrden.first;
    }
  }

  /// Hidratamos los datos retornados desde el servidor
  Future<OrdenEntity> hidratarPiezasFS(List<Map<String, dynamic>> piezas, OrdenEntity ord) async {

    Map<int, List<String>> pzasFotos = {};
    Map<int, String> pzasObs = {};
    List<PiezaEntity> pzas = [];
   
    piezas = await cleanPzasIfHasEnInventario(piezas, ord.id);
    if(piezas.isEmpty){
      ord.piezas = [];
      return ord;
    }
    
    piezas = await cleanPzasIfNoTengo(piezas, ord.id);
    if(piezas.isEmpty){
      ord.piezas = [];
      return ord;
    }

    for (var p = 0; p < piezas.length; p++) {

      // Necesito pasarlo por los filtro para ver si el cotizador maneja esta pieza
      // TODO
      bool isPass = true; // esta sera la que indica si paso el filtro o no

      // Revisamos que la pieza no se encuentre entre el inventario
      if(_globals.invFilter.containsKey(ord.id)) {
        if(_globals.invFilter[ord.id]!.contains(piezas[p]['id'])) {
          isPass = false;
        }
      }

      if(isPass) {
        
        var pz = PiezaEntity();
        pz.fromServer(piezas[p]);
        final has = pzas.firstWhere(
          (pieza) => pieza.id == piezas[p]['id'], orElse: () => PiezaEntity()
        );
        if(has.id == 0) {
          pzas.add(pz);
          pzasFotos.putIfAbsent(pz.id, () => List<String>.from(piezas[p]['fotos']));
          pzasObs.putIfAbsent(
            pz.id, () => (piezas[p]['obs'].isEmpty) ? '0' : piezas[p]['obs']
          );
        }
      }
    }

    if(pzas.isNotEmpty) { ord.piezas = pzas; }
    if(pzasFotos.isNotEmpty) { ord.fotos = pzasFotos; }
    if(pzasObs.isNotEmpty) { ord.obs = pzasObs; }

    pzas = []; pzasFotos = {}; pzasObs = {};

    return ord;
  }

  /// Eliminamos de la lista de piezas todas aquellas que existan en el inventario
  Future<List<Map<String, dynamic>>> cleanPzasIfHasEnInventario
    (List<Map<String, dynamic>> piezas, int idOrd) async
  {
    if(_globals.invFilter.containsKey(idOrd)) {

      // Primero revisamos las piezas nuevas que nos mandan
      for (var i = 0; i < _globals.invFilter[idOrd]!.length; i++) {
        int indx = piezas.indexWhere((p) => p['id'] == _globals.invFilter[idOrd]![i]);
        if(indx != -1) {
          piezas.removeAt(indx);
        }
      }
    }
    return piezas;
  }

  /// Eliminamos de la lista de piezas todas aquellas que existan en el inventario
  Future<List<Map<String, dynamic>>> cleanPzasIfNoTengo
    (List<Map<String, dynamic>> piezas, int idOrd) async
  {
    // Primero revisamos las piezas nuevas que nos mandan
    piezas.map((e) async {
      final noT = await _ntEm.existeInBoxNoTengo(idOrd, e['id']);
      if(noT) {
        piezas.remove(e);
      }
    }).toList();

    return piezas;
  }

  ///
  Future<void> setNoTengo(int idOrd, int idPza, int idUser, {String fileSee = ''}) async {
    
    final nt = NoTengoEntity()
    ..idCot = idUser
    ..idOrd = idOrd
    ..idPza = idPza;
    await _ntEm.setBoxNoTengo(nt, fileSee: fileSee);
  }

  /// [COTIZADAS] Revisamos cada pieza de la orden para ver si existe en el inventario
  /// si existe la eliminamos y si la orden termina bacia retornamos null.
  /// [NO LA TENGO] Revisa que la pieza no este entre las marcadas como NO la TENGO
  Future<OrdenEntity?> cleanOrdenEmpty(OrdenEntity orden) async {

    // Primero revisamos las NO LA TENGO
    if(orden.piezas.isNotEmpty) {
      for (var i = 0; i < orden.piezas.length; i++) {
        final noT = await _ntEm.existeInBoxNoTengo(orden.id, orden.piezas[i].id);
        if(noT) {
          orden.piezas.removeAt(i);
        }
      }
    }
    
    if(orden.piezas.isEmpty) {
      return null;
    }

    if(!_globals.invFilter.containsKey(orden.id)) {
      return orden;
    }
    
    final pzasInInvent = _globals.invFilter[orden.id] ??= [];
    if(pzasInInvent.isNotEmpty) {
      for (var i = 0; i < pzasInInvent.length; i++) {
        int inx = orden.piezas.indexWhere((p) => p.id == pzasInInvent[i]);
        if(inx != -1) {
          orden.piezas.removeAt(inx);
        }
      }
      if(orden.piezas.isNotEmpty) {
        return orden;
      }
    }

    return null;
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
  PiezaEntity getPiezaById(int idPza) => _pem.getPzaById(idPza);

  ///
  Future<AutosEntity?> getAutoById(int idAuto) async => await _aem.getAutoById(idAuto);

  ///
  Future<MarcaEntity?> getMarcaById(int idMk) async => await _aem.getMarcaById(idMk);

  ///
  Future<ModeloEntity?> getModeloById(int idMd) async => await _aem.getModeloById(idMd);

  ///
  Future<Map<String, dynamic>> getDataAuto(int idAuto) async {

    Map<String, dynamic> tile = {};

    final auto = await getAutoById(idAuto);
    if(auto != null) {
      final marca = await getMarcaById(auto.marca);
      tile = {
        'logo':marca!.logo, 'marca':marca.nombre, 'idMrk': auto.marca,
        'isNac': auto.isNac
      };
    }
    
    return tile;
  } 

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
  Future<List<Map<String, dynamic>>> sortPerMoelos(List<OrdenEntity> ords) async {

    List<Map<String, dynamic>> sort = [];
    List<int> metidas = [];

    if(ords.isNotEmpty) {
      for (var i = 0; i < ords.length; i++) {
        final auto = await getAutoById(ords[i].auto);
        if(auto != null) {

          if(metidas.contains(auto.modelo)) {
            
            int indx = sort.indexWhere((element) => element['mdl'] == auto.modelo);
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
            final modelo = await getModeloById(auto.modelo);
            Map<String, dynamic> tile = {
              'logo':marca!.logo, 'marca':marca.nombre, 'idMrk': auto.marca,
              'modelo':modelo!.nombre, 'idMd': modelo.id,
              'cPzas': ords[i].piezas.length, 'isNac': auto.isNac,
              'ords': [ords[i].id], 'created': ords[i].createdAt
            };
            metidas.add(auto.modelo);
            Map<String, dynamic> mdl = {'mdl':auto.modelo, 'tile':tile};
            sort.add(mdl);
          }
        }
      }
    }
    metidas = [];
    return sort;
  }

  ///
  Future<InventarioEntity> getInvById(int id) async => await _iem.getInventarioById(id);

  ///
  Future<int> getIdUser() async => _usEm.getIdUser();
}