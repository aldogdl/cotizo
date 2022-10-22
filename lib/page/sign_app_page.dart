import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../config/sngs_manager.dart';
import '../entity/account_entity.dart';
import '../providers/signin_provider.dart';
import '../vars/globals.dart';
import '../widgets/bg_img_pzas.dart';

class SignAppPage extends StatefulWidget {

  const SignAppPage({Key? key}) : super(key: key);

  @override
  State<SignAppPage> createState() => _SignAppPageState();
}

class _SignAppPageState extends State<SignAppPage> {

  final ValueNotifier<String> _isLoading = ValueNotifier<String>('¡Autenticarme Ahora!');
  final Globals _globals = getIt<Globals>();
  final _frmKey = GlobalKey<FormState>();
  final  _ctrCurc = TextEditingController();
  final  _ctrPass = TextEditingController();
  final  _fcCurc  = FocusNode();
  final  _fcPass  = FocusNode();

  bool _isInit = false;
  bool _isObscure = true;
  bool _isAbsorb = false;
  late final SignInProvider _signIn;

  @override
  void dispose() {
    _isLoading.dispose();
    _ctrCurc.dispose();
    _ctrPass.dispose();
    _fcCurc.dispose();
    _fcPass.dispose();
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
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Container(
        constraints: BoxConstraints.expand(
          width: MediaQuery.of(context).size.width
        ),
        child: BGImgPzas(
          bgColor: _globals.bgMain,
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.width * 0.12
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.4,
                  height: MediaQuery.of(context).size.width * 0.4,
                  child: SvgPicture.asset(
                    'assets/svgs/avatar_male.svg',
                    semanticsLabel: 'Autenticate'
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'AUTENTICATE POR FAVOR',
                  textScaleFactor: 1,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.white,
                    letterSpacing: 1.1
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      _frm(),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 45,
                        child: ValueListenableBuilder<String>(
                          valueListenable: _isLoading,
                          builder: (_, val, __) {
                            return AbsorbPointer(
                              absorbing: _isAbsorb,
                              child: _btnLogin(val),
                            );
                          },
                        )
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: const Image(
                          image: AssetImage('assets/images/logo_dark.png'),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          )
        )
      )
    );
  }

  ///
  Widget _frm() {

    return Form(
      key: _frmKey,
      child: Column(
        children: [
          TextFormField(
            controller: _ctrCurc,
            focusNode: _fcCurc,
            autocorrect: true,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.visiblePassword,
            validator: (curc) {
              if(curc == null || curc.isEmpty) {
                return 'El CURC es necesario.';
              }
              if(!curc.startsWith('anet')) {
                return 'El CURC es invalido.';
              }
              return null;
            },
            style: _styleTxt(),
            decoration: InputDecoration(
              fillColor: Colors.black,
              filled: true,
              hintText: 'anetc0c0',
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 16,
                fontWeight: FontWeight.w100,
                letterSpacing: 1.1
              ),
              border: _border(),
              enabledBorder: _border(),
              prefixIcon: const Icon(Icons.key, color: Colors.grey)
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _ctrPass,
            focusNode: _fcPass,
            autocorrect: true,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            textInputAction: TextInputAction.done,
            keyboardType: TextInputType.visiblePassword,
            onFieldSubmitted: (txt) => _hacerLogin(),
            validator: (pass) {
              if(pass == null || pass.isEmpty) {
                return 'La contraseña es necesaria.';
              }
              if(pass.length < 4) {
                return 'La contraseña es invalida.';
              }
              return null;
            },
            obscureText: _isObscure,
            style: _styleTxt(),
            decoration: InputDecoration(
              border: _border(),
              enabledBorder: _border(color: Colors.blue),
              focusedBorder: _border(color: Colors.blue),
              prefixIcon: const Icon(Icons.password_sharp, color: Colors.grey),
              fillColor: Colors.black,
              filled: true,
              suffixIcon: IconButton(
                onPressed: () => setState(() {
                  _isObscure = !_isObscure;
                }),
                padding: const EdgeInsets.all(0),
                color: Colors.green,
                visualDensity: VisualDensity.compact,
                iconSize: 25,
                constraints: const BoxConstraints(
                  maxHeight: 10, minHeight: 10
                ),
                icon: (_isObscure)
                  ? const Icon(Icons.visibility_off, color: Colors.green)
                  : const Icon(Icons.visibility, color: Colors.green),
              )
            ),
          )
        ],
      )
    );
  }

  ///
  Widget _btnLogin(String msg) {

    Color bgBtn  = _globals.colorGreen;
    Color txtCol = Colors.black;
    if(_isAbsorb) {
      bgBtn  = Colors.black;
      txtCol = _globals.colorGreen;
    }
    
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(bgBtn)
      ),
      onPressed: () async {
        FocusManager.instance.primaryFocus?.unfocus();
        await _hacerLogin();
      },
      child: Text(
        msg,
        textScaleFactor: 1,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 20,
          color: txtCol,
          fontWeight: FontWeight.bold
        ),
      )
    );
  }

  ///
  TextStyle _styleTxt() {

    return const TextStyle(
      color: Colors.grey,
      fontSize: 18
    );
  }

  ///
  OutlineInputBorder _border({ Color color = Colors.green} ) {

    color = _globals.colorGreen;
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: color, width: 1)
    );
  }

  ///
  Future<void> _hacerLogin() async {

    if(_frmKey.currentState!.validate()) {

      _isLoading.value = 'Revisando Credenciales';
      final nav = GoRouter.of(context);
      final account = AccountEntity();

      setState(() {
        _isAbsorb = true;
      });

      final curc = _ctrCurc.text.trim().toLowerCase();
      await _signIn.login({
        'username': curc,
        'password': _ctrPass.text.trim().toLowerCase()
      });

      if(_signIn.userEm.result['abort']) {
        setState(() { _isAbsorb = false; });
        _isLoading.value = _signIn.userEm.result['body'];
        return;
      }

      account.serverToken = _signIn.userEm.result['body'];
      account.curc = curc;
      account.password = _ctrPass.text.trim().toLowerCase();

      _isLoading.value = 'Preparando todo para ti';
      _signIn.userEm.cleanResult();
      await _signIn.userEm.recoveryDataUser(curc);
      if(_signIn.userEm.result['abort']) {
        setState(() { _isAbsorb = false; });
        _isLoading.value = 'ERROR! Inténtalo de nuevo';
        return;
      }

      account.id = _signIn.userEm.result['body']['u_id'];
      account.roles = List<String>.from(_signIn.userEm.result['body']['u_roles']);
      await _signIn.userEm.setDataUserInLocal(account);
      _signIn.isLogin = true;
      nav.go('/');
    }
  }

}