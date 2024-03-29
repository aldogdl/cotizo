import 'package:hive/hive.dart';

import '../vars/enums.dart';
part 'pieza_entity.g.dart';

@HiveType(typeId: piezaHT)
class PiezaEntity extends HiveObject {

  final String avAt = 'aviso_atencion';

  @HiveField(0)
  int id = 0;

  @HiveField(1)
  String piezaName = '0';

  @HiveField(2)
  String origen = '0';

  @HiveField(3)
  String lado = '0';

  @HiveField(4)
  String posicion = '0';

  // La cantidad de veces que se ha solicitado esta misma pieza
  @HiveField(5)
  int cant = 0;

  ///
  void fromServer(Map<String, dynamic> json) {

    id = json['id'];
    piezaName = json['piezaName'];
    origen = json['origen'];
    lado = json['lado'];
    posicion = json['posicion'];
    cant = cant +1;
  }

  ///
  Map<String, dynamic> toJson() {

    return {
      'id': id,
      'piezaName': piezaName,
      'origen': origen,
      'lado': lado,
      'posicion': posicion,
      'cant': cant
    };
  }

  ///
  PiezaEntity avisoAtencion() {
    id = -1;
    piezaName = avAt;
    return this;
  }
}