import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignInProvider  with ChangeNotifier {

  final _gSign = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/drive.file'
    ]
  );

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
      currentUser = await _gSign.signIn().catchError((e){
        currentUser = null;
      });
      if(currentUser != null) {
        if(currentUser!.email.contains('@')) {
          isLogin = await _gSign.isSignedIn();
        }
      }
    } on PlatformException catch (_) {
      isLogin = false;
    }
  }

  ///
  Future<void> logout() async {

    if(_gSign.currentUser != null) {
      await _gSign.currentUser!.clearAuthCache();
    }
    try {
      await _gSign.disconnect();
    } catch (_) {}
    _currentUser = null;
    isLogin = false;
  }

  ///
  GoogleSignInAccount data() => _gSign.currentUser!;

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