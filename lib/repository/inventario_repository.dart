import 'package:hive/hive.dart';

import '../entity/inventario_entity.dart';
import '../vars/enums.dart';

class InventarioRepository {

  final _boxName = HiveBoxs.inventario.name;
  Box<InventarioEntity>? _boxInv;

  ///
  Future<void> openBox() async {

    if(!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter<InventarioEntity>(InventarioEntityAdapter());
    }

    if(!Hive.isBoxOpen(_boxName)) {
      _boxInv = await Hive.openBox<InventarioEntity>(_boxName, compactionStrategy: (entries, deletedEntries) {
        return deletedEntries > 50;
      });
    }else{
      _boxInv = Hive.box<InventarioEntity>(_boxName);
    }
  }

  ///
  Future<void> setBoxInv(InventarioEntity inv) async {

    await openBox();
    if(_boxInv != null) {
      _boxInv!.add(inv);
    }
  }
}