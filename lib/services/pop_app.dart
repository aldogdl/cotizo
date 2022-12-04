import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemNavigator;
import 'package:go_router/go_router.dart';
// import 'package:image/image.dart';
import 'package:provider/provider.dart';

import '../api/push_msg.dart';
import '../config/sngs_manager.dart';
import '../entity/push_in_entity.dart';
import '../providers/signin_provider.dart';
import '../providers/ordenes_provider.dart';
import '../repository/push_in_repository.dart';
import '../widgets/screen_working.dart';
import '../widgets/show_dialogs.dart';
import '../vars/globals.dart';

class PopApp {

  final _globals = getIt<Globals>();
  final _pushEm = PushInRepository();

  ///
  Future<void> onWill(BuildContext context) async {

    final nav = GoRouter.of(context);
    final ordProv = context.read<OrdenesProvider>();

    // Cuando el usuario presiona el BTN de Atras del Device:
    if(nav.location.contains('/home')) {
      
      // 1.- opcion es desacer el filtro...
      if(ordProv.typeFilter['select'].isNotEmpty) {
        ordProv.pressBackDevice = ordProv.pressBackDevice + 1;
        return;
      }

      // 2.- Ver si no estamos en la seccion de listado de piezas
      if(ordProv.currentSeccion != 'por piezas') {
        ordProv.changeToSeccion = ordProv.changeToSeccion + 1;
        return;
      }
    }

    if(nav.location.contains('/estanque') || nav.location.contains('/home')) {

      bool acc = await _showAlertBye(context, nav.location);
      if(!acc) { return; }
      if(acc && nav.location.contains('/home')) {
        SystemNavigator.pop();
        return;
      }else{
        nav.go('/home');
      }
    }else{

      // Hacemos un refuerzo por medio del historial de rutas
      if(_globals.histUri.last.contains('estanque')) {
        bool acc = await _showAlertBye(nav.routerDelegate.navigatorKey.currentContext!, '/estanque');
        if(!acc) {
          return;
        }
      }
    }

    final goBack = _globals.getBack();
    nav.go(goBack);
  }

  ///
  Future<bool> _showAlertBye(BuildContext context, String page) async {

    final nav = Navigator.of(context);
    final screen = ScreenWorking.of(context);
    bool? acc = await _showAlertExit(context, page);
    acc = (acc == null) ? false : !acc;

    if(acc) {

      if(page.contains('/estanque')) { return acc; }

      ScreenWorking.lounch(screen, msg: 'Gracias por tu preferencia');
      await Future.delayed(const Duration(milliseconds: 250));
      if(_globals.pushIn.isNotEmpty) {
        if(nav.mounted) {
          await _lounchPushIn(nav.context);
        }
      }
      nav.pop(true);
    }
    return acc;
  }

  ///
  Future<bool?> _showAlertExit(BuildContext context, page) async {

    String tipo = 'exitApp';
    if(page.contains('/estanque')) {
      return await _showDialogNt(context);
    }

    return await ShowDialogs.alert(
      context, tipo, hasActions: true,
      labelNot: 'SÍ, SALIR',
      labelOk: 'SEGUIR AQUÍ',
    );
  }

  ///
  Future<void> _lounchPushIn(BuildContext context) async {

    if(!context.read<SignInProvider>().desablePushInt) {

      final pushs = getIt<PushMsg>();
      final carnada = PushInEntity();
      carnada.fromGlobals(_globals.pushIn);
      await pushs.makePushInterno(carnada);
      await _pushEm.setPushInLastInBox(carnada);
      _globals.pushIn = {};
      await Future.delayed(const Duration(milliseconds: 1500));
    }
  }

  ///
  Future<bool?> _showDialogNt(BuildContext context) async {

    return await showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (_) => AlertDialog(
        backgroundColor: Globals().bgMain,
        icon: const Icon(Icons.warning_amber),
        iconColor: Colors.amber,
        shape: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color.fromARGB(255, 102, 102, 102))
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        title: const Text(
          'SÓLO 3 SEGUNDOS...',
          textScaleFactor: 1,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.blueAccent
          ),
        ),
        content: _widgetForDialogApartar(),
        actionsAlignment: MainAxisAlignment.spaceAround,
        actions: [
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.white)
            ),
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'SALIR',
              textScaleFactor: 1,
              style: TextStyle(
                color: Color.fromARGB(255, 46, 105, 48),
                fontWeight: FontWeight.bold
              ),
            )
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'ATENDER SOLICITUD',
              textScaleFactor: 1,
              style: TextStyle(
                fontWeight: FontWeight.bold
              ),
            )
          )
        ],
      ),
    );
  }

  ///
  Widget _widgetForDialogApartar() {

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Divider(color: Colors.green),
        Text(
          'Al presionar [ NO LA TENGO ], '
          'Limpias tu lista de solicitudes y\na su vez...',
          textScaleFactor: 1,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 18,
            height: 1.5
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Nos ofreces tu valiosa ATENCIÓN.',
          textScaleFactor: 1,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.greenAccent
          ),
        ),
        const Divider(color: Colors.green),
        const Text(
          'De antemano mil Gracias',
          textScaleFactor: 1,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color.fromARGB(255, 13, 153, 85)
          ),
        ),
      ],
    );
  }

}