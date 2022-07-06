import 'dart:convert';

import 'package:cotizo/vars/my_paths.dart';
import 'package:http/http.dart' as http;

class MyHttp {

  ///
  Map<String, dynamic> _result = {'abort':false, 'msg':'ok', 'body':[]};

  ///
  void cleanResult() {
    _result = {'abort':false, 'msg':'ok', 'body':[]};
  }

  ///
  Future<Map<String, dynamic>> get(String uri, {String params = '/'}) async {

    http.Response resp = await http.get(MyPath.getUri(uri, params));
    if(resp.statusCode == 200) {
      return Map<String, dynamic>.from(json.decode(resp.body));
    }else{
      await _analizarError(resp);
    }
    return _result;
  }

  ///
  Future<void> post(Uri url, {Map<String, dynamic> data = const {}}) async {}

  ///
  Future<void> _analizarError(http.Response resp) async {

    print(resp.statusCode);
    print(resp.reasonPhrase);
    _result = {'abort':true, 'msg':resp.statusCode, 'body': resp.reasonPhrase};
  }

}