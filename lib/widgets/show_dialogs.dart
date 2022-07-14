import 'package:flutter/material.dart';

import '../config/sngs_manager.dart';
import '../vars/constantes.dart';
import '../vars/globals.dart';

class ShowDialogs {

  static final Globals _globals = getIt<Globals>();
  
  ///
  static Widget visorFotosDialog(BuildContext context, Widget child) {

    return AlertDialog(
      alignment: Alignment.bottomCenter,
      backgroundColor: Colors.black,
      contentPadding: const EdgeInsets.all(0),
      insetPadding: const EdgeInsets.all(0),
      scrollable: true,
      titlePadding: const EdgeInsets.all(0),
      buttonPadding: const EdgeInsets.all(0),
      content: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height - 100,
        child: child
      ),
    );
  }

  /// 
  static Future<bool?> alert(BuildContext context, String msg, {
    bool hasActions = false,
    String labelNot = '',
    String labelOk = '',
  }) async {

    return await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: Text(
          '${_msgs(msg)}',
          textScaleFactor: 1,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 19,
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: (hasActions)
        ? [_btnAction(context, labelNot, false), _btnAction(context, labelOk, true)]
        : [_btnAction(context, 'Entendido', false)],
      )
    );
  }

  ///
  static _msgs(String tipo) {

    String lado = (tipo == 'fotosCant') ? 'los lados.' : 'la derecha.';
    String fotos = '¡Por el momento ya cuentas con ${Constantes.cantFotos} fotos!\n\n'
      'Si deseas agregar otra, puedes eliminar la que menos te agrade deslizandola '
      'hacia ';
    final msg = {
      'fotosCant': '$fotos $lado',
      'fotosCantCam': '$fotos $lado',
      'exitCot': '¿Estás seguro de querer abandonar la cotización en curso?\n\n'
        'Esto provocará que todos los datos actualmente capturados se borren de '
        'memoria, los cuales no podrán ser recuperados.\n\n'
        '¿Aún así deseas salir de la cotización?',
      'noLogin': '¡UPS!, para poder RESPONDER esta solicitud...\n\n'
        'Necesitas autenticarte por medio de la cuenta de Google otorgada '
        'por Autoparnet.\n\n'
        '¿Deseas Autenticate ahora?',
      'errCam': '¡UPS!, ERROR al iniciar la Cámara\n\n'
        'Sucedio un error inesperado, por favor, intenta nuevamente entrar a '
        'esta sección.\n\n'
        'Sentimos el inconveniente.',
      'deleteInv': 'Se eliminará esta autoparte del sistema con la finalidad de '
      'no ocupar espacio de almacenamiento inecesario y mantener tu sistema lo más '
      'limpio y organizado posibe.\n\n¿Estás de acuardo en continuar con la operación?.'
    };
    return msg[tipo];
  }

  ///
  static Widget _btnAction(BuildContext context, String label, bool res) {

    final icono = (label.toLowerCase().contains('no'))
      ? Icons.close
      : Icons.done;
    
    Color color = _globals.bgMain;
    if(icono == Icons.done) {
      color = const Color.fromARGB(255, 92, 102, 196);
    }

    return ElevatedButton.icon(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(color)
      ),
      onPressed: () => Navigator.of(context).pop(res),
      icon: Icon(icono),
      label: Text(
        label,
        textScaleFactor: 1,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14
        ),
      )
    );
  }

}