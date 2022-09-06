import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../repository/acount_user_repository.dart';

class SignInProvider  with ChangeNotifier {

  final userEm = AcountUserRepository();

  final _gSign = GoogleSignIn(
    scopes: ['email', 'https://www.googleapis.com/auth/drive.file']
  );
  GoogleSignIn get gSing => _gSign;

  ///
  GoogleSignInAccount? _currentUser; 
  GoogleSignInAccount? get currentUser => _currentUser; 
  set currentUser(GoogleSignInAccount? user) {
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
  Future<void> login() async {

    try {
      currentUser = await _gSign.signIn().catchError((_){
        currentUser = null;
      });
      if(currentUser != null) {
        isLogin = await _gSign.isSignedIn();
      }

    } on PlatformException catch (_) {
      isLogin = false;
    }
  }

  ///
  Future<void> logout() async {

    if(_gSign.currentUser != null) {
      try {
        await _gSign.currentUser!.clearAuthCache();
      } catch (_) {}
    }
    try {
      await _gSign.disconnect();
    } catch (_) {}
    
    _currentUser = null;
    Future.microtask(() async {
      await userEm.cleanAcount();
      isLogin = false;
    });
  }

  ///
  GoogleSignInAccount data() => _gSign.currentUser!;

  ///
  Future<bool> isSame() async {

    if(_gSign.currentUser != null) {
      final data = await userEm.getDataUserInLocal();
      if(data.id != 0) {
        if(data.email == _gSign.currentUser!.email) {
          return true;
        }
      }
    }
    return false;
  }

  ///
  String getCurc() {

    String curc = '';
    if(_gSign.currentUser != null) {

      final email = _gSign.currentUser!.email;
      if(email.contains('@')) {
        final partes = email.split('@');
        curc = partes.first;
      }
    }
    return curc;
  }

  ///
  String getIdOwn() {

    String curc = getCurc();
    if(curc.isNotEmpty) {
      final partes = curc.split('c');
      return partes.last;
    }
    return '';
  }

  ///
  Future<Map<String, dynamic>> metadata() async {

    return {
      'id': _gSign.currentUser!.id,
      'scopes': _gSign.scopes,
      'isLoged': await _gSign.isSignedIn(),
      'displayName': _gSign.currentUser!.displayName,
      'photoUrl': _gSign.currentUser!.photoUrl,
      'email': _gSign.currentUser!.email,
    };
  }


}