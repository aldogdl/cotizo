import 'pieza_entity.dart';

class OrdenEntity {

  int id = 0;
  DateTime createdAt = DateTime.now();
  String est = '0';
  String stt = '0';
  int auto = 0;
  List<PiezaEntity> piezas = [];
  Map<int, String> obs = {};
  Map<int, List<String>> fotos = {};


  /// El campo autos y piezas debieron de ser hidratados desde antes.
  void fromServer(Map<String, dynamic> json) {

    id = json['id'];
    createdAt = DateTime.parse(json['createdAt']['date']);
    est = json['est'];
    stt = json['stt'];
  }

  /// El campo autos y piezas debieron de ser hidratados desde antes.
  Map<String, dynamic> toJson() {

    return {
      'id':id,
      'createdAt':createdAt,
      'est':est,
      'stt':stt,
      'auto': auto,
      'piezas': piezas,
      'obs': obs,
      'fotos': fotos
    };
  }
}
