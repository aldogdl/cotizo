import 'package:hive/hive.dart';

import '../vars/enums.dart';
part 'inventario_entity.g.dart';

@HiveType(typeId: inventarioHT)
class InventarioEntity extends HiveObject {

  @HiveField(0)
  int id = 0;

  @HiveField(1)
  int auto = 0;

  @HiveField(2)
  int pieza = 0;

  @HiveField(3)
  double costo = 0.0;

  @HiveField(4)
  String deta = '';

  @HiveField(5)
  List<Map<String, dynamic>> fotos = [];

  @HiveField(6)
  int shared = 0;

  @HiveField(7)
  String created = DateTime.now().toIso8601String();

  // Se necesitan ciertos datos que relacionen este inventario con la orden
  // y la pieza que fue respondida para no mostrarla entre la lista de las que
  // faltan de responder.
  @HiveField(8)
  int idOrden = 0;

  @HiveField(9)
  int idPieza = 0;

  ///
  void fromJson(Map<String, dynamic> json) {

    String fecha = DateTime.now().toIso8601String();

    if(json.containsKey('created')) {
      if(json['created'].runtimeType == DateTime) {
        fecha = json['created'].toIso8601String();
      }else{
        fecha = json['created'];
      }
    }

    id     = json['id'];
    auto   = json['auto'];
    pieza  = json['pieza'];
    costo  = json['costo'];
    deta   = json['deta'];
    idOrden= json['idOrden'];
    idPieza= json['idPieza'];
    fotos  = List<Map<String, dynamic>>.from(json['fotos']);
    shared = (json.containsKey('shared')) ? json['shared'] : 0;
    created= fecha;
  }

  ///
  Map<String, dynamic> toJson() {

    return {
      'id'    : id,
      'auto'  : auto,
      'pieza' : pieza,
      'costo' : costo,
      'deta'  : deta,
      'fotos' : fotos,
      'shared': shared,
      'idOrden': idOrden,
      'idPieza': idPieza,
      'created': created,
    };
  }

  ///
  Map<String, dynamic> toServer() {

    List<String> fts = [];
    if(fotos.isNotEmpty) {
      for (var i = 0; i < fotos.length; i++) {
        fts.add('$idOrden-${fotos[i]['name']}');
      }
    }
    return {
      'id'    : id,
      'costo' : costo,
      'deta'  : deta,
      'fotos' : fts,
      'idOrden': idOrden,
      'idPieza': idPieza
    };
  }

}