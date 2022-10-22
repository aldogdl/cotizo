import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show DeviceOrientation;
import 'package:provider/provider.dart';

import 'controles_cam.dart';
import 'tile_foto_thubm.dart';
import '../../providers/gest_data_provider.dart';
import '../../vars/constantes.dart';

class PortraitCam extends StatelessWidget {

  final DeviceOrientation orientation;
  final ValueChanged<void> onPressed;
  final ValueChanged<void> onConfirm;
  final ValueChanged<void> onClose;
  final ValueChanged<bool> fromGalery;
  final ValueChanged<int> onView;
  final bool isTest;
  const PortraitCam({
    Key? key,
    required this.orientation,
    required this.onPressed,
    required this.onConfirm,
    required this.onClose,
    required this.fromGalery,
    required this.onView,
    required this.isTest,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    double width = MediaQuery.of(context).size.width;
    double height= MediaQuery.of(context).size.height;
    double alto = height * 0.35;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      width: width, height: alto,
      child: LayoutBuilder(
        builder: (_, c) {

          double partes = c.maxHeight/3;
          double tamLis = partes + 10;
          if(orientation != DeviceOrientation.portraitUp) {
            tamLis = partes + partes - 25;
          }

          return ListView(
            children: [
              if(orientation == DeviceOrientation.portraitUp)
                (isTest) ? _msgTest() : _btnGaleria(),
              SizedBox(
                width: width, height: partes,
                child: ControlesCam(
                  isTest: isTest,
                  onClose: (_) => onClose(null),
                  onConfirm: (_) => onConfirm(null),
                  onPressed: (_) => onPressed(null),
                  onView: (ft) => onView(ft),
                ),
              ),
              SizedBox(
                width: width, height: tamLis,
                child: _lstFotos()
              )
            ],
          );
        },
      )
    );
  }

  ///
  Widget _msgTest() {

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Text(
        'CÁMARA DE PRUEBA APP COTIZO',
        textScaleFactor: 1,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.grey.withOpacity(0.7),
          fontSize: 18,
          fontWeight: FontWeight.bold
        ),
      ),
    );
  }

  ///
  Widget _btnGaleria() {

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ElevatedButton.icon(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(const Color.fromARGB(255, 81, 169, 133))
        ),
        onPressed: () => fromGalery(true),
        icon: const Icon(Icons.create_new_folder_rounded, color: Colors.black45),
        label: const Text(
          'TOMAR FOTOS DESDE GALERÍA',
          textScaleFactor: 1,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            letterSpacing: 1.1,
            height: 1.1,
            color: Colors.black,
            fontWeight: FontWeight.bold
          ),
        ),
      ),
    );
  }

  ///
  Widget _lstFotos() {
    
    return Selector<GestDataProvider, bool>(
      selector: (_, prov) => prov.ftsGestRefresh,
      builder: (cntx, ft, __) {

        final provG = cntx.read<GestDataProvider>();

        return ListView.builder(
          controller: ScrollController(),
          scrollDirection: Axis.horizontal,
          itemCount: Constantes.cantFotos,
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 5),
          itemBuilder: (_, inx) {

            String ftoPath = '';
            try {
              ftoPath = provG.ftsGest[inx].path;
            } catch (e) {
              ftoPath = '0';
            }
            return Padding(
              padding: const EdgeInsets.all(5),
              child: TileFotoThubm(
                orientation: orientation,
                foto: ftoPath,
                onView: (_) => onView(inx),
              ),
            );
          },
        );
      },
    );
  }

}