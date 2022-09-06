import 'dart:convert';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../vars/my_paths.dart';

class MyHttp {

  ///
  Map<String, dynamic> result = {'abort':false, 'msg':'ok', 'body':[]};

  ///
  void cleanResult() {
    result = {'abort':false, 'msg':'ok', 'body':[]};
  }

  ///
  Future<Map<String, dynamic>> get(
    String uri, {String params = '/', Map<String, dynamic>? querys}
  ) async {

    http.Response resp = await http.get(MyPath.getUri(uri, params, querys: querys));
    if(resp.statusCode == 200) {
      result = Map<String, dynamic>.from(json.decode(resp.body));
    }else{
      await _analizaErrorFromServer(resp);
    }
    return result;
  }

  ///
  Future<void> post(Uri url, {Map<String, dynamic> data = const {}}) async {

    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };
    var req = http.MultipartRequest('POST', url);
    
    req.headers.addAll(headers);
    req.fields['data'] = json.encode(data);
    late http.Response response;
    try {
      response = await http.Response.fromStream(await req.send());
      if(response.statusCode == 200) {
        result = Map<String, dynamic>.from(json.decode(response.body));
        if(result['abort']) {
          await _analizaErrorFromServerCode200();
        }
      }else{
        await _analizaErrorFromServer(response);
      }
    } catch (e) {
      result = {'abort':true, 'msg': e.toString(), 'body':'ERROR, Sin conexión al servidor, intentalo nuevamente.'};
      return;
    }
  }

  /// 
  Future<void> upFileByData(Uri uri, {required Map<String, dynamic> metas}) async {

    cleanResult();
    assert((){
      _imprimirEnConsola(titulo: 'HTTP::upFileByData::', msg: uri.path);
      return true;
    }());

    var req = http.MultipartRequest('POST', uri);
    Map<String, String> headers = {'Accept': 'application/json'};
    if(uri.path.contains('api')) {
      headers['Authorization'] = 'Bearer ${metas['token']}';
    }

    String filename = metas['filename'];
    List<String> partes = filename.split('.');
    String ext = partes.last;
    String campo = partes.first;

    if( metas['data'].isNotEmpty ) {

      req.files.add(
        http.MultipartFile.fromBytes(
          campo,
          List<int>.from(metas['data']),
          filename: filename,
          contentType: MediaType('image', ext)
        )
      );
      req.fields['data'] = json.encode({
        'filename': filename,
        'campo'   : campo,
        'metas'   : (metas.containsKey('metas')) ? metas['metas'] : {},
      });
      req.headers.addAll(headers);
      http.Response reServer = await http.Response.fromStream(await req.send());

      if(reServer.statusCode == 200) {
        var body = json.decode(reServer.body);
        if(body.isNotEmpty) {
          try {
            result['body'] = List<Map<String, dynamic>>.from(body);
          } catch (e) {
            result = Map<String, dynamic>.from(body);
            if(body['abort']) {
              await _analizaErrorFromServerCode200();
            }
          }
        }
      }else{
        await _analizaErrorFromServer(reServer);
      }

    }else{
      result['abort']= true;
      result['msg']  = 'err';
      result['body'] = 'Sin Imagenes para enviar.';
    }
  }

  ///
  Future<void> _analizaErrorFromServer(http.Response reServer) async {

    result['msg'] = 'amor';

    if(reServer.body.toString().contains('Expired ')) {
      
      result['abort'] = true;
      result['msg'] = 'Expired';
      result['body'] = 'refreshToken';
    }else{

      if(reServer.body.toString().contains('Access Denied')){
        result['abort'] = true;
        result['msg'] = 'Acceso Denegado';
        result['body'] = 'No tienes autorización para esta sección.';
      }

      if(reServer.body.toString().contains('Invalid ')){
        result['abort'] = true;
        result['msg'] = 'Invalidas';
        result['body'] = 'Revisa tus datos, las Credenciales son invalidas.';
      }
    }

    if(result['msg'] == 'amor') {
      result['abort']= true;
      result['msg']  = 'Error';
      result['body'] = 'Error desconocido, contacta al Asesor.';
    }

    var res = {};
    if(reServer.body.contains('DOCTYPE')) {
      _imprimirEnConsola(titulo: '::ACA EN REVISANDO ERROR::', msg: reServer.body);
    }else{
      res = json.decode(reServer.body);
    }
    assert((){
      _imprimirEnConsola(titulo: '::ACA EN REVISANDO ERROR::', msg: '$res | -- | ${res['detail']}');
      return true;
    }());

  }

  ///
  Future<void> _analizaErrorFromServerCode200() async {

    _imprimirEnConsola(titulo: '::ACA EN REVISANDO ERROR CODE 200::', msg: json.encode(result));
  }

  ///
  void _imprimirEnConsola({ required String titulo, required var msg }) {
    
    debugPrint(titulo);
    debugPrint(msg);
  }
  

}