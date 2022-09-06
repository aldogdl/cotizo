import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../services/my_get.dart';
import '../providers/gest_data_provider.dart';
import '../widgets/ascaffold_main.dart';
import '../widgets/list_pzas_filter.dart';

class LstPiezasByOrden extends StatefulWidget {

  final String ids;
  const LstPiezasByOrden({
    Key? key,
    required this.ids,
  }) : super(key: key);

  @override
  State<LstPiezasByOrden> createState() => _LstPiezasByOrdenState();
}

class _LstPiezasByOrdenState extends State<LstPiezasByOrden> {

  bool _isIni = false;
  bool _isIntentLogin = false;

  @override
  Widget build(BuildContext context) {

    if(!_isIni) {
      _isIni = true;
      Mget.init(context, context.read<GestDataProvider>());
    }
    
    return AscaffoldMain(
      body: (!Mget.auth!.isLogin)
        ? _showLogin()
        : ListPzasFilter(ids: widget.ids)
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
            'Autentícate por favor',
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
              'No olvides autenticarte con la cuenta de Acceso que AutoparNet '
              'te ha otorgado como Socio. ',
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
          AbsorbPointer(
            absorbing: _isIntentLogin,
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(const Color(0xFF00a884))
              ),
              onPressed: () async {
                setState(() {
                  _isIntentLogin = true;
                });
                await _hacerLogin();
              },
              child: Text(
                (_isIntentLogin) ? 'UN MOMENTO, POR FAVOR.' : '¡HACER LOGIN AHORA!',
                textScaleFactor: 1,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.bold
                )
              )
            ),
          ),
          SizedBox(height: MediaQuery.of(Mget.ctx!).size.height * 0.1),
          TextButton(
            onPressed: () => Mget.ctx!.push('/home'),
            child: const Text(
              'SALIR Y NO COTIZAR',
              textScaleFactor: 1,
              style: TextStyle(
                color: Color(0xFF00a884),
                fontSize: 15,
                fontWeight: FontWeight.bold
              )
            )
          )
        ]
      )
    );
  }

  ///
  Future<void> _hacerLogin() async {

    bool isOk = false;
    
    final nav = GoRouter.of(context);
    
    try {
      await Mget.auth!.login();
    } on PlatformException catch (_) {
      isOk = false;
    } finally {
      if(Mget.auth!.currentUser != null) {
        if(Mget.auth!.currentUser!.email.contains('@')) {
          isOk = true;
        }
      }
    }

    if(isOk) {
      setState(() {
        Mget.auth!.isLogin = true;
      });
    }else{
      nav.go('/login');
    }
  }

}