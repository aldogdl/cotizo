import 'package:flutter/material.dart';

import '../../vars/globals.dart';

class Welcome extends StatelessWidget {

  final Globals globals;
  const Welcome({
    Key? key,
    required this.globals
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.all(20),
      child: Text.rich(
        TextSpan(
          text: 'AutoparNet, pensado en tu ',
          style: TextStyle(
            color: globals.txtOnsecMainDark,
            fontSize: 16,
            height: 1.4
          ),
          children: [
            TextSpan(
              text: 'CONFIANZA, SEGURIDAD Y COMODIDAD ',
              style: TextStyle(
                color: globals.txtOnsecMainSuperLigth
              )
            ),
            const TextSpan(
              text: 'utiliza los servicios  ',
            ),
            TextSpan(
              text: 'incluidos en tu teléfono inteligente ',
              style: TextStyle(
                color: globals.txtOnsecMainLigth
              )
            ),
            const TextSpan(
              text: 'para realizar respaldo de tu inventario para cualquier '
              'contrariedad.'
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}