import 'package:hive/hive.dart';

import '../vars/enums.dart';
part 'config_app.g.dart';

@HiveType(typeId: configappHT)
class ConfigApp extends HiveObject {

  /// Sabemos si la app ya ha tenido un inicio
  @HiveField(0)
  bool isInit = false;
  
  /// El modo de cotizar: 0 = Viajero, 1 = Copiloto. 3 = Piloto
  @HiveField(1)
  int modoCot = 1;
  
  /// La ultima fecha y hora que entró a la app
  @HiveField(2)
  String inLast = '';

  /// Marcamos que el token server es invalid cuando se revisa en Background y
  /// este resulta invalido, para que en la siguiente sesion se renueve o al 
  /// momento de cotizar.
  @HiveField(3)
  bool invalidToken = true;

  /// Desabilitamos los push internos.
  @HiveField(4)
  bool desaPushInt = true;

  ///
  Map<String, dynamic> toJson() {
    return {
      'isInit': isInit,
      'modoCot': modoCot,
      'inLast': inLast,
      'invalidToken': invalidToken,
      'desaPushInt': desaPushInt,
    };
  }
}