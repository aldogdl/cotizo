import 'pieza_entity.dart';

class OrdenEntity {

  final String itemFecha = 'indicador';

  int id = 0;
  DateTime createdAt = DateTime.now();
  String est = '0';
  String stt = '0';
  int auto = 0;
  int avo = 0;
  List<PiezaEntity> piezas = [];
  Map<int, String> obs = {};
  Map<int, List<String>> fotos = {};

  /// El campo autos y piezas debieron de ser hidratados desde antes.
  void of(Map<String, dynamic> json) {
    
    id = json['id'];
    createdAt = json['createdAt'];
    est = json['est'];
    stt = json['stt'];
    avo = json['avo'];
    auto= json['auto'];
    piezas = List<PiezaEntity>.from(json['piezas']);
    obs = Map<int, String>.from(json['obs']);
    fotos = Map<int, List<String>>.from(json['fotos']);
  }

  /// El campo autos y piezas debieron de ser hidratados desde antes.
  void fromServer(Map<String, dynamic> json) {
    
    id = json['id'];
    if(json['createdAt'].runtimeType == DateTime) {
      createdAt = json['createdAt'];
    }else{
      createdAt = DateTime.parse(json['createdAt']['date']);
    }
    est = json['est'];
    stt = json['stt'];
    avo = json['avo']['id'];
  }

  /// Una orden falsa que sirve de indicador de fechas.
  OrdenEntity toIndicador(DateTime fecha, String tipo) {
    
    id = 100000000000;
    createdAt = fecha;
    est = itemFecha;
    stt = tipo;
    avo = 0;
    return this;
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
