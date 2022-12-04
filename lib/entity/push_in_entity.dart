import 'package:cotizo/services/my_paths.dart';

import 'orden_entity.dart';

class PushInEntity {
  
  int id = DateTime.now().second;
  String titulo = 'Oportunidad de Venta';
  String subtitulo = 'Tienes más piezas para cotizar :)\nAutoparNet Informa.';
  String imgBig = '0';
  String payload = '';
  int idOrd = 0;
  int indexOrden = -1;
  String findedIn = '';

  ///
  PushInEntity fromOrden(OrdenEntity orden, int user, int indOrden) {

    imgBig = orden.fotos[orden.piezas.first.id]!.first;
    imgBig = MyPath.getUriFotoPieza(imgBig);
    payload = _buildLinkForPush(orden, user);
    idOrd = orden.id;
    indexOrden = indOrden;
    findedIn = findedIn;
    return this;
  }

  /// 
  String _buildLinkForPush(OrdenEntity orden, int user) {

    const base = 'https://autoparnet.com/cotizo/';
    return '$base${orden.id}-$user-${orden.avo}-0-pin';
  }

  ///
  Map<String, dynamic> toJson() {

    return {
      'id': id,
      'titulo': titulo,
      'subtitulo': subtitulo,
      'imgBig': imgBig,
      'payload': payload,
      'idOrd': idOrd,
      'indexOrden': indexOrden,
      'findedIn': findedIn,
    };
  }

  ///
  void fromGlobals(Map<String, dynamic> data) {

    id = data['id'];
    titulo = data['titulo'];
    subtitulo = data['subtitulo'];
    imgBig = (data['imgBig'].toString().startsWith('htt'))
      ? data['imgBig'] : MyPath.getUriFotoPieza(data['imgBig']);
    payload = data['payload'];
    idOrd = data['idOrd'];
    indexOrden = data['indexOrden'];
    findedIn = data['findedIn'];
  }

  ///
  bool isSame(PushInEntity pza, Map<String, dynamic> last) {

    if(last['imgBig'] == pza.imgBig) {
      if(last['payload'] == pza.payload) {
        if(last['idOrd'] == pza.payload) {
          return true;
        }
      }
    }
    return false;
  }
}