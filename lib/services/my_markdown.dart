import 'package:cotizo/services/utils_services.dart';
import 'package:flutter/material.dart';

import '../config/sngs_manager.dart';
import '../vars/globals.dart';
import '../vars/constantes.dart';

class MyMarkDown {

  final Globals _globals = getIt<Globals>();

  String txtInit = '';
  List<TextSpan> perParts= [];

  ///
  Widget getWidgetFormater(String txt, String campo, {String from = 'anet'}) {

    bool hasCode = false;
    for(var c=0; c < Constantes.codesTxt.length; c++) {
      if(txt.contains(Constantes.codesTxt[c])) {
        // Hay una primera parte sin formato
        hasCode = true;
      }
    }

    if(!hasCode) {

      if(from == 'anet') {
        return Text(
          txt,
          textScaleFactor: 1,
          style: styleGral()
        );
      }

      final prefix = _getPrefixResp(campo);
      
      final sum = txt.length + prefix.length;
      if(campo == 'rCosto') {
        txt = UtilServices.toFormat(txt);
      }
      if(sum > 25) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              txt,
              textScaleFactor: 1,
              style: styleGral()
            ),
            _prefix(txt, prefix, withMsg: false)
          ],
        );
      }else{
        return _prefix(txt, prefix);
      }
    }

    perParts= [];
    _dividirEn(txt);

    return Text.rich(
      TextSpan(
        text: txtInit,
        children: perParts,
      ),
      textScaleFactor: 1,
      style: styleGral()
    );
  }

  ///
  Widget _prefix(String txt, String prefix, {bool withMsg = true}) {

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        if(withMsg)
          ...[
            Text(
              txt,
              textScaleFactor: 1,
              style: styleGral()
            ),
            const SizedBox(width: 5),
          ],
        Text(
          '[$prefix]',
          textScaleFactor: 1,
          style: styleGral(isMini: true)
        ),
        const SizedBox(width: 5),
        const Icon(Icons.done, size: 17, color: Colors.blue)
      ],
    );
  }

  ///
  String _getPrefixResp(String campo) {

    final hoy  = DateTime.now();
    final hora = '${hoy.hour}';
    final min  = '${hoy.minute}';
    if(campo == 'rDeta') {
      campo = 'Detalles';
    }
    if(campo == 'rCosto') {
      campo = 'Costo';
    }
    return ' $campo ${hora.padLeft(2, '0')}:${min.padLeft(2, '0')} ';
  }

  ///
  void _dividirEn(String txt) {

    txtInit = '';
    // txt = '   12548754 Recuerda... *EL ÉXITO de tu venta* [radica] _en la calidad_ y costo '
    // 'de tus AUTOPARTES, que tengas -muchas ventas- el día de hoy.\n\n';

    txt = txt.trimLeft();
    bool hasCodeInit = false;
    for(var c=0; c < Constantes.codesTxt.length; c++) {
      if(txt.startsWith(Constantes.codesTxt[c])) {
        // Hay una primera parte sin formato
        hasCodeInit = true;
      }
    }
    if(!hasCodeInit) {
      txt = _getTxtSinFormatoInicial(txt);
    }

    for(var c=0; c < Constantes.codesTxt.length; c++) { 
      txt = _escarbarString(txt);
    }

    if(txt.isNotEmpty) {
      perParts.add(TextSpan(text: txt));
    }
 
  }

  ///
  String _escarbarString(String txt) {

    txt = txt.trimLeft();
    bool hasCodeInit = false;
    for(var c=0; c < Constantes.codesTxt.length; c++) {
      if(txt.startsWith(Constantes.codesTxt[c])) {
        // Hay una primera parte sin formato
        hasCodeInit = true;
      }
    }
    if(!hasCodeInit) {
      txt = _getTxtSinFormatoBetween(txt);
    }

    for(var c=0; c < txt.length; c++) {
      if(Constantes.codesTxt.contains(txt[c])) {

        //hay un codigo
        if(txt[c] == '*') {
          // Extraemos negrita
          txt = _extrarNegritas(txt);
          break;
        }
        if(txt[c] == '_') {
          // Extraemos enfasis ligth
          txt = _enfasisLigth(txt);
          break;
        }
        if(txt[c] == '-') {
          // Extraemos enfasis strong
          txt = _enfasisStrong(txt);
          break;
        }
        if(txt[c] == '+') {
          // Extraemos enfasis super strong
          txt = _enfasisSuperStrong(txt);
          break;
        }
      }
    }

    return txt;
  }

  ///
  String _getTxtSinFormatoInicial(String src) {

    String txt = '';
    for(var c=0; c < src.length; c++) {
      if(!Constantes.codesTxt.contains(src[c])) {
        txt+=src[c];
      }else{
        break;
      }
    }
    if(txt.isNotEmpty) {
      // Iniciamos con un texto sin formato
      txtInit = txt;
      src = src.replaceFirst(txt, '');
    }

    return src;
  }

  ///
  String _getTxtSinFormatoBetween(String src) {

    String txt = '';
    for(var c=0; c < src.length; c++) {
      if(!Constantes.codesTxt.contains(src[c])) {
        txt+=src[c];
      }else{
        break;
      }
    }
    if(txt.isNotEmpty) {
      // Iniciamos con un texto sin formato
      perParts.add(
        TextSpan(text: txt)
      );
      src = src.replaceFirst(txt, '');
    }

    return src;
  }

  ///
  String _extrarNegritas(String src) {

    String code = '*';
    return _extraerCode(src, code, styleBold());
  }

  ///
  String _enfasisLigth(String src) {

    String code = '_';
    return _extraerCode(src, code, styleEnfasisLigth());
  }

  ///
  String _enfasisStrong(String src) {

    String code = '-';
    return _extraerCode(src, code, styleEnfasisStrong());
  }

  ///
  String _enfasisSuperStrong(String src) {

    String code = '+';
    return _extraerCode(src, code, styleBoldEnfatizado());
  }

  /// 
  String _extraerCode(String src, String code, TextStyle estyle) {

    String txt = '';
    if(src.startsWith(code)) {
      src = src.replaceFirst(code, '');
    }

    for(var c=0; c < src.length; c++) {
      if(src[c] != code) {
        txt+=src[c];
      }else{
        break;
      }
    }

    int cant = (src.length > txt.length) ? ( txt.length+1) :  txt.length;
    String delTxt = src.substring(0, cant);
    
    src = src.replaceFirst(delTxt, '');
    if(src.startsWith(code)) {
      src = src.replaceFirst(code, '');
    }

    if(txt.length > 1) {
      if(src.startsWith(' ')) {
        src = src.trimLeft();
        txt = '$txt ';
      }
      perParts.add(
        TextSpan( text: txt, style: estyle )
      );
    }

    return src;
  }

  ///
  TextStyle styleGral({bool isMini = false}) {

    return TextStyle(
      fontSize: (isMini) ? Constantes.fontSizeMin : Constantes.fontSize,
      height: Constantes.heightTxt,
      color: (isMini) ? Colors.white.withOpacity(0.4) : _globals.txtOnsecMainLigth
    );
  }

  ///
  TextStyle styleBold() {

    return const TextStyle(
      fontWeight: FontWeight.bold
    );
  }

  ///
  TextStyle styleEnfasisLigth() {

    return TextStyle(
      fontSize: Constantes.fontSize,
      height: Constantes.heightTxt,
      color: _globals.txtOnsecMainSuperLigth
    );
  }

  ///
  TextStyle styleEnfasisStrong() {

    return TextStyle(
      fontSize: Constantes.fontSize,
      height: Constantes.heightTxt,
      color: _globals.colorGreen
    );
  }

  ///
  TextStyle styleBoldEnfatizado() {

    return TextStyle(
      fontSize: 19,
      fontWeight: FontWeight.bold,
      height: 1.2,
      color: _globals.txtOnsecMainSuperLigth
    );
  }
}