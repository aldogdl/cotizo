import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../api/push_msg.dart';
import '../config/sngs_manager.dart';
import '../repository/inventario_repository.dart';
import '../vars/globals.dart';

class SplashPage extends StatefulWidget {

  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {

  final ValueNotifier<String> _msgs = ValueNotifier<String>('Inicializando...');
  final _invEm = InventarioRepository();
  final _globals = getIt<Globals>();
  final pushMsg = getIt<PushMsg>();
  
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
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 22,
                    fontWeight: FontWeight.w200
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

    _msgs.value = 'Recuperando filtro Inventario';
    await Future.delayed(const Duration(milliseconds: 250));
    _globals.invFilter = await _invEm.getAllInvToFilter();

    _msgs.value = 'Inicializando Mensajer??a';
    await Future.delayed(const Duration(milliseconds: 250));
    await pushMsg.init();
    
    _msgs.value = 'Configurando Aplicaci??n';
    await Future.delayed(const Duration(milliseconds: 250));
      
    final cameras = await availableCameras();
    _globals.firstCamera = cameras.first;

    _msgs.value = 'Bienvendo a AutoparNet';
    await Future.delayed(const Duration(milliseconds: 500));
    nav.go('/home');
  }

}