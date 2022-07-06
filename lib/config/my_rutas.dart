import 'package:cotizo/page/gest_data_page.dart';
import 'package:go_router/go_router.dart';

import '../page/home_page.dart';
import '../page/sign_app_page.dart';

class MyRutas {

  static final rutas = GoRouter(
    routes: [
      GoRoute(
        name: 'home',
        path: '/',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        name: 'login',
        path: '/login',
        builder: (context, state) => const SignAppPage(),
      ),
      GoRoute(
        name: 'gestData',
        path: '/gest-data',
        builder: (context, state) => const GestDataPage(),
      ),
    ],
    initialLocation: '/',
    // refreshListenable: _prov,
    // redirect: (state) {

    //   if (!_prov.isLogin) return (state.subloc == '/login') ? null : '/login';
    //   if (_prov.isLogin) return '/';
    //   return null;
    // }
  );
}