import 'package:hive/hive.dart';

part 'inventario_entity.g.dart';

@HiveType(typeId: 5)
class InventarioEntity {

  // flutter packages pub run build_runner build
  // General
  @HiveField(0)
  String marca = '0';

  @HiveField(1)
  String modelo = '0';

  @HiveField(2)
  int anio = 0;

  @HiveField(3)
  bool isNac = true;

  // La Pieza
  @HiveField(4)
  String piezaName = '';

  @HiveField(5)
  String lado = '';

  @HiveField(6)
  String posicion = '';
  
  // La respuesta
  @HiveField(7)
  String costo = '0';

  @HiveField(8)
  String observs = '';

  @HiveField(9)
  List<String> fotos = [];

  @HiveField(10)
  double size = 0;

}