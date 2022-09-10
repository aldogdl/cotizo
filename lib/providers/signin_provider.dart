import 'package:flutter/foundation.dart' show ChangeNotifier;

import '../entity/account_entity.dart';
import '../repository/acount_user_repository.dart';

class SignInProvider  with ChangeNotifier {

  final userEm = AcountUserRepository();

  ///
  AccountEntity? _currentUser; 
  AccountEntity? get currentUser => _currentUser; 
  set currentUser(AccountEntity? user) {
    _currentUser = user;
    notifyListeners();
  }

  ///
  bool _isLogin = false; 
  bool get isLogin => _isLogin; 
  set isLogin(bool isLog) {
    _isLogin = isLog;
    notifyListeners();
  } 

  ///
  Future<void> login(Map<String, dynamic> data) async => await userEm.login(data);

  ///
  Future<void> logout() async {

    _currentUser = null;
    isLogin = false;
    Future.microtask(() async => await userEm.cleanAcount() );
  }

  ///
  Future<String> getCurc() async => await userEm.getCurc();

  ///
  Future<int> getIdUser() async => await userEm.getIdUser();

  ///
  Future<AccountEntity> getDataUser() async => await userEm.getDataUserInLocal();

}