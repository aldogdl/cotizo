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
    String labelOk = ''}) async
  {

    return await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        backgroundColor: _globals.secMain,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${_msgs(msg)}',
              textScaleFactor: 1,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 19,
                height: 1.2,
                color: _globals.txtComent
              ),
            ),
            const SizedBox(height: 8),
            _determinarWidget(msg),
            Divider(color: _globals.colorGreen, height: 3)
          ],
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actionsPadding: const EdgeInsets.only(top: 0, bottom: 10),
        actionsOverflowButtonSpacing: 0,
        actions: (hasActions)
        ? [
            _btnActionNot(context, labelNot),
            _btnActionOk(context, labelOk)
          ]
        : [
            _btnAction(
              Icons.done_all, 'Entendido', const Color.fromARGB(255, 92, 102, 196),
              () => Navigator.of(context).pop(true)
            )
          ],
      )
    );
  }

  ///
  static _msgs(String tipo) {

    String fotos = '¡Por el momento ya cuentas con ${Constantes.cantFotos} fotos!\n\n'
      'Si deseas agregar otra, elimina cualquiera de la lista dejandola presionada para seleccionarla.';
    final msg = {
      'fotosCant': fotos,
      'fotosCantCam': fotos,
      'fotosCantCamClose': 'CANCELANDO OPERACIÓN\n\n'
        'Estas saliendo de la cámara sin confirmar los cambios, esto borrará todos tus '
        'cambios y eliminará fotos de la cache.\n\n'
        '¿Estás segur@ de cancelar?',
      'errCam': '¡UPS!, ERROR al iniciar la Cámara\n\n'
        'Sucedio un error inesperado, por favor, intenta nuevamente entrar a '
        'esta sección.\n\n'
        'Sentimos el inconveniente.',
      'exitCot': '¿Estás seguro de querer abandonar la cotización en curso?\n\n'
        'Esto provocará que todos los datos actualmente capturados se borren de '
        'memoria, los cuales no podrán ser recuperados.\n\n'
        '¿Aún así deseas salir de la cotización?',
      'noLogin': '¡UPS!, para poder RESPONDER esta solicitud...\n\n'
        'Necesitas autenticarte por medio de la cuenta de acceso otorgada '
        'por AutoparNet.\n\n'
        '¿Deseas autenticarte ahora?',
      'noTengo': 'AGRADECEMOS TU AVISO\n\n'
        'Esta pieza en automático desaparecerá '
        'del listado de solicitudes.\n\n¿Estás segur@ de continuar?',
      'deleteInv': 'Se eliminará esta autoparte del sistema con la finalidad de '
        'no ocupar espacio de almacenamiento inecesario y mantener tu sistema lo más '
        'limpio y organizado posible.\n\n¿Estás de acuardo en continuar con la operación?.',
      'exitApp': '¿Realmente deseas salir de la aplicación de AutoparNet?',
      'pushTest': 'PRUEBA DE NOTIFICACIONES\n\n'
        'Se realizará una prueba para corroborar que tus notificaciones estén '
        'configuradas correctamente, por favor, selecciona el tipo de pueba que '
        'deseas hacer.\n\nToca la pantalla para CANCELAR.',
      'aparta': 'APARTANDO PIEZA\n\n'
        'Esta misma Marca, Modelo y Año, cuenta con más piezas que puedes '
        'aprovechar para vender.\n\n'
        '¿DESEAS APARTAR TODAS LAS DEMÁS PIEZAS?.'
    };
    return msg[tipo];
  }

  ///
  static Widget _determinarWidget(String tipo) {

    Widget wi = const SizedBox();
    switch (tipo) {
      case 'exitApp':
        
        wi = const SizedBox(
          width: 250,
          child: Image(
            image: AssetImage(
              'assets/images/logo_only.png',
            ),
            fit: BoxFit.contain,
          ),
        );
        break;
      default:
    }
    return wi;
  }

  ///
  static Widget _btnActionOk
    (BuildContext context, String label, {IconData ico = Icons.done})
  {
    final nav = Navigator.of(context);
    try {
      return _btnAction(
        ico, label, _globals.colorGreen, () => nav.pop(true)
      );
    } catch (e) {
      return const SizedBox();
    }
  }

  ///
  static Widget _btnActionNot
    (BuildContext context, String label, {IconData ico = Icons.close})
  {
    return _btnAction(
      ico,
      label,
      const Color.fromARGB(255, 70, 71, 73),
      () => Navigator.of(context).pop(false),
      txtColor: Colors.grey
    );
  }

  ///
  static Widget _btnAction
    (IconData icono, String label, Color color, Function fnc, {
      Color txtColor = const Color(0xFF202c33)
    })
  {

    return ElevatedButton.icon(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(color)
      ),
      onPressed: () => fnc(),
      icon: Icon(icono),
      label: Text(
        label,
        textScaleFactor: 1,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: txtColor,
          fontSize: 14
        ),
      )
    );
  }

}