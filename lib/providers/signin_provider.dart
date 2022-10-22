import 'package:flutter/foundation.dart' show ChangeNotifier;

import '../entity/account_entity.dart';
import '../repository/acount_user_repository.dart';

class SignInProvider  with ChangeNotifier {

  final userEm = AcountUserRepository();

  /// Sabemos si es la primera ves que inicia la app para que en home
  /// no se realicen acciones en el Background ya que se realizaron en el Splash
  bool isFirstIniApp = false;
  /// Desde el splash se marco como verdadero si ya pasaron mas de 8 horas, con
  /// la finalidad de realizar tareas en el background
  bool goForData = false;
  /// En el momento que se halla checado la app marcamos esta variable como
  /// verdadera para que no se realice el chequeo cada ves que lleguemos a home
  bool yaCheckApp = false;

  /// Desabilitamos las notificaciones generadas internamente.
  bool _desablePushInt = false; 
  bool get desablePushInt => _desablePushInt; 
  set desablePushInt(bool desable) {
    _desablePushInt = desable;
    notifyListeners();
  }

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