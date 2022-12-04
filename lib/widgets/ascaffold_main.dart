import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'menu_main.dart';
import '../config/sngs_manager.dart';
import '../services/pop_app.dart';
import '../vars/globals.dart';
import '../widgets/app_barr_icon_action.dart';

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
    final onWill = PopApp();

    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          onWill.onWill(context);
          return Future.value(false);
        },
        child: Scaffold(
          backgroundColor: _globals.bgMain,
          appBar: AppBar(
            backgroundColor: _globals.bgAppBar,
            elevation: 0,
            title: _tituloApp(context),
            bottom: bottom,
            actions: [
              IconButton(
                onPressed: () => _showMwnu(context),
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.menu, size: 20)
              )
            ],
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
  Widget _tituloApp(BuildContext context) {

    return Row(
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
        const AppBarIconAction(),
      ],
    );
  }
  
  ///
  void _showMwnu(BuildContext context) {

    showModalBottomSheet(
      context: context,
      backgroundColor: _globals.bgMain,
      enableDrag: false, isDismissible: false, isScrollControlled: true,
      builder: (_) => MediaQuery(
        data: MediaQueryData.fromWindow(WidgetsBinding.instance.window),
        child: MenuMain()
      )
    );
  }
}