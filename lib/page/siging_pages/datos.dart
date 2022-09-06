import 'package:flutter/material.dart';

import '../../vars/globals.dart';

class Datos extends StatelessWidget {

  final Globals globals;
  const Datos({
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
              text: 'AÚN ASÍ NO ESTÁ DE MÁS...\n',
              style: TextStyle(
                color: globals.txtOnsecMainSuperLigth,
                fontSize: 16,
                height: 1.4
              ),
              children: [
                TextSpan(
                  text: 'El sistema está creado y pensado para ser una extención más '
                  'a tus medios de venta tradicional como apoyo a incrementar tus ventas '
                  'y, lograr una SOCIEDAD COMERCIAL permanente entre tu negocio y AutoparNet.\n\n',
                  style: TextStyle(
                    color: globals.txtOnsecMainLigth,
                    fontSize: 13,
                  )
                ),
                const TextSpan(
                  text: 'Por esta razón no te preocupes por tu información ya que...',
                  style: TextStyle(
                    fontSize: 13,
                  )
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Row(
            children: const [
              Icon(Icons.done_all, size: 30, color: Colors.blue),
              SizedBox(width: 10),
              Text(
                'No Solicitamos datos Personales,\nni Confidenciales, mucho menos\n'
                'Datos Financieros o de algún tipo\nde transacción Bancaria.',
                textScaleFactor: 1,
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.green
                ),
              )
            ],
          )
        ],
      )
    );
  }
}