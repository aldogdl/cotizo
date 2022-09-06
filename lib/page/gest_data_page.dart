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
          builder: (_, campoActual, __) {

            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: _determinarFoot()
            );
          }
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
        return FootFotos(
          onSend: (ChatEntity msg) async => _prov.addMsgs(msg),
          onClose: (_) async => await _salirCot()
        );
      case Campos.isCheckData:
        return _accionesFinal();
      default:
        if(_prov.currentCampo == Campos.none) {
          return const SizedBox();
        }
        return EscribirLong(
          onSend: (ChatEntity msg) => _prov.addMsgs(msg),
          onClose: (_) async => await _salirCot()
        );
    }
  }

  ///
  Widget _accionesFinal() {

    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.28,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: _globals.secMain,
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
          _linkFinal(
            'VER SOLO TUS MENSAJES', ico: Icons.reset_tv_rounded,
            fnc: () async {
              await _prov.showResumen();
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

    if(_prov.msgs.isEmpty) {

      if(_prov.showMsgEstasListo) {

        ChatEntity? msg = await GetAnet.msg(ChatKey.none, id: 1, modo: _prov.modoDialog);
        if(msg != null) {
          msg.campo = _prov.currentCampo;
          _prov.addMsgs(msg);
        }
        getNextMsg(msg);

      }else{

        ChatEntity? msg = await GetAnet.msg(ChatKey.getAlertFotosLogos, id: 1, modo: _prov.modoDialog);
        if(msg != null) {
          msg.campo = _prov.currentCampo;
          _prov.addMsgs(msg);
        }
        getNextMsg(msg);
        _prov.currentCampo = Campos.rFotos;
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
    }
  }

  ///
  void getNextMsg(ChatEntity? msg) async {

    if(_prov.msgs.isNotEmpty) {
      msg = await GetAnet.msg(_prov.msgs.last.key, id: _prov.msgs.length+1, modo: _prov.modoDialog);
      if(msg != null) {
        msg.campo = _prov.currentCampo;
        _prov.addMsgs(msg);
      }
    }
  }

  ///
  Future<void> _salirCot() async {
    
    bool alertar = false;
    _prov.campos.forEach((key, value) {
      if(value.runtimeType != bool) {
        if(value.isNotEmpty) { alertar = true; }
      }
    });

    String goBack = '/';
    if(_globals.histUri.isNotEmpty) {
      goBack = _globals.getBack();
    }
    if(!alertar) {
      _prov.clean();
      context.go(goBack);
      return;
    }

    ShowDialogs.alert(
      context, 'exitCot',
      hasActions: true,
      labelNot: 'CONTINUAR',
      labelOk: 'SÍ, SALIR'
    ).then((res) {
      res = (res == null) ? false : res;
      if(res) {
        _prov.clean();
        context.go(goBack);
      }
    });
  }

  ///
  Future<void> _terminarAndSend() async {

    await showModalBottomSheet(
      context: context,
      backgroundColor: _globals.bgMain,
      isDismissible: false,
      enableDrag: false,
      builder: (_) => WillPopScope(
        onWillPop: () => Future.value(false),
        child: SendRespuesta(
          tiempo: DateTime.now(),
          prov: _prov, globals: _globals,
          orden: _orden, idPieza: widget.idP,
          onFinish: (_) async {
            _prov.clean();
            Navigator.of(context).pop();
            await Future.delayed(const Duration(milliseconds: 250));
            _salirCot();
          }
        ),
      )
    );
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
