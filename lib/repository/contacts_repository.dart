import 'package:cotizo/entity/contact_entity.dart';
import 'package:hive/hive.dart';

import '../vars/enums.dart';

class ContactsRepository {

  
  final _boxName = HiveBoxs.contact.name;
  Box<ContactEntity>? box;
  
  ///
  Map<String, dynamic> result = {'abort':false, 'msg':'ok', 'body':[]};
  
  void cleanResult() {
    result = {'abort':false, 'msg':'ok', 'body':[]};
  }

  ///
  Future<void> openBox() async {

    if(!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter<ContactEntity>(ContactEntityAdapter());
    }

    if(!Hive.isBoxOpen(_boxName)) {
      box = await Hive.openBox<ContactEntity>(_boxName, compactionStrategy: (entries, deletedEntries) {
        return deletedEntries > 50;
      });
    }else{
      box = Hive.box<ContactEntity>(_boxName);
    }
  }
}