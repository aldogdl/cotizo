class MyPath {

  static const env = 'dev';
  static const baseProd = 'autoparnet.com';
  static const baseDev  = '192.168.1.74';

  ///
  static String getUriFotoPieza(String foto) {

    final base = 'to_orden_tmp/$foto';
    return Uri.https(baseProd, base).toString();
  }

  ///
  static String getUriLogoMrk(String marca) {

    final base = 'mrks_logos/$marca';
    if(env == 'dev') {
      print(Uri.http(baseDev, 'autoparnet/public_html/$base').toString());
      return Uri.http(baseDev, 'autoparnet/public_html/$base').toString();
    }
    return Uri.https(baseProd, base).toString();
  }

  ///
  static Uri getUri(String uri, String params, {Map<String, dynamic> querys = const {}}) {

    String url = _getPathUri(uri, params);
    if(env == 'dev') {
      print(Uri.http(baseDev, url, querys).path);
      return Uri.http(baseDev, url, querys);
    }
    return Uri.https(baseProd, url, querys);
  }

  ///
  static String _getPathUri(String uri, String params) {

    String subBase = '/api/cotizo/';
    if(env == 'dev') {
      subBase = '/autoparnet/public_html$subBase';
    }
    if(!uri.startsWith('api')) {
      subBase = subBase.replaceFirst('/api/', '/');
    }
    final map = <String, String>{
      'get_ordenes_and_piezas': 'get-ordenes-and-piezas'
    };
    return '$subBase${map[uri]}$params';
  }
}