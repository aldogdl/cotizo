import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../entity/inventario_entity.dart';
import '../entity/share_data_orden.dart';
import '../providers/ordenes_provider.dart';
import '../repository/piezas_repository.dart';
import '../repository/inventario_repository.dart';
import '../widgets/show_dialogs.dart';
import '../widgets/tile_orden_pieza.dart';
import '../services/my_get.dart';
import '../providers/gest_data_provider.dart';
import '../widgets/ascaffold_main.dart';

class InventarioPage extends StatefulWidget {

  const InventarioPage({ Key? key }) : super(key: key);

  @override
  State<InventarioPage> createState() => _InventarioPageState();
}

class _InventarioPageState extends State<InventarioPage> {

  final _scroll = ScrollController();
  final _invEm  = InventarioRepository();
  final _pzaEm  = PiezasRepository();
  final _txtCtr = TextEditingController();
  final _icoAcc = ValueNotifier<IconData>(Icons.search);

  late Future<void> _getPiezas;
  List<InventarioEntity> _lstPzas = [];
  Map<String, dynamic> _info = {};
  String _filTo = '';

  int page = 1;

  @override
  void initState() {
    _getPiezas = _recoveryPzas();
    super.initState();
  }

  @override
  void dispose() {
    _scroll.dispose();
    _txtCtr.dispose();
    _icoAcc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    Mget.init(context, context.read<GestDataProvider>());
    Future.delayed(const Duration(microseconds: 250), (){
      context.read<OrdenesProvider>().isShowHome = true;
    });
    
    return AscaffoldMain(
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            _head(),
            Expanded(
              child: FutureBuilder(
                future: _getPiezas,
                builder: (_, AsyncSnapshot snap) {
                  
                  if(snap.connectionState == ConnectionState.done) {
                    if(_lstPzas.isNotEmpty) {
                      return _lstPiezas();
                    }else{
                      return _sinData();
                    }
                  }

                  return _load();
                }
              ),
            )
          ]
        ),
      )
    );

  }

  ///
  Widget _sinData() {

    IconData ico = Icons.extension_off;
    String msg = 'Sin piezas en tu Inventario';

    if(_icoAcc.value == Icons.close) {
      ico = Icons.search_off;
      msg = 'No se encotraron resultados con el criterio solicitado.';
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        Icon(ico, size: 150, color: Mget.globals.secMain),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            msg,
            textAlign: TextAlign.center,
            textScaleFactor: 1,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 25,
              fontWeight: FontWeight.w200
            ),
          )
        ),
      ],
    );
  }

  ///
  Widget _lstPiezas() {

    return ListView.builder(
      controller: _scroll,
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      itemCount: _lstPzas.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (_, index) {
        
        final fts = List<Map<String, dynamic>>.from(_lstPzas[index].fotos);

        return TileOrdenPieza(
          pieza: _pzaEm.getPzaById(_lstPzas[index].pieza),
          idAuto: _lstPzas[index].auto,
          idOrden: _lstPzas[index].idOrden,
          created: DateTime.parse(_lstPzas[index].created),
          fotos: fts.map((e) => '${e['path']}').toList(),
          requerimientos: _lstPzas[index].deta,
          box: SharedDataOrden(),
          isInv: _lstPzas[index].id,
          onDelete: (id) async {
            bool? res = await _dialogEliminar();
            res = (res == null) ? false : res;
            if(res) {
              await _borrar(id);
              _lstPzas.removeAt(index);
              setState(() {});
            }
          },
        );
      },
    );
  }

  ///
  Widget _head() {

    return Container(
      padding: const EdgeInsets.only(top: 8, right: 5, bottom: 8, left: 10),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.black, width: 2)
        )
      ),
      child: Row(
        children: [
          _txtBusk(),
          const Spacer(),
          ValueListenableBuilder<IconData>(
            valueListenable: _icoAcc,
            builder: (_, val, child) {

              if(val == Icons.abc) { return child!; }

              return IconButton(
                onPressed: () async {
                  if(val == Icons.close) {
                    _txtCtr.text = '';
                    await _recoveryPzas();
                    _icoAcc.value = Icons.search;
                    setState(() {});
                  }else{
                    await _buscar();
                  }
                },
                icon: Icon(val, color: Colors.white)
              );
            },
            child: const SizedBox(
              width: 30, height: 30, child: CircularProgressIndicator(strokeWidth: 3)
            ),
          ),
          IconButton(
            onPressed: () => _dialogFiltrar(),
            icon: const Icon(Icons.filter_list, color: Colors.white)
          )
        ],
      ),
    );
  }

  ///
  Widget _txtBusk() {

    return Container(
      width: MediaQuery.of(context).size.width * 0.65,
      height: MediaQuery.of(context).size.height * 0.07,
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TextField(
        controller: _txtCtr,
        textInputAction: TextInputAction.search,
        onEditingComplete: (){},
        onSubmitted: (_) => _buscar(),
        decoration: InputDecoration(
          border: _border(),
          enabledBorder: _border(),
          focusedBorder: _border(),
          prefixIcon: const Icon(Icons.extension, color: Colors.grey, size: 15),
          prefixIconConstraints: const BoxConstraints(
            maxWidth: 30, minWidth: 30
          ),
          contentPadding: const EdgeInsets.all(5)
        ),
        style: const TextStyle(color: Colors.grey),
      )
    );
  }

  ///
  Widget _filtrarPorMenu() {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _txtIco(ico: Icons.directions_car_filled, label: 'POR MODELOS', fnc: 'modelos'),
        _txtIco(ico: Icons.abc, label: 'POR MARCAS', fnc: 'marcas'),
        _txtIco(ico: Icons.filter_alt_off, label: 'MOSTRAR TODOS', fnc: 'all'),
      ],
    );

  }

  ///
  Widget _txtIco({
    required IconData ico,
    required String label,
    required String fnc}) 
  {

    return TextButton.icon(
      onPressed: () async {
        if(fnc == 'all') {
          Navigator.of(context).pop();
          await _recoveryPzas();
          setState(() {});
        }else{
          _filTo = fnc;
          Navigator.of(context).pop();
          _modalFiltrarPor();
        }
      },
      icon: Icon(ico),
      label: _text(label)
    );
  }

  ///
  Widget _infoAlmacenamiento(StateSetter setDialog) {

    const sp = SizedBox(height: 10);
    return FutureBuilder(
      future: _getInfo(),
      builder: (_, AsyncSnapshot snap) {
        
        if(snap.connectionState == ConnectionState.done) {

          return Column(
            children: [
              _txtRow('total de piezas', _info['pzs']),
              sp,
              _txtRow('total de fotos', _info['fts']),
              sp,
              _txtRow('disco', '${_info['kb']} kbs.'),
              sp,
              sp,
              _status(),
              sp,
              const Divider(color: Colors.grey),
              _text('almacenamiento [ ${_info['mg']} Mgs. ]', fs: 13, cl: Colors.grey),
            ],
          );
        }
        
        return _load();
      },
    );
  }

  ///
  Widget _load() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  ///
  Widget _status() {

    const int tt = 250;
    double mgs = double.parse(_info['mg']);

    return Row(
      children: [
        _text('0', fs: 12),
        const SizedBox(width: 5),
        Expanded(
          child: LayoutBuilder(
            builder: (_, restrics) {

              double x = (mgs * restrics.maxWidth) / tt;
              final libres = tt - mgs;
              if(x < 1) { x = 10; }
              if(libres == tt) { x = 0; }

              return Container(
                constraints: BoxConstraints.expand(
                  width: restrics.maxWidth,
                  height: 20
                ),
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    Container(
                      color: Colors.blueGrey,
                    ),
                    Container(
                      width: x,
                      color: Colors.green,
                    ),
                    Center(
                      child: _text(
                        'Libres: ${libres.toStringAsFixed(2)} Mgs.',
                        fs: 12,
                        cl: Colors.black
                      ),
                    )
                  ],
                )
              );
            },
          ),
        ),
        const SizedBox(width: 5),
        _text('$tt',fs: 12),
      ],
    );
  }

  ///
  Widget _txtRow(String label, String value) {

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _text(label, fs: 14, cl: Colors.grey),
        _text(value, fs: 14, cl: Colors.white),
      ],
    );
  }

  ///
  Widget _text(String label, {double fs = 18, Color cl = Colors.green, bool ib = false}) {

    return Text(
      label.toUpperCase(),
      textScaleFactor: 1,
      style: TextStyle(
        fontSize: fs, color: cl,
        fontWeight: (ib) ? FontWeight.bold : FontWeight.normal
      ),
    );
  }

  ///
  Widget _tituDialog(IconData ico, String titulo) {

    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Mget.globals.bgMain
      ),
      child: Row(
        children: [
          Icon(ico, color: Colors.blueGrey),
          const SizedBox(width: 10),
          Text(
            titulo,
            textScaleFactor: 1,
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold
            )
          )
        ],
      )
    );
  }

  ///
  Widget _tileFilter(Map<String, dynamic> data) {

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Mget.globals.secMain,
        child: const Icon(Icons.car_repair, color: Colors.grey),
      ),
      onTap: () => _showFiltrados(data['invs']),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 20),
      title: _text(data['nombre'], cl: Mget.globals.bgMain, fs: 18, ib: true),
      subtitle: _text('Con ${data['invs'].length} elemntos...', cl: Colors.black, fs: 14),
    );
  }

  ///
  OutlineInputBorder _border() {

    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.grey, width: 0.8)
    );
  }

  ///
  Future<void> _dialogFiltrar() async {

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (_) => AlertDialog(        
        backgroundColor: Mget.globals.secMain,
        contentPadding: const EdgeInsets.all(15),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialog) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _tituDialog(Icons.filter_alt, 'FILTRAR RESULTADOS:'),
                _filtrarPorMenu(),
                const Divider(color: Colors.grey),
                _tituDialog(Icons.filter_frames, 'INFORMACIÓN GENERAL:'),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _infoAlmacenamiento(setDialog)
                )
              ],
            );
          }
        ),
      )
    );
  }

  ///
  Future<void> _modalFiltrarPor() async {

    await showModalBottomSheet(
      context: context,
      backgroundColor: Mget.globals.txtOnsecMainDark,
      builder: (_) {

        final pref = (_filTo) == 'modelos' ? 'LOS' : 'LAS';

        return Container(
          constraints: BoxConstraints.expand(
            height: MediaQuery.of(context).size.height * 0.45
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 7),
                color: Mget.globals.secMain,
                child: Center(
                  child: _tituDialog(Icons.filter_alt_rounded, 'ENTRE LOS [ ${_lstPzas.length} ] RESULTADOS:')
                )
              ),
              const SizedBox(height: 8),
              _text('Se encontraron $pref ${_filTo.toUpperCase()}...', cl: Mget.globals.secMain),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _filtrarResultadosBy(),
                  builder: (_, AsyncSnapshot<List<Map<String, dynamic>>> snap) {

                    if(snap.connectionState == ConnectionState.done) {
                      if(snap.hasData) {
                        return ListView.builder(
                          itemCount: snap.data!.length,
                          itemBuilder: (_, index) => _tileFilter(snap.data![index])
                        );
                      }
                    }

                    return _load();
                  },
                )
              )
            ],
          ),
        );
      }
    );
  }

  ///
  Future<bool?> _dialogEliminar() async {

    return await ShowDialogs.alert(
      context, 'deleteInv',
      hasActions: true,
      labelNot: 'NO',
      labelOk: 'CONTINUAR'
    );
  }

  ///
  Future<void> _recoveryPzas() async {
    _pzaEm.openBox();
    _lstPzas = await _invEm.getInventario(page);
  }

  ///
  Future<void> _buscar() async {

    _icoAcc.value = Icons.abc;
    await Future.delayed(const Duration(milliseconds: 250));
    
    int? criterio = int.tryParse(_txtCtr.text.trim());
    if(criterio != null) {

      /// Buscamos por id de inventario
      _lstPzas = await _invEm.buscarInvPorId(_txtCtr.text);
      
    }else{

      // Esto busca por nombre de piezas
      final lstSearch = await _pzaEm.buscarPiezas(_txtCtr.text);
      if(lstSearch.isNotEmpty) {
        _lstPzas = await _invEm.getInvByIdsPiezas(lstSearch);
      }else{
        _lstPzas = [];
      }
    }

    _icoAcc.value = Icons.close;
    _txtCtr.selection = TextSelection(baseOffset: 0, extentOffset: _txtCtr.value.text.length);
    setState(() {});
  }

  ///
  Future<void> _borrar(int id) async => await _invEm.deleteInvById(id);
 
  ///
  Future<void> _getInfo() async {

    if(_info.isEmpty) {
      _info = await _invEm.getInfo();
    }
  }

  ///
  Future<List<Map<String, dynamic>>> _filtrarResultadosBy() async {

    var em = SharedDataOrden();

    List<String> finded = [];
    List<Map<String, dynamic>> items = [];

    for (var i = 0; i < _lstPzas.length; i++) {

      em.auto = await em.solEm.getAutoById(_lstPzas[i].auto);
      if(em.auto != null) {

        late final dynamic entity;
        if(_filTo == 'modelos') {
          em.modelo = await em.solEm.getModeloById(em.auto!.modelo);
          entity = em.modelo;
        }else{
          em.marca = await em.solEm.getMarcaById(em.auto!.marca);
          entity = em.marca;
        }

        if(!finded.contains(entity!.nombre)) {

          finded.add(entity!.nombre);
          items.add({'nombre': entity!.nombre, 'cant': 0, 'invs':[_lstPzas[i].id]});
        }else{

          final has = items.indexWhere((element) => element['nombre'] == entity!.nombre);
          if(has != -1) {
            items[has]['invs'].add(_lstPzas[i].id);
          }
        }
      }
    }

    for (var i = 0; i < items.length; i++) {
      items[i]['cant'] = items[i]['invs'].length;
    }

    em = SharedDataOrden();
    finded = [];
    return items;
  }

  ///
  Future<void> _showFiltrados(List<int> invs) async {

    List<InventarioEntity> temp = [];
    for (var i = 0; i < _lstPzas.length; i++) {
      if(invs.contains(_lstPzas[i].id)) {
        temp.add(_lstPzas[i]);
      }
    }
    setState(() {
      _lstPzas = List<InventarioEntity>.from(temp);
      temp = [];
    });
    Navigator.of(context).pop();
  }
}