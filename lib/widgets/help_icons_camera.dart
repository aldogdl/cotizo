import 'package:flutter/material.dart';

import '../config/sngs_manager.dart';
import '../vars/globals.dart';

class HelpIconsCamera extends StatelessWidget {

  final double width;
  final ValueChanged<void> onExit;

  HelpIconsCamera({
    Key? key,
    required this.width,
    required this.onExit,
  }) : super(key: key);

  final Globals _globals = getIt<Globals>();
  
  @override
  Widget build(BuildContext context) {

    const instrucT = <Map<String, dynamic>>[
      {
        'i': Icons.motion_photos_on_sharp,
        't': 'Haz click en este icono para tomar la fotografía.'
      },
      {
        'i': Icons.panorama,
        't': 'Después de tomar la fotografía podrás verla del lado izquierdo.'
      },
      {
        'i': Icons.arrow_back,
        't': 'Para ver maximizada la foto que tomaste, presiona sobre ella y '
        'desliza hacia la izquierda.'
      },
      {
        'i': Icons.zoom_in_map,
        't': 'Para ver detalles más cercanos podrás hacer zoom deslizando los dedos '
        'sobre la zona deseada.'
      },
      {
        'i': Icons.arrow_forward,
        't': 'Si deseas ELIMINAR alguna foto solo presiona sobre ella, y con tu dedo '
        'desliza hacia la derecha.'
      },
      {
        'i': Icons.close,
        't': 'Al presionar este icono cerrarás la cámara.'
      },
      {
        'i': Icons.done,
        't': 'Al seleccionar este icono enviarás todas las fotos tomadas.'
      },
    ];

    return RotatedBox(
      quarterTurns: 1,
      child: _bgHelp(
        context,
        width: width,
        child: ListView(
          controller: ScrollController(),
          children: [
            _titulo(),
            Divider(color: _globals.txtOnsecMainSuperLigth),
            _salir(),

            for(var i = 0; i < instrucT.length; i++)
              _instruc(icono: instrucT[i]['i'], txt: instrucT[i]['t']),
          ],
        )
      )
    );
  }

  ///
  Widget _titulo() {

    return Row(
      children: [
        Text.rich(
          const TextSpan(
            text: '¿Cómo utilizar la ',
            children: [
              TextSpan(
                text: 'CÁMARA',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold
                ),
              ),
              TextSpan(
                text: ' de Cotizo?'
              )
            ]
          ),
          textScaleFactor: 1,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: _globals.txtOnsecMainLigth
          ),
        )
      ],
    );
  }
  
  ///
  Widget _instruc({required IconData icono, required String txt}) {

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icono, color: Colors.blue),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              txt,
              textScaleFactor: 1,
              style: TextStyle(
                fontSize: 17,
                color: _globals.txtOnsecMainLigth
              ),
            )
          )
        ],
      ),
    );
  }

  ///
  Widget _salir() {

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.max,
      children: [
        TextButton(
          onPressed: () async => onExit(null),
          child: Text(
            'Salir de Ayuda',
            textScaleFactor: 1,
            style: TextStyle(
              color: _globals.txtAlerts,
              fontSize: 15
            ),
          )
        )
      ],
    );
  }

  ///
  Widget _bgHelp(BuildContext context, {required Widget child, required double width}) {

    return Container(
      width: width,
      height: MediaQuery.of(context).size.height,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage('assets/images/bg.jpg'),
          repeat: ImageRepeat.repeat,
          invertColors: true,
          colorFilter: ColorFilter.mode(_globals.bgMain, BlendMode.dst)
        )
      ),
      child: child
    );
  }

}