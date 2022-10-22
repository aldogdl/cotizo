import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'burbuja_piquito.dart';
import '../../config/sngs_manager.dart';
import '../../entity/chat_entity.dart';
import '../../providers/gest_data_provider.dart';
import '../../services/my_markdown.dart';
import '../../vars/constantes.dart';
import '../../vars/enums.dart';
import '../../vars/globals.dart';

class BurbujaDialog extends StatelessWidget {

  final ChatEntity msg;
  final bool isInteractive;
  final String labelOk;
  final String labelNot;
  final ValueChanged<Map<String, dynamic>>? onResponse;

  BurbujaDialog({
    Key? key,
    required this.msg,
    this.isInteractive = false,
    this.labelOk = 'COMENZAR',
    this.labelNot= 'SALIR',
    this.onResponse,
  }) : super(key: key);

  final Globals _globals = getIt<Globals>();
  final MyMarkDown _mark = MyMarkDown();
  
  @override
  Widget build(BuildContext context) {

    if(msg.from == ChatFrom.anet) {
      return _burguja(context);
    }

    return Dismissible(
      key: UniqueKey(),
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
        margin: (msg.from == ChatFrom.anet)
        ? EdgeInsets.only(right: margin, left: 0)
        : EdgeInsets.only(left: margin, right: 0),
        child: Column(
          crossAxisAlignment: (msg.from == ChatFrom.anet)
          ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  constraints: BoxConstraints(
                    minWidth: MediaQuery.of(context).size.width * 0.5
                  ),
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
                  child: _mark.getWidgetFormater(msg.value, msg.campo.name, from: msg.from.name)
                ),
                (msg.from == ChatFrom.anet) ? _topAnet(piquito) : _topResp(piquito)
              ],
            ),
            if(isInteractive)
              ...[
                const SizedBox(height: 10),
                Container(
                  margin: (msg.from == ChatFrom.anet)
                  ? const EdgeInsets.only(left: 10)
                  : const EdgeInsets.only(right: 10),
                  child: Row(
                    children: [
                      if(labelNot != 'onlyYes')
                        ...[
                          Expanded(
                            flex: 1,
                            child: _btn(labelNot, {'res':false})
                          ),
                          const SizedBox(width: 10),
                        ],
                      Expanded(
                        flex: 1,
                        child: _btn(labelOk, {'res':true}, isOk: true)
                      ),
                    ],
                  ),
                )
              ]
          ],
        ),
      ),
    );
  }

  ///
  Widget _topAnet(Widget child) => Positioned(top: 0, left: 0, child: child);

  ///
  Widget _topResp(Widget child) => Positioned(top: 0, right: 0, child: child);

  ///
  Widget _btn(String label, Map<String, dynamic> result, {bool isOk = false}) {

    return SizedBox(
      height: 40,
      child: ElevatedButton(
        style: ButtonStyle(
          padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 10)),
          elevation: MaterialStateProperty.all(0),
          backgroundColor: MaterialStateProperty.all(_globals.secMain)
        ),
        onPressed: () => onResponse!(result),
        child: Text(
          label,
          textScaleFactor: 1,
          style: TextStyle(
            color: (isOk)
            ? const Color.fromARGB(255, 241, 177, 0)
            : _globals.txtOnsecMainLigth
          ),
        )
      ),
    );
  }

}
