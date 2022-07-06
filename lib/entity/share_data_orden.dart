import '../repository/soli_em.dart';
import 'autos_entity.dart';
import 'marca_entity.dart';
import 'modelo_entity.dart';
import 'pieza_entity.dart';

class SharedDataOrden {

  final solEm = SoliEm();
  AutosEntity? auto;
  MarcaEntity? marca;
  ModeloEntity? modelo;
  PiezaEntity? pieza;
}