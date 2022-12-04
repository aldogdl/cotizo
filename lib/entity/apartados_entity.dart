import 'package:hive/hive.dart';

import '../vars/enums.dart';

part 'apartados_entity.g.dart';
@HiveType(typeId: apartadosHT)
class ApartadosEntity extends HiveObject {

  @HiveField(0)
  int idOrd = 0;
  @HiveField(1)
  List<int> idPza = [];

  ///
  Map<String, dynamic> toJson() => {'ord': idOrd, 'pza': idPza};

}