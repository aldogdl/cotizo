import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'burbuja_image.dart';
import 'burbuja_dialog.dart';
import '../../entity/chat_entity.dart';
import '../../providers/gest_data_provider.dart';
import '../../services/my_get.dart';
import '../../vars/enums.dart';
import 'burbuja_msg.dart';

class GetTipoBurbuja extends StatelessWidget {

  final ChatEntity msg;
  const GetTipoBurbuja({
    Key? key,
    required this.msg
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    Mget.init(context, context.read<GestDataProvider>());

    switch (msg.tipo) {
      case ChatTip.msg:
        return BurbujaMsg(msg: msg.value);
      case ChatTip.interactive:
        return _getTipoInteractivo(context);
      case ChatTip.image:
        return BurbujaImage(msg: msg);
      default:
        return BurbujaDialog(msg: msg);
    }
  }

  ///
  Widget _getTipoInteractivo(BuildContext context) {

    switch (msg.key) {

      case ChatKey.estasListo:
        return BurbujaDialog(
          msg: msg,
          isInteractive: true,
          labelOk: 'COTIZAR AHORA',
          labelNot: 'NO, SALIR',
          onResponse: (Map<String, dynamic> res) {
            if(Mget.globals.goBackTo.isNotEmpty) {
              res['backUri'] = Mget.globals.goBackTo;
            }
            Mget.prov!.responseInteractive(context, res, msg.key);
          }
        );
      case ChatKey.errAwaitFotos:
        return BurbujaDialog(
          msg: msg,
          isInteractive: true,
          labelOk: 'NO DESEO AGREGAR MÁS',
          labelNot: 'onlyYes',
          onResponse: (Map<String, dynamic> res) => Mget.prov!.responseInteractive(context, res, msg.key)
        );
      default:
        return const SizedBox();
    }
  }

  // ///
  // Widget _msgsWidgets(BuildContext context) {

  //   switch (msg.key) {
  //     case 'estas_listo':
  //       return _estasListo();
  //     case 'alert_cantFotos':
  //       return _youAddMoreFotos(context);
  //     default:
  //   }
    
  //   Color color = _globals.txtComent;
  //   if(msg.tipo == 'frm') {
  //     color = _globals.txtFrmReq;
  //   }
  //   return Text(
  //     msg.value,
  //     textScaleFactor: 1,
  //     style: TextStyle(
  //       color: color,
  //       fontSize: 19,
  //       height: 1.2
  //     ),
  //   );
  // }

  
  // ///
  // Widget _estasListo(int id) {

  //   return BurbujaDialog(
  //     msg: ChatEntity(
  //       id: id,
  //       from: ChatFrom.anet,
  //       key: 'estas_listo',
  //       value: ''
  //     ),
  //     isInteractive: true,
  //     onResponse: (response) {
  //       if(response['res']) {
  //         Mget.prov.showWelcomeInChat = false;
  //         _setRequerimientosPza();
  //       }else{
  //         Mget.prov.clean();
  //         context.goNamed('home');
  //       }
  //     },
  //   );
  // }

  // ///
  // Widget _estasListo() {

  //   return Text.rich(
  //     const TextSpan(
  //       text: 'Recuerda... EL ÉXITO de tu venta radica en la calidad y costo '
  //       'de tus AUTOPARTES, que tengas muchas ventas el día de hoy.\n\n',
  //       children: [
  //         TextSpan(
  //           text: '¿Estás Listo?...',
  //           style: TextStyle(
  //             color: Colors.white,
  //             fontWeight: FontWeight.bold
  //           )
  //         )
  //       ]
  //     ),
  //     textScaleFactor: 1,
  //     style: TextStyle(
  //       color: Mget.globals.txtComent,
  //       fontSize: 19,
  //       height: 1.2
  //     ),
  //   );
  // }

  // ///
  // Widget _youAddMoreFotos(BuildContext context) {

  //   final cantNow = List<String>.from(
  //     context.read<GestDataProvider>().campos[Campos.rFotos]
  //   );
  //   int rest = (MyIm.cantFotos - cantNow.length);

  //   return Text.rich(
  //     TextSpan(
  //       text: 'Puedes agregar otras $rest fotos más.\n\n',
  //       children: const [
  //         TextSpan(
  //           text: '¿Deseas Agregar más?',
  //           style: TextStyle(
  //             color: Colors.white,
  //             fontWeight: FontWeight.bold
  //           )
  //         )
  //       ]
  //     ),
  //     textScaleFactor: 1,
  //     style: TextStyle(
  //       color: _globals.txtComent,
  //       fontSize: 19,
  //       height: 1.2
  //     ),
  //   );
  // }

  // ///
  // Widget _alertFotos() {
    
  //   return BurbujaDialog(
  //     msg: msg,
  //     isInteractive: true,
  //     labelNot: 'Ya no más',
  //     labelOk: 'Si Agregar más',
  //     onResponse: (resp) {
  //       if(resp['res']) {
  //         Mget.prov.addMsgs(ChatEntity(
  //           id: Mget.prov.msgs.length+1,
  //           from: ChatFrom.anet,
  //           key: 'none',
  //           value: DialogsOf.fotosMore(modo: Mget.prov.modoDialog)
  //         ));
  //       }else{
  //         Mget.prov.addMsgs(ChatEntity(
  //           id: Mget.prov.msgs.length+1,
  //           from: ChatFrom.anet,
  //           key: 'get_deta',
  //           value: 'Continuamos...'
  //         ));
  //       }
  //     },
  //   );
  // }
}