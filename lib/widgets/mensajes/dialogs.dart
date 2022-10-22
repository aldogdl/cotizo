import 'dart:math';
import 'package:cotizo/services/utils_services.dart';

import '../../vars/constantes.dart';

class DialogsOf {

  ///
  static String icon(String tipo) {

    Map<String, dynamic> icos = {
      'apaz': '✌', 'cel': '🤳',
      'alert': '🙁', 'cam':'📸',
      'ok': '🙂', 'obs': '📝',
      'bell':'🔔', 'fine': '👍🏻',
      'sabe': '📲', 'chk': '☑️',
      'reg': '🎁', 'fel': '😃',
      'brav': '👏🏻',
      'play': '▶️'
    };
    return icos[tipo];
  }

  ///
  static String getTime({required int modo}) {

    modo = (modo == 0) ? 1 : modo;
    Map<int, List<String>> df = {
      1: [
        '${icon('bell')} Gracias por atender esta solicitud de cotización. '
        'En tan sólo 3 pasos estará lista PARA VENDER.\n\n'
        '${icon('brav')} Recuerda que premiamos tu atención y por cada vez que nos cotizas '
        'te ${icon('reg')} regalamos espacio de almacenamiento para tu ${icon('sabe')} INVENTARIO DIGITAL.'
      ],
      2: [
        '${icon('apaz')} ¡AutoparNet te desea el mejor de los éxitos para hoy, gracias por tu '
        'tiempo y dedicación en responder a esta cotización.'
      ],
      3: [
        '${icon('apaz')} ¡AutoparNet te desea éxito en tus ventas.'
      ]
    };
    return df[modo]!.first;
  }

  ///
  static String estasListo() {

    return '${icon('bell')} -EL ÉXITO de tu venta- radica en la calidad y costo '
    'de tus *AUTOPARTES*, te deseamos éxito en tus ventas del día.\n\n+¿Estás Listo?+';
  }

  ///
  static String fotos({required int modo}) {

    modo = (modo == 0) ? 1 : modo;
    Map<int, List<String>> df = {
      1: [
        '${icon('play')} Paso 1 de ${Constantes.pasosCot}.\n\n'
        '${icon('cel')} -AGREGA FOTOGRAFÍAS-. \n\n'
        '${icon('cam')} Recuerda que una buena foto *AYUDA AL CLIENTE* al momento '
        'de ver la refacción, por ello debe ser tomada lo más fiel a la realidad '
        'para no generar -expectativas falsas-.'
      ],
      2: [
        '${icon('play')} -Agrega de 1 a ${Constantes.cantFotos} FOTOGRAFIAS-...'
      ],
      3: [
        '${icon('play')} -De 1 a ${Constantes.cantFotos} FOTOS-...'
      ]
    };

    return df[modo]!.first;
  }

  ///
  static String detalles({required int modo}) {

    modo = (modo == 0) ? 1 : modo;
    Map<int, List<String>> df = {
      1: [
        '${icon('play')} Paso 3 de ${Constantes.pasosCot}.\n\n'
        '${icon('obs')} -Agrega DETALLES u OBSERVACIONES-. \n\n'
        'Escribe todo aquel detalle y condiciones en el que se '
        'encuentra la refacción.'
      ],
      2: [
        '${icon('play')} -Agrega DETALLES u OBSERVACIONES-...'
      ],
      3: [
        '${icon('play')} -DETALLES u OBSERVACIONES-...'
      ]
    };

    return df[modo]!.first;
  }

  ///
  static String costo({required int modo}) {
    
    modo = (modo == 0) ? 1 : modo;
    Map<int, List<String>> df = {
      1: [
        '${icon('play')} Paso 2 de ${Constantes.pasosCot}.\n\n'
        '${icon('ok')} -Agrega tu MEJOR COSTO-. \n\n'
        'Este es un factor importante para el éxito de tu venta.\n'
        '_Recuerda que los clientes siempre buscan oportunidades de compra.'
      ],
      2: [
        '${icon('play')} -Agrega tu MEJOR COSTO-...'
      ],
      3: [
        '${icon('play')} -TU MEJOR COSTO?-...'
      ]
    };

    return df[modo]!.first;
  }

  ///
  static String checkData({
    required int modo, List<String> params = const []})
  {
    modo = (modo == 0) ? 1 : modo;

    String msgFin = '${icon('obs')} +RESÚMEN:+.\n\n'
    '_Observaciones y/o Detalles_:\n'
    '${params[0].toUpperCase()}.\n\n'
    '_Costo para AutoparNet_:\n'
    '${UtilServices.toFormat(params[1].toUpperCase())}.\n\n';

    if(modo < 3) {
      msgFin = '$msgFin'
      '-PARA EDITAR UN DATO.-\n'
      'Sólo deslizalo hacia los lados y éste será cambiado.\n\n'
      '_GRACIAS POR TU ATENCIÓN._\n'
      '${icon('cel')} Esta pieza ya esta en tu inventario Digital.\n';
    }else{
      msgFin = '$msgFin'
      '${icon('fel')} GRACIAS POR TODO.\n';
    }

    return msgFin;
  }

  ///
  static String fotosAlert() {

    return '${icon('bell')} Por favor, para que tu publicación pueda ser aceptada, '
    'no coloques logotipos de empresas entre las fotos.';
  }

  ///
  static String errAwaitFotos({required int modo}) {

    modo = (modo == 0) ? 1 : modo;

    final msgs = [
      'Puedes agregar hasta ${Constantes.cantFotos} fotos.',
      '${icon('bell')} Recuenda... puedes seleccionar las ${Constantes.cantFotos} fotos al mismo tiempo.',
      'Entre más fotos, mejor para tu cliente. ${icon('fel')}',
      'Puedes usar la cámara si en tu galería no cuentas con más fotografías ${icon('ok')}.',
    ];

    if(modo == 3) { return '¿Deseas agregar más?'; }
    return msgs[_getRan(msgs.length)];
  }

  ///
  static String errAwaitFotosOk() {

    final msgs = [
      'En lugar de una en una puedes agregar las restantes de una sola vez.',
      'Puedes agregar las restantes de una sola vez :-)',
      '¡Buena elección!, sabes que una imagen vende más que mil palabras.',
      'Perfecto mil gracias...',
    ];

    return msgs[_getRan(msgs.length)];
  }

  ///
  static int _getRan(int max) {
    final rnd = Random();
    return rnd.nextInt(max);
  }

}