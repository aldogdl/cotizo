import 'package:hive/hive.dart';

import '../vars/enums.dart';
import 'pieza_entity.dart';
part 'orden_entity.g.dart';

@HiveType(typeId: ordenHT)
class OrdenEntity extends HiveObject {

  final String itemFecha = 'indicador';

  @HiveField(0)
  int id = 0;

  @HiveField(1)
  DateTime createdAt = DateTime.now();

  @HiveField(2)
  String est = '0';

  @HiveField(3)
  String stt = '0';

  @HiveField(4)
  int auto = 0;

  @HiveField(5)
  int avo = 0;

  @HiveField(6)
  List<PiezaEntity> piezas = [];

  @HiveField(7)
  Map<int, String> obs = {};

  @HiveField(8)
  Map<int, List<String>> fotos = {};

  @HiveField(9)
  String type = 'cot';

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
      'est':est,
      'stt':stt,
      'avo': avo,
      'type': type,
      'auto': auto,
      'piezas': piezas,
      'obs': obs,
      'fotos': fotos,
      'createdAt':createdAt
    };
  }

}
