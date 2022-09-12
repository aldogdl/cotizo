import 'package:camera/camera.dart';
import 'package:cotizo/providers/signin_provider.dart';
import 'package:cotizo/repository/acount_user_repository.dart';
import 'package:cotizo/repository/no_tengo_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../api/push_msg.dart';
import '../config/sngs_manager.dart';
import '../entity/account_entity.dart';
import '../repository/inventario_repository.dart';
import '../vars/globals.dart';

class SplashPage extends StatefulWidget {

  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {

  final ValueNotifier<String> _msgs = ValueNotifier<String>('Inicializando...');
  final _invEm   = InventarioRepository();
  final _ntgEm   = NoTengoRepository();
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
                      'assets/images/pistones.gif',
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

    bool isOk = await _revisandoCredenciales();
    if(!isOk) { return; }

    _msgs.value = 'Recuperando filtro Inventario';
    await Future.delayed(const Duration(milliseconds: 250));
    _globals.invFilter = await _invEm.getAllInvToFilter();

    _msgs.value = 'Limpiando almacén de Inexistentes';
    await Future.delayed(const Duration(milliseconds: 250));
    final ntgIds = await _ntgEm.getAllNoTengo();
    if(ntgIds.isNotEmpty) {
      _ntgEm.cleanAlmacenNtFromServer(ntgIds);
    }
    
    _msgs.value = 'Inicializando Mensajería';
    await Future.delayed(const Duration(milliseconds: 250));
    await pushMsg.init();
    
    _msgs.value = 'Configurando Aplicación';
    await Future.delayed(const Duration(milliseconds: 250));
      
    final cameras = await availableCameras();
    _globals.firstCamera = cameras.first;

    _msgs.value = 'Bienvenido a\nCOTIZO de AutoparNet';
    await Future.delayed(const Duration(milliseconds: 500));
    nav.go('/home');
  }

  ///
  Future<bool> _revisandoCredenciales() async {

    final nav = GoRouter.of(context);
    final siging = context.read<SignInProvider>();
    
    _msgs.value = 'Verificando Identidad';
    await Future.delayed(const Duration(milliseconds: 250));
    user = await _userEm.getDataUserInLocal();

    if(user!.id == 0) {

      _msgs.value = 'Autenticate por favor.';
      Future.delayed(const Duration(milliseconds: 1500), (){
        nav.go('/login');
      });
      return false;

    }else{

      _msgs.value = 'Bienvenido: ${user!.curc.toUpperCase()}';
      await _userEm.isTokenCaducado();
      
      if(_userEm.result['abort']) {
        _msgs.value = 'Actualizando Credenciales';
        await Future.delayed(const Duration(milliseconds: 250));
        await _userEm.login({'username':user!.curc, 'password': user!.password});
        
        if(_userEm.result['abort']) {
          _msgs.value = 'Autenticate por favor.';
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