import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/sngs_manager.dart';
import '../entity/account_entity.dart';
import '../providers/signin_provider.dart';
import '../vars/globals.dart';
import '../widgets/cuotas_storage.dart';

class MenuMain extends StatelessWidget {

  MenuMain({Key? key}) : super(key: key);

  final Globals _globals = getIt<Globals>();

  @override
  Widget build(BuildContext context) {

    final provi = context.read<SignInProvider>();
    
    return Padding(
      padding: const EdgeInsets.all(10),
      child: ListView(
        children: [
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.6,
              child: const Image(
                image: AssetImage('assets/images/logo_only.png'),
              ),
            ),
          ),
          Divider(color: _globals.txtOnsecMainDark),
          _item(
            icono: Icons.unpublished_rounded, label: 'Cerrar Sesión',
            fnc: () async {
              final nav = Navigator.of(context);
              await provi.logout();
              nav.pop();
            }
          ),
          _titleSecc('Cuotas de Almacenamiento en Inventario'),
          const SizedBox(height: 8),
          const CuotasStorage(),
          _titleSecc('Claves de Registro y Acceso'),
          FutureBuilder(
            future: provi.getDataUser(),
            builder: (_, AsyncSnapshot snapshot) {
              if(snapshot.connectionState == ConnectionState.done) {
                if(snapshot.hasData) {
                  return _dataAccount(snapshot.data);
                }
              }
              return _dataAccount(null);
            }
          ),
        ],
      ),
    );
  }

  ///
  Widget _titleSecc(String titulo) {

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.symmetric(
          horizontal: BorderSide(color: _globals.colorGreen)
        )
      ),
      child: Text(
        titulo,
        textScaleFactor: 1,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          color: _globals.colorGreen
        ),
      ),
    );
  }
  ///
  Widget _dataAccount(AccountEntity? account) {

    String curc  = 'Sin Registro';
    String iDMsg = 'Sin Id de Mensajería';
    String dDSrv = 'Sin Token de Servidor';
    
    if(account != null) {
      curc = account.curc;
      iDMsg= account.msgToken;
      dDSrv= account.serverToken;
      
      if(iDMsg.length > 10) {
        var first = iDMsg.substring(0, 10);
        var last  = iDMsg.substring((iDMsg.length - 10), iDMsg.length);
        iDMsg = '$first...$last';
      }

      if(dDSrv.length > 10) {
        var first = dDSrv.substring(0, 10);
        var last  = dDSrv.substring((dDSrv.length - 10), dDSrv.length);
        dDSrv = '$first...$last';
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
          _row('IDMsg:', iDMsg),
          _row('IDSrv:', dDSrv),
          _row('CURC:', curc.toUpperCase()),
        ],
      ),
    );
  }

  ///
  Widget _item({
    required IconData icono,
    required String label,
    required Function fnc}) 
  {

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
    double sz = 17, Color cl = const Color.fromARGB(255, 246, 247, 248)}) 
  {

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