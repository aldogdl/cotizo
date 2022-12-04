import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/ordenes_provider.dart';
import '../providers/gest_data_provider.dart';
import '../repository/acount_user_repository.dart';
import '../repository/soli_em.dart';
import '../services/my_get.dart';
import '../widgets/ascaffold_main.dart';
import '../widgets/bg_img_pzas.dart';
import '../vars/globals.dart';
import '../vars/constantes.dart' show WhereReg;

class PtaInDownOrdenById extends StatefulWidget {

  final String ids;
  const PtaInDownOrdenById({
    Key? key,
    required this.ids,
  }) : super(key: key);

  @override
  State<PtaInDownOrdenById> createState() => _PtaInDownOrdenByIdState();
}

class _PtaInDownOrdenByIdState extends State<PtaInDownOrdenById> {

  final _solEm = SoliEm();
  final _userEm = AcountUserRepository();
  final _msgLoad = ValueNotifier<String>('...');

  OrdenesProvider? _ordProv;
  int _idOrd = 0;
  int _user = 0;
  int _avo = 0;
  int _idCamp = 0;
  String _from = WhereReg.appi.name;
  bool _isIni = false;
  bool _fechData = false;

  @override
  void initState() {

    if(widget.ids.contains('-')) {

      final partes = widget.ids.split('-');
      _idOrd = int.parse(partes.first);
      _user = int.parse(partes[1]);
      _avo = int.parse(partes[2]);
      
      bool hasIdCamp = false;
      if(partes.length == 4) {
        // Apertura de la app por push in
        hasIdCamp = true;
        _from = WhereReg.apl.name;
      }else if(partes.length == 5) {
        // Apertura de la app por push out
        _from = (partes[3] == '0') ? WhereReg.appi.name : WhereReg.appo.name;
        hasIdCamp = true;
      }
      if(hasIdCamp) {
        _idCamp = int.parse(partes[3]);
      } 
    }
    super.initState();
  }

  @override
  void dispose() {
    _msgLoad.dispose();
    super.dispose();
  } 

  /// HOME y Esta clase son las unicas puertas de apertura de la app, por lo cual
  /// en home y aqui debe guardarce el registro de apertura.
  @override
  Widget build(BuildContext context) {

    if(!_isIni) {
      _isIni = true;
      Mget.init(context, context.read<GestDataProvider>());
    }
    
    return AscaffoldMain(
      body: (!Mget.auth!.isLogin)
        ? _showLogin()
        : _downData()
    );
  }

  ///
  Widget _showLogin() {

    if(Mget.ctx == null) {
      Mget.init(context, context.read<GestDataProvider>());
    }

    return SizedBox.expand(
      child: Column(
        children: [
          SizedBox(height: MediaQuery.of(Mget.ctx!).size.height * 0.1),
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: SvgPicture.asset(
              'assets/svgs/avatar_male.svg',
              alignment: Alignment.topCenter,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(height: MediaQuery.of(Mget.ctx!).size.height * 0.05),
          const Text(
            'GRACIAS POR TU TIEMPO',
            textScaleFactor: 1,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold
            )
          ),
          SizedBox(height: MediaQuery.of(Mget.ctx!).size.height * 0.05),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              'Espera por favor un momento, estamos habilitando tus credenciales '
              'y autenticando tu exclusividad. ',
              textAlign: TextAlign.center,
              textScaleFactor: 1,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w200
              )
            )
          ),
          SizedBox(height: MediaQuery.of(Mget.ctx!).size.height * 0.1),
          StreamBuilder<String>(
            stream: _hacerLogin(),
            initialData: 'Validando...',
            builder: (_, AsyncSnapshot<String> val) {
              return Text(
                val.data!,
                textScaleFactor: 1,
                style: const TextStyle(
                  color: Color(0xFF00a884),
                  fontSize: 15,
                  fontWeight: FontWeight.bold
                )
              );
            },
          )
        ]
      )
    );
  }

  ///
  Widget _downData() {

    return BGImgPzas(
      bgColor: Globals().bgMain,
      child: SizedBox.expand(
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.1),
            SizedBox(
              width: 100, height: 100,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Positioned.fill(child: CircularProgressIndicator()),
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.green,
                    child: SvgPicture.asset(
                      'assets/svgs/no_data.svg',
                      alignment: Alignment.topCenter,
                      fit: BoxFit.contain,
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            const Text(
              'Estamos preparando todo',
              textScaleFactor: 1,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold
              )
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            _msgAcc(),
            FutureBuilder(
              future: _fetchData(),
              initialData: 'load',
              builder: (_, AsyncSnapshot snap) => _acciones(snap.data)
            )
          ]
        )
      )
    );
  }

  ///
  Widget _msgAcc() {

    return ValueListenableBuilder<String>(
      valueListenable: _msgLoad,
      builder: (_, val, __) {
        
        Color txtC = Colors.white;
        if(val.contains('sentimos')) {
          txtC = Colors.yellow;
        }
        
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                val,
                textAlign: TextAlign.center,
                textScaleFactor: 1,
                style: TextStyle(
                  color: txtC,
                  fontSize: 20,
                  height: 1.5,
                  fontWeight: FontWeight.w200
                )
              )
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.1),
          ],
        );
      }
    );
  }

  ///
  Widget _acciones(String data) {

    final nav = GoRouter.of(context);
    bool cancelBtn = true;
    String accBtn = 'retry';
    String txtBtn = 'UN MOMENTO POR FAVOR';

    switch (data) {
      case 'retry':
        cancelBtn = false;
        _fechData = false;
        accBtn = 'retry';
        txtBtn = 'INTENTARLO NUEVAMENTE';
        break;
      case 'noId':
        cancelBtn = false;
        accBtn = 'home';
        txtBtn = 'PRESIONA AQUÍ\npara ver más PIEZAS';
        break;
      case 'home':
        Future.microtask(() => nav.go('/home'));
        break;
      case 'homeW':
        cancelBtn = false;
        accBtn = 'home';
        txtBtn = 'Ver más PIEZAS para Cotizar';
        break;
      case 'ok':
        txtBtn = '¡ÉXITO EN TUS VENTAS!.';
        
        // Apertura de la app por push out
        if(_from == WhereReg.appo.name) {
          _from = WhereReg.sepo.name;
        }else if(_from == WhereReg.apl.name) {
          _from = WhereReg.sel.name;
        }
        _ordProv!.setDataReg(
          from: _from, id: _idOrd, user: _user, avo: _avo, idCamp: '$_idCamp'
        );
        Future.microtask(() => nav.go('/estanque/$_idOrd'));
        break;
      default:
    }

    return AbsorbPointer(
      absorbing: cancelBtn,
      child: TextButton(
        onPressed: () async {

          if(accBtn == 'home') {
            Future.microtask(() => nav.go('/home'));
            return;
          }
          _msgLoad.value = 'UN MOMENTO POR FAVOR';
          cancelBtn = true;
          if(mounted) {
            setState(() {});
          }
        },
        child: Text(
        txtBtn,
        textScaleFactor: 1,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF00a884),
          fontSize: 20,
          fontWeight: FontWeight.normal
          )
        )
      )
    );
  }

  ///
  Stream<String> _hacerLogin() async* {

    final nav = GoRouter.of(context);

    final user = await _userEm.getDataUserInLocal();
    if(user.id == 0) {
      nav.go('/login');
      return;
    }

    yield 'Bienvenido: ${user.curc.toUpperCase()}';
    await _userEm.isTokenCaducado();
    
    if(_userEm.result['abort']) {
      yield 'Actualizando Credenciales';
      await _userEm.login({'username':user.curc, 'password': user.password});
      
      if(_userEm.result['abort']) {
        yield 'Autenticate por favor.';
        Future.delayed(const Duration(milliseconds: 1500), (){
          nav.go('/login');
        });
        return;

      }else{
        await _userEm.setTokenServer(_userEm.result['body']);
      }
    }

    Future.microtask(() => Mget.auth!.isLogin = true);
    setState(() {});
  }

  ///
  Future<String> _fetchData() async {

    if(Router.of(context).routeInformationProvider != null) {
      final pageC = Router.of(context).routeInformationProvider!.value.location;
      if(!pageC!.startsWith('/cotizo')){ return ''; }
    }

    if (!mounted) { return 'home'; }
    if(_fechData) { return ''; }
    _fechData = true;
    
    _ordProv = context.read<OrdenesProvider>();
    if(_ordProv == null) { return 'home'; }

    final iduser = await _solEm.getIdUser();
    if(iduser != _user) {
      _msgLoad.value = 'Lo sentimos mucho, este enlace no corresponde al registro de tu App.';
      return 'noId';
    }

    _msgLoad.value = 'Recuperando Solicitud # $_idOrd';

    return await _descargarOrden();
  }

  ///
  Future<String> _descargarOrden() async {

    if(!mounted){ return ''; }

    final result = await _solEm.oem.getAOrdenAndPieza(_idOrd, '$_user::$_from');
    _solEm.oem.cleanResult();

    if(result.isNotEmpty) {

      final laOrden = Map<String, dynamic>.from(result);

      _msgLoad.value = 'Recuperada con éxito';
      final orden = await _solEm.hidratarOrdenFull(laOrden, _ordProv!.items());

      _msgLoad.value = 'Revisando Autopartes';
      if(orden.piezas.isEmpty) {

        // Piezas en el inventario
        if(orden.id == -1) {
          _msgLoad.value = 'Parece ser que ya haz cotizado todas las '
          'piezas de esta orden, por favor, selecciona cualquier otra.';
          return 'homeW';
        }

        // Piezas marcadas como NO TENGO
        if(orden.id == -2) {
          _msgLoad.value = 'Las piezas de esta solicitud, las haz marcado '
          'como NO TENGO, ¿deseas liberarlas para cotizarlas?';
          return 'libNt';
        }

        // Piezas que no han pasado el filtro
        // TODO hacer una rebusqueda de piezas para este usuario
        if(orden.id == -3) {
          _msgLoad.value = '';
          return 'research';
        }
      }

      if( _solEm.addToList ){
        _ordProv!.addItem = orden;
      }
      _idOrd = orden.id;
      return 'ok';

    }else{
      _msgLoad.value = 'No se logró recuperar la orden.';
      return 'retry';
    }
  }

}