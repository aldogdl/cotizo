import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../services/my_get.dart';
import '../providers/gest_data_provider.dart';
import '../widgets/ascaffold_main.dart';
import '../widgets/list_pzas_filter.dart';

class LstPiezasByOrden extends StatelessWidget {

  final String ids;
  const LstPiezasByOrden({
    Key? key,
    required this.ids,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    Mget.init(context, context.read<GestDataProvider>());
    Mget.globals.goBackTo = '';

    return AscaffoldMain(
      body: (!Mget.auth!.isLogin)
        ? _showLogin() : ListPzasFilter(ids: ids)
    );

  }

  ///
  Widget _showLogin() {

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
            'Autenticate por favor',
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
              'No olvides autenticarte con la cuenta de Google que Autoparnet '
              'te ha otorgado como Socios ',
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
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(const Color(0xFF00a884))
            ),
            onPressed: () {
              Mget.globals.goBackTo = '/cotizo/$ids';
              Mget.ctx!.push('/login');
            },
            child: const Text(
              '¡HACER LOGIN AHORA!',
              textScaleFactor: 1,
              style: TextStyle(
                color: Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.bold
              )
            )
          ),
          SizedBox(height: MediaQuery.of(Mget.ctx!).size.height * 0.1),
          TextButton(
            onPressed: () => Mget.ctx!.go('/'),
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
  
}