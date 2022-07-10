import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import 'tile_orden_pieza.dart';
import '../config/sngs_manager.dart';
import '../entity/pieza_entity.dart';
import '../entity/share_data_orden.dart';
import '../entity/orden_entity.dart';
import '../providers/gest_data_provider.dart';
import '../repository/soli_em.dart';
import '../providers/ordenes_provider.dart';
import '../services/my_get.dart';
import '../vars/globals.dart';
import '../widgets/bg_img_pzas.dart';

class ListPzasFilter extends StatefulWidget {
  
  final String ids;
  const ListPzasFilter({
    Key? key,
    required this.ids,
  }) : super(key: key);

  @override
  State<ListPzasFilter> createState() => _ListPzasFilterState();
}

class _ListPzasFilterState extends State<ListPzasFilter> {

  final _globals = getIt<Globals>();
  final SoliEm _solEm = SoliEm();
  final ScrollController _scrollCtr = ScrollController();
  final ValueNotifier<String> _msgLoad = ValueNotifier<String>('...');

  OrdenesProvider? _ordProv;
  OrdenEntity? _orden;
  late Future _getData;
  
  int _idOrd = 0;

  @override
  void initState() {
    if(widget.ids.contains('-')) {
      final partes = widget.ids.split('-');
      _idOrd = int.parse(partes.first);
    }else{
      _idOrd = int.parse(widget.ids);
    }
    _getData = _fetchData();
    super.initState();
  }

  @override
  void dispose() {
    _scrollCtr.dispose();
    _msgLoad.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
      future: _getData,
      initialData: 'load',
      builder: (_, AsyncSnapshot snap) {

        Widget child =  _load('');
        if(snap.connectionState == ConnectionState.done) {

          child = _load('sinData');
          if(snap.data == 'show') {
            if(_orden != null) {
              if(_orden!.piezas.isNotEmpty) {
                return _buildLstPzas();
              }
            }
          }
        }

        return BGImgPzas(bgColor: _globals.bgMain, child: child);
      }
    );
  }

  ///
  Widget _load(String sinData) {

    bool isLoad = true;
    String title = 'Estamos preparando todo';
    if(sinData.isNotEmpty) {
      isLoad = false;
      title = 'La búsqueda arrojo...';
    }
    return SizedBox.expand(
      child: Column(
        children: [
          SizedBox(height: MediaQuery.of(Mget.ctx!).size.height * 0.1),
          SizedBox(
            width: 100, height: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if(isLoad)
                  const Positioned.fill(child: CircularProgressIndicator()),
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.green,
                  child: SvgPicture.asset(
                    'assets/svgs/no_data.svg',
                    alignment: Alignment.topCenter,
                    fit: BoxFit.contain,
                  ),
                )
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(Mget.ctx!).size.height * 0.05),
          Text(
            title,
            textScaleFactor: 1,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold
            )
          ),
          SizedBox(height: MediaQuery.of(Mget.ctx!).size.height * 0.05),
          ValueListenableBuilder<String>(
            valueListenable: _msgLoad,
            builder: (_, val, __) {
              
              bool showBtn = true;
              String txtBtn = 'ESPERA UN MOMENTO POR FAVOR';
              if(val.contains('inténtalo')) {
                showBtn = false;
                txtBtn = 'INTENTARLO NUEVAMENTE';
              }

              if(isLoad) {
                val = 'No se encontraron datos disponibles para la orde No. $_idOrd.\n'
                '¿Deseas internar nuevamente?';
                showBtn = false;
                txtBtn = 'BUSCAR NUEVAMENTE';
              }

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      val,
                      textAlign: TextAlign.center,
                      textScaleFactor: 1,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w200
                      )
                    )
                  ),
                  SizedBox(height: MediaQuery.of(Mget.ctx!).size.height * 0.1),
                  AbsorbPointer(
                    absorbing: showBtn,
                    child: TextButton(
                      onPressed: () async {
                        _msgLoad.value = 'REINTENTANDOLO...';
                        setState(() {});
                        await Future.delayed(const Duration(milliseconds: 1000));
                        _fetchData();
                      },
                      child: Text(
                      txtBtn,
                      textScaleFactor: 1,
                      style: const TextStyle(
                        color: Color(0xFF00a884),
                        fontSize: 15,
                        fontWeight: FontWeight.bold
                        )
                      )
                    )
                  )
                ],
              );
            }
          ),
        ]
      )
    );
  }

  ///
  Widget _buildLstPzas() {

    final size = MediaQuery.of(context).size;

    return SizedBox(
      width: size.width, height: size.height,
      child: ListView.builder(
        controller: _scrollCtr,
        shrinkWrap: true,
        padding: const EdgeInsets.all(10),
        itemCount: _orden!.piezas.length,
        itemBuilder: (_, int index) {
          return _piezaTile(_orden!.piezas[index]);
        }
      )
    );
  } 
  
  ///
  Widget _piezaTile(int idPza) {

    if(_orden != null) {

      return FutureBuilder<PiezaEntity?>(
        future: _solEm.getPiezaById(idPza),
        builder: (_, AsyncSnapshot snap) {
          
          if(snap.hasData) {
            return TileOrdenPieza(
              idPieza: snap.data.id,
              idAuto: _orden!.auto,
              idOrden: _orden!.id,
              created: _orden!.createdAt,
              fotos: (_orden!.fotos.containsKey(snap.data.id))
                ? List<String>.from(_orden!.fotos[snap.data.id]!) : <String>[],
              box: SharedDataOrden(),
            );
          }

          return const SizedBox();
        }
      );
    }

    return const SizedBox();
  }

  ///
  Future<String> _fetchData() async {

    if (!mounted) { return 'none'; }
    _ordProv = context.read<OrdenesProvider>();
    Mget.init(context, context.read<GestDataProvider>());
    _msgLoad.value = 'Recuperando la Orde # $_idOrd';
    await Future.delayed(const Duration(microseconds: 200));

    final hasOrdInCache = _ordProv!.items().where((element) => element.id == _idOrd);
    if(hasOrdInCache.isNotEmpty) {
      _orden = hasOrdInCache.first;
    }else{
      final fileReg = '${widget.ids}-${DateTime.now().microsecondsSinceEpoch}.see';
      final result = await _solEm.oem.getAOrdenAndPieza(_idOrd, fileReg);
      _solEm.oem.cleanResult();

      if(result.isNotEmpty) {
        _msgLoad.value = 'Hidratando Modelos';
        await Future.delayed(const Duration(microseconds: 200));
        _orden = await _solEm.hidratarOrdenFull(result, _ordProv!.items());
        if( _solEm.addToList ) {
          if(_orden != null) {
            _ordProv!.addItem = _orden!;
            _ordProv!.setIndexResult(_ordProv!.items().first.id, _orden!.id);
          }
        }
      }else{
        _msgLoad.value = 'No se logró recuperar la orden, inténtalo nuevamente por favor';
        await Future.delayed(const Duration(microseconds: 200));
      }
    }

    return 'show';
  }


}