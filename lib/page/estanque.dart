import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'cotizar_page.dart';
import '../config/sngs_manager.dart';
import '../entity/pieza_entity.dart';
import '../entity/orden_entity.dart';
import '../entity/share_data_orden.dart';
import '../providers/ordenes_provider.dart';
import '../providers/gest_data_provider.dart';
import '../services/my_get.dart';
import '../services/pop_app.dart';
import '../vars/globals.dart';
import '../vars/constantes.dart';
import '../widgets/bg_img_pzas.dart';
import '../widgets/show_dialogs.dart';
import '../widgets/aviso_atencion.dart';
import '../widgets/ascaffold_main.dart';
import '../widgets/mensajes/dialogs.dart';
import '../widgets/tile_orden_pieza.dart';

class Estanque extends StatefulWidget {

  final String idOrden;
  const Estanque({
    Key? key,
    required this.idOrden,
  }) : super(key: key);

  @override
  State<Estanque> createState() => _EstanqueState();
}

class _EstanqueState extends State<Estanque> {

  final _globals = getIt<Globals>();
  final _scrollCtr = ScrollController();
  final _ds = SharedDataOrden();
  final _showAviso = ValueNotifier<bool>(false);
  final _searchCarnada = ValueNotifier<bool>(true);
  final _idDeOrden = ValueNotifier<int>(0);

  OrdenesProvider? _ordProv;
  OrdenEntity? _orden;
  bool _isIni = false;
  bool _isShowDialogWorking = false;
  bool _isFromApartadosCarnada = false;
  int _idOrd    = 0;
  int _indexOrd = -1;
  int _idPzaSel = 0;
  String _from  = '';
  String _segmento = 'normal';
  
  @override
  void dispose() {
    _scrollCtr.dispose();
    _showAviso.dispose();
    _searchCarnada.dispose();
    _idDeOrden.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;

    return AscaffoldMain(
      body: SizedBox(
        width: size.width, height: size.height,
        child: BGImgPzas(
          bgColor: Colors.black,
          child: Column(
            children: [
              Container(
                color: _globals.bgAppBar,
                child: _titulo(),
              ),
              ValueListenableBuilder<bool>(
                valueListenable: _showAviso,
                builder: (_, show, __) => _avisoCotizaTmp()
              ),
              Expanded(
                child: ValueListenableBuilder<bool>(
                valueListenable: _searchCarnada,
                  builder: (_, isSearch, __) =>
                    (isSearch) ? _buscarCarnada() : _lstPzas()
                ),
              )
            ],
          )
        )
      )
    );
  }

  ///
  Widget _titulo() {

    return Row(
      children: [
        _containerTit(
          bg: const Color.fromARGB(255, 92, 50, 47),
          child: _btnSalirEstanque()
        ),
        const Spacer(),
        _containerTit(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Row(
                  children: [
                    const Text(
                      'PIEZAS DE LA ORDEN ',
                      textScaleFactor: 1,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.03,
                        color: Color.fromARGB(255, 100, 96, 96)
                      ),
                    ),
                    ValueListenableBuilder<int>(
                      valueListenable: _idDeOrden,
                      builder: (_, i, __) {

                        return Text(
                          '  #$i',
                          textScaleFactor: 1,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.03,
                            color: Color.fromARGB(255, 161, 161, 161)
                          ),
                        );
                      }
                    )
                  ],
                ),
              ),
            ],
          )
        ),
      ],
    );
  }

  ///
  Widget _btnSalirEstanque() {

    return IconButton(
      padding: const EdgeInsets.all(0),
      constraints: const BoxConstraints(
        maxHeight: 23
      ),
      visualDensity: VisualDensity.compact,
      iconSize: 23,
      onPressed: () async {
        final popApp = PopApp();
        await popApp.onWill(context);
      },
      icon: const Icon(
        Icons.close,
        color: Color.fromARGB(255, 255, 176, 176)
      )
    );
  }
  
  ///
  Widget _containerTit({required Widget child, Color? bg}) {

    bg ??= _globals.bgMain;

    return Container(
      margin: const EdgeInsets.only(
        top: 0, left: 10, right: 10, bottom: 15
      ),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10)
      ),
      child: child
    );
  }

  ///
  Widget _lstPzas() {

    final sep = (_orden!.piezas.length > 1) ? 8.0 : 0.0;

    return ListView.separated(
      controller: _scrollCtr,
      separatorBuilder: (_, __) => SizedBox(height: sep),
      padding: const EdgeInsets.all(10),
      itemCount: _orden!.piezas.length,
      itemBuilder: (_, int index) {

        if(_globals.invFilter.isNotEmpty) {
          if(_globals.invFilter.containsKey(_orden!.id)) {
            if(_globals.invFilter[_orden!.id]!.contains(_orden!.piezas[index].id)) {
              return const SizedBox(height: 0);
            }
          }
        }

        if(_orden!.piezas[index].piezaName == _orden!.piezas[index].avAt) {
          return const AvisoAtencion();
        }
        return _piezaTile(index);
      }
    );
  }

  ///
  Widget _piezaTile(int indexPza) {

    final idPza = _orden!.piezas[indexPza].id;
    
    if(_orden != null) {
      return TileOrdenPieza(
        idOrden: _orden!.id,
        idAuto: _orden!.auto,
        pieza: _orden!.piezas[indexPza],
        created: _orden!.createdAt,
        fotos: (_orden!.fotos.containsKey(idPza))
          ? List<String>.from(_orden!.fotos[idPza]!) : <String>[],
        requerimientos: _orden!.obs[idPza]!,
        box: _ds,
        onCot: (int idP) async => _showPageCotizar(idP),
        onNtg: (int idP) async => await _setNoTengo(idP),
        onApartar: (_ordProv!.isFromApartados || _isFromApartadosCarnada)
          ? null
          : (idP) => _apartarPza(_orden!.id, idPza),
      );
    }

    return const SizedBox();
  }

  ///
  Widget _avisoCotizaTmp() {

    if(!_showAviso.value) { return const SizedBox(); }

    String titulo = '¡Aprovecha y vende más...! ${DialogsOf.icon('fine')}';
    String aviso = 'Encontramos piezas para un auto ';
    const sub = 'similar al que acabas de cotizar';

    if(_ordProv != null) {
      switch (_ordProv!.avisoFrom) {
        case 'Marca':
          aviso = '$aviso de una ${ _ordProv!.avisoFrom } $sub.';
          break;
        case 'Modelo':
          aviso = '$aviso de un ${ _ordProv!.avisoFrom } $sub.';
          break;
        case 'Orden':
          aviso = 'Encontramos piezas para la misma ORDEN ID: $_idOrd.';
          break;
        default:
          aviso = '$aviso que posiblemente también tengas.';
      }
    }

    if(_isFromApartadosCarnada) {
      titulo = 'SIN MÁS COINCIDENCIAS ${DialogsOf.icon('bell')}';
      aviso = 'Este auto lo encontramos entre tu LISTA DE APARTADOS. '
      'Si estás preparado.\n¿Te gustaría Cotizarlo?';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _globals.secMain,
          border: Border.all(color: _globals.colorBurbbleResp),
          borderRadius: BorderRadius.circular(5)
        ),
        child: Column(
          children: [
            Text(
              titulo,
              textScaleFactor: 1,
              style: const TextStyle(
                color: Colors.green,
                fontSize: 20
              ),
            ),
            const Divider(color: Colors.grey),
            Text(
              aviso,
              textScaleFactor: 1,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 17
              ),
            )
          ],
        ),
      ),
    );
  }

  ///
  Widget _buscarCarnada() {

    return SizedBox.expand(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.3,
            height: MediaQuery.of(context).size.width * 0.3,
            child: Stack(
              alignment: Alignment.center,
              fit: StackFit.expand,
              children: const [
                CircularProgressIndicator(
                  strokeWidth: 5,
                ),
                Icon(Icons.search, size: 70, color: Color.fromARGB(255, 77, 77, 77))
              ],
            )
          ),
          const SizedBox(height: 10),
          StreamBuilder<String>(
            stream: _searchCarnadaStream(),
            initialData: '...',
            builder: (_, AsyncSnapshot snap) {

              return Text(
                snap.data,
                style: const TextStyle(
                  color: Color.fromARGB(255, 103, 138, 255)
                ),
              );
            }
          ),
          const SizedBox(height: 20),
          const Text(
            'UN MOMENTO POR FAVOR',
            style: TextStyle(
              color: Colors.white
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'ORDENANDO DATOS PARA TI',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 18
            ),
          ),
        ],
      )
    );
  }

  ///
  Stream<String> _searchCarnadaStream() async* {

    final nav = GoRouter.of(context);
    if (!mounted) { return; }

    if(!_isIni) {
      _isIni = true;
      Mget.init(context, context.read<GestDataProvider>());
      _ordProv = context.read<OrdenesProvider>();
      // _from tiene afuerza que estar indicado, ya que se llega aqui por link o home
      if(widget.idOrden.contains('-')) {
        // Llegada por home
        _isShowDialogWorking = true;
        // Future.microtask(() => ScreenWorking.show(context));
        final partes = widget.idOrden.split('-');
        _idOrd = int.parse(partes.first);
        _idPzaSel = int.parse(partes.last);
        _from  = WhereReg.seh.name;
      }else{
        // Llegada por link o push
        _from = WhereReg.sel.name;
        _idOrd = (_idOrd == 0) ? int.parse(widget.idOrden) : _idOrd;
      }
    }

    bool goHome = false;
    yield 'Acomplando Solicitud';
    await Future.delayed(const Duration(milliseconds: 250));

    await _fechOrden();
    if(_orden != null && _indexOrd != -1) {

      yield 'Ensamblando Referencia';
      await Future.delayed(const Duration(milliseconds: 250));
      // Crear ANSUELO
      await _ordProv!.buildAnsuelo(_orden!.id, _orden!.auto, _indexOrd);

      if(await _fetchPieza() != -1) {

        yield 'Buscando Coinsidencias';
        await Future.delayed(const Duration(milliseconds: 250));

        _globals.pushIn = await _ordProv!.fetchCarnada(_idPzaSel);
        // colocamos un Aviso de Atención cuando no se venga de HOME
        final pzasSinAviso = _orden!.piezas.indexWhere((p) => p.piezaName == p.avAt);
        if(pzasSinAviso == -1) {
          final pSep = PiezaEntity();
          _orden!.piezas.insert(1, pSep.avisoAtencion());
        }

        yield 'Notificando Servicio';
        await Future.delayed(const Duration(milliseconds: 250));
        if(_ordProv!.carnada != null && _ordProv!.carnada!.findedIn != 'same') {
          _ordProv!.makeRegOf('see', _from);
        }
        
      }else{

        yield 'Sin más Piezas...';
        await Future.delayed(const Duration(milliseconds: 250));
        goHome = true;
      }

    }else{
      yield 'No se encontró la orden Solicitada';
      await Future.delayed(const Duration(milliseconds: 1000));
      goHome = true;
    }

    if(goHome) {

      yield 'Gracias por tu Atención';
      await Future.delayed(const Duration(milliseconds: 1000));
      yield 'Redirigiendote a HOME';
      _ordProv!.initApp = true;
      _ordProv!.currentSeccion = 'por piezas';
      await Future.delayed(const Duration(milliseconds: 500), (){
        nav.go('/home');
      });

    }else{

      _idDeOrden.value = _idOrd;
      await Future.delayed(const Duration(milliseconds: 250));
      _searchCarnada.value = false;
      if(_from == WhereReg.seca.name) {
        _showAviso.value = true;
      }

      if(_isShowDialogWorking) {
        _isShowDialogWorking = false;
        Future.delayed(const Duration(milliseconds: 500), (){
          _showPageCotizar(_idPzaSel);
        });
      }
    }
  }

  ///
  Future<void> _fechOrden() async {

    if(_indexOrd != -1){ return; }

    _segmento = 'normal';
    _indexOrd = _ordProv!.items().indexWhere((ord) => ord.id == _idOrd);
    if(_indexOrd == -1) {
      _segmento = 'apartados';
      _indexOrd = _ordProv!.apartados().indexWhere((ord) => ord.id == _idOrd);
    }

    if(_indexOrd > -1) {

      final dataMap = (_segmento == 'normal')
        ? _ordProv!.items()[_indexOrd].toJson()
        : _ordProv!.apartados()[_indexOrd].toJson();

      // Hacemos una copia de la orden encontrada
      _orden = OrdenEntity()..of(dataMap);

      // Datos de Registro
      if(_ordProv!.idsDataRegistro.isEmpty) {
        _ordProv!.setDataReg(
          from: _from, id: _orden!.id, user: _globals.idUser, avo: _orden!.avo
        );
      }

    }else{
      _orden = null;
    }
  }

  ///
  Future<int> _fetchPieza() async {

    int indexPza = 0;
    // _idPzaSel si es igual a cero, es que viene desde link
    if(_idPzaSel != 0) {
      indexPza = _orden!.piezas.indexWhere((p) => p.id == _idPzaSel);
    }else{
      _idPzaSel = _orden!.piezas.first.id;
    }
    return indexPza;
  }

  ///
  Future<void> _showPageCotizar(int idP) async {

    final nav = Navigator.of(context);
    if(_orden == null) {
      if(nav.canPop()) { nav.pop(); }
      context.go('/home');
      return;
    }
    _isFromApartadosCarnada = false;

    await showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      enableDrag: false, isDismissible: false, isScrollControlled: true,
      builder: (_) => MediaQuery(
        data: MediaQueryData.fromWindow(WidgetsBinding.instance.window),
        child: CotizarPage(
          idOrden: _orden!.id,
          idP: idP,
          onExit: (int res) async {

            if(nav.canPop()) { nav.pop(); }
            if(context.read<GestDataProvider>().isMakeCot) {
              await _deletePiezaOrdenCurrent(
                idP, deleteAllPzas: (res == 2) ? true : false
              );
            }
          }
        )
      )
    );
  }

  ///
  Future<void> _apartarPza(int idO, int idPza) async {

    bool deleteAllPzas = false;
    _isFromApartadosCarnada = false;
    _ordProv!.setApartar(idO, _globals.idUser, idPza, WhereReg.apr.name).then((res) async {
      
      if(res == 0) { return; }

      // Significa que la orden tiene mas de una pieza
      if(res == 2) {
        bool? acc = await ShowDialogs.alert(
          context, 'aparta',
          hasActions: true,
          labelNot: 'SOLO ESTA PIEZA',
          labelOk: 'SI, TODAS',
        );

        if(acc != null){
          res = await _ordProv!.setApartar(idO, _globals.idUser, idPza, WhereReg.apr.name, all: acc);
          deleteAllPzas = (res == 4) ? true : false;
        }
      }

      await _deletePiezaOrdenCurrent(idPza, deleteAllPzas: deleteAllPzas);
    });

  }

  ///
  Future<void> _setNoTengo(int idP) async {

    _isFromApartadosCarnada = false;
    // Borramos la pieza indicada y su avisos.
    final res = await _ordProv!.setNoTengo(
      _orden!.id, _globals.idUser, idP, Constantes.parseFrom(_from, 'nt')
    );
    if(res > 0) {
      await _deletePiezaOrdenCurrent(idP, deleteAllPzas: (res == 2) ? true : false);
    }
  }

  ///
  Future<void> _deletePiezaOrdenCurrent(int idP, {bool deleteAllPzas = false}) async {

    if(deleteAllPzas) {
      _orden!.piezas.clear();
      if(_ordProv!.carnada != null) {
        if(_ordProv!.carnada!.idOrd == _orden!.id) {
          _ordProv!.carnada = null;
        }
      }
    }else{
      _orden!.piezas.removeWhere((p) => p.id == idP);
      _orden!.piezas.removeWhere((p) => p.id == idP && p.piezaName == p.avAt);
    }

    await _cleanValues(
      idOrd: (_ordProv!.carnada != null) ? _ordProv!.carnada!.idOrd : 0
    );
    _showAviso.value = false;
    _searchCarnada.value = true;
  }

  ///
  Future<void> _cleanValues({int idOrd = 0}) async {

    if(idOrd == 0 && _ordProv!.carnada == null) {
      final has = await _ordProv!.fetchCarnadaFromApartados();
      if(has != -1 && _ordProv!.carnada != null) {
        idOrd = _ordProv!.carnada!.idOrd;
        _isFromApartadosCarnada = true;
      }
    }

    _idOrd = idOrd;
    _idPzaSel = 0;
    _indexOrd = -1;
    _orden = null;
    _from = WhereReg.seca.name;
    _isShowDialogWorking = false;
    _ordProv!.carnada = null;
    _ordProv!.idsDataRegistro = {};
  }

}