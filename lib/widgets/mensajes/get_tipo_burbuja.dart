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
          labelNot: 'CANCELAR',
          onResponse: (Map<String, dynamic> res) {
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

}