import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../entity/account_entity.dart';
import '../../repository/acount_user_repository.dart';
import '../../providers/signin_provider.dart';
import '../../vars/globals.dart';

class ListoLogin extends StatefulWidget {

  final Globals globals;
  final ValueChanged<void> onFinish;
  const ListoLogin({
    Key? key,
    required this.globals,
    required this.onFinish,
  }) : super(key: key);

  @override
  State<ListoLogin> createState() => _ListoLoginState();
}

class _ListoLoginState extends State<ListoLogin> {

  late final SignInProvider _prov;
  late final AcountUserRepository _cEm;
  bool _isInit = false;

  @override
  Widget build(BuildContext context) {

    if(!_isInit) {
      _isInit = true;
      _prov = context.read<SignInProvider>();
      _cEm = AcountUserRepository();
    }

    return Column(
      children: [
        const SizedBox(height: 150),
        Text(
          'GRACIAS POR AUTENTICARTE',
          textScaleFactor: 1,
          style: TextStyle(
            fontSize: 19,
            color: widget.globals.colorGreen
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.85,
          child: Image.asset(
            'assets/images/logo_1024.png',
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 50),
        Text(
          'Estamos preparando todo para ti.',
          textScaleFactor: 1,
          style: TextStyle(
            fontSize: 19,
            color: widget.globals.colorGreen
          ),
        ),
        const Expanded(child: SizedBox()),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.1,
          child: Image.asset(
            'assets/images/pistones.gif',
            fit: BoxFit.contain,
          ),
        ),
        StreamBuilder<String>(
          stream: _make(),
          initialData: 'Espera por favor',
          builder: (_, AsyncSnapshot<String> msg) {

            if(msg.data!.startsWith('!ERROR')) {

              return ElevatedButton(
                onPressed: () async {
                  setState((){});
                },
                child: const Text(
                  'INTENTARLO DE NUEVO',
                  textScaleFactor: 1,
                  style: TextStyle(
                    fontSize: 17,
                    color: Color.fromARGB(255, 22, 22, 22)
                  ),
                )
              );
            }

            if(msg.data!.startsWith('!ÉXITO')) {
              widget.onFinish(null);
            }

            return Text(
              msg.data!,
              textScaleFactor: 1,
              style: TextStyle(
                fontSize: 19,
                color: widget.globals.txtOnsecMainLigth
              ),
            );
          }
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  ///
  Stream<String> _make() async* {

    yield 'Contruyendo cuenta nueva';
    await Future.delayed(const Duration(milliseconds: 500));
    
    final acount = AccountEntity();
    acount.fromLoginGoogle(_prov.currentUser!);
    acount.curc = _prov.getCurc();
    yield 'Cotejando Credenciales';
    await _cEm.recoveryDataUser(acount.curc);
    
    if(!_cEm.result['abort']) {
      if(_cEm.result['body'].isNotEmpty) {
        acount.id = _cEm.result['body']['u_id'];
        acount.roles = List<String>.from(_cEm.result['body']['u_roles']);
        yield 'Resguardando Credenciales';
        await _cEm.setDataUserInLocal(acount);
        await _cEm.setTokenMessaging(null);
      }
    }else{
      yield '!ERROR!, ¿Deséas intentárlo nuevamante?';
      return;
    }
    
    yield '!ÉXITO en tus Ventas!';
    await Future.delayed(const Duration(milliseconds: 1000));
  }
}