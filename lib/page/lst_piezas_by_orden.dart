import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../repository/acount_user_repository.dart';
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
  final _userEm = AcountUserRepository();

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

}