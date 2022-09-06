import 'package:get_it/get_it.dart';

import '../api/push_msg.dart';
import '../vars/globals.dart';

final getIt = GetIt.instance;

void sngManager() {

  getIt.registerSingleton<Globals>(Globals());
  getIt.registerSingleton<PushMsg>(PushMsg());
}