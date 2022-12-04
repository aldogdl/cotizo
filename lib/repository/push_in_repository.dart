import 'package:hive/hive.dart';

import '../entity/push_in_entity.dart';
import '../entity/push_last.dart';
import '../vars/enums.dart';

class PushInRepository {

  final _boxName = HiveBoxs.pushIn.name;
  Box<PushLast>? _box;
  Box<PushLast> get box => _box!;

  ///
  Map<String, dynamic> result = {'abort':false, 'msg':'ok', 'body':[]};
  void cleanResult() {
    result = {'abort':false, 'msg':'ok', 'body':[]};
  }

  ///
  Future<void> openBox() async {

    if(!Hive.isAdapterRegistered(pushIn)) {
      Hive.registerAdapter<PushLast>(PushLastAdapter());
    }

    if(!Hive.isBoxOpen(_boxName)) {
      _box = await Hive.openBox<PushLast>(_boxName, compactionStrategy: (entries, deletedEntries) {
        return deletedEntries > 50;
      });
    }else{
      _box = Hive.box<PushLast>(_boxName);
    }
  }

  ///
  Future<void> setPushInLastInBox(PushInEntity pza) async {

    await openBox();
    if(_box != null) {
      if(_box!.isOpen) {

        bool existe = false;
        _box!.values.map((e) {
          existe = pza.isSame(pza, e.pushIn);
        }).toList();

        if(!existe) {
          final lastE = PushLast();
          lastE.fromPushEntity(pza);
          _box!.add(lastE);
        }
      }
    }
    return;
  }

  ///
  Future<Map<String, dynamic>> getPushInLastInBox() async {

    const base = 'https://autoparnet.com';

    await openBox();
    if(_box != null) {
      if(_box!.isOpen) {
        if(_box!.values.isNotEmpty) {
          final last = Map<String, dynamic>.from(_box!.values.last.pushIn);
          _box!.delete(_box!.values.last.key);
          if(last['payload'].toString().startsWith('http')) {
            last['payload'] = last['payload'].toString().replaceAll(base, '').trim();
          }
          return last;
        }
      }
    }
    return {};
  }
}