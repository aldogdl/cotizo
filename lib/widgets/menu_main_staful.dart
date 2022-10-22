import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/gest_data_provider.dart';
import '../providers/signin_provider.dart';
import '../repository/config_app_repository.dart';

class MenuMainStaful extends StatefulWidget {

  const MenuMainStaful({Key? key}) : super(key: key);

  @override
  State<MenuMainStaful> createState() => _MenuMainStafulState();
}

class _MenuMainStafulState extends State<MenuMainStaful> {

  final _cngEm = ConfigAppRepository();

  @override
  void initState() {

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_getDataInit);
  }

  @override
  Widget build(BuildContext context) {

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Selector<SignInProvider, bool>(
          selector: (_, prov) => prov.desablePushInt,
          builder: (cntx, valP, __) {
            
            final txt = (valP) ? 'Deshabilitar' : 'Habilitar';
            return _row(
              ic: Icons.notifications_active, label: '$txt Notificaciones',
              child: Switch(
                onChanged: (val) async => await _saveSttPush(val),
                value: valP,
                inactiveTrackColor: Colors.grey,
                activeColor: Colors.blue,
              )
            );
          },
        ),
        const SizedBox(height: 8),
        Selector<GestDataProvider, int>(
          selector: (_, prov) => prov.modoCot,
          builder: (cntx, valP, __) {
            
            String txt = 'VIAJERO';
            switch (valP) {
              case 2:
                txt = 'COPILOTO';
                break;
              case 3:
                txt = 'PILOTO';
                break;
            }

            return TextButton(
              onPressed: (){},
              onLongPress: () async => await _saveModoCot(valP),
              child: Row(
                children: [
                  const Icon(
                    Icons.point_of_sale_sharp, size: 22, color: Color(0xFF83929c),
                  ),
                  const SizedBox(width: 5),
                  _texto('Modo de Cotizar Típo:', sz: 16),
                  const Spacer(),
                  _texto(txt, sz: 16),
                ],
              )
            );
          },
        ),
      ],
    );
  }

  ///
  Widget _padd(Widget child, {double top = 0}) {

    return Padding(
      padding: EdgeInsets.only(left: 10, top: top),
      child: child,
    );
  }

  ///
  Widget _row({
    required IconData ic, required String label, required Widget child  }) 
  {
    return _padd(
      Row(
        children: [
          Icon(
            ic, size: 22, color: const Color(0xFF83929c),
          ),
          const SizedBox(width: 5),
          _texto(label, sz: 16),
          const Spacer(),
          SizedBox(
            width: 40, height: 32,
            child: FittedBox(
              fit: BoxFit.fill,
              child: child,
            ),
          )
        ],
      ),
      top: 5
    );
  }

  ///
  Widget _texto(String label, {
    double sz = 17, Color cl = const Color.fromARGB(255, 246, 247, 248)}) 
  {
    return Text(
      label,
      textScaleFactor: 1,
      textAlign: TextAlign.left,
      style: TextStyle(
        fontSize: sz,
        letterSpacing: 1.1,
        color: cl
      ),
    );
  }

  ///
  Future<void> _saveModoCot(int current) async {

    int modo = 0;
    switch (current) {
      case 1:
        modo = 2;
        break;
      case 2:
        modo = 3;
        break;
      case 3:
        modo = 1;
        break;
      default:
        modo = 1;
    }
    if(mounted) {
      context.read<GestDataProvider>().modoCot = modo;
      await _cngEm.setModoCotiza(modo);
    }
  }

  ///
  Future<void> _saveSttPush(bool newVal) async {

    if(mounted) {
      context.read<SignInProvider>().desablePushInt = newVal;
      await _cngEm.setStatusNotiff(newVal);
    }
  }

  ///
  Future<void> _getDataInit(_) async {

    if(mounted) {
      final prov = context.read<SignInProvider>();
      context.read<GestDataProvider>().modoCot = await _cngEm.getModoCotiza();
      prov.desablePushInt = await _cngEm.getStatusNotiff();
    }

  }

}