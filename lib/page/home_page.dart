import 'package:cotizo/widgets/pesta_apartados.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'apartados_page.dart';
import 'inventario_page.dart';
import 'home_pzas_page.dart';
import '../config/sngs_manager.dart';
import '../providers/ordenes_provider.dart';
import '../providers/signin_provider.dart';
import '../vars/globals.dart';
import '../widgets/ascaffold_main.dart';

class HomePage extends StatefulWidget {
  
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {

  final _globals = getIt<Globals>();
  late final TabController _tab;
  final List<String> _seccs = ['INVENTARIO', 'POR PIEZAS', 'APARTADOS'];
  final List<Widget> _misPages= [];

  @override
  void initState() {

    _tab = TabController(length: _seccs.length, initialIndex: 1, vsync: this);
    _seccs.map((tab) {

      switch (tab) {
        case 'INVENTARIO':
          _misPages.add(const InventarioPage());
          break;
        case 'POR PIEZAS':
          _misPages.add(const HomePzasPage());
          break;
        default:
          _misPages.add(const ApartadosPage());
      }
    }).toList();

    super.initState();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return DefaultTabController(
      length: _seccs.length,
      initialIndex: 1,
      child: AscaffoldMain(
        bottom: _tabs(),
        body: _paginas(),
        floatingActionButton: Selector<SignInProvider, bool>(
          selector: (_, provi) => provi.isLogin,
          builder: (_, log, child) => (log) ? const SizedBox() : child!,
          child: _btnLogin(context),
        ),
      ),
    );
  }

  ///
  PreferredSizeWidget _tabs() {

    return TabBar(
      indicatorColor: const Color(0xFF4da07f),
      indicatorWeight: 3.5,
      labelPadding: const EdgeInsets.symmetric(horizontal: 0),
      labelColor: Colors.white,
      unselectedLabelColor: Colors.grey,
      physics: const BouncingScrollPhysics(),
      enableFeedback: true,
      automaticIndicatorColorAdjustment: true,
      controller: _tab,
      tabs: _seccs.map((tab) => buildTaps(tab)).toList()
    );
  }

  ///
  Widget _paginas() {

    return TabBarView(
      controller: _tab,
      physics: const BouncingScrollPhysics(),
      children: _misPages,
    );
  }

  ///
  Widget buildTaps(String tab) {

    double textScaleFactor = 0.82;
    TextStyle styleText = const TextStyle(
      fontSize: 17,
      letterSpacing: 1.1
    );

    if(MediaQuery.of(context).size.width < 360) {
      textScaleFactor = 0.8;
      styleText = const TextStyle(
        fontSize: 15.5,
        letterSpacing: 1
      );
    }

    if(tab == 'APARTADOS') {

      return Tab(
        child: PestaApartados(
          tab: tab,
          onAnimate: (page) => _tab.animateTo(page)
        )
      );

    }else{

      if(tab == 'SOLICITUDES') {

        return Tab(
          child: Selector<OrdenesProvider, int>(
            selector: (_, prov) => prov.changeToSeccion,
            builder: (_, secc, __) {
              // es un escucha para ver si el usuario presiono el btn back device
              final oP = context.read<OrdenesProvider>();
              if(secc != oP.lastChangeToSeccion) {
                oP.lastChangeToSeccion = secc;
                Future.delayed(const Duration(milliseconds: 250), (){
                  _tab.animateTo(1);
                });
              }

              return Text(
                tab,
                textScaleFactor: textScaleFactor,
                style: styleText,
              );
            },
          )
        );
      }

      return Tab(
        child: Text(
          tab,
          textScaleFactor: textScaleFactor,
          style: styleText,
        )
      );
    }
  }
  
  ///
  Widget? _btnLogin(BuildContext context) {

    return FloatingActionButton(
      onPressed: () => context.push('/login'),
      tooltip: 'Login',
      backgroundColor: _globals.colorGreen,
      child: Icon(
        (GoRouter.of(context).location == '/login')
        ? Icons.close : Icons.verified_user_sharp,
        color: const Color.fromARGB(255, 255, 255, 255), size: 30
      ),
    );
  }

}