class MyPath {

  static const env = 'prod';
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
      return Uri.http(baseDev, 'autoparnet/public_html/$base').toString();
    }
    return Uri.https(baseProd, base).toString();
  }

  ///
  static Uri getUri(String uri, String params, {Map<String, dynamic>? querys}) {

    String url = _getPathUri(uri, params);
    if(env == 'dev') {
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
      'get_orden_and_pieza': 'get-orden-and-pieza',
      'get_ordenes_and_piezas': 'get-ordenes-and-piezas',
      'upload_img_rsp': 'upload-img',
      'set_resp': 'set-resp',
      'set_no_tengo': 'set-no-tengo',
      'get_all_ntg_filtros': 'get-all-ntg-filtros',
      'get_user_by_campo': 'get-user-by-campo',
      'set_token_messaging_by_id_user': 'set-token-messaging-by-id-user',
    };

    return '$subBase${map[uri]}${(params.isNotEmpty) ? params : ""}';
  }
}