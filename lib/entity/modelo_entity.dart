  import 'package:hive/hive.dart';
  
  part 'modelo_entity.g.dart';
  
  @HiveType(typeId: 7)
  class ModeloEntity extends HiveObject {

    @HiveField(0)
    int id = 0;

    @HiveField(1)
    int marca = 0;

    @HiveField(2)
    String nombre = '';

    ///
    void fromServer(Map<String, dynamic> json) {

      id = json['id'];
      marca = json['marca'];
      nombre = json['nombre'];
    }

    ///
    Map<String, dynamic> toJson() {

      return {
        'id': id,
        'marca': marca,
        'nombre': nombre
      };
    }
  }