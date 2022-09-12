import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'inventario_page.dart';
import '../config/sngs_manager.dart';
import '../providers/signin_provider.dart';
import '../vars/globals.dart';
import '../widgets/ascaffold_main.dart';
import '../widgets/menu_main.dart';
import '../widgets/my_infinity_list.dart';

class HomePage extends StatefulWidget {
  
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {

  final _globals = getIt<Globals>();
  late final TabController _tab;
  final List<String> _seccs = ['MENÚ', 'SOLICITUDES', 'INVENTARIO'];
  final List<Widget> _misTabs = [];
  final List<Widget> _misPages= [];

  @override
  void initState() {

    _tab = TabController(length: _seccs.length, initialIndex: 1, vsync: this);

    _seccs.map((tab){

      switch (tab) {
        case 'MENÚ':
          _misPages.add(MenuMain());
          break;
        case 'SOLICITUDES':
          _misPages.add(const MyInfinityList());
          break;
        default:
          _misPages.add(const InventarioPage());
      }

      if(tab == 'MENÚ') {
        _misTabs.add(
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.menu),
                const SizedBox(width: 5),
                Text(
                  tab,
                  textScaleFactor: 1,
                  style: const TextStyle(
                    fontSize: 16
                  ),
                )
              ],
            )
          )
        );
        
      }else{

        _misTabs.add(
          Tab(
            child: Text(
              tab,
              textScaleFactor: 1,
              style: const TextStyle(
                fontSize: 16
              ),
            )
          )
        );
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
      indicatorWeight: 4.0,
      labelColor: Colors.white,
      labelPadding: const EdgeInsets.only(top: 10.0),
      unselectedLabelColor: Colors.grey,
      physics: const BouncingScrollPhysics(),
      enableFeedback: true,
      automaticIndicatorColorAdjustment: true,
      controller: _tab,
      tabs: _misTabs
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