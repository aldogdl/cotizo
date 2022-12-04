import 'package:cotizo/vars/globals.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/ordenes_provider.dart';

class TileFilter extends StatelessWidget {

  final String filtro;
  final IconData ico;
  final double altoFilters;
  final ValueChanged<String> onPress;
  const TileFilter({
    Key? key,
    required this.filtro,
    required this.ico,
    required this.altoFilters,
    required this.onPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return SizedBox(
      height: altoFilters, width: MediaQuery.of(context).size.width / 4,
      child: _tile(),
    );
  }

  ///
  Widget _tile() {

    return Selector<OrdenesProvider, Map<String, dynamic>>(
      selector: (_, prov) => prov.typeFilter,
      builder: (_, f, __) {
        
        bool isActive = false;
        bool isSelect = false;

        Color bg = const Color.fromARGB(255, 46, 160, 107);
        Color ic = Colors.black;
        Color bd = const Color.fromARGB(255, 114, 114, 114);
        Color tx = const Color.fromARGB(255, 121, 121, 121);
        
        if(f['current'] == filtro.toLowerCase()) {
          isActive = true;
        }else{
          if(f['current'].isEmpty) {
            if('todas' == filtro.toLowerCase()) {
              isActive = true;
            }
          }
        }

        if(f['select'] == filtro.toLowerCase()) {
          isSelect = true;
        }else{
          if(f['select'].isEmpty) {
            if('todas' == filtro.toLowerCase()) {
              isSelect = true;
            }
          }
        }

        if(isActive) {
          bg = const Color.fromARGB(255, 0, 0, 0);
          ic = const Color.fromARGB(255, 46, 160, 107);
          bd = const Color.fromARGB(255, 46, 160, 107);
        }

        if(isSelect) { tx = Colors.green; }

        final cBtn = Globals().bgAppBar;
        return ListView(
          children: [
            ElevatedButton(
              style: ButtonStyle(
                overlayColor: MaterialStateProperty.all(cBtn),
                backgroundColor: MaterialStateProperty.all(cBtn),
                padding: MaterialStateProperty.all(const EdgeInsets.all(0)),
                visualDensity: VisualDensity.compact
              ),
              onPressed: () => onPress(filtro.toLowerCase()),
              child: CircleAvatar(
                radius: 25, backgroundColor: bd,
                child: CircleAvatar(
                  radius: 23, backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                  child: CircleAvatar(
                    radius: 20, backgroundColor: bg,
                    child: Icon(ico, size: 20, color: ic),
                  ),
                ),
              )
            ),
            const SizedBox(height: 5),
            Text(
              filtro,
              textScaleFactor: 1,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: tx,
                fontSize: 13.5,
              ),
            )
          ],
        );
      },
    );
  }
}