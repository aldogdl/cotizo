import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'burbuja_piquito.dart';
import '../../config/sngs_manager.dart';
import '../../entity/chat_entity.dart';
import '../../providers/gest_data_provider.dart';
import '../../vars/enums.dart';
import '../../vars/globals.dart';
import '../../vars/constantes.dart';

class BurbujaImage extends StatelessWidget {

  final ChatEntity msg;
  BurbujaImage({
    Key? key,
    required this.msg,
  }) : super(key: key);

  final Globals _globals = getIt<Globals>();

  @override
  Widget build(BuildContext context) {

    return Dismissible(
      key: Key('${msg.id}'),
      confirmDismiss: (direcc) => Future.value(true),
      onDismissed: (direcc) {
        context.read<GestDataProvider>().editMsgs(msg);
      },
      child: _burguja(context)
    );
  }

  ///
  Widget _burguja(BuildContext context) {

    double radius = 10;
    double alto = 250;
    double margin = MediaQuery.of(context).size.width * Constantes.marginBubble;
    Widget piquito = CustomPaint(
      size: const Size(20, 20),
      painter: BurbujaPiquito(
        bg: (msg.from == ChatFrom.anet) ? _globals.secMain : _globals.colorBurbbleResp,
        from: msg.from
      ),
    );
    
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: alto,
        margin: (msg.from == ChatFrom.anet)
        ? EdgeInsets.only(right: margin, left: 0)
        : EdgeInsets.only(left: margin, right: 0),
        child: LayoutBuilder(
          builder: (_, restrics) {
            return Column(
              crossAxisAlignment: (msg.from == ChatFrom.anet)
              ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        width: restrics.maxWidth,
                        height: alto,
                        padding: const EdgeInsets.all(10),
                        margin: (msg.from == ChatFrom.anet)
                        ? const EdgeInsets.only(left: 10)
                        : const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: (msg.from == ChatFrom.anet)
                          ? _globals.secMain
                          : _globals.colorBurbbleResp,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(radius),
                            bottomRight: Radius.circular(radius),
                            bottomLeft: Radius.circular(radius),
                          )
                        ),
                        child: SizedBox.expand(
                          child: _imageClean(restrics)
                        )
                      ),
                      (msg.from == ChatFrom.anet) ? _topAnet(piquito) : _topResp(piquito)
                    ],
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }

  ///
  Widget _imageClean(BoxConstraints restrics) {

    return Image.file(
      File(msg.value),
      alignment: Alignment.center,
      fit: BoxFit.cover,
      width: restrics.maxWidth,
    );
  }

  ///
  Widget _topAnet(Widget child) => Positioned(top: 0, left: 0, child: child);

  ///
  Widget _topResp(Widget child) => Positioned(top: 0, right: 0, child: child);

}