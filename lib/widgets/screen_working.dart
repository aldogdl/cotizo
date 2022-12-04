import 'package:flutter/material.dart';

import '../vars/globals.dart';
class ScreenWorking {

  final BuildContext context;
  ScreenWorking({required this.context});

  static ScreenWorking of(BuildContext cntx) {
    return ScreenWorking(context: cntx);
  }

  ///
  static Future<bool> lounch(ScreenWorking w, {String msg = 'Un momento por favor.'}) async {
    show(w.context, msg: msg);
    return true;
  }

  ///
  static Future<void> show(BuildContext cntx, {String msg = 'Un momento por favor.'}) async {

    showDialog(
      context: cntx,
      barrierDismissible: false,
      barrierColor: Globals().bgAppBar,
      builder: (_) => SimpleDialog(
        alignment: Alignment.center,
        elevation: 0,
        backgroundColor: Globals().bgAppBar,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  msg.toUpperCase(),
                  textScaleFactor: 1,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15.5
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Realizando tu Solicitud',
                  textScaleFactor: 1,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 15
                  ),
                ),
              ],
            ),
          )
        ],
      )
    );
  }
}