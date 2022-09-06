import 'package:flutter/material.dart';

import '../../vars/globals.dart';

class CuentaNueva extends StatelessWidget {

  final Globals globals;
  const CuentaNueva({
    Key? key,
    required this.globals
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text.rich(
            TextSpan(
              text: 'TU CUENTA NUEVA DE EMAIL\n',
              style: TextStyle(
                color: globals.txtOnsecMainSuperLigth,
                fontSize: 16,
                height: 1.4
              ),
              children: [
                TextSpan(
                  text: 'Recomendamos ampliamente que el uso de esta cuenta sea '
                  'meramente comercial, AutoparNet utiliza este espacio de almacenamiento '
                  'para hacer respaldos de tu propio inventario de Autopartes.\n\n',
                  style: TextStyle(
                    color: globals.txtOnsecMainLigth,
                    fontSize: 13,
                  )
                ),
                const TextSpan(
                  text: 'AutoparNet, premia tu compromiso y fidelidad',
                  style: TextStyle(
                    fontSize: 13,
                  )
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          const Text(
            'Entre más respondas a las solicitudes\nde cotización, más '
            'almacenamiento\ntendrás para publicar tu inventario\ny mayor '
            'oportunidad de venta digital\ntu negocio tendrá.',
            textScaleFactor: 1,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              color: Colors.green
            ),
          )
        ],
      )
    );
  }
}