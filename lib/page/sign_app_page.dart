import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../config/sngs_manager.dart';
import '../providers/signin_provider.dart';
import '../vars/globals.dart';

class SignAppPage extends StatefulWidget {

  const SignAppPage({Key? key}) : super(key: key);

  @override
  State<SignAppPage> createState() => _SignAppPageState();
}

class _SignAppPageState extends State<SignAppPage> {

  final ValueNotifier<String> _isLoading = ValueNotifier<String>('');
  final TextEditingController _ctrCurc = TextEditingController();
  final TextEditingController _ctrPass = TextEditingController();

  final PageController _ctrPage = PageController();
  final Globals _globals = getIt<Globals>();
  
  int _pageCurrent = 0;
  bool _isInit = false;
  late final SignInProvider _signIn;

  @override
  void dispose() {
    _ctrPage.dispose();
    _isLoading.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    if(!_isInit) {
      _isInit = true;
      _signIn = context.read<SignInProvider>();
    }

    return Scaffold(
      backgroundColor: _globals.bgMain,
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          constraints: BoxConstraints.expand(
            width: MediaQuery.of(context).size.width
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: PageView(
                  controller: _ctrPage,
                  onPageChanged: (index) => setState(() {
                    _pageCurrent = index;
                  }),
                  children: [
                    FutureBuilder(
                      future: _checkUser(),
                      initialData: false,
                      builder: (_, AsyncSnapshot snap) {
                        return _buildPage(sgv: 'avatar_male.svg', child: _dataLogin(snap.data ?? false));
                      },
                    ),
                    _buildPage(sgv: 'bookmarks.svg', child: _welcome()),
                    _buildPage(sgv: 'bookmarks.svg', child: _welcome()),
                  ],
                )
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.85,
                height: MediaQuery.of(context).size.height * 0.07,
                child: ElevatedButton.icon(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(const Color.fromARGB(255, 15, 109, 185))
                  ),
                  onPressed: () async => await _hacerLogin(),
                  icon: const Icon(Icons.account_circle),
                  label: const Text(
                    'LOGIN CUANTA DE GOOGLE',
                    textScaleFactor: 1,
                    style: TextStyle(
                      fontSize: 17
                    ),
                  )
                ),
              )
            ],
          ),
        ),
      )
    );
  }

  ///
  Widget _buildPage({
    required String sgv,
    required Widget child,
  }) {

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _getSgv(sgv),
        child,
        ValueListenableBuilder(
          valueListenable: _isLoading,
          builder: (_, acc, child) {
            return (acc == 'auth') ? child! : _btnSaberMas();
          },
          child: _autenticando(),
        ),
        const SizedBox(height: 20),
        _indicadorDePosicion()
      ],
    );
  }

  ///
  Widget _autenticando() {

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        const SizedBox(
          width: 30, height: 30,
          child: CircularProgressIndicator(),
        ),
        const SizedBox(width: 10),
        Text(
          'Autenticando...',
          textScaleFactor: 1,
          style: TextStyle(
            color: _globals.txtOnsecMainSuperLigth
          ),
        )
      ],
    );
  }

  ///
  Widget _btnSaberMas() {

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        ElevatedButton(
          onPressed: () async {
            await _ctrPage.animateToPage(
              _pageCurrent+1,
              duration: const Duration(microseconds: 1000), curve: Curves.easeIn
            );
          },
          child: Text(
            (_pageCurrent == 0) ? '¿Por que una cuenta nueva?' : 'Saber Más...',
            textScaleFactor: 1,
            style: const TextStyle(
              fontSize: 17
            ),
          )
        )
      ],
    );
  }

  ///
  Widget _getSgv(String sgv) {

    return Container(
      padding: const EdgeInsets.all(20),
      height: MediaQuery.of(context).size.height * 0.35,
      child: SvgPicture.asset(
        'assets/svgs/$sgv',
        alignment: Alignment.topCenter,
        fit: BoxFit.contain,
      ),
    );
  }

  ///
  Widget _indicadorDePosicion() {

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: List.generate(4, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Icon(
            Icons.circle,
            size: 15,
            color: (index == _pageCurrent) ? Colors.blue : Colors.grey
          ),
        );
      })
    );
  }

  ///
  Widget _dataLogin(bool isLoged) {

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.grey)
            ),
            onPressed: () {
              if(_globals.goBackTo.isNotEmpty) {
                context.go(_globals.goBackTo);
              }else{
                context.pop();
              }
            },
            child: const Text(
              'Continuar sin Autenticación',
              textScaleFactor: 1,
              style: TextStyle(
                fontSize: 17,
                color: Colors.black
              ),
            )
          )
        ],
      ),
    );
  }

  ///
  Widget _welcome() {

    return Container(
      padding: const EdgeInsets.all(20),
      child: Text.rich(
        TextSpan(
          text: 'AutoparNet, pensado en tu ',
          style: TextStyle(
            color: _globals.txtOnsecMainDark,
            fontSize: 16
          ),
          children: [
            TextSpan(
              text: 'CONFIANZA, SEGURIDAD Y COMODIDAD ',
              style: TextStyle(
                color: _globals.txtOnsecMainSuperLigth
              )
            ),
            const TextSpan(
              text: 'utiliza los servicios  ',
            ),
            TextSpan(
              text: 'incluidos en tu teléfono inteligente ',
              style: TextStyle(
                color: _globals.txtOnsecMainLigth
              )
            ),
            const TextSpan(
              text: 'para realizar respaldo de tu inventario para cualquier '
              'contrariedad.'
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  ///
  Future<void> _hacerLogin() async {

    final nav = GoRouter.of(context);
    _isLoading.value = 'auth';
    
    try {
      await _signIn.login();
    } on PlatformException catch (e) {
      _isLoading.value = 'cancel';
    } finally {
      _isLoading.value = '';
    }

    if(_signIn.currentUser != null) {
      if(_globals.goBackTo.isNotEmpty) {
        nav.go(_globals.goBackTo);
      }else{
        nav.pop();
      }
    }
  }

  ///
  Future<bool> _checkUser() async {

    if(_signIn.currentUser != null) {
      if(_signIn.currentUser!.email.contains('@')) {
        return true;
      }else{
        print('sin email');
      }
    }else{
      print('userAccount nulo');
    }

    return false;
  }

}