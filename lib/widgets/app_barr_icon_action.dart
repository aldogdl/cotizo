import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart' show AuthorizationStatus;
import 'package:provider/provider.dart';

import '../api/push_msg.dart';
import '../config/sngs_manager.dart';
import '../providers/gest_data_provider.dart';
import '../providers/ordenes_provider.dart';
import '../providers/signin_provider.dart';
import '../repository/acount_user_repository.dart';
import '../repository/config_app_repository.dart';
import '../repository/inventario_repository.dart';
import '../repository/no_tengo_repository.dart';
import '../vars/globals.dart';

class AppBarIconAction extends StatefulWidget {

  const AppBarIconAction({Key? key}) : super(key: key);

  @override
  State<AppBarIconAction> createState() => _AppBarIconActionState();
}

class _AppBarIconActionState extends State<AppBarIconAction> {

  final _globals = getIt<Globals>();
  final _invEm   = InventarioRepository();
  final _ntgEm   = NoTengoRepository();
  final _cngEm   = ConfigAppRepository();
  final _userEm  = AcountUserRepository();
  final icono = ValueNotifier<Map<String, dynamic>>({});
  final colorPas = const Color.fromARGB(255, 107, 107, 107);
  
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(_checkGoData);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    
    return ValueListenableBuilder<Map<String, dynamic>>(
      valueListenable: icono,
      builder: (__, value, _) {
        return Icon(
          value['ico'], color: value['color'], size: 18,
        );
      },
    );
  }

  /// ---> Acciones que se tienes que realizar en cada inicio.
  /// 'Configurar los push Notifications'
  /// ---> Acciones que se realizan cada 8 horas
  /// 'Recuperando filtro Inventario' 
  /// 'Limpiando almacén de Inexistentes'
  /// 'Actualizando Credenciales'
  Future<void> _checkGoData(_) async {
    
    final sign = context.read<SignInProvider>();
    final push = getIt<PushMsg>();
    if(sign.yaCheckApp){
      _setIconStatic(push.authPush);
      return; 
    }

    icono.value = {'ico':Icons.notifications_active, 'color': const Color.fromARGB(255, 53, 82, 245)};
    context.read<GestDataProvider>().modoCot = await _cngEm.getModoCotiza();
    sign.desablePushInt = await _cngEm.getStatusNotiff();
    await push.init();
    if(sign.isFirstIniApp) {
      Future.delayed(const Duration(milliseconds: 5000), () async {
        final prov = context.read<OrdenesProvider>();
        final orden = await prov.getParaNotificFromRange();
        push.makePushInt(orden);
      });
    }

    sign.isFirstIniApp = false;
    if(sign.goForData) {
      
      icono.value = {'ico':Icons.filter_alt, 'color': const Color.fromARGB(255, 237, 238, 241)};
      await Future.delayed(const Duration(milliseconds: 250));
      _globals.invFilter = await _invEm.getAllInvToFilter();

      icono.value = {'ico':Icons.point_of_sale_sharp, 'color': const Color.fromARGB(255, 8, 223, 26)};
      await Future.delayed(const Duration(milliseconds: 250));
      final ntgIds = await _ntgEm.getAllNoTengo();
      if(ntgIds.isNotEmpty) {
        _ntgEm.cleanAlmacenNtFromServer(ntgIds);
      }

      icono.value = {'ico':Icons.point_of_sale_sharp, 'color': const Color.fromARGB(255, 8, 223, 26)};
      await Future.delayed(const Duration(milliseconds: 250));
      await _cngEm.updateIfNotEmpty();

      icono.value = {'ico':Icons.verified_user_sharp, 'color': const Color.fromARGB(255, 150, 223, 156)};
      await Future.delayed(const Duration(milliseconds: 250));
      await _userEm.isTokenCaducado();

      if(_userEm.result['abort']) {

        final user = await _userEm.getDataUserInLocal();
        icono.value = {'ico':Icons.password, 'color': const Color.fromARGB(255, 88, 148, 150)};
        await _userEm.login({'username':user.curc, 'password': user.password});
        
        if(_userEm.result['abort']) {
          await _cngEm.setTokenInvalido();
        }else{
          await _userEm.setTokenServer(_userEm.result['body']);
        }
      }
    }

    sign.yaCheckApp = true;
    _setIconStatic(push.authPush);
  }

  ///
  void _setIconStatic(AuthorizationStatus? authPush) {

    switch(authPush) {
      case AuthorizationStatus.denied:
        icono.value = {
          'ico'  : Icons.notifications_off_outlined, 'color': colorPas
        };
        break;
      case AuthorizationStatus.notDetermined:
        icono.value = {
          'ico'  : Icons.notification_important_outlined, 'color': Colors.red
        };
        break;
      case AuthorizationStatus.provisional:
        icono.value = {
          'ico'  : Icons.edit_notifications, 'color': Colors.orange
        };
        break;
      case AuthorizationStatus.authorized:
        icono.value = {
          'ico'  : Icons.notifications_sharp, 'color': colorPas
        };
        break;
      default:
        icono.value = {
          'ico'  : Icons.circle_notifications_sharp, 'color': Colors.greenAccent
        };
    }
  }
}