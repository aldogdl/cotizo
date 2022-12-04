import 'package:cotizo/page/estanque.dart';
import 'package:go_router/go_router.dart';

import '../vars/globals.dart';
import '../config/sngs_manager.dart';

import '../page/splash_page.dart';
import '../page/pta_in_down_orden_by_id.dart';
import '../page/home_page.dart';
import '../page/sign_app_page.dart';

class MyRutas {

  static final globals = getIt<Globals>();

  static final rutas = GoRouter(
    routes: [
      GoRoute(
        name: 'splash',
        path: '/',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        name: 'home',
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        name: 'login',
        path: '/login',
        builder: (context, state) => const SignAppPage(),
      ),
      GoRoute(
        name: 'downDataOrden',
        path: '/cotizo/:ids',
        builder: (context, state) => PtaInDownOrdenById(ids: '${state.params['ids']}'),
      ),
      GoRoute(
        name: 'estanque',
        path: '/estanque/:idOrden',
        builder: (context, state) => Estanque(idOrden: '${state.params['idOrden']}'),
      ),
    ],
    initialLocation: '/',
    // refreshListenable: _prov,
    redirect: (_, state) {

      if(state.location != '/') {  globals.setHistUri(state.location); }
      // if (!_prov.isLogin) return (state.subloc == '/login') ? null : '/login';
      // if (_prov.isLogin) return '/';
      return null;
    }
  );
}