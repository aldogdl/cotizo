import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'empty_list_indicator.dart';
import '../entity/share_data_orden.dart';
import '../entity/orden_entity.dart';
import '../providers/ordenes_provider.dart';
import '../widgets/tile_orden_soli.dart';

class FiltradoPorSols extends StatefulWidget {
  
  final ValueChanged<void> onPress;
  const FiltradoPorSols({
    Key? key,
    required this.onPress
  }) : super(key: key);

  @override
  State<FiltradoPorSols> createState() => _FiltradoPorSolsState();
}

class _FiltradoPorSolsState extends State<FiltradoPorSols> {

  final _ctrScroll = ScrollController();
  late OrdenesProvider _ords;
  late Future<List<OrdenEntity>> _filtrar;

  bool _isInit = false;

  @override
  void initState() {
    _filtrar = _makeFiltro();
    super.initState();
  }

  @override
  void dispose() {
    _ctrScroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return FutureBuilder<List<OrdenEntity>>(
      future: _filtrar,
      builder: (_, AsyncSnapshot<List<OrdenEntity>> filtrados){

        if(filtrados.connectionState == ConnectionState.done) {
          if(filtrados.hasData) {

            return ListView.builder(
              controller: _ctrScroll,
              itemCount: filtrados.data!.length,
              itemBuilder: (_, int index) => _sortPerSolicitudes(filtrados.data![index])
            );

          }else{
            return const EmptyListIndicator(
              error: 'Sin Datos actualmente',
            );
          }
        }

        return const Center(
          child: SizedBox(
            width: 40, height: 40,
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  ///
  Widget _sortPerSolicitudes(OrdenEntity orden) {

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: TileOrdenSoli(item: orden, box: SharedDataOrden())
    );
  }

  ///
  Future<List<OrdenEntity>> _makeFiltro() async {

    if (!mounted) { return []; }

    if(!_isInit) {
      _isInit = true;
      _ords = context.read<OrdenesProvider>();
    }

    final res = await _ords.getRange();
    return res;
  }

}