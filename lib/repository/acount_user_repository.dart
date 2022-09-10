import 'package:hive/hive.dart';

import '../api/push_msg.dart';
import '../config/sngs_manager.dart';
import '../entity/account_entity.dart';
import '../services/my_http.dart';
import '../vars/enums.dart';
import '../vars/my_paths.dart';

class AcountUserRepository {

  final _boxName = HiveBoxs.account.name;
  final http = MyHttp();

  Box<AccountEntity>? _box;
  
  ///
  Map<String, dynamic> result = {'abort':false, 'msg':'ok', 'body':[]};
  void cleanResult() {
    result = {'abort':false, 'msg':'ok', 'body':[]};
  }

  ///
  Future<void> openBox() async {

    if(!Hive.isAdapterRegistered(10)) {
      Hive.registerAdapter<AccountEntity>(AccountEntityAdapter());
    }

    if(!Hive.isBoxOpen(_boxName)) {
      _box = await Hive.openBox<AccountEntity>(_boxName);
    }else{
      _box = Hive.box<AccountEntity>(_boxName);
    }
  }

  /// Hacemos una revision si esta inicializada la variable box y abierta la caja
  Future<bool> _isMyOpen() async {

    bool ok = false;
    if(_box != null && _box!.isOpen) {
      ok = true;
    }else{
      await openBox();
      ok = true;
    }
    return ok;
  }

  ///
  Future<void> isTokenCaducado() async {

    http.token = await getTokenServer();
    await http.get('api_is_token_caducado', hasTkn: true);
    result = http.result;
    return;
  }

  ///
  Future<void> login(Map<String, dynamic> data) async {
    
    await http.makeLogin(data);
    result = http.result;
    http.cleanResult();
    return;
  }

  ///
  Future<void> recoveryDataUser(String curc) async {

    await http.get('get_user_by_campo', querys: {'campo':'curc', 'valor':curc});
    result = Map<String, dynamic>.from(http.result);
    http.cleanResult();
  }

  ///
  Future<AccountEntity> getDataUserInLocal() async {

    var us = AccountEntity();
    bool ok = await _isMyOpen();
    if(ok) {
      final user = _box!.values;
      if(user.isNotEmpty) {
        return user.first;
      }
    }
    return us;
  }

  ///
  Future<void> cleanAcount() async {

    bool ok = await _isMyOpen();
    if(ok) {
      await _box!.deleteFromDisk();
    }
  }

  ///
  Future<void> setDataUserInLocal(AccountEntity acount) async {

    bool ok = await _isMyOpen();
    if(ok) {
      final user = _box!.values.where((element) => element.id == acount.id);
      if(user.isNotEmpty) {
        await user.first.box!.put(user.first.key, acount);
      }else{
        await _box!.clear();
        await _box!.add(acount);
        await acount.save();
      }
    }
  }

  ///
  Future<void> setTokenMessaging(String? token) async {

    bool ok = await _isMyOpen();
    if(ok) {

      String elTk = '';
      if(token != null) {
        elTk = token;
      }else{

        final msgPush = getIt<PushMsg>();
        if(msgPush.fcmToken != null && msgPush.fcmToken!.isNotEmpty) {
          elTk = msgPush.fcmToken!;
        }
      }

      if(_box!.values.isNotEmpty) {

        final user = _box!.values.first;
        if(user.id != 0) {
          if(user.msgToken != elTk) {
            user.msgToken = elTk;
            user.save();
            Uri url = MyPath.getUri('set_token_messaging_by_id_user', '');
            await http.post(url, data: {'user':user.id, 'toSafe':'app', 'token':elTk});
          }
        }
      }

      elTk = '';
    }
  }

  ///
  Future<void> setTokenServer(String token) async {

    bool ok = await _isMyOpen();
    if(ok) {

      if(token.isNotEmpty) {  
        if(_box!.values.isNotEmpty) {

          final user = _box!.values.first;
          if(user.id != 0) {
            user.serverToken = token;
            user.save();
          }
        }
      }
    }
  }

  ///
  Future<int> getIdUser() async {

    bool ok = await _isMyOpen();
    if(ok) {
      final user = _box!.values;
      if(user.isNotEmpty) {
        return user.first.id;
      }
    }
    return 0;
  }

  ///
  Future<String> getCurc() async {

    bool ok = await _isMyOpen();
    if(ok) {
      final user = _box!.values;
      if(user.isNotEmpty) {
        return user.first.curc;
      }
    }
    return '';
  }

  ///
  Future<String> getTokenServer() async {

    bool ok = await _isMyOpen();
    if(ok) {
      final user = _box!.values;
      if(user.isNotEmpty) {
        return user.first.serverToken;
      }
    }
    return '';
  }

}
