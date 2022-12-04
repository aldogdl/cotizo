
import 'package:cotizo/services/my_http.dart';

/// Marcar como atendido, se usa desde el estanque y cuando se toma la carnada
/// desde los datos del cache.
Future<void> setRegOf(String file) async {

  if(file.isNotEmpty) {
    final http = MyHttp();
    await http.get('set_reg_of', params: '/$file/');
    http.cleanResult();
  }
  return;
}