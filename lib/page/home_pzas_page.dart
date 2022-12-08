import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../entity/pieza_entity.dart';
import '../config/sngs_manager.dart';
import '../entity/orden_entity.dart';
import '../entity/share_data_orden.dart';
import '../providers/ordenes_provider.dart';
import '../repository/push_in_repository.dart';
import '../vars/globals.dart';
import '../vars/constantes.dart' show WhereReg;
import '../widgets/aviso_atencion.dart';
import '../widgets/empty_list_indicator.dart';
import '../widgets/filtro/btns_filter.dart';
import '../widgets/tile_orden_pieza.dart';
import '../widgets/show_dialogs.dart';
import '../widgets/filtro/lst_items_filtros.dart';

class HomePzasPage extends StatefulWidget {

  const HomePzasPage({ Key? key }) : super(key: key);

  @override
  State<HomePzasPage> createState() => _HomePzasPageState();
}

class _HomePzasPageState extends State<HomePzasPage> {

  final _showFilter = ValueNotifier<int>(0);
  final _globals = getIt<Globals>();
  final _pushIn = PushInRepository();
  late final ValueNotifier<double> _sizeFilter;

  final _scrollCtrFilter = ScrollController();
  late final PagingController _pagingController;

  final altoFilters = 95.0;
  final List<int> _inserAvIn = [];
  late OrdenesProvider _ords;
  bool _isInit = false;
  bool _isLoad = false;
  int pageCurrent = 0;
  List<OrdenEntity> _lstfiltrada = [];

  @override
  void initState() {

    _sizeFilter = ValueNotifier<double>(0);
    _pagingController = PagingController<int, OrdenEntity>(firstPageKey: 1)
      ..addPageRequestListener(_fetchPage);
    WidgetsBinding.instance.addPostFrameCallback(_initWidget);
    super.initState();
  }

  @override
  void dispose() {
    _showFilter.dispose();
    _sizeFilter.dispose();
    _pagingController.dispose();
    _scrollCtrFilter.removeListener(_scrollListener);
    _scrollCtrFilter.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {

    return LayoutBuilder(
      builder: (_, restrics) {

        return SizedBox(
          width: restrics.maxWidth,
          height: restrics.maxHeight,
          child: Stack(
            children: [
              ValueListenableBuilder<int>(
                valueListenable: _showFilter,
                builder: (_, verFilter, __) {
                  switch (verFilter) {
                    case 1:
                      return _lstFiltrada();
                    case 2:
                      return _lstFiltrada();
                    default:
                      return _lstInfinity();
                  }
                },
              ),
              Positioned(
                bottom: 0, right: 0, left: 0,
                child: ValueListenableBuilder<double>(
                  valueListenable: _sizeFilter,
                  builder: (_, tam, __) => _filtros(tam),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  ///
  Widget _filtros(double tam) {

    return AnimatedContainer(
      height: tam,
      duration: const Duration(milliseconds: 200),
      child: BtnsFilter(
        altoFilters: altoFilters,
        onPress: (sel) async {

          switch (sel) {
            case 'todas':
              pageCurrent = 1;
              _ords.numberPage = 1;
              _ords.filterBySols.clear();
              _lstfiltrada = [];
              _showFilter.value = 0;
              await _fetchPage(pageCurrent);
              break;
            case 'ordenes':
              // _ords.typeFilter = {
              //   'current': 'ordenes', 'select': 'ordenes', 'from':'none'
              // };
              // _showFilter.value = 2;
              await _showModalfilter(sel);
              break;
            default:
              await _showModalfilter(sel);
          }
        }
      ),
    );
  }

  /// Visualizamo todas las piezas que han sido filtradas por marcas o modelos
  Widget _lstFiltrada() {

    if(_lstfiltrada.isEmpty) {
      return const EmptyListIndicator(from: 'filter');
    }
    
    return ListView.builder(
      controller: _scrollCtrFilter,
      itemCount: _lstfiltrada.length,
      padding: const EdgeInsets.all(10),
      itemBuilder: (BuildContext context, int index) {
        return _sortPerPiezas(_lstfiltrada[index], index);
      },
    );
  }

  /// Mostramos todas las piezas sin filtros
  Widget _lstInfinity() {

    return RefreshIndicator(
      onRefresh: () async => await _refreshComplete(),
      child: PagedListView.separated(

        pagingController: _pagingController,
        scrollController: _scrollCtrFilter,
        padding: const EdgeInsets.all(10),
        builderDelegate: PagedChildBuilderDelegate<dynamic>(
          itemBuilder: (_, orden, index) => _sortPerPiezas(orden, index),
          noItemsFoundIndicatorBuilder: (_) => const EmptyListIndicator(),
          noMoreItemsIndicatorBuilder: (_) => _totales(),
          firstPageErrorIndicatorBuilder: (_) => EmptyListIndicator(
            error: _pagingController.error.toString().toLowerCase(),
            onTray: (_) => _refreshComplete()
          ),
        ),
        separatorBuilder: (context, index) => const SizedBox(height: 5)
      )
    );
  }

  ///
  Widget _sortPerPiezas(OrdenEntity orden, int index) {

    if(orden.est == 'indicador') {
      return _indicadorDeFecha(orden);
    }

    if(orden.piezas.isEmpty) {
      return const SizedBox(height: 0);
    }

    int indexPza = -1;
    return Column(
      children: orden.piezas.map((pza) {
        
        if(pza.piezaName == pza.avAt) {
          return const AvisoAtencion();
        }
        indexPza = indexPza + 1;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: TileOrdenPieza(
            pieza: pza,
            idAuto: orden.auto,
            idOrden: orden.id,
            created: orden.createdAt,
            callFrom: 'home',
            fotos: (orden.fotos.containsKey(pza.id))
              ? List<String>.from(orden.fotos[pza.id]!) : <String>[],
            requerimientos: orden.obs[pza.id]!,
            box: SharedDataOrden(),
            onCot: (int idP) => context.go('/estanque/${orden.id}-$idP'),
            onNtg: (Map<String, dynamic> data) async => await _setNoTengo(orden.id, data),
            onApartar: (idP) async => await _apartarPza(orden.id, idP),
          )
        );
      }).toList(),
    );
  }

  ///
  Widget _indicadorDeFecha(OrdenEntity orden) {

    String fecha = 'HOY';
    if(orden.stt == 'fech') {
      final d = '${orden.createdAt.day}'.padLeft(2, '0');
      final m = '${orden.createdAt.month}'.padLeft(2, '0');
      fecha = 'A partir del: $d-$m-${orden.createdAt.year}';
    }
    if(orden.stt == 'ayer') {
      fecha = 'Del día de AYER';
    }
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Center(
        child: Container(
          margin: const EdgeInsets.only(top: 10),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: _globals.colorBurbbleResp,
            borderRadius: BorderRadius.circular(25)
          ),
          child: Text(
            fecha,
            textScaleFactor: 1,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white
            ),
          ),
        ),
      ),
    );
  }

  ///
  Widget _totales() {

    int pzas = 0;
    _ords.items().map((o) {
      if(o.est != o.itemFecha) {
        final pzs = o.piezas.where((p) => p.piezaName != p.avAt);
        pzas = pzas + pzs.length;
      }
    }).toList();

    final conType = (_ords.conect == 'wifi') ? 'WiFi' : 'Datos';
    
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.black
      ),
      child: Column(
        children: [
          _row(label: 'Total de Solicitudes:', value: '${_ords.dataPag['total']}'),
          _row(label: 'Total de Páginas:', value: '${_ords.dataPag['tpages']}'),
          _row(label: 'Piezas por Página: [$conType]', value: '${_ords.cantItemsPerPage}'),
          _row(label: 'Piezas Listadas:', value: '$pzas'),
          _row(label: 'Piezas Apartadas:', value: '${_ords.apartados().length}'),
          _row(label: 'Piezas No Tengo:', value: '${_ords.noTengoCant}'),
        ],
      ),
    );
  }

  ///
  Widget _row({required String label, required String value}) {

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          const Icon(Icons.arrow_forward_ios_outlined, color: Colors.greenAccent, size: 12,),
          const SizedBox(width: 5),
          Text(
            label,
            textScaleFactor: 1,
            textAlign: TextAlign.left,
            style: const TextStyle(
              fontSize: 17,
              color: Color.fromARGB(255, 100, 100, 100),
              fontWeight: FontWeight.normal
            ),
          ),
          const Spacer(),
          Text(
            '[ ${value.padLeft(2, '0')} ]',
            textScaleFactor: 1,
            textAlign: TextAlign.left,
            style: const TextStyle(
              fontSize: 16,
              color: Color.fromARGB(255, 87, 91, 114),
              fontWeight: FontWeight.bold
            ),
          ),
        ]
      ),
    );
  }

  ///
  Future<void> _setNoTengo(int idO, Map<String, dynamic> data) async {

    final res = await _ords.setNoTengo(
      idO, _globals.idUser, data['idPza'], data['from']
    );

    if(res > 0) {
      if(_pagingController.itemList != null && _pagingController.itemList!.isNotEmpty) {
        final ind = _pagingController.itemList!.indexWhere((o) => o.id == idO);
        if(ind != -1) {
          _pagingController.itemList![ind].piezas.removeWhere((p) => p.id == data['idPza']);
          _pagingController.itemList![ind].piezas.removeWhere(
            (p) => p.id == data['idPza'] && p.piezaName == p.avAt
          );
          if(_pagingController.itemList![ind].piezas.isEmpty) {
            _pagingController.itemList!.removeAt(ind);
            _ords.items().removeWhere((o) => o.id == idO);
          }
        }
      }
      
      _isOnFilterRefresh(idO, data['idPza']);
    }
  }

  ///
  Future<void> _apartarPza(int idO, int idPza) async {

    _ords.setApartar(idO, _globals.idUser, idPza, WhereReg.apr.name).then((res) async {
      
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
          // Apartamos en DB y eliminamos de cache la pieza
          await _ords.setApartar(idO, _globals.idUser, idPza, WhereReg.apr.name, all: acc);
        }
      }

      _isOnFilterRefresh(idO, idPza);
      
    });

  }

  /// Usamos este metodo para refrescar pantalla detectando si esstamos en un
  /// determinado filtro, si no es asi, refrescamos el controlador de la lista
  /// infinita.
  void _isOnFilterRefresh(int idO, int idPza) {

    bool refreshInfinity = true;

    if(_lstfiltrada.isNotEmpty) {
      
      refreshInfinity = false;
      if(_ords.typeFilter['select'].isNotEmpty) {
        final hasOrd = _lstfiltrada.indexWhere((o) => o.id == idO);
        if(hasOrd != -1) {
          _lstfiltrada[hasOrd].piezas.removeWhere((p) => p.id == idPza);
          if(_lstfiltrada[hasOrd].piezas.isEmpty) {
            _lstfiltrada.removeAt(hasOrd);
            _ords.filterBySols.clear();
          }
        }
      }

      // La _lstfiltrada es para guardar las ordenes que cumplen con los criteros
      // de filtro por marca y modelo, SI NO ESTA BACIA, ES QUE ESTAMOS VIENDO
      // ORDENES FILTRADAS.
      if(_lstfiltrada.isEmpty) {
        _showFilter.value = 0;
        _ords.typeFilterClean();
        refreshInfinity = true;
      }
      
      if(!refreshInfinity  && _showFilter.value == 1) {
        if(mounted) { setState(() { }); }
      }
    }

    if(refreshInfinity) {
      if(mounted) {
        _showFilter.value = 0;
        _ords.typeFilterClean();
        Future.delayed(const Duration(milliseconds: 250), () {
          if(mounted) {
            _pagingController.refresh();
          }
        });
      }
    }
    
    _showFiltrosWidget();
  }

  ///
  Future<void> _showModalfilter(String filtro) async {
    
    await showModalBottomSheet(
      context: context,
      backgroundColor: Globals().secMain,
      builder: (_) {
        _ords.typeFilter['from'] = 'none';
        return LstItemsFiltros(
          altoFilters: altoFilters,
          select: filtro,
          onSelect: (_) async => await _mostrarItemsFiltrados()
        );
      }
    ).whenComplete(() {

      if(mounted) {
        if(_ords.typeFilter['current'] == 'ordenes') {
          // con el valor 2, mostramos el widget de solicitudes
          _showFilter.value = 2;
        }
        if(_ords.typeFilter['current'] == '') {
          // con el valor 0, mostramos la  lista de todas las piezas
          _showFilter.value = 0;
        }
        setState(() {});
      }
    });
    
  }

  ///
  Future<void> _initWidget(_) async {
    
    final nav = GoRouter.of(context);
    // Revisamos si existe alguna notificacion guardada.
    final hasPush = await _pushIn.getPushInLastInBox();
    if(hasPush.isNotEmpty) {
      Future.microtask(() => nav.go(hasPush['payload']));
      return;
    }

    _scrollCtrFilter.addListener(_scrollListener);
  }

  ///
  Future<void> _fetchPage(int pageKey) async {

    if (!mounted) { return; }
    if(!_isInit) {
      _isInit = true;
      _ords = context.read<OrdenesProvider>();
    }

    if(_isLoad){ return; }
    
    bool getNextPage = false;

    Future.sync(() async {
      
      _isLoad = true;

      _ords.getItemsFrom = 'server';
      var ordenes = await _ords.fetchData(
        pageKey, '${_globals.idUser}::${WhereReg.aph.name}', call: 'home'
      );

      if(_ords.getItemsFrom == 'cache') {

        if(_globals.invFilter.isNotEmpty) {
          for (var i = 0; i < ordenes.length; i++) {

            if(_globals.invFilter.containsKey(ordenes[i].id)) {
              for (var p = 0; p < ordenes[i].piezas.length; p++) {  
                if(_globals.invFilter[ordenes[i].id]!.contains(ordenes[i].piezas[p].id)) {
                  ordenes[i].piezas.removeAt(p);
                }
              }
              if(ordenes[i].piezas.isEmpty) {
                ordenes.removeAt(i);
              }
            }
          }
        }
      }

      int hasTot = _ords.items().length + _ords.apartados().length;
      if(_ords.dataPag.isNotEmpty) {
        if(_ords.dataPag.containsKey('total')) {
          final hayInServer = _ords.dataPag['total'] - _ords.cantItemsPerPage;
          if(hasTot < hayInServer) {
            getNextPage = true;
          }
        }
      }

      if(ordenes.isNotEmpty) {
        
        // Algoritmo para calcular donde insertar aviso de atencion
        final List<int> todasPzas = [];
        for (var i = 0; i < ordenes.length; i++) {

          final List<int> pzas = [];
          ordenes[i].piezas.map((e) => pzas.add(e.id)).toList();
          todasPzas.addAll(pzas);
          if(i == 0) {
            _inserAvIn.add(ordenes[i].id);
          }else{
            if(((todasPzas.length) % 7) == 0) {
              if(pzas.isNotEmpty) { _inserAvIn.add(ordenes[i].id); }
            }
          }
        }
        
        /// Colocamos entidades bacias para indicar donde va un aviso de atencion.
        ordenes = _insertAvAtention(ordenes);
        /// Colocamos entidades bacias para marcar las fechas.
        ordenes = _insertarFechas(ordenes);
        if(_pagingController.itemList != null) {
          if(_ords.getItemsFrom == 'cache') {
            _pagingController.itemList!.clear();
          }
        }

        bool isLastPage = ordenes.length < _ords.cantItemsPerPage;

        try {
          if (isLastPage || _ords.getItemsFrom == 'cache') {
            _pagingController.appendLastPage(List<OrdenEntity>.from(ordenes));
          } else {
            _pagingController.appendPage(List<OrdenEntity>.from(ordenes), (pageKey + 1));
          }
        } catch (error) {
          try {
            _pagingController.error = error;
          } catch (_) {}
        }
        
        ordenes = [];
        // Al finalizar de colocar las ordenes mostramos los filtros
        _showFiltrosWidget();
        
        // Movemos el scroll a su ultima posicion
        if(_ords.pixelsScrollM > 0) {
          Future.delayed(const Duration(milliseconds: 500), () {
            try {
              _scrollCtrFilter.position.animateTo(
                _ords.pixelsScrollM,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeIn
              );
            } catch (_) {}
          });
        }
      }else{
        if(mounted) {
          _pagingController.appendLastPage(<OrdenEntity>[]);
        }
      }

      if(getNextPage) {
        if((pageKey +1) <= _ords.dataPag['tpages']) {
          if(_pagingController.nextPageKey == null) {
            _pagingController.nextPageKey = (pageKey +1);
          }else{
            _pagingController.nextPageKey = (pageKey +1);
          }
        }
      }

      if(_ords.typeFilter['select'].isNotEmpty) {
        _pagingController.nextPageKey = 1;
        Future.microtask(() {
          _ords.typeFilterClean();
        });
      }
      _isLoad = false;
    });
  }

  ///
  void _showFiltrosWidget() {

    Future.delayed(const Duration(milliseconds: 1000), () {
      if(mounted) {
        _ords.currentSeccion = 'por piezas';
        _ords.isFromApartados = false;
        _sizeFilter.value = altoFilters;
        _ords.initApp = true;
      }
    });
  }

  ///
  Future<void> _refreshComplete() async {

    Future.sync (() async {

      _ords.numberPage = -1;
      _ords.items().clear();
      _ords.apartados().clear();
      _pagingController.refresh();
    });
  }

  ///
  Future<void> _mostrarItemsFiltrados() async {
    
    _lstfiltrada = [];
    
    final ords = List<int>.from(_ords.filterBySols['ords']);
    if(ords.isNotEmpty) {
      for (var i = 0; i < ords.length; i++) {
        final ord = _ords.items().where((o) => o.id == ords[i]);
        if(ord.isNotEmpty) {
          OrdenEntity? ordn = await _ords.solEm.cleanOrdenEmpty(ord.first);
          if(ordn != null) {
            _lstfiltrada.add(ordn);
          }
        }
      }
    }
    
    if(mounted) {
      Future.microtask(() {
        if(_lstfiltrada.isNotEmpty) {
          _showFilter.value = 1;
        }
      });
    }
    return;
  }

  ///
  List<OrdenEntity> _insertAvAtention(List<OrdenEntity> ordenes) {
    
    for (var i = 0; i < _inserAvIn.length; i++) {
      final laOrd = ordenes.indexWhere((element) => element.id == _inserAvIn[i]);
      if(laOrd != -1) {
        final has = ordenes[laOrd].piezas.indexWhere((p) => p.piezaName == p.avAt);
        if(has == -1) {
          ordenes[laOrd].piezas.insert(1, PiezaEntity()..avisoAtencion());
        }
      }
    }
    return ordenes;
  }

  ///
  List<OrdenEntity> _insertarFechas(List<OrdenEntity> ordenes) {
    
    final indicadores = _getIndicadoresFechas(ordenes);

    if(indicadores.containsKey('hoy')) {
      ordenes.insert(
        indicadores['hoy']!, OrdenEntity().toIndicador(
          ordenes[indicadores['hoy']!].createdAt, 'hoy'
        )
      );
    }
    if(indicadores.containsKey('ayer')) {
      ordenes.insert(
        indicadores['ayer']!, OrdenEntity().toIndicador(
          ordenes[indicadores['ayer']!].createdAt, 'ayer'
        )
      );
    }
    if(indicadores.containsKey('fech')) {
      ordenes.insert(
        indicadores['fech']!, OrdenEntity().toIndicador(
          ordenes[indicadores['fech']!].createdAt, 'fech'
        )
      );
    }
    return ordenes;
  }

  /// Vemos en donde se tendrán que insertar los indicadores de fechas
  Map<String, int> _getIndicadoresFechas(List<OrdenEntity> ordenes) {

    Map<String, int> indexInsert = {};
    final hoy = DateTime.now();
    for (var i = 0; i < ordenes.length; i++) {

      bool select = false;
      final diff = hoy.difference(ordenes[i].createdAt);
      if(diff.inDays == 0 && ordenes[i].createdAt.day == hoy.day) {
        if(i == 0) {
          select = true;
          indexInsert.putIfAbsent('hoy', () => 0);
        }
      }

      if(diff.inDays <= 1 && !select) {
        if(!indexInsert.containsKey('ayer')) {
          select = true;
          indexInsert.putIfAbsent('ayer', () => i);
        }
      }

      if(diff.inDays > 1 && !select) {
        if(!indexInsert.containsKey('fech')) {
          indexInsert.putIfAbsent('fech', () => i);
        }
      }

      if(indexInsert.containsKey('fech')) {
        if(indexInsert.containsKey('ayer')) {
          if(indexInsert.containsKey('hoy')) {
            break;
          }
        }
      }
    }
    return indexInsert;
  }

  ///
  void _scrollListener() {

    if (_scrollCtrFilter.position.userScrollDirection == ScrollDirection.reverse) {
      if (_sizeFilter.value != 0) {
        _sizeFilter.value = 0;
      }
    }

    if (_scrollCtrFilter.position.userScrollDirection == ScrollDirection.forward) {
      if (_sizeFilter.value == 0) {
        _sizeFilter.value = altoFilters;
      }
    }
    _ords.pixelsScrollM = _scrollCtrFilter.position.pixels;
  }

}