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
}