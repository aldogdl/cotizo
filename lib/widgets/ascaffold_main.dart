import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../config/sngs_manager.dart';
import '../providers/ordenes_provider.dart';
import '../services/my_get.dart';
import '../vars/globals.dart';
import '../widgets/show_dialogs.dart';
import '../widgets/menu_main.dart';

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

    return SafeArea(
      child: WillPopScope(
        onWillPop: () => _onWill(context),
        child: Scaffold(
          backgroundColor: _globals.bgMain,
          appBar: AppBar(
            backgroundColor: _globals.secMain,
            elevation: 0,
            title: Text.rich(
              TextSpan(
                text: 'AutoparNet ',
                style: GoogleFonts.comfortaa(
                  color: Colors.green,
                  fontSize: 19,
                  fontWeight: FontWeight.bold
                ),
                children: [
                  TextSpan(
                    text: '[ COTIZO ${_globals.version} ]',
                    style: TextStyle(
                      color: _globals.txtComent,
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ]
              ),
              textScaleFactor: 1,
            ),
            actions: [
              Selector<OrdenesProvider, bool>(
                selector: (_, prov) => prov.isShowHome,
                builder: (_, val, child) {
                  
                  if(val) {
                    return IconButton(
                      onPressed: () => context.go('/home'),
                      icon: const Icon(Icons.home)
                    );
                  }
                  return child!;
                },
                child: IconButton(
                  onPressed: () => context.go('/inventario'),
                  icon: const Icon(Icons.search)
                ),
              ),
              
              IconButton(
                onPressed: () async => await _showMenuMain(context),
                icon: const Icon(Icons.more_vert_rounded)
              )
            ],
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
  Future<void> _showMenuMain(BuildContext context) async {

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _globals.secMain,
      constraints: BoxConstraints.expand(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.9,
      ),
      builder: (_) => MenuMain()
    );
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