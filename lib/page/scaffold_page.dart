import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../providers/signin_provider.dart';
import '../widgets/ascaffold_main.dart';

class ScaffoldPage extends StatelessWidget {

  final Widget child;
  ScaffoldPage({
    Key? key,
    required this.child,
  }) : super(key: key);

  final _labelsTap = ['GENERALES', 'POR MARCAS', 'SOLICITUDES'];

  @override
  Widget build(BuildContext context) {

    return DefaultTabController(
      length: _labelsTap.length,
      child: AscaffoldMain(
        body: child,
        bottom: TabBar(
          indicatorColor: const Color(0xFF4da07f),
          indicatorWeight: 5.0,
          labelColor: Colors.white,
          labelPadding: const EdgeInsets.only(top: 10.0),
          unselectedLabelColor: Colors.grey,
          onTap: (index) {},
          tabs: List.generate(_labelsTap.length, (index) => Tab(
            child: Text(
              _labelsTap[index],
              textScaleFactor: 1,
            )
          )),
        ),
        floatingActionButton: Selector<SignInProvider, bool>(
          selector: (_, provi) => provi.isLogin,
          builder: (_, log, child) => (log) ? const SizedBox() : child!,
          child: _btnLogin(context),
        ),
      ),
    );
  }

  ///
  Widget? _btnLogin(BuildContext context) {

    return FloatingActionButton(
      onPressed: () => context.push('/login'),
      tooltip: 'Login',
      backgroundColor: const Color(0xFF00a884),
      child: Icon(
        (GoRouter.of(context).location == '/login')
        ? Icons.close : Icons.verified_user_sharp,
        color: const Color.fromARGB(255, 255, 255, 255), size: 30
      ),
    );
  }

}
