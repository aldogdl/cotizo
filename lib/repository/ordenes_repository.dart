import '../services/my_http.dart';
import '../services/my_paths.dart';

class OrdenesRepository {

  final http = MyHttp();

  ///
  Map<String, dynamic> result = {'abort':false, 'msg':'ok', 'body':[]};
  void cleanResult() {
    result = {'abort':false, 'msg':'ok', 'body':[]};
  }

  /// Recuperamos todas las ordenes y sus piezas paginadas
  Future<List<Map<String, dynamic>>> getAllOrdenesAndPiezas
    (int page, String userWhere, int cantPerPege, {String call = 'otro'}) async
  {
    print('/$call/$page/$userWhere/$cantPerPege/');
    await http.get('get_ordenes_and_piezas', params: '/$call/$page/$userWhere/$cantPerPege/');
    result = Map<String, dynamic>.from(http.result);
    http.cleanResult();
    if(!result['abort']) {
      if(result['body'].isNotEmpty) {
        return List<Map<String, dynamic>>.from(result['body']);
      }
    }
    return [];
  }

  /// Recuperamos todas las ordenes y sus piezas apartadas por el usuario
  Future<List<Map<String, dynamic>>> getApartadosByData(List<Map<String, dynamic>> ap) async {

    Uri uri = MyPath.getUri('get_piezas_apartadas', '');
    await http.post(uri, data: {'ap':ap});
    result = Map<String, dynamic>.from(http.result);
    http.cleanResult();
    if(!result['abort']) {
      if(result['body'].isNotEmpty) {
        return List<Map<String, dynamic>>.from(result['body']);
      }
    }
    return [];
  }

  /// 
  Future<Map<String, dynamic>> getAOrdenAndPieza(int idOrd, String userWhere) async {

    await http.get('get_orden_and_pieza', params: '/$idOrd/$userWhere');
    result = Map<String, dynamic>.from(http.result);
    http.cleanResult();
    if(!result['abort']) {
      if(result['body'].isNotEmpty) {
        return Map<String, dynamic>.from(result['body']);
      }
    }
    return {};
  }

  /// 
  Future<Map<String, dynamic>> fetchCarnadaFromServer(Map<String, dynamic> ansuelo) async {
    
    Uri uri = MyPath.getUri('fetch_carnada', '');
    await http.post(uri, data: ansuelo);
    result = Map<String, dynamic>.from(http.result);
    http.cleanResult();
    if(!result['abort']) {
      if(result['body'].isNotEmpty) {
        return Map<String, dynamic>.from(result['body']);
      }
    }
    return {};
  }

  ///
  Future<Map<String, dynamic>> uploadImgOfRespuesta(Map<String, dynamic> data) async {

    final uri = MyPath.getUri('upload_img_rsp', '');
    await http.upFileByData(uri, metas: data);
    return http.result;
  }

}