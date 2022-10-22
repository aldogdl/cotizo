import 'package:hive/hive.dart';

import '../vars/enums.dart';
part 'no_tengo_entity.g.dart';

@HiveType(typeId: noTengoHT)
class NoTengoEntity extends HiveObject {

  @HiveField(0)
  int idCot = 0;
  @HiveField(1)
  int idPza = 0;
  @HiveField(2)
  int idOrd = 0;

  ///
  Map<String, dynamic> toJson() {

    return {
      'cot': idCot,
      'pza': idPza,
      'ord': idOrd
    };
  }

}