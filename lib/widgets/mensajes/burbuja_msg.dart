import 'package:flutter/material.dart';

import '../../config/sngs_manager.dart';
import '../../vars/globals.dart';

class BurbujaMsg extends StatelessWidget {

  final String msg;
  const BurbujaMsg({
    Key? key,
    required this.msg,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    final glob = getIt<Globals>();

    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        color: glob.secMain,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(10),
          bottomRight: Radius.circular(10),
          bottomLeft: Radius.circular(10),
        )
      ),
      child: Text(
        msg,
        textScaleFactor: 1,
        style: TextStyle(
          color: glob.txtAlerts,
          fontSize: 17,
          height: 1.3
        ),
      )
    );
  }
}