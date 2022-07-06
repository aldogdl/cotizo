import 'dart:math';
import '../../vars/constantes.dart';

enum ModoDialog {dummy, expert}

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
  static String getTime({ModoDialog modo = ModoDialog.dummy}) {

    Map<ModoDialog, List<String>> df = {
      ModoDialog.dummy: [
        '${icon('bell')} Gracias por atender esta solicitud para la refacción: Facia trasera.\n'
        'En tan solo 3 pasos cotizarás esta solicitud.\n\n'
        '${icon('brav')} Recuerda que premiamos tu atención y por cada vez que nos cotizas '
        'te ${icon('reg')} regalamos espacio de almacenamiento para tu ${icon('sabe')} INVENTARIO DIGITAL.'
      ],
      ModoDialog.expert: [
        '${icon('apaz')} ¡Autoparnet te desea el mejor de los éxitos para hoy, gracias por tu '
        'tiempo y dedicación en responder a esta cotización.'
      ]
    };
    return df[modo]!.first;
  }

  ///
  static String estasListo({ModoDialog modo = ModoDialog.dummy}) {

    return '${icon('bell')} Recuerda... -EL ÉXITO de tu venta- radica en la calidad y costo '
    'de tus *AUTOPARTES*, que tengas muchas ventas el día de hoy.\n\n+¿Estás Listo?+';
  }

  ///
  static String fotos({ModoDialog modo = ModoDialog.dummy}) {

    Map<ModoDialog, List<String>> df = {
      ModoDialog.dummy: [
        '${icon('play')} Paso 1 de ${Constantes.pasosCot}.\n\n'
        '${icon('cel')} -AGREGA FOTOGRAFÍAS-. \n\n'
        '${icon('cam')} Recuerda que una buena foto *AYUDA AL CLIENTE* al momento '
        'de ver la refacción, por ello debe ser tomada lo más fiel a la realidad '
        'para no generar -expectativas falsas-.'
      ],
      ModoDialog.expert: [
        '${icon('play')} -Agrega tus ${Constantes.cantFotos} FOTOGRAFIAS-...'
      ]
    };

    return df[modo]!.first;
  }

  ///
  static String detalles({ModoDialog modo = ModoDialog.dummy}) {

    Map<ModoDialog, List<String>> df = {
      ModoDialog.dummy: [
        '${icon('play')} Paso 2 de ${Constantes.pasosCot}.\n\n'
        '${icon('obs')} -Agrega OBSERVACIONES-. \n\n'
        'Escribe todo aquel detalle y condiciones en el que se '
        'encuentra la refacción.'
      ],
      ModoDialog.expert: [
        '${icon('play')} -Agrega DETALLES u OBSERVACIONES-...'
      ]
    };

    return df[modo]!.first;
  }

  ///
  static String costo({ModoDialog modo = ModoDialog.dummy}) {
    
    Map<ModoDialog, List<String>> df = {
      ModoDialog.dummy: [
        '${icon('play')} Paso 3 de ${Constantes.pasosCot}.\n\n'
        '${icon('ok')} -Agrega tu MEJOR COSTO-. \n\n'
        'Este es un factor importante para el éxito de tu venta.\n'
        '_Recuerda que los clientes siempre buscan ese ingrediente.'
      ],
      ModoDialog.expert: [
        '${icon('play')} -Agrega tu MEJOR COSTO-...'
      ]
    };

    return df[modo]!.first;
  }

  ///
  static String checkData({
    ModoDialog modo = ModoDialog.dummy, List<String> params = const []
  }) {
    
    String msgFin = '${icon('obs')} +Estos son tus datos+.\n\n'
    '_Observaciones y/o Detalles_.\n'
    '${params[0].toUpperCase()}.\n\n'
    '_Costo para Autoparnet_.\n'
    '${params[1].toUpperCase()}.\n\n'
    '-PARA EDITAR UN DATO.-\n'
    'Sólo deslizalo hacia los lados y éste será cambiado.\n\n'
    '_GRACIAS POR TU ATENCIÓN._\n'
    '${icon('play')} Encuentra esta pieza en tu inventario.\n';

    Map<ModoDialog, List<String>> df = {
      ModoDialog.dummy: [msgFin],
      ModoDialog.expert: [msgFin]
    };

    return df[modo]!.first;
  }

  ///
  static String fotosAlert() {

    return '${icon('bell')} Por favor, para que tu publicación pueda ser aceptada, '
    'no coloques logotipos de tu empresa.';
  }

  ///
  static String errAwaitFotos({ModoDialog modo = ModoDialog.dummy}) {

    final msgs = [
      'Puedes agregar hasta ${Constantes.cantFotos} fotos por pieza.',
      'Recuenda... puedes agregar hasta ${Constantes.cantFotos} fotos por pieza.',
      'Ingresa hasta ${Constantes.cantFotos} fotos por pieza.',
      'Tu cotización puede llevar hasta ${Constantes.cantFotos} fotos por pieza.',
    ];
    Map<ModoDialog, dynamic> df = {
      ModoDialog.dummy: msgs, ModoDialog.expert: msgs
    };

    if(df[modo].length == 0) { return ''; }
    return df[modo][_getRan(df[modo].length)];
  }

  ///
  static String errAwaitFotosOk({ModoDialog modo = ModoDialog.dummy}) {

    final msgs = [
      'En lugar de una en una puedes agregar las restantes de una sola vez.',
      'Puedes agregar las restantes de una sola vez :-)',
      '¡Buena elección!, sabes que una imagen vende más que mil palabras.',
      'Perfecto mil gracias...',
    ];
    Map<ModoDialog, dynamic> df = {
      ModoDialog.dummy: msgs, ModoDialog.expert: msgs
    };

    if(df[modo].length == 0) { return ''; }
    return df[modo][_getRan(df[modo].length)];
  }

  ///
  static int _getRan(int max) {
    final rnd = Random();
    return rnd.nextInt(max);
  }

}