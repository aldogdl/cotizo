import 'package:hive/hive.dart';

import '../vars/enums.dart';
part 'autos_entity.g.dart';

@HiveType(typeId: autosHT)
class AutosEntity extends HiveObject {

  @HiveField(0)
  int id = 0;

  @HiveField(1)
  int anio = 0;

  @HiveField(2)
  bool isNac = true;

  @HiveField(3)
  int marca = 0;

  @HiveField(4)
  int modelo = 0;

  // La cantidad de veces que se ha solicitado este mismo auto
  @HiveField(5)
  int cant = 0;

  ///
  void fromServer(Map<String, dynamic> json, int idNew) {

    id = idNew;
    anio = json['anio'];
    isNac = json['isNac'];
    cant = cant + 1;
  }

  ///
  Map<String, dynamic> toJson() {

    return {
      'id': id,
      'marca': marca,
      'modelo': modelo,
      'anio': anio,
      'isNac': isNac,
      'cant': cant
    };
  }
}