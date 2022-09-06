import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../config/sngs_manager.dart';
import '../providers/ordenes_provider.dart';
import '../providers/signin_provider.dart';
import '../vars/globals.dart';
import '../widgets/ascaffold_main.dart';
import '../widgets/my_infinity_list.dart';

class HomePage extends StatefulWidget {
  
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {

  final _globals = getIt<Globals>();
  late final TabController _tab;
  final List<String> _seccs = ['GENERALES', 'POR MARCAS', 'SOLICITUDES'];
  final List<Widget> _misTabs = [];
  final List<Widget> _misPages= [];

  OrdenesProvider? _ordP;

  bool _isInit = false;

  @override
  void initState() {

    _seccs.map((tab){

      _misPages.add(
        MyInfinityList(
          tile: tab,
          onPress: (String animateTo) {
            int secc = _seccs.indexWhere((element) => element == animateTo);
            if(secc != -1) {
              _tab.index = secc;
              _tab.animateTo(secc);
            }
          }
        )
      );
      
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
      
    }).toList();

    /// Seccion para seleccionar la ultima pestaña visitada en caso de haberla
    int initEn = 0;
    if(_globals.lastSecc.isNotEmpty) {
      initEn = _seccs.indexWhere((element) => element == _globals.lastSecc);
    }else{
      _globals.lastSecc = _seccs.first;
    }
    _tab = TabController(initialIndex: initEn, length: _seccs.length, vsync: this)
      ..addListener(() {
        _globals.lastSecc = _seccs[_tab.index];
        _cleanFilterBySols();
      });

    super.initState();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    if(!_isInit) {
      _isInit = true;
      _ordP = context.read<OrdenesProvider>();
      Future.delayed(const Duration(microseconds: 250), (){
        _ordP!.isShowHome = false;
      });
    }

    return DefaultTabController(
      length: _seccs.length,
      initialIndex: 0,
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
      onTap: (index) => _cleanFilterBySols(page: index),
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

  /// filterBySols es el mapa donde ordenamos las ordenes por solicitud,
  /// Al dar click en la lista de ordenes ordenadas por marca, mostramos
  /// en la seccion de ordenar por solicitud, solo las solicitudes de dicha
  /// marca seleccionada.
  void _cleanFilterBySols({int page = -1}) {

    int index = (page == -1) ? _tab.index : page;
    
    if(_seccs[index] != 'SOLICITUDES') {
      if(_ordP != null) {
        _ordP!.filterBySols = {};
      }
    }
  }


}