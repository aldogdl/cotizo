import 'package:camera/camera.dart' show CameraDescription;
import 'package:flutter/material.dart' show Color;

class Globals {

  String version = '1.3.3';
  
  int idOrdenCurrent = 0;
  String idsFromLinkCurrent = '';
  String idCampaingCurrent = '';
  bool isFromWhatsapp = false;
  List<String> histUri = [];
  void setHistUri(String uri) {
    if(!histUri.contains(uri)) {
      histUri.add(uri);
    }
  }
  String getBack() {

    String uri = '';
    if(histUri.length > 2) {
      histUri.removeLast();
      uri = histUri.removeLast();
    }else{
      uri = histUri.first;
      histUri = [];
    }
    return uri;
  }

  /// Usado para tener en memoria las piezas que ya respondieron, es decir...
  /// toda pieza que este en el inventario ya fue respondida.
  /// key = id de la orden | value = lista de ids de las piezas.
  Map<int, List<int>> invFilter = {};

  Color bgMain = const Color.fromARGB(255, 13, 21, 26);
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