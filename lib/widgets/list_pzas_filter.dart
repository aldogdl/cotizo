import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'tile_orden_pieza.dart';
import '../config/sngs_manager.dart';
import '../entity/share_data_orden.dart';
import '../entity/orden_entity.dart';
import '../providers/ordenes_provider.dart';
import '../repository/soli_em.dart';
import '../vars/globals.dart';
import '../widgets/bg_img_pzas.dart';
import '../widgets/empty_list_indicator.dart';

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
  final _ds = SharedDataOrden();

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
    _globals.setHistUri('/cotizo/$_idOrd');
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

        final nav = GoRouter.of(context);
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
          
          if(snap.data == 'redirec') {
            Future.delayed(const Duration(milliseconds: 1500), (){
              nav.go('/home');
            });
            return const EmptyListIndicator();
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
          SizedBox(height: MediaQuery.of(context).size.height * 0.1),
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
          SizedBox(height: MediaQuery.of(context).size.height * 0.05),
          Text(
            title,
            textScaleFactor: 1,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold
            )
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.05),
          ValueListenableBuilder<String>(
            valueListenable: _msgLoad,
            builder: (_, val, __) {
              
              bool showBtn = true;
              String txtBtn = 'ESPERA UN MOMENTO POR FAVOR';
              if(val.contains('inténtalo')) {
                showBtn = false;
                txtBtn = 'INTENTARLO NUEVAMENTE';
              }

              if(val.startsWith('Parece')) {
                showBtn = false;
                txtBtn = 'GRACIAS POR TU ATENCIÓN.';
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
                        height: 1.5,
                        fontWeight: FontWeight.w200
                      )
                    )
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.1),
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
    final sep = (_orden!.piezas.length > 1) ? 8.0 : 0.0;

    return SizedBox(
      width: size.width, height: size.height,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _globals.secMain,
              borderRadius: BorderRadius.circular(20)
            ),
            child: Center(
              child: Text(
                'Estas son piezas de la Orden $_idOrd',
                textScaleFactor: 1,
                style: const TextStyle(
                  fontSize: 14,
                  letterSpacing: 1.03,
                  color: Colors.white
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              controller: _scrollCtr,
              separatorBuilder: (_, __) => SizedBox(height: sep),
              shrinkWrap: true,
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
                return _piezaTile(index);
              }
            ),
          )
        ],
      )
    );
  } 

  ///
  Widget _piezaTile(int indexPza) {

    final idPza = _orden!.piezas[indexPza].id;
    
    if(_orden != null) {
      return TileOrdenPieza(
        pieza: _orden!.piezas[indexPza],
        idAuto: _orden!.auto,
        idOrden: _orden!.id,
        created: _orden!.createdAt,
        fotos: (_orden!.fotos.containsKey(idPza))
          ? List<String>.from(_orden!.fotos[idPza]!) : <String>[],
        requerimientos: _orden!.obs[idPza]!,
        box: _ds,
        idsFromLink: widget.ids,
        onNt: (int idP) async {
          
          final nav = GoRouter.of(context);
          await _ordProv!.setNoTengo(_orden!.id, idP);
          _orden!.piezas.removeAt(indexPza);
          if(_orden!.piezas.isEmpty) {
            nav.go('/home');
          }else{
            setState(() {});
          }
        },
      );
    }

    return const SizedBox();
  }

  ///
  Future<String> _fetchData() async {

    if (!mounted) { return 'none'; }

    _ordProv = context.read<OrdenesProvider>();
    _msgLoad.value = 'Recuperando la Orde # $_idOrd';
    await Future.delayed(const Duration(microseconds: 200));
    
    final hasOrdInCache = _ordProv!.items().where(
      (element) => element.id == _idOrd
    ).toList();

    if(hasOrdInCache.isNotEmpty) {

      _globals.isFromWhatsapp = false;
      _orden = hasOrdInCache.first;
      if(_orden!.piezas.isEmpty) {
        return 'redirec';
      }

    }else{
      
      final fileReg = '${widget.ids}-${DateTime.now().microsecondsSinceEpoch}.see';
      final result = await _solEm.oem.getAOrdenAndPieza(_idOrd, fileReg);

      _solEm.oem.cleanResult();
      _globals.isFromWhatsapp = true;

      if(result.isNotEmpty) {
        
        _msgLoad.value = 'Hidratando Modelos';
        await Future.delayed(const Duration(microseconds: 200));
        _orden = await _solEm.hidratarOrdenFull(result, _ordProv!.items());
        
        if( _solEm.addToList ){
          if(_orden != null) {
            _ordProv!.addItem = _orden!;
            _ordProv!.setIndexResult(_ordProv!.items().first.id, _orden!.id);
          }
        }else{
          _msgLoad.value = 'Parece ser que ya haz cotizado todas las '
          'piezas de esta orden, por favor, selecciona cualquier otra.';  
        }
      }else{
        _msgLoad.value = 'No se logró recuperar la orden, inténtalo nuevamente por favor';
        await Future.delayed(const Duration(microseconds: 200));
      }
    }

    return 'show';
  }


}