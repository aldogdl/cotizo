import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart' show PlatformException;

import 'siging_pages/cuenta_nueva.dart';
import 'siging_pages/datos.dart';
import 'siging_pages/listo_login.dart';
import 'siging_pages/permisos.dart';
import 'siging_pages/welcome.dart';
import '../config/sngs_manager.dart';
import '../providers/signin_provider.dart';
import '../vars/globals.dart';
import '../widgets/bg_img_pzas.dart';

class SignAppPage extends StatefulWidget {

  const SignAppPage({Key? key}) : super(key: key);

  @override
  State<SignAppPage> createState() => _SignAppPageState();
}

class _SignAppPageState extends State<SignAppPage> {

  final ValueNotifier<String> _isLoading = ValueNotifier<String>('');
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
      body: Container(
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
              child: BGImgPzas(
                bgColor: _globals.bgMain,
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
                        return _buildPage(
                          sgv: 'avatar_male.svg',
                          child: _dataLogin(snap.data ?? false)
                        );
                      },
                    ),
                    _buildPage(sgv: 'bookmarks.svg', child: Welcome(globals: _globals)),
                    _buildPage(sgv: '', child: Permisos(globals: _globals)),
                    _buildPage(sgv: '', ico: Icons.co_present_rounded, child: Datos(globals: _globals)),
                    _buildPage(
                      sgv: '', ico: Icons.attach_email_outlined,
                      child: CuentaNueva(globals: _globals),
                      isLast: true
                    ),
                  ],
                )
              )
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.85,
              height: MediaQuery.of(context).size.height * 0.07,
              child: ElevatedButton.icon(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    const Color.fromARGB(255, 15, 109, 185)
                  )
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
            ),
            const SizedBox(height: 10)
          ],
        ),
      )
    );
  }

  ///
  Widget _buildPage
    ({
      required String sgv, required Widget child,
      IconData ico = Icons.security,
      bool isLast = false
    })
  {

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if(sgv.isNotEmpty)
          _getSgv(sgv)
        else
          Icon(ico, size: 120, color: Colors.blueGrey),
        child,
        if(!isLast)
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
              fontSize: 17,
              color: Color.fromARGB(255, 22, 22, 22)
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
      children: List.generate(5, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Icon(
            Icons.circle,
            size: 13,
            color: (index == _pageCurrent)
              ? _globals.colorGreen
              : const Color.fromARGB(255, 68, 68, 68)
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
          TextButton(
            onPressed: () {
              if(_globals.histUri.isNotEmpty) {
                context.go(_globals.getBack());
              }else{
                context.pop();
              }
            },
            child: Text(
              'CONTINUAR SIN AUTENTICACIÓN',
              textScaleFactor: 1,
              style: TextStyle(
                fontSize: 15,
                color: _globals.colorGreen
              ),
            )
          ),
          const SizedBox(height: 35),
          Text(
            'No olvides otorgar TODO los permisos',
            style: TextStyle(
              fontSize: 13,
              color: _globals.txtOnsecMainLigth
            )
          ),
        ],
      ),
    );
  }

  ///
  Future<void> _hacerLogin() async {

    _isLoading.value = 'auth';
    final nav = GoRouter.of(context);

    try {
      await _signIn.login();
    } on PlatformException catch (_) {
      _isLoading.value = 'cancel';
    } finally {
      _isLoading.value = '';
    }

    bool isOk = await _checkUser();
    if(isOk) {

      isOk = await _signIn.isSame();
      if(isOk) { nav.pop(); }

      await showModalBottomSheet(
        context: context,
        isDismissible: false,
        isScrollControlled: true,
        backgroundColor: _globals.bgMain,
        builder: (ctx) {

          final nav = GoRouter.of(ctx);
          return ListoLogin(
            globals: _globals,
            onFinish: (_) {
              if(nav.canPop()) {
                Future.microtask(() => nav.pop());
              }else{
                Future.microtask(() => nav.go('/home'));
              }
            }
          );
        }
      );
    }
  }

  ///
  Future<bool> _checkUser() async {

    if(_signIn.currentUser != null) {
      if(_signIn.currentUser!.email.contains('@')) {
        return true;
      }
    }
    return false;
  }

}