
import 'package:cotizo/services/my_http.dart';
import 'package:cotizo/services/my_paths.dart';

/// Utilizada para recuperar los datos de la carnada, y crear registros
/// A) Buscamos en el servidor una nueva orden para cotizar (CARNADA).
/// B) Creamos el archivo de atendido.
/// C) Guardamos el filtro de que maneja esta marca.
Future<Map<String, dynamic>> fetchCarnadaFiltrosAndSee(Map<String, dynamic> data) async {

  Uri uri = MyPath.getUri('fetch_next_ordto_cot', '');
  final http = MyHttp();
  await http.post(uri, data: data);
  final res = Map<String, dynamic>.from(http.result);
  http.cleanResult();
  return res;
}

/// Marcar como atendido, se usa desde el estanque y cuando se toma la carnada
/// desde los datos del cache.
Future<Map<String, dynamic>> setRegistroSee(String file) async {

  Uri uri = MyPath.getUri('fetch_next_ordto_cot', '');
  final http = MyHttp();
  await http.post(uri, data: {'se':file, 'setF': false, 'at':{}});
  final res = Map<String, dynamic>.from(http.result);
  http.cleanResult();
  return res;
}