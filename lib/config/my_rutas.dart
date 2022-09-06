import 'package:go_router/go_router.dart';

import '../vars/globals.dart';
import '../config/sngs_manager.dart';

import '../page/splash_page.dart';
import '../page/inventario_page.dart';
import '../page/gest_data_page.dart';
import '../page/lst_piezas_by_orden.dart';
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
        name: 'gestData',
        path: '/gest-data/:idP',
        builder: (context, state) => GestDataPage(idP: int.parse('${state.params['idP']}')),
      ),
      GoRoute(
        name: 'lstPiezasByOrden',
        path: '/cotizo/:ids',
        builder: (context, state) => LstPiezasByOrden(ids: '${state.params['ids']}'),
      ),
      GoRoute(
        name: 'inventario',
        path: '/inventario',
        builder: (context, state) => const InventarioPage(),
      ),
    ],
    urlPathStrategy: UrlPathStrategy.path,
    initialLocation: '/',
    // refreshListenable: _prov,
    redirect: (state) {

      if(globals.histUri.contains(state.location)){
        globals.histUri.remove(state.location);
      }
      if(state.location != '/') {
        if(state.location != '/login') {
          globals.histUri.add(state.location);
        }
      }
      // if (!_prov.isLogin) return (state.subloc == '/login') ? null : '/login';
      // if (_prov.isLogin) return '/';
      return null;
    }
  );
}