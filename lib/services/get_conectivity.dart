import 'package:connectivity_plus/connectivity_plus.dart';

class GetConectivity {

  ///
  static Future<String> device() async {

    var res = await (Connectivity().checkConnectivity());

    if (res == ConnectivityResult.mobile) {
      return ConnectivityResult.mobile.name;
    } else if (res == ConnectivityResult.wifi) {
      return ConnectivityResult.wifi.name;
    }
    return '';
  }
}