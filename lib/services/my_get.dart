import 'package:flutter/material.dart' show BuildContext, Size;
import 'package:provider/provider.dart';

import '../config/sngs_manager.dart';
import '../providers/gest_data_provider.dart';
import '../providers/signin_provider.dart';
import '../vars/globals.dart';

class Mget{
  
  static bool isInit = false;
  static BuildContext? ctx;
  static GestDataProvider? prov;
  static final Globals globals = getIt<Globals>();
  static Size size = const Size(0,0);
  static SignInProvider? auth;

  static init(BuildContext context, GestDataProvider? provi) {
    isInit = true;
    ctx = context;
    auth = context.read<SignInProvider>();
    if(provi != null) {
      prov = provi;
    }
  }
}