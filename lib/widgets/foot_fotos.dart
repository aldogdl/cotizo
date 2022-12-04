import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' show XFile;
import 'package:provider/provider.dart';

import 'show_dialogs.dart';
import '../config/sngs_manager.dart';
import '../entity/chat_entity.dart';
import '../providers/gest_data_provider.dart';
import '../services/my_image/my_im.dart';
import '../vars/constantes.dart';
import '../vars/enums.dart';
import '../vars/globals.dart';
import 'camara/my_camera.dart';

class FootFotos extends StatefulWidget {

  final ValueChanged<ChatEntity> onSend;
  final ValueChanged<void> onClose;
  const FootFotos({
    Key? key,
    required this.onSend,
    required this.onClose,
  }) : super(key: key);

  @override
  State<FootFotos> createState() => _FootFotosState();
}

class _FootFotosState extends State<FootFotos>{

  final ValueNotifier<bool> _showCamera = ValueNotifier<bool>(true);

  late final GestDataProvider _prov;
  final _globals = getIt<Globals>();

  List<String> imgPaths = [];
  bool _isInit = false;
  bool _showGaleriFromCamera = false;

  @override
  void dispose() async {
    super.dispose();
    _showCamera.dispose();
  }

  @override
  Widget build(BuildContext context) {

    if(!_isInit) {
      _isInit = true;
      _prov = context.read<GestDataProvider>();
      if(_prov.initCamAuto) {
        _prov.initCamAuto = false;
        Future.microtask(() => _getFotosFromCamera());
      }
    }
    return _body();
  }

  ///
  Widget _body() {

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.17,
      color: _globals.bgMain,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Selector<GestDataProvider, String>(
            selector: (_, provi) => provi.msgCampos,
            builder: (_, val, __) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.keyboard, size: 12, color: _globals.txtAlerts),
                  const SizedBox(width: 10),
                  Text(
                    val,
                    textScaleFactor: 1,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: _globals.txtAlerts
                    ),
                  )
                ],
              );
            }
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _iconBol(
                Icons.close, 'Cerrar',
                const Color.fromARGB(255, 81, 169, 169),
                () async => widget.onClose(null)
              ),
              _iconBol(
                Icons.attach_file, 'Galería',
                const Color.fromARGB(255, 2, 168, 91),
                () async =>  _getFotoFromGalery()
              ),
              _iconBol(
                Icons.camera_alt, 'Cámara',
                const Color(0xFF51a985),
                () async => _getFotosFromCamera()
              ),
            ],
          )
        ],
      ),
    );
  }
  
  ///
  Widget _iconBol(IconData i, String label, Color c, Function fnc) {

    return Column(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: c,
          child: IconButton(
            padding: const EdgeInsets.all(0),
            onPressed: () async => fnc(),
            icon: Icon(i, color: _globals.bgMain),
          )
        ),
        const SizedBox(height: 3),
        Text(
          label,
          textScaleFactor: 1,
          style: TextStyle(
            fontSize: 14,
            color: _globals.txtOnsecMainLigth
          ),
        )
      ],
    );
  }

  ///
  Future<void> _preGetFotos() async {

    try {
      // Cancelamos el cron de revision de fotos en caso de estar encendido.
      _prov.msgCampos = '...';
      _prov.onCheckFotos = false;
    } catch (_) {}

    if(_prov.campos[Campos.rFotos].length == Constantes.cantFotos) {
      if(mounted) {
        await _alertFotosCant();
      }
      return;
    }

    await _prov.cleanMsgsAnetInFotos();
  }

  ///
  Future<void> _getFotosFromCamera() async {

    _preGetFotos().then((_) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MyCamera(
            onFinish: (fotos) async {
              final nav = Navigator.of(context);
              _showGaleriFromCamera = false;
              await _processImage(fotos);
              nav.pop();
            },
            fromGaleria: (fotos) async {
              _showGaleriFromCamera = true;
              await _processImage(fotos);
            }
          )
        ),
      );
    });
  }

  ///
  Future<void> _getFotoFromGalery() async {
    
    if(_showGaleriFromCamera) { Navigator.of(context).pop(); }
    _showGaleriFromCamera = false;
    _preGetFotos().then((_) async {
      await _processImage( await MyIm.galeria() );
    });
  }

  ///
  Future<void> _processImage(List<XFile>? imgs) async {

    bool hasFotos = false;
    if(imgs != null && imgs.isNotEmpty) {
      
      hasFotos = true;
      _prov.imgTmps = 0;
      final pathsCurrent = List<String>.from(_prov.campos[Campos.rFotos]).toList().length;
      // Metemos todas las fotos nuevas que nos mandan por parametro
      for(var i = 0; i < imgs.length; i++) {
        if((pathsCurrent + imgPaths.length) < Constantes.cantFotos) {
          if(!imgPaths.contains(imgs[i].path)) {
            imgPaths.add(imgs[i].path);
          }
        }
      }
    }

    if(_showGaleriFromCamera) {
      await _getFotoFromGalery();
      return;
    }else{
      if(hasFotos) {
        _sendFotosToMessage();
      }else{
        Navigator.of(context).pop();
      }
    }

    _prov.msgCampos = ':-) Al menos coloca una FOTO';
  }

  /// Enviamos todas las fotos para colocar en pantalla
  void _sendFotosToMessage() async {

    final pathsCurrent = List<String>.from(_prov.campos[Campos.rFotos]).toList();
    _prov.campos[Campos.rFotos] = [];

    // Metemos todas las fotos que ya teniamos a las nuevas.
    for (var i = 0; i < pathsCurrent.length; i++) {
      if(!imgPaths.contains(pathsCurrent[i])) {
        imgPaths.insert(0, pathsCurrent[i]);
      }
    }

    _prov.campos[Campos.rFotos] = List<String>.from(imgPaths);

    if(imgPaths.isNotEmpty) {

      for(var i = 0; i < imgPaths.length; i++) {
        widget.onSend(
          ChatEntity(
            id: _prov.msgs.length+1,
            from: ChatFrom.user,
            key: ChatKey.userRes,
            campo: _prov.currentCampo,
            tipo: ChatTip.image,
            value: imgPaths[i],
          )
        );
        await Future.delayed(const Duration(milliseconds: 150));
      }
      imgPaths = [];
    }
  }

  ///
  Future<void> _alertFotosCant() async {

    ShowDialogs.alert(
      context, 'fotosCant',
      hasActions: false
    ).then((res){
      res = (res == null) ? false : res;
      if(res) {
        widget.onClose(null);
      }
      _prov.campos[Campos.isValidFotos] = true;
      _prov.changeCampoToDetalles();
    });
  }

}