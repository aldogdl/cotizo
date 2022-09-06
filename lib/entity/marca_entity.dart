import 'package:hive/hive.dart';

part 'marca_entity.g.dart';

@HiveType(typeId: 6)
class MarcaEntity extends HiveObject {

  @HiveField(0)
  int id = 0;

  @HiveField(1)
  String nombre = '';

  @HiveField(2)
  String logo = '';

  ///
  void fromServer(Map<String, dynamic> json) {

    id = json['id'];
    nombre = json['nombre'];
    logo = json['logo'];
  }

  ///
  Map<String, dynamic> toJson() {

    return {
      'id': id,
      'nombre': nombre,
      'logo': logo
    };
  }
}