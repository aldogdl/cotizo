import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../config/sngs_manager.dart';
import '../entity/orden_entity.dart';
import '../entity/chat_entity.dart';
import '../entity/share_data_orden.dart';
import '../providers/gest_data_provider.dart';
import '../providers/ordenes_provider.dart';
import '../vars/enums.dart';
import '../vars/globals.dart';
import '../widgets/send_respuesta.dart';
import '../widgets/tile_orden_pza_msg.dart';
import '../widgets/mensajes/get_anet_msg.dart';
import '../widgets/show_dialogs.dart';
import '../widgets/foot_fotos.dart';
import '../widgets/bg_img_pzas.dart';
import '../widgets/escribir_long.dart';
import '../widgets/mensajes/get_tipo_burbuja.dart';

class GestDataPage extends StatefulWidget {

  final int idP;
  const GestDataPage({
    Key? key,
    required this.idP,
  }) : super(key: key);

  @override
  State<GestDataPage> createState() => _GestDataPageState();
}

class _GestDataPageState extends State<GestDataPage> {

  final ScrollController _scroolCtr = ScrollController();
  final Globals _globals = getIt<Globals>();
  late final GestDataProvider _prov;
  late final OrdenesProvider _ordProv;
  OrdenEntity _orden = OrdenEntity();

  bool _isInit = false;
  bool _showOnlyMyMsgs = false;
  final List<int> _piezasForCot = [];

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(_initWidget);
    super.initState();
  }

  @override
  void dispose() {
    _scroolCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    if(!_isInit) {
      _isInit = true;
      _prov = context.read<GestDataProvider>();
      _ordProv = context.read<OrdenesProvider>();
    }

    return Scaffold(
      backgroundColor: _globals.bgMain,
      body: SafeArea(
        child: WillPopScope(
          onWillPop: () async {
            await _salirCot();
            return Future.value(false);
          },
          child: BGImgPzas(
            bgColor: _globals.bgMain,
            child: _body()
          ),
        ),
      )
    );
  }

  ///
  Widget _body() {

    return Column(
      children: [
        _laPieza(),
        Expanded(
          child: SizedBox.expand(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  top: 15,
                  child: _mensajes(),
                ),
                _fecha()
              ],
            ),
          ),
        ),
        Selector<GestDataProvider, Campos>(
          selector: (_, provi) => provi.currentCampo,
          builder: (_, campoActual, __) => _determinarFoot()
        )
      ]
    );
  }

  ///
  Widget _laPieza() {

    return Container(
      color: _globals.secMain,
      padding: const EdgeInsets.all(8),
      child: FutureBuilder(
        future: _getOrden(),
        builder: (_, AsyncSnapshot snap) {

          if(snap.connectionState == ConnectionState.done) {
            return TileOrdenPzaMsg(
              item: _orden, idPza: widget.idP, box: SharedDataOrden(),
            );
          }
          return SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.065,
            child: const Center(
              child: SizedBox()
            )
          );
        },
      )
    );
  }

  ///
  Widget _mensajes() {

    return Selector<GestDataProvider, List<ChatEntity>>(
      selector: (_, prov) => prov.msgs,
      builder: (_, lstChats, __){

        final wids = <Widget>[];
        for(var x = 0; x < lstChats.length; x++) {
          if(x == 0) {
            wids.add(const SizedBox(height: 35));
          }
          wids.add(GetTipoBurbuja(msg: lstChats[x]));
        }

        Future.delayed(const Duration(milliseconds: 450), (){
          _moveDown();
        });

        return ListView(
          controller: _scroolCtr,
          children: wids,
        );
      }
    );
  }

  ///
  Widget _fecha() {

    final hoy = DateTime.now();
    final dia = '${hoy.day}';
    final mes = '${hoy.month}';
    final es = '${dia.padLeft(2, '0')}-${mes.padLeft(2, '0')}-${hoy.year}';
    return Positioned(
      top: 10,
      child: Container(
        decoration: BoxDecoration(
          color: _globals.secMain,
          borderRadius: BorderRadius.circular(10)
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 12
        ),
        child: Text(
          'Gracias ! Hoy es: $es',
          textScaleFactor: 1,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.6)
          ),
        ),
      )
    );
  }

  ///
  Widget _determinarFoot() {

    switch (_prov.currentCampo) {

      case Campos.rFotos:
        return Padding(
          padding: const EdgeInsets.only(top: 16),
          child: FootFotos(
            onSend: (ChatEntity msg) async => _prov.addMsgs(msg),
            onClose: (_) async => await _salirCot(),
          )
        );
      case Campos.isCheckData:
        return _accionesFinal();
      default:
        if(_prov.currentCampo == Campos.none) {
          return const SizedBox();
        }
        return Padding(
          padding: const EdgeInsets.only(top: 3),
          child: EscribirLong(
            onSend: (ChatEntity msg) => _prov.addMsgs(msg),
            onClose: (_) async => await _salirCot(),
          ),
        );
    }
  }

  ///
  Widget _accionesFinal() {

    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.only(bottom: 1),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 13, 21, 26),
        borderRadius: BorderRadius.circular(5)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              '¿POR FAVOR, QUÉ DESEAS HACER?',
              textScaleFactor: 1,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _globals.txtOnsecMainDark,
                fontSize: 17
              )
            ),
          ),
          const SizedBox(height: 15),
          _linkFinal(
            'DESCARTAR COTIZACIÓN', ico: Icons.do_disturb_alt_sharp,
            fnc: () async => await _salirCot()
          ),
          if(!_showOnlyMyMsgs)
            _linkFinal(
              'VER SOLO TUS MENSAJES', ico: Icons.reset_tv_rounded,
              fnc: () async {
                await _prov.showResumen();
                _showOnlyMyMsgs = true;
                setState(() {});
              }
            ),
          _linkFinal(
            'TERMINAR Y ENVIAR', ico: Icons.check_circle_sharp,
            fnc: () async => await _terminarAndSend()
          ),
        ],
      ),
    );
  }

  ///
  Widget _linkFinal(String label, {required Function fnc, required IconData ico}) {

    return TextButton.icon(
      onPressed: () async => await fnc(),
      icon: Icon(ico, color: _globals.txtComent),
      label: Text(
        label,
        textScaleFactor: 1,
        style: TextStyle(
          color: (label.startsWith('TERMINAR'))
            ? Colors.blue : _globals.colorGreen,
          fontWeight: FontWeight.bold,
          fontSize: 16
        )
      ),
    );
  }
  
  ///
  Future<void> _initWidget(_) async {

    _prov.ansuelo = {};
    _prov.carnada = {};

    if(_prov.msgs.isEmpty) {

      if(_prov.showMsgEstasListo && _prov.modoCot <= 1) {

        ChatEntity? msg = await GetAnet.msg(ChatKey.none, id: 1, modo: _prov.modoCot);
        if(msg != null) {
          msg.campo = _prov.currentCampo;
          _prov.addMsgs(msg);
        }
        getNextMsg(msg);

      }else{

        if(_prov.modoCot < 3) {

          ChatEntity? msg = await GetAnet.msg(ChatKey.getAlertFotosLogos, id: 1, modo: _prov.modoCot);
          if(msg != null) {
            msg.campo = _prov.currentCampo;
            _prov.addMsgs(msg);
          }
          getNextMsg(msg);
          _prov.currentCampo = Campos.rFotos;
        }else{
          _prov.initCamAuto = true;
          _prov.currentCampo = Campos.rFotos;
        }
      }
    }
  }

  ///
  Future<void> _getOrden() async {

    if(_orden.id == 0) {

      _orden = _ordProv.items().firstWhere(
        (element) => element.id == _globals.idOrdenCurrent, 
        orElse: () => OrdenEntity()
      );

      // Se recaba la información necesaria para ir por la siguiente cotizacion
      // esta info es llamada el ANSUELO.
      // vamos al servidor por background para mostrarla despues de que el
      // cotizador termine de cotizar la pieza actual.
      final auto = await _ordProv.solEm.getAutoById(_orden.auto);
      if(auto != null) {

        int user = await _ordProv.solEm.getIdUser();
        // Tomamos los ides de las piezas, para saber al finalizar que esta
        // orden cuneta con mas piezas, y redirigir al user al estanque
        _orden.piezas.map((e) {
          if(e.id != widget.idP) {
            _piezasForCot.add(e.id);
          }
        }).toList();

        String from = 'cth';
        bool makeRegSee = true;
        if(_globals.idsFromLinkCurrent.isNotEmpty) {
          makeRegSee = false;
          // Pagina llamada desde el link, pero que link?
          if(!_globals.idsFromLinkCurrent.contains('pin')) {
            // Si el link contiene el sufix pin, es desde un push interno
            from = '';
            // Si dejamos vacio el from, es que viene de Whatsapp
          }
        }

        // Antes de buscar en el servidor observamos si hay mas ordenes en
        // cache, para tomar la orden que se mostrará como push al:
        // a) Final de cotizar,
        // b) Si cancela por algun medio la cotizacion en curso.
        _prov.carnada = {};
        _prov.ansuelo = _orden.buildAnsuelo(user, from, {
          'idOrdCurrent': _orden.id, 'user': user, 'mk': auto.marca 
        });
        _prov.ansuelo['setF'] = makeRegSee;
        
        final hasMore = _ordProv.items().where((element) => element.id != _orden.id);

        if(hasMore.isNotEmpty) {
          
          if(_piezasForCot.isEmpty) {
            // Si en cache no es vacio, buscamos la carnada en cache
            _prov.carnada = await _ordProv.fetchCarnada(
              auto: {'mk':auto.marca, 'md': auto.modelo, 'a':auto.anio},
              idOrdCurrent: _orden.id, user: user
            );
          }else {
            // Si la orden cuenta con mas de una pieza, tomamos la misma
            //orden siguiente pieza
            _prov.carnada = await _ordProv.fetchCarnadaSameOrden(
              idPCurrent: widget.idP, idOrdCurrent: _orden.id, user: user
            );
          }
        }else{
          _prov.ansuelo['at']['ido'] = _orden.id;
        }
      }
    }
  }

  ///
  void getNextMsg(ChatEntity? msg) async {

    if(_prov.msgs.isNotEmpty) {
      msg = await GetAnet.msg(_prov.msgs.last.key, id: _prov.msgs.length+1, modo: _prov.modoCot);
      if(msg != null) {
        msg.campo = _prov.currentCampo;
        _prov.addMsgs(msg);
      }
    }
  }

  ///
  Future<void> _terminarAndSend() async {

    bool isOk =  await _prov.isValidData();
    if(!isOk){ return; }

    await showModalBottomSheet(
      context: context,
      backgroundColor: _globals.bgMain,
      isDismissible: false,
      enableDrag: false,
      builder: (_) => WillPopScope(
        onWillPop: () => Future.value(false),
        child: SendRespuesta(
          tiempo: DateTime.now(),
          globals: _globals,
          orden: _orden, idPieza: widget.idP,
          onFinish: (_) async => await _salirCot(isFinish: true)
        ),
      )
    );
  }

  ///
  Future<void> _salirCot({bool isFinish = false}) async {
    
    bool alertar = false;
    if(!isFinish) {
      _prov.campos.forEach((key, value) {
        if(value.runtimeType != bool) {
          if(value.isNotEmpty) { alertar = true; }
        }
      });
    }

    if(!alertar) {
      _okExit(isFinish);
      return;
    }

    ShowDialogs.alert(
      context, 'exitCot',
      hasActions: true,
      labelNot: 'CONTINUAR AQUÍ',
      labelOk: 'SÍ, SALIR'
    ).then((res) {
      res = (res == null) ? false : res;
      if(res) {
        _okExit(isFinish);
      }
    });
  }

  ///
  void _okExit(bool isFinish) {

    if(_prov.currentCampo == Campos.none){ return; }

    String goBack = '/';
    if(isFinish) {
      if(_prov.carnada.isNotEmpty) {
        goBack = '/cotizo/${_prov.carnada['link']}';
        _ordProv.showAviso = true;
        if(_prov.carnada.containsKey('findedIn')) {
          _ordProv.avisoFrom = _prov.carnada['findedIn'];
        }
      }
    }

    if(goBack == '/') {
      if(_globals.histUri.isNotEmpty) {
        goBack = _globals.getBack();
      }
    }
    if(!goBack.contains('/cotizo/')) {
      _prov.launchCarnada();
    }
    _piezasForCot.clear();
    _prov.clean();
    context.go(goBack);
  }

  ///
  void _moveDown() {

    if(!mounted){ return; }
    _scroolCtr.animateTo(
      _scroolCtr.position.maxScrollExtent,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeIn
    );
  }

}
