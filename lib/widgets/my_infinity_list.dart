import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';

import 'filtrado_por_mds.dart';
import 'filtrado_por_mrks.dart';
import 'filtrado_por_sols.dart';
import 'empty_list_indicator.dart';
import 'filtrar_dialog.dart';
import 'tile_orden_pieza.dart';
import '../entity/orden_entity.dart';
import '../entity/share_data_orden.dart';
import '../providers/ordenes_provider.dart';
import '../vars/globals.dart';

class MyInfinityList extends StatefulWidget {

  const MyInfinityList({ Key? key }) : super(key: key);

  @override
  State<MyInfinityList> createState() => _MyInfinityListState();
}

class _MyInfinityListState extends State<MyInfinityList> {

  final _txtFiltros = 'Organiza los Resultados por:';
  final _filtros = ValueNotifier<String>('Organiza los Resultados por:');
  final _showFilter = ValueNotifier<bool>(false);
  final _scrollCtrFilter = ScrollController();
  final _pagingController = PagingController<int, OrdenEntity>(firstPageKey: 1);

  late OrdenesProvider _ords;
  bool _isInit = false;
  int pageCurrent = 0;
  List<OrdenEntity> _lstfiltrada = [];

  @override
  void initState() {

    _pagingController.addPageRequestListener((pageKey) { _fetchPage(pageKey); });
    super.initState();
  }

  @override
  void dispose() {
    _pagingController.dispose();
    _filtros.dispose();
    _showFilter.dispose();
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
          child: Column(
            children: [
              _headFilter(),
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: _showFilter,
                  builder: (_, verFilter, __) {
                    return (verFilter) ? _lstFiltrada() : _lstInfinity();
                  },
                ),
              )
            ],
          ),
        );
      },
    );
  }

  ///
  Widget _headFilter() {

    return Container(
      decoration: const BoxDecoration(
        color: Colors.black,
      ),
      child: ValueListenableBuilder(
        valueListenable: _filtros,
        builder: (_, val, child) {

          if(val.contains('Organiza')){ return child!; }

          return Row(
            children: [
              const SizedBox(width: 10),
              Text(
                val,
                style: const TextStyle(
                  color: Color.fromARGB(255, 81, 169, 133)
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () async => await _refreshComplete(fromFilter: true),
                child: const Text(
                  'VER TODOS',
                  style: TextStyle(
                    color: Colors.orange
                  ),
                ),
              )
            ],
          );
        },
        child: Row(
          children: [
            const SizedBox(width: 10),
            Text(
              _txtFiltros,
              style: const TextStyle(
                color: Color.fromARGB(255, 81, 169, 133)
              ),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward, color: Color.fromARGB(255, 95, 95, 95)),
            FiltrarDialog(
              from: 'sols',
              onPresed: (fnc) async {
                Navigator.of(context).pop();
                _showModalfilter(fnc);
              },
            )
          ],
        ),
      ),
    );
  }

  ///
  Widget _lstFiltrada() {

    if(_lstfiltrada.isEmpty) {
      return const EmptyListIndicator(from: 'filter');
    }

    return ListView.builder(
      controller: _scrollCtrFilter,
      itemCount: _lstfiltrada.length,
      padding: const EdgeInsets.all(10),
      itemBuilder: (BuildContext context, int index) {
        return _sortPerPiezas(_lstfiltrada[index]);
      },
    );
  }

  ///
  Widget _lstInfinity() {

    return RefreshIndicator(
      onRefresh: () async => await _refreshComplete(),
      child: PagedListView.separated(
        pagingController: _pagingController,
        padding: const EdgeInsets.all(10),
        shrinkWrap: true,
        builderDelegate: PagedChildBuilderDelegate<dynamic>(
          itemBuilder: (_, orden, index) => _sortPerPiezas(orden),
          noItemsFoundIndicatorBuilder: (context) => const EmptyListIndicator(),
          firstPageErrorIndicatorBuilder: (context) => EmptyListIndicator(
            error: _pagingController.error.toString().toLowerCase(),
            onTray: (_) {
              _ords.numberPage = -1;
              Future.sync (() {
                _ords.items().clear();
                _pagingController.refresh();
              });
            },
          ),
        ),
        separatorBuilder: (context, index) => const SizedBox(height: 5)
      )
    );
  }

  ///
  Widget _sortPerPiezas(OrdenEntity orden) {

    if(orden.piezas.isEmpty) {
      return const SizedBox(height: 0);
    }

    return Column(
      children: orden.piezas.map((pza) {
        
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: TileOrdenPieza(
            pieza: pza,
            idAuto: orden.auto,
            idOrden: orden.id,
            created: orden.createdAt,
            fotos: (orden.fotos.containsKey(pza.id))
              ? List<String>.from(orden.fotos[pza.id]!) : <String>[],
            requerimientos: orden.obs[pza.id]!,
            box: SharedDataOrden(),
            onNt: (int idP) async {

              // Guardar en File LOCAL y BD REMOTO
              int idUSer = await _ords.solEm.getIdUser();
              await _ords.setNoTengo(
                orden.id, idP, idUSer, fileSee: orden.buildFileSee(idUSer, 'nth'),
              );

              if(_ords.filterBySols.isNotEmpty) {
                if(_lstfiltrada.isNotEmpty) {
                  _lstfiltrada.removeWhere((element) => element.id == idP);
                  orden.piezas.removeWhere((element) => element.id == idP);
                  setState(() {});
                }
              }else{
                orden.piezas.removeWhere((element) => element.id == idP);
                setState(() {});
              }
              _pagingController.refresh();
            },
          )
        );
      }).toList(),
    );
  }

  ///
  void _showModalfilter(String filtro) {

    final globals = Globals();
    late Widget widgetFiltro;

    switch (filtro) {
      case 'marcas':
        widgetFiltro = FiltradoPorMrks(onPress: (_) => _refreshWithFilter());
        break;
      case 'modelos':
        widgetFiltro = FiltradoPorMds(onPress: (_) => _refreshWithFilter());
        break;
      case 'cotizaciones':
        widgetFiltro = FiltradoPorSols(onPress: (_) => _refreshWithFilter());
        break;
      default:
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: globals.secMain,
      builder: (_) {

        return SafeArea(
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                decoration: BoxDecoration(
                  color: globals.bgMain,
                  border: Border(
                    top: BorderSide(
                      color: globals.colorGreen,
                      width: 3
                    )
                  )
                ),
                child: Row(
                  children: [
                    Text(
                      'Filtrado por: ${filtro.toUpperCase()}',
                      textScaleFactor: 1,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: globals.colorGreen,
                        fontSize: 17
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.white)
                    )
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: widgetFiltro,
                )
              )
            ],
          ),
        );
      }
    );
  }

  ///
  Future<void> _fetchPage(int pageKey) async {

    if (!mounted) { return; }

    if(!_isInit) {
      _isInit = true;
      _ords = context.read<OrdenesProvider>(); 
    }

    // Revisamos para ver si no hay algun filtro en memoria
    if(_ords.filterBySols.isNotEmpty) {
      await _refreshWithFilter();
      setState(() {});
      return;
    }

    final ordenes = await _ords.fetchData(_pagingController.nextPageKey ?? 1);
    bool isLastPage = ordenes.length < _ords.cantItemsPerPage;
    _ords.numberPage = pageKey;

    try {
      if (isLastPage) {
        _pagingController.appendLastPage(List<OrdenEntity>.from(ordenes));
      } else {
        _pagingController.appendPage(List<OrdenEntity>.from(ordenes), (pageKey + 1));
      }
    } catch (error) {
      try {
        _pagingController.error = error;
      } catch (_) {}
    }
  }

  ///
  Future<void> _refreshComplete({bool fromFilter = false}) async {

    Future.sync (() {

      if(fromFilter) {
        _filtros.value = _txtFiltros;
        _showFilter.value = false;
        _lstfiltrada = [];
        _ords.filterBySols.clear();
        _ords.typeFilter = '';
        _pagingController.refresh();
        return;
      }

      final ords = context.read<OrdenesProvider>();
      ords.numberPage = -1;
      ords.items().clear();
      _pagingController.refresh();
    });
  }

  ///
  Future<void> _refreshWithFilter() async {
    
    if(_ords.typeFilter == 'marcas') {

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
      
      _filtros.value = 'Piezas del ${_ords.filterBySols['marca'].toUpperCase()}';
    }

    if(_ords.typeFilter == 'modelos') {

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

      _filtros.value = 'Piezas del ${_ords.filterBySols['modelo'].toUpperCase()}';
    }

    Future.microtask(() => _showFilter.value = true);
  }

}