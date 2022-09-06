import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart' show GoogleSignInAccount;
import 'package:provider/provider.dart';

import '../config/sngs_manager.dart';
import '../providers/signin_provider.dart';
import '../vars/globals.dart';

class MenuMain extends StatelessWidget {

  MenuMain({Key? key}) : super(key: key);

  final Globals _globals = getIt<Globals>();

  @override
  Widget build(BuildContext context) {

    final provi = context.read<SignInProvider>();
    
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            _titulo(context),
            Divider(color: _globals.txtOnsecMainDark),
            _item(
              icono: Icons.bubble_chart_rounded, label: 'Inventario',
              fnc: () {}
            ),
            _item(
              icono: Icons.bar_chart_sharp, label: 'Coutas de Almacenamiento',
              fnc: () {}
            ),
            _item(
              icono: Icons.settings, label: 'Configuración',
              fnc: () {}
            ),
            Divider(color: _globals.txtOnsecMainDark),
            _dataAccount(provi.currentUser),
            _item(
              icono: Icons.unpublished_rounded, label: 'Cerrar Sesión',
              fnc: () async {
                provi.logout().then((value) => Navigator.of(context).pop());
              }
            ),
          ],
        ),
      ),
    );
  }

  ///
  Widget _titulo(BuildContext context) {

    return Container(
      constraints: BoxConstraints.expand(
        width: MediaQuery.of(context).size.width,
        height: 50
      ),
      child: Row(
        children: [
          Icon(Icons.menu, color: _globals.txtOnsecMainDark),
          const SizedBox(width: 10),
          Text(
            'MENÚ PRINCIPAL',
            textScaleFactor: 1,
            style: TextStyle(
              fontSize: 17,
              color: _globals.txtOnsecMainLigth
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.close, color: _globals.txtOnsecMainSuperLigth)
          )
        ],
      ),
    );
  }

  ///
  Widget _dataAccount(GoogleSignInAccount? account) {

    String curc = 'Sin Registro';
    if(account != null) {
      List<String> partes = account.email.split('@');
      if(partes.isNotEmpty) {
        curc = partes.first;
      }
    }

    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white.withOpacity(0.1),
      ),
      child: Column(
        children: [
          _row('ID:', (account != null) ? account.id : '0000000'),
          _row('CURC:', curc),
          _row('EMAIL:', (account != null) ? account.email : 'anónimo@cuenta.com'),
        ],
      ),
    );
  }

  ///
  Widget _item({
    required IconData icono,
    required String label,
    required Function fnc,
  }) {

    return TextButton(
      onPressed: () => fnc(),
      child: Row(
        children: [
          const Icon(
            Icons.arrow_forward_ios_rounded, size: 15, color: Colors.blue,
          ),
          _texto(' $label'),
          const Spacer(),
          Icon(
            icono, size: 22, color: _globals.txtOnsecMainDark,
          )
        ],
      )
    );
  }

  ///
  Widget _row(String label, String data) {

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _texto(data, cl: _globals.txtOnsecMainLigth),
          Divider(height: 2, color: _globals.txtOnsecMainDark),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _texto(label, sz: 12, cl: Colors.grey)
            ],
          ),
        ],
      ),
    );
  }

  ///
  Widget _texto(String label, {
    double sz = 17,
    Color cl = const Color.fromARGB(255, 246, 247, 248)
  }) {

    return Text(
      label,
      textScaleFactor: 1,
      style: TextStyle(
        fontSize: 17,
        letterSpacing: 1.1,
        color: cl
      ),
    );
  }


}