import 'package:flutter/material.dart';

import 'mensajes/dialogs.dart';

class AvisoAtencion extends StatelessWidget {

  const AvisoAtencion({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          // color: Color.fromARGB(255, 13, 21, 26),
          borderRadius: BorderRadius.circular(5)
        ),
        child: Column(
          children: [
            Text(
              DialogsOf.getTituloAtencion(),
              textScaleFactor: 1,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 15, fontWeight: FontWeight.bold,
                letterSpacing: 1.1
              ),
            ),
            const Divider(color: Colors.greenAccent),
            Text(
              DialogsOf.getMsgAtencion(),
              textScaleFactor: 1,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color.fromARGB(255, 114, 167, 115).withOpacity(0.7),
                fontSize: 16, fontWeight: FontWeight.normal,
                height: 1.3
              ),
            ),
          ],
        ),
      ),
    );
  }
}