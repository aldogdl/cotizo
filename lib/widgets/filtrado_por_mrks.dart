import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'empty_list_indicator.dart';
import 'tile_orden_auto.dart';
import '../providers/ordenes_provider.dart';
import '../repository/soli_em.dart';

class FiltradoPorMrks extends StatefulWidget {

  final ValueChanged<void> onPress;
  const FiltradoPorMrks({
    Key? key,
    required this.onPress
  }) : super(key: key);

  @override
  State<FiltradoPorMrks> createState() => _FiltradoPorMrksState();
}

class _FiltradoPorMrksState extends State<FiltradoPorMrks> {

  final _solEm = SoliEm();
  final _scr = ScrollController();
  late OrdenesProvider _ords;
  late Future<List<Map<String, dynamic>>> _filtrar;

  bool _isInit = false;
  int pageCurrent = 0;

  @override
  void initState() {
    _filtrar = _makeFiltro();
    super.initState();
  }

  @override
  void dispose() {
    _scr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _filtrar,
      builder: (_, AsyncSnapshot<List<Map<String, dynamic>>> filtrados){

        if(filtrados.connectionState == ConnectionState.done) {
          if(filtrados.hasData) {

            return ListView.builder(
              controller: _scr,
              itemCount: filtrados.data!.length,
              itemBuilder: (_, int index) => _tilePerMarca(filtrados.data![index])
            );

          }else{
            return const EmptyListIndicator(
              error: 'Sin Datos actualmente',
            );
          }
        }

        return const Center(
          child: Icon(Icons.time_to_leave_rounded, size: 150, color: Color.fromARGB(255, 58, 58, 58)),
        );
      },
    );
  }

  ///
  Widget _tilePerMarca(Map<String, dynamic> tile) {

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: TileOrdenAuto(
        item: tile['tile'],
        tipo: 'mrk',
        onPress: (item) {
          _ords.filterBySols = item;
          _ords.typeFilter['current'] = 'marcas';
          _ords.typeFilter['select']  = 'marcas';
          widget.onPress(null);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  ///
  Future<List<Map<String, dynamic>>> _makeFiltro() async {

    if (!mounted) { return []; }

    if(!_isInit) {
      _isInit = true;
      _ords = context.read<OrdenesProvider>();
    }

    final res = await _solEm.sortPerMark(_ords.items());
    return res;
  }

}