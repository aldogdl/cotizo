import 'pieza_entity.dart';

class OrdenEntity {

  int id = 0;
  DateTime createdAt = DateTime.now();
  String est = '0';
  String stt = '0';
  int auto = 0;
  int avo = 0;
  List<PiezaEntity> piezas = [];
  Map<int, String> obs = {};
  Map<int, List<String>> fotos = {};

  /// cth = desde Cotizar Home,
  /// nth = desde el no Tengo de Home
  /// nte = desde el no Tengo del Estanque
  /// pin = desde el push interno
  /// pch = Push interno datos tomados desde la cache
  /// 
  /// Construimos el link que simula un ingreso desde el link de WhatsApp
  String buildFileSee(int idUser, String from) {
    const ext = '.see';
    if(idUser == -1) {
      return '$from-${DateTime.now().microsecondsSinceEpoch}$ext';
    }
    return '$id-$idUser-$avo-$from-${DateTime.now().microsecondsSinceEpoch}$ext';
  }

  /// Construimos el link que simula un ingreso desde el link de WhatsApp
  String buildLinkIds(int idUser, String from) {
    return '$id-$idUser-$avo-$from';
  }

  /// Construimos el link que simula un ingreso desde el link de WhatsApp
  Map<String, dynamic> buildAnsuelo(int idUser, String from, Map<String, dynamic> auto) {
    return {
      'ct': idUser, 'se': buildFileSee(idUser, from), 'at': auto
    };
  }

  /// El campo autos y piezas debieron de ser hidratados desde antes.
  void fromServer(Map<String, dynamic> json) {
    
    id = json['id'];
    createdAt = DateTime.parse(json['createdAt']['date']);
    est = json['est'];
    stt = json['stt'];
    avo = json['avo']['id'];
  }

  /// El campo autos y piezas debieron de ser hidratados desde antes.
  Map<String, dynamic> toJson() {

    return {
      'id':id,
      'createdAt':createdAt,
      'est':est,
      'stt':stt,
      'auto': auto,
      'avo': avo,
      'piezas': piezas,
      'obs': obs,
      'fotos': fotos
    };
  }
}
