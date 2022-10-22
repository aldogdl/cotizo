class MyPath {

  static const env = 'dev';
  static const baseProd = 'autoparnet.com';
  static const baseDev  = '192.168.1.72';

  ///
  static String getUriFotoPieza(String foto) {

    final base = 'to_orden_tmp/$foto';
    return Uri.https(baseProd, base).toString();
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
      'fetch_next_ordto_cot': 'fetch-next-ordto-cot',
      'upload_img_rsp': 'upload-img',
      'set_resp': 'set-resp',
      'set_no_tengo': 'set-no-tengo',
      'get_all_ntg_filtros': 'get-all-ntg-filtros',
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