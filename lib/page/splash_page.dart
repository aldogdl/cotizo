import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../api/push_msg.dart';
import '../config/sngs_manager.dart';
import '../entity/account_entity.dart';
import '../providers/signin_provider.dart';
import '../repository/config_app_repository.dart';
import '../repository/acount_user_repository.dart';
import '../repository/inventario_repository.dart';
import '../vars/globals.dart';

class SplashPage extends StatefulWidget {

  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {

  final ValueNotifier<String> _msgs = ValueNotifier<String>('Inicializando...');
  final _cngEm   = ConfigAppRepository();
  final _invEm   = InventarioRepository();
  final _userEm  = AcountUserRepository();
  final _globals = getIt<Globals>();
  final pushMsg  = getIt<PushMsg>();
  
  AccountEntity? user;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_initWidget);
  }

  @override
  void dispose() {
    _msgs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: ValueListenableBuilder<String>(
          valueListenable: _msgs,
          builder: (_,  val, __) {

            return Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Opacity(
                  opacity: 0.5,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.35,
                    child: Image.asset(
                      'assets/images/logo_only.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Text(
                  val,
                  textScaleFactor: 1,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.comfortaa(
                    textStyle: TextStyle(
                      color: _globals.colorGreen,
                      fontSize: 18,
                      height: 1.5
                    )
                  )
                )
              ],
            );
          },
        ),
      ),
    );
  }

  ///
  Future<void> _initWidget(_) async {

    final nav = GoRouter.of(context);
    if(_globals.firstCamera == null) {
      late List<CameraDescription> cameras;
      try {
        cameras = await availableCameras();
        _globals.firstCamera = cameras.first;
      } on CameraException catch (_) {
        // print('${e.code}, ${e.description}');
      }
    }
    
    bool isOk = await _revisandoCredenciales();
    if(!isOk) { return; }

    _msgs.value = 'Inicializando Mensajería';
    await Future.delayed(const Duration(milliseconds: 250));
    await pushMsg.init();

    _msgs.value = 'Bienvenido a\nCOTIZO de AutoparNet';
    await Future.delayed(const Duration(milliseconds: 250));
    await _cngEm.updateIfNotEmpty();

    nav.go('/home');
  }

  ///
  Future<bool> _revisandoCredenciales() async {

    final nav = GoRouter.of(context);
    final siging = context.read<SignInProvider>();
    siging.yaCheckApp = false;
    _msgs.value = 'Verificando Identidad';
    user = await _userEm.getDataUserInLocal();

    if(user!.id == 0) {

      _msgs.value = 'Autentícate por favor.';
      siging.isFirstIniApp = true;
      Future.delayed(const Duration(milliseconds: 1500), (){
        nav.go('/login');
      });
      return false;

    }else{
      
      _globals.idUser = user!.id;

      /// Revisamos que halla una inicialización previa
      final hoy = DateTime.now();
      DateTime? hasd = await _cngEm.hasData();
      if(hasd != null) {
        
        _msgs.value = 'BIENVENIDO DE NUEVO';
        siging.goForData = false;
        final diff = hoy.difference(hasd);
        if(diff.inSeconds > 28000) {
          siging.goForData = true;
        }
        
        final valid = await _cngEm.isValidToken();
        if(valid) {
          
          if(!siging.goForData) {
            _msgs.value = 'Preparando todo para ti';
            await Future.delayed(const Duration(milliseconds: 250));
            _globals.invFilter = await _invEm.getAllInvToFilter();
          }

          siging.isLogin = true;
          Future.delayed(const Duration(milliseconds: 100), (){
            nav.go('/home');
          });
          return false;
        }
      }

      _msgs.value = 'HOLA! ${user!.curc.toUpperCase()}';
      await Future.delayed(const Duration(milliseconds: 250));
      await _userEm.isTokenCaducado();

      if(_userEm.result['abort']) {
        _msgs.value = 'Actualizando Credenciales';
        await Future.delayed(const Duration(milliseconds: 250));
        await _userEm.login({'username':user!.curc, 'password': user!.password});
        
        if(_userEm.result['abort']) {
          _msgs.value = 'Autentícate por favor.';
          Future.delayed(const Duration(milliseconds: 1500), (){
            nav.go('/login');
          });
          return false;

        }else{
          await _userEm.setTokenServer(_userEm.result['body']);
        }
      }
    }

    siging.isLogin = true;
    return true;
  }

}