import 'package:cotizo/entity/share_data_orden.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'empty_list_indicator.dart';
import 'error_widget_Items.dart';
import 'tile_orden_pieza.dart';
import '../entity/orden_entity.dart';
import '../repository/soli_em.dart';
import '../providers/ordenes_provider.dart';
import '../widgets/tile_orden_mrks.dart';
import '../widgets/tile_orden_soli.dart';

class MyInfinityList extends StatefulWidget {
  
  final String tile;
  const MyInfinityList({
    Key? key,
    required this.tile
  }) : super(key: key);

  @override
  State<MyInfinityList> createState() => _MyInfinityListState();
}

class _MyInfinityListState extends State<MyInfinityList> {

  final SoliEm _solEm = SoliEm();

  late OrdenesProvider _ords;
  bool _isInit = false;
  int pageCurrent = 0;
  final _pagingController = PagingController<int, OrdenEntity>(firstPageKey: 1);

  @override
  void initState() {

    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return RefreshIndicator( 
      onRefresh: () => Future.sync (() => _pagingController.refresh() ),
      child: PagedListView.separated(
        pagingController: _pagingController,
        padding: const EdgeInsets.all(10),
        builderDelegate: PagedChildBuilderDelegate<OrdenEntity>(
          itemBuilder: (_, orden, index) {
            
            switch (widget.tile) {
              case 'gral':
                if(orden.piezas.isNotEmpty) {
                  for(var p = 0; p < orden.piezas.length; p++) {
                    return TileOrdenPieza(
                      idPieza: orden.piezas[p],
                      idAuto: orden.auto,
                      idOrden: orden.id,
                      created: orden.createdAt,
                      fotos: (orden.fotos.containsKey(orden.piezas[p]))
                        ? List<String>.from(orden.fotos[orden.piezas[p]]!) : <String>[],
                      box: SharedDataOrden(),
                    );
                  }
                }
                return const SizedBox();
              case 'mrks':
                return TileOrdenMrks(item: orden, box: SharedDataOrden(),);
              case 'soli':
                return TileOrdenSoli(item: orden);
              default:
                return const SizedBox();
            }
          },
          noItemsFoundIndicatorBuilder: (context) => const EmptyListIndicator(),
          firstPageErrorIndicatorBuilder: (context) => ErrorWidgetItems(
            error: _pagingController.error.toString().toLowerCase(),
            onTryAgain: (_) => _pagingController.refresh(),
          ),
        ),
        separatorBuilder: (context, index) => const SizedBox(height: 14)
      )
    );
  }

  ///
  Future<void> _fetchPage(int pageKey) async {

    if(!_isInit) {
      _isInit = true;
      _ords = context.read<OrdenesProvider>();
    }

    try {

      final contentNewPage = await _fetchData(_pagingController.nextPageKey ?? 1);

      final isLastPage = contentNewPage.length < _ords.cantItemsPerPage;
      if (isLastPage) {
        _pagingController.appendLastPage(contentNewPage);
      } else {
        _pagingController.appendPage(contentNewPage, (pageKey + 1));
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
        response = await _solEm.setOrdenFromServer(result, _ords.items);
        _ords.items.addAll(response);
        _ords.setIndexResult(response.first.id, response.last.id);
      }
    }else{
      if(_ords.indexFirsPerPage == _ords.indexLastPerPage) {
        response.add(_ords.items.first);
      }else{
        response = _ords.items.getRange(_ords.indexFirsPerPage, _ords.indexLastPerPage).toList();
      }
    }
    
    return response;
  }


}