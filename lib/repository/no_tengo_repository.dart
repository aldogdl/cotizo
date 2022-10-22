import 'package:hive/hive.dart';

import '../entity/no_tengo_entity.dart';
import '../services/my_http.dart';
import '../services/my_paths.dart';
import '../vars/enums.dart';

class NoTengoRepository {

  final _http = MyHttp();

  final _boxName = HiveBoxs.noTengo.name;
  Box<NoTengoEntity>? _boxNt;

  ///
  Future<void> openBox() async {

    if(!Hive.isAdapterRegistered(noTengoHT)) {
      Hive.registerAdapter<NoTengoEntity>(NoTengoEntityAdapter());
    }

    if(!Hive.isBoxOpen(_boxName)) {
      _boxNt = await Hive.openBox<NoTengoEntity>(_boxName);
    }else{
      _boxNt = Hive.box<NoTengoEntity>(_boxName);
    }
  }

  ///
  Future<void> setBoxNoTengo(NoTengoEntity nt, {String fileSee = ''}) async {

    await openBox();

    if(_boxNt != null) {
      final has = _boxNt!.values.where(
        (i) => i.idOrd == nt.idOrd && i.idPza == nt.idPza
      );

      if(has.isNotEmpty) {
        await _boxNt!.put(has.first.key, nt);
      }else{
      
        await _boxNt!.add(nt);
        Map<String, dynamic> data = nt.toJson();
        if(fileSee.isNotEmpty) {
          data['see'] = fileSee;
        }
        setNtToServer(data);
      }
    }
  }

  ///
  Future<bool> existeInBoxNoTengo(int idOrd, int idPza) async {

    await openBox();
    if(_boxNt != null) {
      final has = _boxNt!.values.where((i) => i.idOrd == idOrd && i.idPza == idPza);
      return (has.isEmpty) ? false : true;
    }
    return false;
  }

  ///
  Future<String> getAllNoTengo() async {

    await openBox();
    List<int> idsOrd = [];
    if(_boxNt != null) {
      _boxNt!.values.map((nt){
        if(!idsOrd.contains(nt.idOrd)) {
          idsOrd.add(nt.idOrd);
        }
      }).toList();
    }
    return (idsOrd.length > 99) ? idsOrd.join(',') : '';
  }

  /// 
  Future<void> cleanAlmacenNtFromServer(String idOrds) async {

    await _http.get('get_all_ntg_filtros', params: '/$idOrds');
    
    if(!_http.result['abort']) {
      final elimOrds = List<String>.from(_http.result['body']);
      
      if(elimOrds.isNotEmpty) {

        List<int> toElim = elimOrds.map((e) => int.parse(e)).toList();
        await openBox();
        if(_boxNt != null) {
          for (var i = 0; i < toElim.length; i++) {
            var ntE = _boxNt!.values.firstWhere(
              (n) => n.idOrd == toElim[i], orElse: () => NoTengoEntity()
            );
            if(ntE.idOrd == toElim[i]) {
              await ntE.delete();
            }
          }
        }
        await _boxNt!.compact();
      }
    }
  }

  /// 
  Future<void> setNtToServer(Map<String, dynamic> json) async {

    Uri uri = MyPath.getUri('set_no_tengo', '');
    await _http.post(uri, data: json);
  }

}