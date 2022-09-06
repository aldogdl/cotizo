import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'empty_list_indicator.dart';
import 'tile_orden_pieza.dart';
import '../entity/share_data_orden.dart';
import '../entity/orden_entity.dart';
import '../repository/soli_em.dart';
import '../providers/ordenes_provider.dart';
import '../widgets/tile_orden_mrks.dart';
import '../widgets/tile_orden_soli.dart';

class MyInfinityList extends StatefulWidget {
  
  final String tile;
  final ValueChanged<String> onPress;
  const MyInfinityList({
    Key? key,
    required this.tile,
    required this.onPress
  }) : super(key: key);

  @override
  State<MyInfinityList> createState() => _MyInfinityListState();
}

class _MyInfinityListState extends State<MyInfinityList> {

  final _solEm = SoliEm();
  final _pagingController = PagingController<int, OrdenEntity>(firstPageKey: 1);
  late OrdenesProvider _ords;

  List<Map<String, dynamic>> _lstSortMark = [];
  List<int> _lstMrksSend = [];

  bool _isInit = false;
  int pageCurrent = 0;

  @override
  void initState() {

    _pagingController.addPageRequestListener((pageKey) { _fetchPage(pageKey); });
    super.initState();
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return LayoutBuilder(
      builder: (_, restrics) {

        return SizedBox(
          width: restrics.maxWidth,
          height: restrics.maxHeight,
          child: RefreshIndicator( 
            onRefresh: () =>
              Future.sync (() {
                _ords.numberPage = -1;
                _ords.items().clear();
                _pagingController.refresh();
            }),
            child: PagedListView.separated(
              pagingController: _pagingController,
              padding: const EdgeInsets.all(10),
              shrinkWrap: true,
              builderDelegate: PagedChildBuilderDelegate<OrdenEntity>(
                itemBuilder: (_, orden, index) {
                  
                  switch (widget.tile) {
                    case 'GENERALES':
                      return _sortPerPiezas(orden);
                    case 'POR MARCAS':
                      return _sortPerMarcas(orden.id);
                    case 'SOLICITUDES':
                      return _sortPerSolicitudes(orden);
                    default:
                      return const SizedBox();
                  }
                },
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
          ),
        );
      },
    );
  }

  ///
  Future<void> _fetchPage(int pageKey) async {

    if(!_isInit) {
      _isInit = true;
      _ords = context.read<OrdenesProvider>();
    }

    try {
      
      final ordenes = await _fetchData(_pagingController.nextPageKey ?? 1);
      final isLastPage = ordenes.length < _ords.cantItemsPerPage;

      if (isLastPage) {
        _pagingController.appendLastPage(ordenes);
      } else {
        _pagingController.appendPage(ordenes, (pageKey + 1));
      }

    } catch (error) {
      _pagingController.error = error;
    }
  }

  ///
  Future<List<OrdenEntity>> _fetchData(int page) async {

    if (!mounted) { return []; }

    List<OrdenEntity> response = [];

    if(_ords.numberPage != page) {
      
      _ords.numberPage = page;
      final result = await _solEm.oem.getAllOrdenesAndPiezas(_ords.numberPage);
      _solEm.oem.cleanResult();
      
      if(result.isNotEmpty) {
        response = await _ords.toEntity(result);
      }
      
    }else{
      response = await _ords.getRange();
    }

    _lstSortMark = [];
    _lstMrksSend = [];

    if(widget.tile == 'POR MARCAS') {
      _lstSortMark = await _solEm.sortPerMark(response);
    }
    
    return response;
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
              await _ords.setNoTengo(orden.id, idP);
              _pagingController.refresh();
            },
          )
        );
      }).toList(),
    );
  }

  ///
  Widget _sortPerMarcas(int idOrden) {

    if(_lstSortMark.isNotEmpty) {
      
      final tile = _lstSortMark.firstWhere(
        (element) => element['tile']['ords'].contains(idOrden),
        orElse: () => {}
      );

      if(tile.isNotEmpty) {
        
        if(!_lstMrksSend.contains(tile['mrk'])) {

          _lstMrksSend.add(tile['mrk']);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: TileOrdenMrks(
              item: tile['tile'],
              onPress: (item) {
                _ords.filterBySols = item;
                widget.onPress('SOLICITUDES');
              },
            ),
          );
        }
      }
    }

    return const SizedBox(width: 0, height: 0);
  }

  ///
  Widget _sortPerSolicitudes(OrdenEntity orden) {

    late Widget child;

    if(_ords.filterBySols.isNotEmpty) {
      if(_ords.filterBySols['ords'].contains(orden.id)) {
        child = TileOrdenSoli(item: orden, box: SharedDataOrden());
      }else{
        return const SizedBox();
      }
    }else{
      child = TileOrdenSoli(item: orden, box: SharedDataOrden());
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: child
    );
  }

}