import 'package:flutter/material.dart';
import 'package:camera/camera.dart' show XFile;
import 'package:provider/provider.dart';

import '../../vars/constantes.dart';
import '../../providers/gest_data_provider.dart';
import '../../widgets/camara/btn_take.dart';

class ControlesCam extends StatelessWidget {

  final ValueChanged<void> onPressed;
  final ValueChanged<void> onConfirm;
  final ValueChanged<void> onClose;
  final ValueChanged<int> onView;
  final bool isTest;
  const ControlesCam({
    Key? key,
    required this.onPressed,
    required this.onConfirm,
    required this.onClose,
    required this.onView,
    required this.isTest,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    return Container(
      color: Colors.black,
      child: Align(
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(width: 10),
            Selector<GestDataProvider, List<XFile>>(
              selector: (_, prov) => prov.ftsGest,
              builder: (_, cant, __) {

                return Chip(
                  label: Text(
                    '${cant.length}/${Constantes.cantFotos}',
                    textScaleFactor: 1,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 28, 77, 29)
                    ),
                  ),
                  deleteIcon: const Icon(Icons.close),
                  deleteIconColor: Colors.black,
                  backgroundColor: Colors.green,
                  onDeleted: () => onClose(null),
                );
              },
            ),
            const SizedBox(width: 20),
            (isTest) ? const SizedBox(width: 20) : _icoOk(),
            const Spacer(),
            BtnTake(onPressed: (_) => onPressed(null)),
            const SizedBox(width: 20),
            _btn(
              () => onView(0),
              Icons.remove_red_eye, Colors.greenAccent
            ),
            const Spacer(),
            _icoDel(),
            const SizedBox(width: 5),
          ],
        ),
      ),
    );
  }

  ///
  Widget _icoOk() {

    return _btn(() => onConfirm(null), Icons.done_all, Colors.blue);
  }

  ///
  Widget _icoDel() {

    return Selector<GestDataProvider, List<int>>(
      selector: (_, prov) => prov.ftsGestDel,
      builder: (provContext, lst, __) {

        Color c = const Color.fromARGB(255, 250, 98, 98);
        if(lst.isEmpty) {
          c = Colors.grey.withOpacity(0.2);
        }
        if(lst.isNotEmpty) {
          if(lst.first == -1) {
            c = Colors.grey.withOpacity(0.2);
          }
        }
        
        return _btn(() async {
          if(lst.isEmpty){ return; }
          if(lst.first == -1) { return; }
          await provContext.read<GestDataProvider>().deleteFotosSelected();
        }, Icons.delete, c);
      },
    );
  }

  ///
  Widget _btn(Function fnc, IconData ico, Color col) {

    Widget icono = Icon(ico, color: col);
    if(ico == Icons.add_circle) {
      icono = Transform.rotate(
        angle: .75,
        child: Icon(ico, color: col),
      );
    }

    return IconButton(
      onPressed: () => fnc(),
      icon: icono,
    );
  }

}