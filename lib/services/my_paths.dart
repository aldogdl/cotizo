class MyPath {

  static const env = 'prod';
  static const baseProd = 'autoparnet.com';
  static const baseDev  = '192.168.1.72';

  ///
  static String getUriFotoPieza(String foto, {bool isThubm = false}) {

    String base = 'to_orden_tmp/$foto';
    if(isThubm) {
      base = 'to_orden_tmp/p_$foto';
    }
    if(env != 'dev') {
      return Uri.https(baseProd, base).toString();
    }
    base = 'autoparnet/public_html/$base';
    return Uri.http(baseDev, base).toString();
  }

  ///
  static Uri getUri(String uri, String params, {Map<String, dynamic>? querys}) {

    String url = _getPathUri(uri, params);
    if(!url.endsWith('/')) {
      if(!url.contains('secure')) {
        url = '$url/';
      }
    }
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
      'login_check_admin' : 'secure-api-check',
      'api_is_token_caducado' : 'is-token-caducado',
      'get_orden_and_pieza': 'get-orden-and-pieza',
      'get_ordenes_and_piezas': 'get-ordenes-and-piezas',
      'get_piezas_apartadas': 'get-piezas-apartadas',
      'fetch_carnada': 'fetch-carnada',
      'upload_img_rsp': 'upload-img',
      'set_resp': 'set-resp',
      'set_reg_of': 'set-reg-of',
      'get_all_my_ntg': 'get-all-my-ntg',
      'get_user_by_campo': 'get-user-by-campo',
      'set_token_messaging_by_id_user': 'set-token-messaging-by-id-user',
    };

    if(uri.startsWith('login_')) {
      if(env == 'dev') {
        subBase = subBase.replaceFirst('/cotizo/', '/');
        return '$subBase${map[uri]!}';
      }
      return map[uri]!;
    }

    return '$subBase${map[uri]}${(params.isNotEmpty) ? params : ""}';
  }
}