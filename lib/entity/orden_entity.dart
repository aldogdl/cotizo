import 'package:hive/hive.dart';

part 'orden_entity.g.dart';

@HiveType(typeId: 8)
class OrdenEntity extends HiveObject {

  @HiveField(0)
  int id = 0;

  @HiveField(1)
  DateTime createdAt = DateTime.now();

  @HiveField(2)
  String est = '0';

  @HiveField(3)
  String stt = '0';

  @HiveField(4)
  // El id del reg del auto
  int auto = 0;

  @HiveField(5)
  // Los ids de los registros de pieza
  List<int> piezas = [];

  @HiveField(6)
  Map<int, String> obs = {};

  @HiveField(7)
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
