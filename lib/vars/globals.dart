import 'package:camera/camera.dart' show CameraDescription;
import 'package:flutter/material.dart' show Color;

class Globals {

  String version = '2.0.0';
  int idUser = 0;

  /// Usado para generar un push In, generado desde el estanque
  Map<String, dynamic> pushIn = {};
  
  /// Rutas que no deben guardarce en historial
  final noSave = ['/login', '/gest-data/', '/cotizo/'];
  ///
  List<String> histUri = [];
  void setHistUri(String uri) {

    bool save = true;
    noSave.map((e) {
      if(uri.contains(e)) {
        save = false;
      }
    }).toList();

    if(save) {
      if(histUri.contains(uri)){  histUri.remove(uri); }
      histUri.add(uri);
      _putHome();
    }
  }

  ///
  String getBack() {

    String uri = '';
    if(histUri.length > 2) {
      histUri.removeLast();
      if(histUri.isNotEmpty) {
        uri = histUri.removeLast();
      }
    }else{
      uri = histUri.first;
      histUri = [];
    }
    _putHome();
    return (uri.isEmpty) ? histUri.first : uri;
  }

  ///
  void _putHome() {
    final inx = histUri.indexWhere((e) => e.contains('/home'));
    if(inx != -1) {
      if(inx > 0) {
        histUri.removeAt(inx);
        histUri.insert(0, '/home');
      }
    }else{
      histUri.insert(0, '/home');
    }
  }

  /// Usado para tener en memoria las piezas que ya respondieron, es decir...
  /// toda pieza que este en el inventario ya fue respondida.
  /// key = id de la orden | value = lista de ids de las piezas.
  Map<int, List<int>> invFilter = {};

  Color bgMain = const Color.fromARGB(255, 13, 21, 26);
  Color bgAppBar = const Color.fromARGB(255, 25, 34, 39);
  Color secMain = const Color(0xFF202c33);
  Color txtOnsecMainDark = const Color(0xFF83929c);
  Color txtAlerts = const Color(0xFFf5d278);
  Color txtOrage = const Color.fromARGB(255, 235, 174, 21);
  Color txtComent = const Color.fromARGB(255, 204, 204, 204);
  Color txtFrmReq = const Color.fromARGB(255, 7, 226, 142);
  Color txtOnsecMainLigth = const Color.fromARGB(255, 170, 192, 206);
  Color txtOnsecMainSuperLigth = const Color.fromARGB(255, 246, 247, 248);
  Color colorBurbbleResp = const Color.fromARGB(255, 42, 93, 75);
  Color colorGreen = const Color.fromARGB(255, 81, 169, 133);
  
  CameraDescription? firstCamera;

}