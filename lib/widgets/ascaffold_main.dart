import 'package:cotizo/api/push_msg.dart';
import 'package:firebase_messaging/firebase_messaging.dart' show AuthorizationStatus;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../config/sngs_manager.dart';
import '../services/my_get.dart';
import '../vars/globals.dart';
import '../widgets/show_dialogs.dart';

class AscaffoldMain extends StatelessWidget {

  final Widget body;
  final PreferredSizeWidget? bottom;
  final Widget? floatingActionButton;

  AscaffoldMain({
    Key? key,
    required this.body,
    this.floatingActionButton,
    this.bottom,
  }) : super(key: key);

  final _globals = getIt<Globals>();

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;
    final push = getIt<PushMsg>();
    late IconData icono;

    switch(push.authPush) {
      case AuthorizationStatus.denied:
        icono = Icons.notifications_off_outlined;
        break;
      case AuthorizationStatus.notDetermined:
        icono = Icons.notification_important_outlined;
        break;
      case AuthorizationStatus.provisional:
        icono = Icons.notifications_paused_rounded;
        break;
      default:
        icono = Icons.notifications_active;
    }
    
    return SafeArea(
      child: WillPopScope(
        onWillPop: () => _onWill(context),
        child: Scaffold(
          backgroundColor: _globals.bgMain,
          appBar: AppBar(
            backgroundColor: _globals.secMain,
            elevation: 0,
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text.rich(
                  TextSpan(
                    text: 'AutoparNet ',
                    style: GoogleFonts.comfortaa(
                      color: Colors.green,
                      fontSize: 19,
                      fontWeight: FontWeight.bold
                    ),
                    children: const [
                      TextSpan(
                        text: 'COTIZO',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ]
                  ),
                  textScaleFactor: 1,
                ),
                const Spacer(),
                Text(
                  _globals.version,
                  style: TextStyle(
                    color: _globals.txtComent,
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  icono, color: const Color.fromARGB(255, 107, 107, 107), size: 18,
                )
              ],
            ),
            bottom: bottom,
          ),
          body: SizedBox(
            width: size.width, height: size.height,
            child: body
          ),
          floatingActionButton: floatingActionButton
        )
      ),
    );
  }

  ///
  Future<bool> _onWill(BuildContext context) async {

    late final GoRouter nav;

    if(Mget.ctx != null) {
      try {
        nav = GoRouter.of(Mget.ctx!);
      } catch (e) {
        nav = GoRouter.of(context);
      }
    }else{
      nav = GoRouter.of(context);
    }

    if(_globals.histUri.isEmpty) {
      if(nav.canPop()) {
        return Future.value(true);
      }
      if(_globals.isFromWhatsapp) {
        return Future.value(true);
      }
      bool? acc = await _showAlertExit(context);
      acc = (acc == null) ? false : acc;
      if(acc) {
        return Future.value(true);
      }
      nav.go('/home');
      return Future.value(false);
    }else{
      nav.go(_globals.getBack());
      return Future.value(false);
    }
  }

  ///
  Future<bool?> _showAlertExit(BuildContext context) async {

    return await ShowDialogs.alert(
      context, 'exitApp', hasActions: true,
      labelNot: 'SEGUIR AQUÍ',
      labelOk: 'SÍ, SALIR'
    );
  }

}