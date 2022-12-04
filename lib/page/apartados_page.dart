import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../config/sngs_manager.dart';
import '../entity/apartados_entity.dart';
import '../entity/orden_entity.dart';
import '../entity/share_data_orden.dart';
import '../providers/ordenes_provider.dart';
import '../repository/apartados_repository.dart';
import '../vars/globals.dart';
import '../vars/constantes.dart' show WhereReg;
import '../widgets/aviso_atencion.dart';
import '../widgets/empty_list_indicator.dart';
import '../widgets/tile_orden_pieza.dart';

class ApartadosPage extends StatefulWidget {

  const ApartadosPage({ Key? key }) : super(key: key);

  @override
  State<ApartadosPage> createState() => _ApartadosPageState();
}

class _ApartadosPageState extends State<ApartadosPage> {

  final _apEm = ApartadosRepository();
  final _globals = getIt<Globals>();
  final _pagingController = PagingController<int, OrdenEntity>(firstPageKey: 1);

  late Future<bool> _hasApartados;
  late OrdenesProvider _ords;
  bool _isInit = false;
  int pageCurrent = 0;
  List<ApartadosEntity> _hasAp = [];

  @override
  void initState() {
    _hasApartados = _fetchApartados();
    _pagingController.addPageRequestListener(_fetchPage);
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
          child: FutureBuilder(
            future: _hasApartados,
            initialData: false,
            builder: (_, AsyncSnapshot snap) {
              if(snap.connectionState == ConnectionState.done) {
                return (!snap.data) ? _lstBacia() : _lstApartados();
              }
              return const SizedBox();
            },
          )
        );
      },
    );
  }

  ///
  Widget _lstBacia() {

    const String assetName = 'assets/svgs/inbox_2.svg';
    final double radio = MediaQuery.of(context).size.width * 0.55;

    return SizedBox.expand(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              width: radio, height: radio,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(radio)
              ),
              child: SvgPicture.asset(
                assetName, semanticsLabel: 'Apartados'
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'Tu Sección de Apartados',
              textScaleFactor: 1,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.white
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Navega entre la lista de solicitudes y todas aquellas piezas que '
              'por el momento quieras confirmar la existencia en tu inventario '
              'físico, puedes irlas colocando en esta sección.',
              textScaleFactor: 1,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 19,
                color: Colors.grey,
                height: 1.3
              ),
            )
          ],
        ),
      )
    );
  }

  ///
  Widget _lstApartados() {

    return RefreshIndicator(
      onRefresh: () async => await _refreshComplete(),
      child: PagedListView.separated(
        pagingController: _pagingController,
        padding: const EdgeInsets.all(10),
        builderDelegate: PagedChildBuilderDelegate<dynamic>(
          itemBuilder: (_, orden, index) => _lstPiezas(orden, index),
          noItemsFoundIndicatorBuilder: (context) => _lstBacia(),
          noMoreItemsIndicatorBuilder: (_) => const AvisoAtencion(),
          firstPageErrorIndicatorBuilder: (context) => EmptyListIndicator(
            error: _pagingController.error.toString().toLowerCase(),
            onTray: (_) {
              Future.sync (() {
                _refreshComplete();
              });
            },
          ),
        ),
        separatorBuilder: (context, index) => const SizedBox(height: 5)
      )
    );
  }

  ///
  Widget _lstPiezas(OrdenEntity orden, int index) {

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

        String obs = '...';
        try {
          obs = orden.obs[pza.id]!;
        } catch (_) {}
        
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: TileOrdenPieza(
            pieza: pza,
            idAuto: orden.auto,
            idOrden: orden.id,
            created: orden.createdAt,
            fotos: (orden.fotos.containsKey(pza.id))
              ? List<String>.from(orden.fotos[pza.id]!) : <String>[],
            requerimientos: obs,
            box: SharedDataOrden(),
            onCot: (int idP) {
              _ords.isFromApartados = true;
              context.go('/estanque/${orden.id}-$idP');
            },
            onNtg: (int idP) async => await _setNoTengo(orden.id, idP),
            onApartar: null,
          )
        );
      }).toList(),
    );
  }

  ///
  Future<bool> _fetchApartados() async {
    _hasAp = await _apEm.getAllApartado();
    return (_hasAp.isEmpty) ? false : true;
  }

  ///
  Future<void> _setNoTengo(int idO, int idPza) async {

    final res = await _ords.setNoTengo(
      idO, _globals.idUser, idPza, WhereReg.apr.name
    );

    if(res > 0) {
      if(mounted) {
        _refreshComplete();
      }
    }
  }

  ///
  Future<void> _fetchPage(int pageKey) async {

    if (!mounted) { return; }

    if(!_isInit) {
      _isInit = true;
      _ords = context.read<OrdenesProvider>();
    }

    _ords.currentSeccion = 'apartados';

    // Tomamos todos los apartados que estan en dblocal
    if(_hasAp.isEmpty) {
      _hasAp = await _apEm.getAllApartado();
    }

    var fromS   = <ApartadosEntity>[];
    var ordenes = <OrdenEntity>[];

    // Si hay apartados en cache, revisamos uno a uno para ver cual falta
    if(_ords.apartados().isNotEmpty) {
      
      _hasAp.map((e){
        final enCache = _ords.apartados().where((o) => o.id == e.idOrd);
        if(enCache.isEmpty) {
          if(enCache.first.piezas.isNotEmpty) {
            fromS.add(e);
          }
        }else{
          List<int> quitar = [];
          final rota = enCache.first.piezas.length;
          for (var i = 0; i < rota; i++) {
            if(!e.idPza.contains(enCache.first.piezas[i].id)) {
              quitar.add(enCache.first.piezas[i].id);
            }
          }
          enCache.first.piezas.removeWhere((pza) => quitar.contains(pza.id));
          if(enCache.first.piezas.isNotEmpty) {
            ordenes.add(enCache.first);
          }
          quitar = [];
        }
      }).toList();

    }else{
      fromS = List<ApartadosEntity>.from(_hasAp);
    }

    if(ordenes.isNotEmpty) {

      try {
        if(fromS.isEmpty) {
          _pagingController.appendLastPage(List<OrdenEntity>.from(ordenes));
          _hasAp = []; ordenes = [];
          return;
        }else{
          _pagingController.appendPage(List<OrdenEntity>.from(ordenes), (pageKey + 1));
        }
      } catch (error) {
        try {
          _pagingController.error = error;
        } catch (_) {}
      }

    }else{
      _pagingController.appendLastPage(<OrdenEntity>[]);
      Future.microtask(() => _ords.cantApartados = 0 );
    }

    // Faltan algunos apartados, por lo tanto los recuperamos desde el server.
    ordenes = [];
    List<Map<String, dynamic>> dta = [];
    fromS.map( (e) => dta.add(e.toJson()) ).toList();
    
    ordenes.addAll(await _ords.fetchApartadosFromServer(dta));
    if(ordenes.isNotEmpty) {
      try {
        _pagingController.appendLastPage(List<OrdenEntity>.from(ordenes));
      } catch (error) {
        try {
          _pagingController.error = error;
        } catch (_) {}
      }
    }

    _hasAp = [];
    ordenes = [];
  }

  ///
  Future<void> _refreshComplete() async {

    Future.sync (() async {
      // _ords.apartados().clear();
      _pagingController.refresh();
    });
  }

}