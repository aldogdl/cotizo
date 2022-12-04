import 'package:hive/hive.dart';

import '../vars/enums.dart';

part 'no_tengo_entity.g.dart';
@HiveType(typeId: noTengoHT)
class NoTengoEntity extends HiveObject {

  @HiveField(0)
  int idOrd = 0;
  @HiveField(1)
  List<int> idPza = [];

  ///
  Map<String, dynamic> toJson() => {'ord': idOrd, 'pza': idPza};

}