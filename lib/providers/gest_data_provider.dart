import 'dart:io' show File;

import 'package:camera/camera.dart' show XFile;
import 'package:flutter/material.dart' show BuildContext, ChangeNotifier, Navigator;
import 'package:cron/cron.dart';

import '../entity/chat_entity.dart';
import '../repository/ordenes_repository.dart';
import '../services/my_image/my_im.dart';
import '../vars/constantes.dart';
import '../vars/enums.dart';
import '../widgets/mensajes/get_anet_msg.dart';

class GestDataProvider with ChangeNotifier {

  Cron cronImgProcess = Cron();
  final int espera = 3;
  final _ordEm = OrdenesRepository();

  ///
  void clean() {
    _msgs = [];
    _imgsListas = [];
    _imgProcessCurrent = '';
    _currentCampo = Campos.none;
    _ftsGestDel = [];
    _changeKeyboard = 'txt';
    onCheckFotos = false;
    reviciones = 0;
    imgTmps = 0;
    dataSaveImg= [];
    isAccEdit = false;
    ftsGest = [];
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
  /// Ei ID de la orden que se esta cotizando
  int idOrdenCurrentCot = 0;
  /// Es usada para saber si el usuario cotizó, cuando cancela la cotizacion
  /// y sale de la seccion se va al estanque, pero no se hace nada, solo si
  /// cotizo se muestra carnada
  bool isMakeCot = false;

  /// Cambiamos el modo de cotizar.
  int _modoCot = 1;
  int get modoCot => _modoCot;
  set modoCot(int tipo) {
    _modoCot = tipo;
    notifyListeners();
  }

  /// Cambiamos el teclado segun el requerimiento del campo en curso.
  String _changeKeyboard = 'txt';
  String get changeKeyboard => _changeKeyboard;
  set changeKeyboard(String tipo) {
    _changeKeyboard = tipo;
    notifyListeners();
  }

  /// mostrar la primer pagina de Estas Listo!!
  bool showMsgEstasListo = true;
  /// Utilizado para encender el check de las fotos
  int reviciones = 0;

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

  /// Usado para rectificar que las fotos esten completas cunado son agregadas
  /// de una sola vez todas.
  int imgTmps = 0;

  /// Saber cuando se esta editado un campo.
  bool isAccEdit = false;

  bool onCheckFotos = false;
  /// Usado para saber si mostramos el mensaje encima de la camara de agrega fotos
  bool showAlertAddFotos = true;
  /// Usado para saber si la camara se inicia automáticamente modo PILOTO
  bool initCamAuto = false;
  /// Utilizado en el btn de take foto para absorver los click cuando la foto
  /// se esta tomando y evitar que clicken mas en el proceso de la toma.
  bool _isTakeFoto = false;
  bool get isTakeFoto => _isTakeFoto;
  set isTakeFoto(bool mc) {
    _isTakeFoto = mc;
    notifyListeners();
  }
  /// Lista de fotos usadas para gestionar las imagenes en el widget camara.
  bool _ftsGestRefresh = false;
  bool get ftsGestRefresh => _ftsGestRefresh;
  set ftsGestRefresh(bool mc) {
    _ftsGestRefresh = mc;
    notifyListeners();
  }
  /// Lista de fotos usadas para gestionar las imagenes en el widget camara.
  List<XFile> ftsGest = [];
  /// Adicionamos una foto desde la camara
  void addNewFoto(XFile foto) {
    var tmp = List<XFile>.from(ftsGest).toList();
    ftsGest.clear();
    tmp.insert(0, foto);
    ftsGest = List<XFile>.from(tmp);
    tmp.clear();
    ftsGestRefresh = !ftsGestRefresh;
  }
  /// Usado para saber que foto se ha seleccionado para ser borrada.
  List<int> _ftsGestDel = [];
  List<int> get ftsGestDel => _ftsGestDel;
  set ftsGestDel(List<int> mc) {
    _ftsGestDel = mc;
    notifyListeners();
  }
  /// Agregamos el path de la foto que se requiere eliminar
  void addFtoToDelete(String ftPat, bool isAdd) {

    var tmp = List<int>.from(_ftsGestDel);
    if(tmp.isNotEmpty) {
      if(tmp.first == -1) {
        tmp.clear();
      }
    }
    _ftsGestDel.clear();
    if(ftsGest.isNotEmpty) {
      final ind = ftsGest.indexWhere((element) => element.path == ftPat);
      if(ind != -1) {
        if(isAdd) {
          tmp.add(ind);
        }else{
          tmp.remove(ind);
        }
      }
      ftsGestDel = (tmp.isEmpty) ? [-1] : List<int>.from(tmp);
    }
    tmp.clear();
  }
  /// Borramos desde la camara todas las imagenes que han sido eliminadas
  Future<void> deleteFotosSelected({bool cleaned = false}) async {

    // Primero borramos visualmente para el usuario.
    var files = List<XFile?>.from(ftsGest).toList();

    // Borramos los paths existentes en el campo fotos.
    List<String> currents = [];
    if(campos.containsKey(Campos.rFotos)) {
      currents = List<String>.from(campos[Campos.rFotos]);
    }

    ftsGest.clear();
    List<XFile> inCache = [];
    List<int> filesD = [];
    if(cleaned) {
      for (var i = 0; i < files.length; i++) {
        filesD.add(i);
      }
    }else{
      filesD = List<int>.from(_ftsGestDel).toList();
      filesD.sort(); 
    }

    for (var i = 0; i < filesD.length; i++) {
      try {
        inCache.add(files[filesD[i]]!);
      } catch (_) {}
      try {

        files[filesD[i]] = null;
      } catch (_) {}
    }
    
    files = files.where((element) => element != null).toList();
    if(files.isNotEmpty) {
      ftsGest = List<XFile>.from(files).toList();
    }else{
      ftsGest = [];
    }

    ftsGestRefresh = !ftsGestRefresh;
    // Ahora limpiamos la lista de fotos para borrar
    ftsGestDel = [];

    // Ahora borramos de cache las imagenes.
    for (var i = 0; i < inCache.length; i++) {
      File fo = File(inCache[i].path);
      if(fo.existsSync()) {
        fo.deleteSync();
        currents.removeWhere((element) => element == inCache[i].path);
      }
    }
    if(campos.containsKey(Campos.rFotos)) {
      campos[Campos.rFotos] = List<String>.from(currents);
    }
  }

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

  String _callFrom = '';
  String get callFrom => _callFrom;
  set callFrom(String callF) {
    _callFrom = callF;
    notifyListeners();
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

          // Es correcto tomar el siguiente campo,
          reviciones = 0;
          if(currentCampo == Campos.rFotos) {

            imgTmps++;
            if(campos[Campos.rFotos].length < Constantes.cantFotos) {
              if(imgTmps == campos[Campos.rFotos].length) {

                final hasErr = _msgs.indexWhere(
                  (chat) => chat.from == ChatFrom.anet && chat.campo == ChatKey.rFotos
                );

                if(hasErr != -1) {
                  _msgs.removeAt(hasErr);
                }
                showAlertFotos();
              }
            }
          }

          if(currentCampo == Campos.rFotos && campos[Campos.isValidFotos]) {
            if(isAccEdit) {
              _changeCampoToCheckData();
            }else{
              _changeCampoToCosto();
            }
          }

          if(currentCampo == Campos.rCosto && campos[Campos.isValidCosto]) {
            if(isAccEdit) {
              _changeCampoToCheckData();
            }else{
              changeCampoToDetalles();
            }
          }

          if(currentCampo == Campos.rDeta && campos[Campos.isValidDeta]) {
            _changeCampoToCheckData();
          }
        }
      }

      final msgsTmp = List<ChatEntity>.from(_msgs).toList();
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

    _msgs.removeWhere((element) => element.from == ChatFrom.anet);
    int msgEditIndex = _msgs.indexWhere((m) => m.campo == msg.campo);
    if(msgEditIndex != -1) {

      isAccEdit = true;
      _msgs.removeAt(msgEditIndex);

      if(msg.campo == Campos.rFotos) {
        
        Map<String, dynamic> removeFoto = {};
        if(campos[Campos.rFotos].isNotEmpty) {

          imgTmps = campos[Campos.rFotos].length;
          for(var f=0; f < campos[Campos.rFotos].length; f++) {

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

          if(campos[Campos.rFotos].length < Constantes.cantFotos) {
            campos[Campos.isValidFotos] = false;
            if(!onCheckFotos) {
              showAlertFotos();
            }
          }
        }
      }

      for (var i = 0; i < _msgs.length; i++) {
        _msgs[i].id = i+1;
      }
      msgs = List<ChatEntity>.from(_msgs);
      
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

  /// HAcemos la ultima revision de los datos antes de enviar la cotizacion.
  Future<bool> isValidData() async {

    campos[Campos.isValidFotos] = false;
    _checkValidezCantFotos(isOnlyCheck: true);
    if(!campos[Campos.isValidFotos]) {
      currentCampo = Campos.rFotos;
      showAlertFotos();
      return false;
    }

    return true;
  }

  ///
  void _changeCampoToCosto() async {

    imgTmps = 0;
    currentCampo = Campos.rCosto;
    final msg = await GetAnet.msg(ChatKey.putCosto, id: msgs.length+1, modo: modoCot);
    if(msg != null) {
      msg.campo = currentCampo;
      addMsgs(msg);
      changeKeyboard = 'num';
      _initProcesarImgs();
    }
  }

  ///
  void changeCampoToDetalles() async {

    currentCampo = Campos.rDeta;
    final msg = await GetAnet.msg(ChatKey.putDeta, id: msgs.length+1, modo: modoCot);
    if(msg != null) {
      msg.campo = currentCampo;
      addMsgs(msg);
    }
    changeKeyboard = 'txt';
  }

  ///
  void _changeCampoToCheckData() async {

    currentCampo = Campos.isCheckData;
    var msg = await GetAnet.msg(
      ChatKey.checkData, id: msgs.length+1, modo: modoCot,
      params: [campos[Campos.rDeta], campos[Campos.rCosto]]
    );
    isAccEdit = false;
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

          ChatEntity? msg = await GetAnet.msg(ChatKey.getAlertFotosLogos, id: msgs.length+1, modo: modoCot);
          if(msg != null) {
            showMsgEstasListo = false;
            currentCampo = Campos.rFotos;
            msg.campo = currentCampo;
            _msgs.clear();
            addMsgs(msg);
            msg = await GetAnet.msg(msgs.last.key, id: msgs.length+1, modo: modoCot);
            if(msg != null) {
              msg.campo = currentCampo;
              addMsgs(msg);
            }
          }
        }else{
          clean();
          Navigator.of(context).pop();
        }
        break;
      case ChatKey.errAwaitFotos:

        if(res['res']) {

          campos[Campos.isValidFotos] = false;
          _checkValidezCantFotos(isOnlyCheck: true);
          if(!campos[Campos.isValidFotos]) {
            currentCampo = Campos.rFotos;
            showAlertFotos();
            return;
          }
          _changeCampoToCosto();
        }
        break;
      default:
    }
  }

  /// Validamos la info dada por el usuario
  /// Retornamos NULL en caso exito.
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
  void _checkValidezCantFotos({bool isOnlyCheck = false}) {

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
      if(!isOnlyCheck) {
        _changeCampoToCosto();
      }
    }
    if(isOnlyCheck) {
      if(imgTmps > 0) {
        campos[Campos.isValidFotos] = true;
      }
    }
  }

  /// Cada ves que abrimos la galeria o la camara eliminamos del chat todos los
  /// mensajes previos de alertas y errores acerca de las fotos, con la finalidad
  /// de agrupar todas las imagenes una a otra.
  Future<void> cleanMsgsAnetInFotos() async {
    
    // Borramos del chat todos los mensajes que sean las fotos que ya se
    // tomaron para mostrarlas en el carrucel, y a su ves, borramos todos
    // los mensajes de error.
    final msgsTmp = List<ChatEntity>.from(msgs).toList();
    for (var i = 0; i < msgs.length; i++) {
      msgsTmp.removeWhere((chat){
        return msgs[i].from == ChatFrom.anet && msgs[i].campo == Campos.rFotos;
      });
    }

    if(campos.containsKey(Campos.rFotos)) {
      final lstPaths = List<String>.from(campos[Campos.rFotos]);
      // Proceguimos con las imagenes...
      if(lstPaths.isNotEmpty) {
        for (var i = 0; i < lstPaths.length; i++) {
          msgsTmp.removeWhere((chat) => chat.value == lstPaths[i]);
        }
      }
    }

    msgs = List<ChatEntity>.from(msgsTmp).toList();
    msgsTmp.clear();
  }

  ///
  void showAlertFotos() async {

    msgCampos = 'AutoparNet te informa...';
    
    onCheckFotos = false;
    ChatEntity? msg = await GetAnet.msg(ChatKey.getAwaitFotos, id: msgs.length+1, modo: modoCot);
    if(msg != null) {
      imgTmps = campos[Campos.rFotos].length;
      msg.campo = currentCampo;
      addMsgs(msg);
    }
  }


  // ------------------------- FOTOS ----------------------------------

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
      {'filename': '$idOrdenCurrentCot-$nameF', 'data':result['data']}
    );

    if(response['body'] == 'ok') {

      result = await MyIm.comprimirImage(result, minWidth: Constantes.minSize, minHeight: Constantes.minSize);

      final pathSave = await MyIm.saveImageInApp(nameF, result['data']);
      if(pathSave.isNotEmpty) {

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