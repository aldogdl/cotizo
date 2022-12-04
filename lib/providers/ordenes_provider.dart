import 'dart:math';
import 'package:flutter/foundation.dart' show ChangeNotifier, compute;

import '../entity/apartados_entity.dart';
import '../entity/push_in_entity.dart';
import '../entity/ansuelo_entity.dart';
import '../entity/pieza_entity.dart';
import '../entity/orden_entity.dart';
import '../services/get_conectivity.dart';
import '../services/isolates/task_server_isolate.dart';
import '../repository/soli_em.dart';
import '../vars/constantes.dart';

class OrdenesProvider with ChangeNotifier {

  final solEm = SoliEm();
  int cantItemsPerPage = 6;
  int numberPage = 0;
  Map<String, dynamic> _typeFilter = {
    'current': '', 'select': '', 'from': 'none'
  };
  Map<String, dynamic> get typeFilter => _typeFilter;
  set typeFilter(Map<String, dynamic> typeF) {
    _typeFilter = typeF;
    notifyListeners();
  }
  void typeFilterClean() {
    typeFilter = {'current': '', 'select': '', 'from': 'none'};
  }

  /// Usado para enviar al usuario a apartados en caso de que halla al iniciar la app
  bool initApp = false;
  /// Usado para saber si el usuario presiono el btn de atras del dispositivo
  /// con la finalidad de ver si hay algun filtro y borrarlo.
  int oldValBackDevice = 0;
  int _pressBackDevice = 0;
  int get pressBackDevice => _pressBackDevice;
  set pressBackDevice(int n) {
    _pressBackDevice = n;
    notifyListeners();
  }

  /// Grbamos la ultima posicion del scroll del infinityList principal de piezas
  double pixelsScrollM = 0;
  /// Grbamos la ultima posicion del scroll del infinityList del Inventario
  double pixelsScrollI = 0;

  /// usado para saber de donde se saco la carnada (Marca, Modelos u Otros)
  String avisoFrom = '';
  /// Los datos obtenidos desde el servidor con relacion a la paginacion
  Map<String, dynamic> dataPag = {};
  /// Usado para saber de donde se toman los items si del servidor o de cache
  String getItemsFrom = '';
  /// Usado para saber de donde se toman los items si del servidor o de cache
  bool isFromApartados = false;
  /// Usado para saber en que pestaña se encuentra el usuario si en solicitudes
  /// apartados o inventario.
  String currentSeccion = 'por piezas';
  /// Usado para regresar al usuario a la pestaña de solicitudes, cuendo este
  /// presiona el btn de back del dispositivo.
  int lastChangeToSeccion = 0;
  int _changeToSeccion = 0;
  int get changeToSeccion => _changeToSeccion;
  set changeToSeccion(int to) {
    _changeToSeccion = to;
    notifyListeners();
  }
  /// SECC de ver ordenes por solicitud
  /// Utilizada para saber si es necesario filtrar las ordenes y mostrar solo las
  /// que se indiquen en esta variable.
  Map<String, dynamic> filterBySols = {};

  /// El tipo de coneccion detectada a internet en el dipositivo
  String conect = 'movile';
  /// Es la info. necesaria para conocer el tipo de auto que se esta cotizando,
  /// con estos datos podemos recuperar otra orden parecida para crear la carnada
  AnsueloEntity? ansuelo;
  /// La info. recuperada para atrapar al cotizador y no dejarlo salir del estanque
  PushInEntity? carnada;
  /// Estos son los ids recuperados necesarios para realizar registros de 
  /// see, ntg, etc.
  Map<String, dynamic> idsDataRegistro = {};
  void setDataReg
    ({
      required String from, required int id, required int user, required int avo,
      String idCamp = '0', String idP = '0'
    })
  {
    idsDataRegistro = {
      'from': from, 'id': id, 'user': user, 'avo': avo,
      'idCamp': idCamp, 'idP': idP
    };
  }

  /// Las ordenes listadas en HOME
  final List<OrdenEntity> _items = [];
  List<OrdenEntity> items() => _items;
  set addItem(OrdenEntity itm) { _items.add(itm); }
  setItems(List<OrdenEntity> its) {

    for (var i = 0; i < its.length; i++) {
      final has = _items.indexWhere((o) => o.id == its[i].id);
      if(has != -1) {
        if(its[i].piezas.length != _items[has].piezas.length) {
          _items[has].piezas = its[i].piezas;
        }
      }else{
        _items.add(its[i]);
      }
    }
  }

  /// Numero de solicitudes marcadas como No tengo.
  int noTengoCant = 0;
  /// Cantida de apartados para mostrar una marquita en el titulo de la pestaña
  int _cantApartados = 0;
  int get cantApartados => _cantApartados;
  set cantApartados(int c) {
    _cantApartados = c;
    notifyListeners();
  }
  /// Las ordenes listadas en APARTADOS
  List<OrdenEntity> _apartados = [];
  List<OrdenEntity> apartados() => _apartados;
  setApartados(List<OrdenEntity> its) {
    _apartados = its;
  }
  set addApartados(OrdenEntity itm) {

    final has = _apartados.indexWhere((a) => a.id == itm.id);
    if(has != -1) {
      itm.piezas.map((e) {
        final hp = _apartados[has].piezas.where((p) => p.id == e.id).toList();
        if(hp.isEmpty) {
          _apartados[has].piezas.add(e);
        }
      }).toList();
    }else{
      _apartados.add(itm);
    }
  }

  ///
  Future<List<OrdenEntity>> fetchData(int page, String idUser, {String call = 'otro'}) async {

    //await solEm.resetApartado();
    bool ir = true;
    if(page == 1 && _items.isEmpty) { numberPage = 1;  ir = false; }

    if(page > numberPage) { numberPage = page; ir = false; }

    // Eliminamos todos las marcas de fechas.
    _items.removeWhere((o) => o.est == o.itemFecha);
    if(ir) {
      getItemsFrom = 'cache';
      return _items;
    }else{
      return await _fromServer(idUser, call);
    }
  }

  ///
  Future<List<OrdenEntity>> _fromServer(String idUser, String call) async {

    conect = await GetConectivity.device();
    cantItemsPerPage = (conect == 'wifi') ? 19 : 6;
    
    final result = await solEm.oem.getAllOrdenesAndPiezas(
      numberPage, idUser, cantItemsPerPage, call: call
    );
    if(!solEm.oem.result['abort']) {
      dataPag = Map<String, dynamic>.from(solEm.oem.result['msg']);
    }
    solEm.oem.cleanResult();
    if(result.isNotEmpty) {
      return await toEntity(result);
    }
    return [];
  }

  ///
  Future<List<OrdenEntity>> fetchApartadosFromServer(List<Map<String, dynamic>> ap) async {

    final ords = await solEm.oem.getApartadosByData(ap);
    
    solEm.oem.cleanResult();
    
    if(ords.isNotEmpty) {
      final response = await solEm.setOrdenFromServer(ords, _apartados);
      if(response.isNotEmpty) {
        response.map((e) => addApartados = e).toList();
      }
    }
    cantApartados = await solEm.getCantApartados();
    return _apartados;
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
  Future<List<OrdenEntity>> toEntity(List<Map<String, dynamic>> ords) async {

    var response = await solEm.setOrdenFromServer(ords, _items);
    response = await cleanPzasIfHasApartados(response);
    response = await cleanPzasIfHasNoTengo(response);

    if(response.isNotEmpty) {
      setItems(response);
    }
    return response;
  }

  /// Necesitamos revisar cual esta en apartados.
  Future<List<OrdenEntity>> cleanPzasIfHasApartados(List<OrdenEntity> response) async {

    if(response.isEmpty){ return []; }
    
    final allAp = await solEm.getAllApartado();
    if(allAp.isNotEmpty) {

      for (var i = 0; i < allAp.length; i++) {

        final ordenS = response.indexWhere((o) => o.id == allAp[i].idOrd);
        if(ordenS != -1) {

          // Removemos los anuncion de atencion
          response[ordenS].piezas.removeWhere((p) => p.piezaName == p.avAt);

          final eap = OrdenEntity();
          eap.of(response[ordenS].toJson());
          // Recorremos cada pieza para ver cual es la que esta apartada
          for (var p = 0; p < allAp[i].idPza.length; p++) {
            final pAp = eap.piezas.indexWhere((pz) => pz.id == allAp[i].idPza[p]);
            if(pAp == -1) {
              // No esta entre las apartadas, la eliminamos
              eap.piezas.removeWhere((pz) => pz.id == allAp[i].idPza[p]);
            }else{
              // Si esta entre las apartadas, la eliminamos de la lista main
              response[ordenS].piezas.removeWhere((pz) => pz.id == allAp[i].idPza[p]);
            }
          }

          addApartados = eap;
          if(response[ordenS].piezas.isEmpty) {
            response.removeAt(ordenS);
          }
        }
      }
    }

    for (var i = 0; i < response.length; i++) {
      OrdenEntity? ord = await solEm.cleanOrdenEmpty(response[i]);
      if(ord == null) {
        response.removeAt(i);
      }        
    }
    cantApartados = await solEm.getCantApartados();
    return response;
  }

  /// Necesitamos revisar cual esta en apartados.
  Future<List<OrdenEntity>> cleanPzasIfHasNoTengo(List<OrdenEntity> response) async {

    if(response.isEmpty){ return []; }
    
    noTengoCant = 0;
    final allNt = await solEm.getAllNoTengo();
    if(allNt.isNotEmpty) {

      for (var i = 0; i < allNt.length; i++) {

        final ordenS = response.indexWhere((o) => o.id == allNt[i].idOrd);
        if(ordenS != -1) {

          // Removemos los anuncion de atencion
          response[ordenS].piezas.removeWhere((p) => p.piezaName == p.avAt);

          // Recorremos cada pieza para ver cual es la que esta en No Tengo
          for (var p = 0; p < allNt[i].idPza.length; p++) {
            final pNt = response[ordenS].piezas.indexWhere((pz) => pz.id == allNt[i].idPza[p]);
            if(pNt != -1) {
              // Si esta entre las Ntartadas, la eliminamos de la lista main
              response[ordenS].piezas.removeAt(pNt);
            }else{
              noTengoCant = noTengoCant +1;
            }
          }
          
          if(response[ordenS].piezas.isEmpty) {
            response.removeAt(ordenS);
          }
        }
      }
    }

    for (var i = 0; i < response.length; i++) {
      OrdenEntity? ord = await solEm.cleanOrdenEmpty(response[i]);
      if(ord == null) {
        response.removeAt(i);
      }        
    }

    return response;
  }

  ///
  Future<void> buildAnsuelo(int idOrd, int idAuto, int index) async {
    ansuelo = await AnsueloEntity().buildAnsuelo(idOrd, idAuto, index);
  }
  
  /// Construimos el nombre del archivo para enviar un tipo de registro see | ntg
  String getFileOf(String tipo, String from) {

    if(idsDataRegistro.isNotEmpty) {

      if(idsDataRegistro['from'].isEmpty) {
        if(from.isEmpty) {
          idsDataRegistro['from'] = 'unknow';
        }else{
          idsDataRegistro['from'] = from;
        }
      }

      final i = Map<String, dynamic>.from(idsDataRegistro);
      idsDataRegistro = {};
      final ext = '__${DateTime.now().millisecondsSinceEpoch}.$tipo';
      if(i['idP'] == '0') {
        return '${i['from']}__${i['id']}-${i['user']}-${i['avo']}cc${i['idCamp']}$ext';
      }else{
        return '${i['from']}__${i['id']}-${i['user']}-${i['avo']}pp${i['idP']}$ext';
      }
    }
    return '';
  }

  /// [RETURN] 0 si no encontramos la orden en cache,
  /// [RETURN] 1 si todo bien y la orden hay mas piezas
  /// [RETURN] 2 si la orden tambien se borro por falta de piezas
  Future<int> setNoTengo(int idO, int user, int idPza, String from) async {

    int ordenS = -1;
    String callFrom = 'normal';
    OrdenEntity? orden;
    
    ordenS = _items.indexWhere((o) => o.id == idO);
    if(ordenS == -1) {
      callFrom = 'apartados';
      ordenS = _apartados.indexWhere((o) => o.id == idO);
      if(ordenS != -1) {
        orden = _apartados[ordenS];
      }
    }else{
      orden = _items[ordenS];
    }

    if(orden == null) { return 0; }

    setDataReg(
      from: from, id: orden.id, user: user, avo: orden.avo,
      idCamp: '0', idP: '$idPza'
    );
    await solEm.setNoTengo(idO, idPza);

    if(callFrom == 'normal') {
      _items[ordenS].piezas.removeWhere((p) => p.id == idPza);
      _items[ordenS].piezas.removeWhere((p) => p.id == idPza && p.piezaName == p.avAt);
    }else{
      await solEm.deletePiezaApartadosById(_apartados[ordenS].id, idPza);
      _apartados[ordenS].piezas.removeWhere((p) => p.id == idPza);
      cantApartados = await solEm.getCantApartados();
    }

    orden = null;
    noTengoCant = noTengoCant + 1;
    // Si la orden queda sin piezas eliminarla
    final deleteOrden = await deleteOrdenIfEmpty(idO);
    makeRegOf('ntg', from);
    return (deleteOrden) ? 2 : 1;
  }

  /// Agregamos a la lista de apartados una pieza y su orden correspondiente
  /// [RETURN] 0 si no encontramos la orden en cache,
  /// [RETURN] 1 si todo bien, 2 en caso de que la orden tenga mas de 1 pza.
  /// [RETURN] 2 en caso de que la orden tenga mas de 1 pza.
  /// [RETURN] 3 si se selecciono apartar 1 pieza en caso de aber mas
  /// [RETURN] 4 si se borro todas pzas.
  Future<int> setApartar(int idO, int user, int idPza, String from, {bool? all}) async {

    int res = 1;
    final ordenS = _items.indexWhere((o) => o.id == idO);
    if(ordenS == -1) { return 0; }

    // Removemos los anuncion de atencion
    _items[ordenS].piezas.removeWhere((p) => p.piezaName == p.avAt);

    String idsP = '$idPza';
    final ispz = <int>[idPza];

    // Revisamos si hay mas de una pieza quitando los avisos de atencion
    if(all == null) {
      if(_items[ordenS].piezas.length > 1) {
        return 2;
      }else{
        all = false;
      }
    }else{
      if(all) {
        _items[ordenS].piezas.map((e) {
          if(!ispz.contains(e.id)) {  ispz.add(e.id); }
        }).toList();
        idsP = ispz.join('-');
      }
    }

    setDataReg(
      from: from, id: _items[ordenS].id, user: user, avo: _items[ordenS].avo,
      idCamp: '0', idP: idsP
    );
    
    for (var i = 0; i < ispz.length; i++) {
      await solEm.setApartado(idO, ispz[i]);
    }

    // Creo una copia de la orden y sus piezas sin avisos de atencion
    final eap = OrdenEntity();
    eap.of(_items[ordenS].toJson());

    // All indica si es false que solo apartemos una pieza.
    if(!all) {
      final pE =  _items[ordenS].piezas.where((p) => p.id == idPza);
      eap.piezas = [pE.first];
      // Eliminamos la que enviamos a apartados
      _items[ordenS].piezas.removeWhere((p) => p.id == idPza);
      _items[ordenS].piezas.removeWhere((p) => p.id == idPza && p.piezaName == p.avAt);
      res = 3;
    }else{
      _items[ordenS].piezas.clear();
      res = 4;
    }
    addApartados = eap;

    // Si la orden queda sin piezas eliminarla
    await deleteOrdenIfEmpty(idO);
    makeRegOf('pap', from);
    cantApartados = await solEm.getCantApartados();
    return res;
  }

  /// Eliminar la orden que quede sin piezas
  Future<bool> deleteOrdenIfEmpty(int idO) async {

    // Borramos todo los aviso de fechas.
    String segmento = 'normal';
    int ordenS = _items.indexWhere((o) => o.id == idO);
    if(ordenS == -1) {
      segmento = 'apartados';
      ordenS = _apartados.indexWhere((o) => o.id == idO);
    }

    if(ordenS == -1) { return true; }

    // Si la orden queda sin piezas, necesitamos eliminar tambien la orden
    if(segmento == 'normal') {

      _items[ordenS].piezas.removeWhere((p) => p.piezaName == p.avAt);
      if(_items[ordenS].piezas.isEmpty) {
        _items.removeAt(ordenS);
        return true;
      }
    }else{

      _apartados[ordenS].piezas.removeWhere((p) => p.piezaName == p.avAt);
      if(_apartados[ordenS].piezas.isEmpty) {
        int idOrd = _apartados[ordenS].id;
        _apartados.removeAt(ordenS);
        await solEm.deleteOrdenApartadosById(idOrd);
        return true;
      }
    }
    return false;
  }

  /// por medio de background guardamos los archivos de registros en SR
  /// los cuales son de tipo see o ntg
  void makeRegOf(String tipo, String from) {
    try {
      compute(setRegOf, getFileOf(tipo, from));
    } catch (_) {}
  }

  /// Buscamos una carnada
  Future<Map<String, dynamic>> fetchCarnada(int idPza) async {

    carnada = null;
    int hasOne = -1;

    // Esenarios para tomar carnada
    // 1.- Si la orden que se esta en pantall cuenta con mas piezas entoncen
    // la carnada es la otra pieza de la misma orden
    hasOne = await _fetchCarnadaSameOrden(idPza);

    if(hasOne == -1){

      // 2.- Si viene de apartados tomar carnada de apartados.
      if(currentSeccion == 'apartados') {
        hasOne = await fetchCarnadaFromApartados();
      }
      
      if(hasOne == -1) {
        
        // 3.- Si hay un filtro o viene de home, tomar carnada normal
        hasOne = await _fetchCarnadaFromCache();
        if(hasOne < 1) {
          // Si en cache no hay carnada, buscamos en el servidor.
          await _fetchCarnadaFromServer();
        }

        if(carnada != null) {
          carnada!.titulo = 'Me VENDES esta Autoparte!';
        }
      }
    }

    if(carnada != null) { return carnada!.toJson(); }

    return {};
  }

  /// Al llegar aqui es por que ya hay un ansuelo en memoria
  /// return -1 si no hay ordenes o no se encontro carnada else envio 1 de ok
  Future<int> _fetchCarnadaSameOrden(int idPza) async
  {
    int hasOne = -1;
    OrdenEntity? itemTmp;

    if(currentSeccion == 'apartados') {
      hasOne = _apartados.indexWhere((a) => a.id == ansuelo!.ido && a.est != a.itemFecha);
      if(hasOne != -1) {
        itemTmp = _apartados[hasOne];
      }
    }else{
      hasOne = _items.indexWhere((a) => a.id == ansuelo!.ido && a.est != a.itemFecha);
      if(hasOne != -1) {
        itemTmp = _items[hasOne];
      }
    }

    if(hasOne == -1) { return hasOne; }

    // Revisamos si hay mas piezas aparte de la que esta en pantalla
    final morePzas = itemTmp!.piezas.where(
      (p) => p.id != idPza && p.piezaName != p.avAt
    ).toList();
 
    if(morePzas.isNotEmpty) {
      final carr = await solEm.getAutoById(itemTmp.auto);
      if(carr != null) {
        final c = PushInEntity();
        carnada = c.fromOrden(itemTmp, ansuelo!.ct, hasOne);
        if(currentSeccion == 'apartados') {
          carnada!.titulo = 'Pendiente para Cotizar';
        }else{
          carnada!.titulo = 'Me VENDES esta Autoparte!';
        }
        carnada!.findedIn = 'Same';
      }else{
        hasOne = -1;
      }
    }else{
      hasOne = -1;
    }

    return hasOne;
  }

  /// Al llegar aqui es por que ya hay un ansuelo en memoria
  /// return -1 si no hay ordenes o no se encontro carnada else envio 1 de ok
  Future<int> fetchCarnadaFromApartados() async {

    String findedIn = 'Otros';
    int hasOne = -1;
    int indexOrd = -1;
    OrdenEntity? ordenFind;
    final c = PushInEntity();
    
    List<OrdenEntity> apartadosTmp = _apartados.where(
      (a) => a.id != ansuelo!.ido && a.est != a.itemFecha
    ).toList();

    if(apartadosTmp.isNotEmpty) {

      final carr = await solEm.getAutoById(apartadosTmp.first.auto);
      if(carr != null) {
        hasOne = 1;
        indexOrd = 0;
        ordenFind = apartadosTmp.first;
        if(carr.modelo == ansuelo!.md) { findedIn = 'Modelo'; }
        if(carr.marca == ansuelo!.mk) { findedIn = 'Marca'; }
      }

    }else{

      if(apartados().isEmpty) {

        final aprt = await solEm.getAllApartado();
        if(aprt.isNotEmpty) {

          ApartadosEntity? opOne;

          for (var i = 0; i < aprt.length; i++) {
            if(aprt[i].idOrd != ansuelo!.ido) {

              indexOrd = i;
              if(i == 0) { opOne = aprt[i]; }
              if(_items.isNotEmpty) {
                final has = _items.where((o) => o.id == aprt[i].idOrd);
                if(has.isNotEmpty) {
                  hasOne = 1;
                  ordenFind = has.first;
                  break;
                }
              }
            }
          }

          if(ordenFind == null && opOne != null) {

            // Recuperar la primera opcion desde el server.
            final user = solEm.getIdUser();
            final result = await solEm.oem.getAOrdenAndPieza(opOne.idOrd, '$user::${WhereReg.apr.name}');
            solEm.oem.cleanResult();
            final laOrden = Map<String, dynamic>.from(result);
            ordenFind = await solEm.hidratarOrdenFull(laOrden, apartados());
            if(ordenFind.piezas.isNotEmpty) {
              hasOne = 1;
              if(solEm.addToList) { addApartados = ordenFind; }
              indexOrd = _apartados.indexWhere((a) => a.id == opOne!.idOrd);
            }
            cantApartados = await solEm.getCantApartados();
          }
        }
      }
    }

    if(hasOne == 1) {
      carnada = c.fromOrden(ordenFind!, ansuelo!.ct, indexOrd);
      carnada!.findedIn = findedIn;
      carnada!.titulo = 'Pendiente para Cotizar';
    }

    apartadosTmp = [];
    return hasOne;
  }

  /// Al llegar aqui es por que ya hay un ansuelo en memoria
  /// return -1 si no hay ordenes en cache | 0 si no se encontro carnada | 1 ok
  Future<int> _fetchCarnadaFromCache() async {

    String findedIn = '';
    int hasOne = -1;

    if(_items.isNotEmpty) {

      // Convertimos las ordenes en cache a Map. SIN TOMAR LA ORDEN ACTUAL
      for (var i = 0; i < _items.length; i++) {

        int hasApartado = _apartados.indexWhere((a) => a.id == _items[i].id);
        if(_items[i].id != ansuelo!.ido && hasApartado == -1 && _items[i].est != _items[i].itemFecha) {

          final carr = await solEm.getAutoById(_items[i].auto);
          if(carr != null) {
            if(carr.modelo == ansuelo!.md) {
              hasOne = i;
              findedIn = 'Modelo';
              break;
            }
            if(carr.marca == ansuelo!.mk) {
              hasOne = i;
              findedIn = 'Marca';
              break;
            }
          }
        }
      }

      if(hasOne == -1) { return 0; }
      final c = PushInEntity();
      carnada = c.fromOrden(_items[hasOne], ansuelo!.ct, hasOne);
      carnada!.findedIn = findedIn;

      return 1;
    }

    return -1;
  }

  /// Al llegar aqui es por que ya hay un ansuelo en memoria
  Future<void> _fetchCarnadaFromServer() async
  {
    final ordenCarnada = await solEm.fetchCarnadaFromServer(ansuelo!.toJson());

    if(ordenCarnada.isNotEmpty) {
      final hasApartados = _apartados.indexWhere((a) => a.id == ordenCarnada['orden']['id']);
      if(hasApartados != -1) { return; }

      final orden = await solEm.hidratarOrdenFull(ordenCarnada['orden'], _items);
      if(orden.piezas.isEmpty) { return; }
      
      int indexInsert = 0;
      if(solEm.addToList) {
        _items.insert(indexInsert, orden);
      }else{
        indexInsert = _items.indexWhere((o) => o.id == ordenCarnada['orden']['id']);
      }
      final c = PushInEntity();
      carnada = c.fromOrden(_items[indexInsert], ansuelo!.ct, indexInsert);
    }

    return;
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