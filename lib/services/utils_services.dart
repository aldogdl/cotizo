import 'package:intl/intl.dart' as intl;

class UtilServices {

  /// 
  static String toFormat(String number) {

    double? numero = 0.0;
    if(number.runtimeType == String) {
      if(number != '0') {
        numero = double.tryParse(number);
        numero = numero ??= 0.0; 
      }
    }
    return intl.NumberFormat.currency(locale: 'en_US', customPattern: '\$ #,###.##').format(numero);
  }

  /// 
  static String getRequerimientos(String req) {

    // Etiqueta para los cotizadores.
    const String eci = '<c>';
    const String ecf = '</c>';
    // Etiqueta para los solicitantes.
    const String esi = '<s>';
    const String esf = '</s>';

    req = req.toLowerCase().trim();
    if(req.contains(eci)){
      final partes = req.split(eci);
      for (var i = 0; i < partes.length; i++) {
        partes[i] = partes[i].trim();
        if(partes[i].endsWith(ecf)){
          req = partes[i].replaceAll(ecf, '');
        }
      }
    }else{

      if(req.contains(esi)) {
        final partes = req.split(esi);
        for (var i = 0; i < partes.length; i++) {
          partes[i] = partes[i].trim();
          if(partes[i].endsWith(esf)){
            req = partes[i].replaceAll(esf, '');
          }
        }
      }
    }
    
    req = (req.length > 225)
      ? '${req.substring(0, 225)}...' : req;
    
    req = (req == '0' || req.isEmpty) ? 'sin requerimientos específicos.' : req;

    return req.toUpperCase();
  }
}