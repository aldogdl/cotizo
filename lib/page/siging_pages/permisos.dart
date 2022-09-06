import 'package:flutter/material.dart';

import '../../vars/globals.dart';

class Permisos extends StatelessWidget {

  final Globals globals;
  const Permisos({
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
              text: 'PERMISOS Y MÁS PERMISOS\n',
              style: TextStyle(
                color: globals.txtOnsecMainSuperLigth,
                fontSize: 16,
                height: 1.4
              ),
              children: [
                TextSpan(
                  text: 'Al autenticarte con una cuenta de Email en tu teléfono, ',
                  style: TextStyle(
                    color: globals.txtOnsecMainLigth
                  )
                ),
                const TextSpan(
                  text: 'ésta solicita permisos para ingresar al contenido de almacenamiento ',
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text.rich(
            TextSpan(
              text: 'Para generar confianza en nuestra relación comercial, '
              'utiliza la cuenta otorgada por tu Asesor de Ventas Online.\n\n',
              style: TextStyle(
                color: globals.txtOnsecMainLigth,
                fontSize: 13,
                height: 1.4
              ),
              children: [
                TextSpan(
                  text: 'Tus cuentas personales no serán utilizadas para esta Aplicación.\n',
                  style: TextStyle(
                    color: globals.txtOnsecMainSuperLigth,
                    fontSize: 15,
                  )
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      )
    );
  }
}