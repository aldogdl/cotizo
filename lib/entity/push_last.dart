import 'package:cotizo/entity/push_in_entity.dart';
import 'package:hive/hive.dart';

import '../vars/enums.dart';

part 'push_last.g.dart';

@HiveType(typeId: pushIn)
class PushLast extends HiveObject {

  @HiveField(0)
  Map<String, dynamic> pushIn = {};

  ///
  void fromPushEntity(PushInEntity push) {
     
    pushIn = {
      'id': push.id,
      'titulo': push.titulo,
      'subtitulo': push.subtitulo,
      'imgBig': push.imgBig,
      'payload': push.payload,
      'idOrd': push.idOrd,
      'indexOrden': push.indexOrden,
      'findedIn': push.findedIn,
    };
  }
}