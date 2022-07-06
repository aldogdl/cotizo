import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../config/sngs_manager.dart';
import '../providers/signin_provider.dart';
import '../vars/globals.dart';
import '../widgets/menu_main.dart';

class ScaffoldPage extends StatelessWidget {

  final Widget child;
  ScaffoldPage({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Globals _globals = getIt<Globals>();
  final _labelsTap = ['GENERALES', 'POR MARCAS', 'SOLICITUDES'];

  @override
  Widget build(BuildContext context) {

    return DefaultTabController(
      length: _labelsTap.length,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: _globals.bgMain,
          appBar: AppBar(
            backgroundColor: _globals.secMain,
            elevation: 0,
            title: Text(
              'AutoparNet',
              style: TextStyle(
                color: _globals.txtOnsecMainDark,
                fontSize: 17,
                fontWeight: FontWeight.bold
              ),
            ),
            actions: [
              IconButton(
                onPressed: (){},
                icon: const Icon(Icons.search)
              ),
              IconButton(
                onPressed: () async => await _showMenuMain(context),
                icon: const Icon(Icons.more_vert_rounded)
              )
            ],
            bottom: TabBar(
              indicatorColor: const Color(0xFF4da07f),
              indicatorWeight: 5.0,
              labelColor: Colors.white,
              labelPadding: const EdgeInsets.only(top: 10.0),
              unselectedLabelColor: Colors.grey,
              onTap: (index) {},
              tabs: List.generate(_labelsTap.length, (index) => Tab(text: _labelsTap[index])),
            ),
          ),
          body: child,
          floatingActionButton: Selector<SignInProvider, bool>(
            selector: (_, provi) => provi.isLogin,
            builder: (_, log, child) => (log) ? const SizedBox() : child!,
            child: _btnLogin(context),
          )
        ),
      )
    );
  }

  ///
  Widget? _btnLogin(BuildContext context) {

    return FloatingActionButton(
      onPressed: () => context.push('/login'),
      tooltip: 'Login',
      child: Icon(
        (GoRouter.of(context).location == '/login')
        ? Icons.close : Icons.verified_user_sharp
      ),
    );
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

}
