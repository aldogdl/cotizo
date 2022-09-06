import 'package:camera/camera.dart' show XFile;
import 'package:cotizo/repository/ordenes_repository.dart';
import 'package:flutter/material.dart' show BuildContext, ChangeNotifier;
import 'package:cron/cron.dart';
import 'package:go_router/go_router.dart';

import '../config/sngs_manager.dart';
import '../entity/chat_entity.dart';
import '../services/my_image/my_im.dart';
import '../vars/globals.dart';
import '../widgets/mensajes/get_anet_msg.dart';
import '../widgets/mensajes/dialogs.dart';
import '../vars/constantes.dart';
import '../vars/enums.dart';

class GestDataProvider with ChangeNotifier {

  final _globals = getIt<Globals>();

  Cron cronImgProcess = Cron();
  final int espera = 3;
  final _ordEm = OrdenesRepository();

  ///
  void clean() {
    _msgs = [];
    currentCampo = Campos.none;
    onCheckFotos = false;
    changeKeyboard = 'txt';
    reviciones = 0;
    imgTmps = 0;
    dataSaveImg= [];
    _imgsListas = [];
    _imgProcessCurrent = '';
    _globals.idOrdenCurrent = 0;
    _globals.idsFromLinkCurrent = '';
    _globals.idCampaingCurrent = '';
    campos = {
      Campos.rFotos: <String>[],
      Campos.isValidFotos :false,
      Campos.rDeta :'',
      Campos.isValidDeta :false,
      Campos.rCosto:'',
      Campos.isValidCosto: false,
      Campos.isCheckData: false
    };
  }

  /// Cambiamos el teclado segun el requerimiento del campo en curso.
  String _changeKeyboard = 'txt';
  String get changeKeyboard => _changeKeyboard;
  set changeKeyboard(String tipo) {
    _changeKeyboard = tipo;
    notifyListeners();
  }

  /// Usado para rectificar que las fotos esten completas cunado son agregadas
  /// de una sola vez todas.
  int imgTmps = 0;

  /// mostrar la primer pagina de Estas Listo!!
  bool showMsgEstasListo = true;
  /// Utilizado para encender el check de las fotos
  int reviciones = 0;
  bool onCheckFotos = false;
  // Los mensajes pueden ser largos y explicativos en caso de ser un dummy
  ModoDialog modoDialog = ModoDialog.dummy;

  ///
  Campos _currentCampo = Campos.none;
  Campos get currentCampo => _currentCampo;
  set currentCampo(Campos ncampo) {
    _currentCampo = ncampo;
    notifyListeners();
  }

  // Campos necesarios para una respuesta
  Map<Campos, dynamic> campos = {
    Campos.rFotos: <String>[],
    Campos.isValidFotos: false,
    Campos.rDeta :'',
    Campos.isValidDeta :false,
    Campos.rCosto:'',
    Campos.isValidCosto: false,
    Campos.isCheckData: false
  };

  /// Mensajes para los compos cuando se esta cotizando.
  String _msgCampos = '...';
  String get msgCampos => _msgCampos;
  set msgCampos(String mc) {
    _msgCampos = mc;
    notifyListeners();
  }
  
  ///
  List<ChatEntity> _msgs = [];
  List<ChatEntity> get msgs => _msgs;
  set msgs(List<ChatEntity> messages) {
    _msgs.clear();
    _msgs.addAll(messages);
  }

  /// Agregamos y revisamos las respuestas del usuario
  void addMsgs(ChatEntity msg) async {

    if(msg.value.isNotEmpty) {

      ChatEntity? msgErr;
      // Validamos solo mensajes que sean enviados por el usuario y no por la app
      if(msg.from == ChatFrom.user) {

        // Debo de validarlos,
        msgErr = await _isValidData(msg);
        if(msgErr == null) {

          // es correcto tomar el siguiente campo,
          reviciones = 0;
          if(currentCampo == Campos.rFotos) {

            if(campos[Campos.rFotos].length < Constantes.cantFotos) {
              showAlertFotos();
            }else{
              imgTmps++;
            }
          }

          if(currentCampo == Campos.rFotos && campos[Campos.isValidFotos]) {
            changeCampoToDetalles();
          }

          if(currentCampo == Campos.rDeta && campos[Campos.isValidDeta]) {
            _changeCampoToCosto();
          }

          if(currentCampo == Campos.rCosto && campos[Campos.isValidCosto]) {
            _changeCampoToCheckData();
          }
        }
      }

      final msgsTmp = List<ChatEntity>.from(_msgs);
      _msgs.clear();
      msgsTmp.add(msg);
      if(msgErr != null) {
        msgsTmp.add(msgErr);
      }
      _msgs = List<ChatEntity>.from(msgsTmp);
      if(currentCampo == Campos.rFotos) {
        _checkValidezCantFotos();
      }
      msgsTmp.clear();
      notifyListeners();
    }
  }

    ///
  void editMsgs(ChatEntity msg) async {

    int msgEditIndex = msgs.indexWhere((m) => m.campo == msg.campo);
    if(msgEditIndex != -1) {

      msgs.removeAt(msgEditIndex);
      if(msg.campo == Campos.rFotos) {
        
        Map<String, dynamic> removeFoto = {};
        if(campos[Campos.rFotos].isNotEmpty) {
          for(var f=0; f<campos[Campos.rFotos].length; f++) {

            if(campos[Campos.rFotos][f] == msg.value) {
              campos[Campos.rFotos].removeAt(f);
              if(_imgsListas.contains(msg.value)) {

                _imgsListas.remove(msg.value);
                final foto = dataSaveImg.indexWhere(
                  (element) => element['absolute'] == msg.value,
                );
                if(foto != -1) {
                  removeFoto = Map<String, dynamic>.from(dataSaveImg[foto]);
                  dataSaveImg.removeAt(foto);
                }
                if(removeFoto.isNotEmpty) {
                  await MyIm.removeFotoInApp(removeFoto['path']);
                }
              }
              imgTmps--;
            }
          }

          imgTmps = (imgTmps < 0) ? 0 : imgTmps;
          if(currentCampo != Campos.rFotos) {
            currentCampo = Campos.rFotos;
          }

          await Future.delayed(const Duration(milliseconds: 350));
          if(campos[Campos.rFotos].length < Constantes.cantFotos) {

            campos[Campos.isValidFotos] = false;
            if(!onCheckFotos) {
              showAlertFotos();
            }
          }
        }
      }
      if(msg.campo == Campos.rDeta) {
        campos[Campos.rDeta] = '';
        campos[Campos.isValidDeta] = false;
        changeCampoToDetalles();
      }
      if(msg.campo == Campos.rCosto) {
        campos[Campos.rCosto] = '';
        campos[Campos.isValidCosto] = false;
        _changeCampoToCosto();
      }
    }
  }

  ///
  void _checkValidezCantFotos() {

    int imgScreen = 0;
    for(var f = 0; f < msgs.length; f++) {
      if(msgs[f].tipo == ChatTip.image) {
        imgScreen++;
      }
    }

    if(imgScreen > imgTmps) {
      imgTmps = imgScreen;
    }

    if(imgTmps == Constantes.cantFotos) {
      campos[Campos.isValidFotos] = true;
      changeCampoToDetalles();
    }
  }

  ///
  void changeCampoToDetalles() async {

    imgTmps = 0;
    currentCampo = Campos.rDeta;
    final msg = await GetAnet.msg(ChatKey.putDeta, id: msgs.length+1, modo: modoDialog);
    if(msg != null) {
      _initProcesarImgs();
      msg.campo = currentCampo;
      addMsgs(msg);
    }
  }

  ///
  void _changeCampoToCosto() async {

    currentCampo = Campos.rCosto;
    final msg = await GetAnet.msg(ChatKey.putCosto, id: msgs.length+1, modo: modoDialog);
    if(msg != null) {
      msg.campo = currentCampo;
      addMsgs(msg);
    }
    changeKeyboard = 'num';
  }

  ///
  void _changeCampoToCheckData() async {

    currentCampo = Campos.isCheckData;
    var msg = await GetAnet.msg(
      ChatKey.checkData, id: msgs.length+1, modo: modoDialog,
      params: [campos[Campos.rDeta], campos[Campos.rCosto]]
    );
    if(msg != null) {
      msg.campo = currentCampo;
      addMsgs(msg);
    }
    changeKeyboard = 'txt';
  }

  ///
  void responseInteractive(BuildContext context, Map<String, dynamic> res, ChatKey key) async {
    
    switch (key) {
      case ChatKey.estasListo:
        if(res['res']) {

          ChatEntity? msg = await GetAnet.msg(ChatKey.getAlertFotosLogos, id: msgs.length+1, modo: modoDialog);
          if(msg != null) {
            showMsgEstasListo = false;
            currentCampo = Campos.rFotos;
            msg.campo = currentCampo;
            _msgs.clear();
            addMsgs(msg);
            msg = await GetAnet.msg(msgs.last.key, id: msgs.length+1, modo: modoDialog);
            if(msg != null) {
              msg.campo = currentCampo;
              addMsgs(msg);
            }
          }
        }else{
          clean();
          if(res.containsKey('backUri')) {
            context.go(res['backUri']);
          }else{

            String goBack = '/home';
            if(_globals.histUri.isNotEmpty) {
              goBack = _globals.getBack();
            }
            context.go(goBack);
          }
        }
        break;
      case ChatKey.errAwaitFotos:

        if(res['res']) {
          
          campos[Campos.isValidFotos] = true;
          changeCampoToDetalles();
        }
        break;
      default:
    }
  }

  /// Validamos la info dada por el usuario
  /// Retornamos NULL en caso de que no exista errores.
  Future<ChatEntity?> _isValidData(ChatEntity msg) async {

    ChatEntity? resp = ChatEntity(
      campo: currentCampo,
      from: ChatFrom.anet, id: msgs.length+1, key: ChatKey.rFotos, value: ''
    );
    switch (currentCampo) {
      case Campos.rFotos:
        if(campos[Campos.rFotos].isEmpty) {
          resp.tipo = ChatTip.dialog;
          resp.key = ChatKey.rFotos;
          resp.value = 'Lo sentimos al menos debes agregar una fotografía.';
        }
        break;
      case Campos.rDeta:
        String deta = campos[Campos.rDeta];
        if(deta.isEmpty) {
          resp.tipo = ChatTip.dialog;
          resp.key = ChatKey.rFotos;
          resp.value = 'Los detalles u observaciones deben incluirce en tu cotización.';
        }
        if(deta.length < 5) {
          resp.tipo = ChatTip.dialog;
          resp.key = ChatKey.rFotos;
          resp.value = 'Por favor se un poco más específico en tus detalles u observaciones.';
        }
          
        if(resp.value.isEmpty) {
          campos[Campos.isValidDeta] = true;
        }
        break;
      case Campos.rCosto:
        double? costo = double.tryParse(campos[Campos.rCosto]);
        if(costo != null) {

          if(costo <= 0) {
            resp.tipo = ChatTip.dialog;
            resp.key = ChatKey.rCosto;
            resp.value = 'Incrementa tu costo por favor.';
          }

        }else{
          resp.tipo = ChatTip.dialog;
          resp.key = ChatKey.rCosto;
          resp.value = 'El costo no es valido, intenta nuevamente por favor.';
        }

        if(resp.value.isEmpty) {
          campos[Campos.isValidCosto] = true;
        }
        break;
      default:
        resp.tipo = ChatTip.msg;
        resp.key = ChatKey.know;
        resp.value = 'UPSS!!, repite tu mensaje, ocurrio un error inesperado.';
    }
    return (resp.value.isEmpty) ? null : resp;
  }

  ///
  Future<void> showResumen() async {

    List<ChatEntity> msgTmp = List<ChatEntity>.from(msgs);
    List<ChatEntity> msgUser = [];
    _msgs.clear();
    for(var m=0; m<msgTmp.length; m++) {
      if(msgTmp[m].key == ChatKey.userRes) {
        msgUser.add(msgTmp[m]);
      }
    }
    msgs = msgUser;
  }

  ///
  void showAlertFotos() async {

    msgCampos = 'Autoparnet te informa...';
    
    onCheckFotos = false;
    ChatEntity? msg = await GetAnet.msg(ChatKey.getAwaitFotos, id: msgs.length+1, modo: modoDialog);
    if(msg != null) {
      imgTmps = campos[Campos.rFotos].length;
      msg.campo = currentCampo;
      addMsgs(msg);
    }
  }

  bool isFinishProcessImage = false;
  // Los datos que se guardaran como inventario en la app
  List<Map<String, dynamic>> dataSaveImg = [];
  // Las imagenes que ya fueron procesadas y enviadas
  List<String> _imgsListas = [];
  String _imgProcessCurrent = '';

  ///
  void _initProcesarImgs() {

    try {
      cronImgProcess.schedule(Schedule.parse('*/2 * * * * *'), () => _taskImages());
    } catch (e) {
      _imgProcessCurrent = '';
      if(e.toString().contains('Closed')) {
        cronImgProcess = Cron();
        _initProcesarImgs();
      }
    }
  }

  ///
  void _taskImages() {

    bool isFinish = true;
    if(_imgProcessCurrent.isEmpty) {

      final lst = List<String>.from(campos[Campos.rFotos]);
      for (var i = 0; i < lst.length; i++) {

        if(!_imgsListas.contains(lst[i])) {
          _imgProcessCurrent = lst[i];
          isFinish = false;
          _procesarImagen();
          break;
        }
      }
    }else{
      isFinish = false;
    }

    if(isFinish) {
      isFinishProcessImage = true;
      cronImgProcess.close();
    }
  }

  ///
  Future<void> _procesarImagen() async {
    
    // Obtenemos la data inicial de la imagen original
    Map<String, dynamic> result = await MyIm.getDataInitImage(XFile(_imgProcessCurrent));

    result = await MyIm.comprimirImage(result, minWidth: 1024, minHeight: 720);

    final nameF = MyIm.buildNewNameFile(result['fotoName']);

    var response = await _ordEm.uploadImgOfRespuesta(
      {'filename': '${_globals.idOrdenCurrent}-$nameF', 'data':result['data']}
    );

    if(response['body'] == 'ok') {

      result = await MyIm.comprimirImage(result, minWidth: Constantes.minSize, minHeight: Constantes.minSize);

      final pathSave = await MyIm.saveImageInApp(nameF, result['data']);
      if(pathSave.isNotEmpty) {

        // Guardamos en DRIVE.
        Map<String, dynamic> save = {
          'path': pathSave, 'kb': result['kb'],
          'name': nameF, 'absolute': _imgProcessCurrent
        };

        dataSaveImg.add(save);
        _imgsListas.add(_imgProcessCurrent);
      }
    }
    _imgProcessCurrent = '';
  }

  ///
  Map<String, dynamic> getData() {
    
    for (var i = 0; i < dataSaveImg.length; i++) {
      dataSaveImg[i].remove('absolute');
    }
    return {
      'deta': campos[Campos.rDeta],
      'costo': campos[Campos.rCosto],
      'fotos': []
    };
  }


}