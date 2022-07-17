import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

import '../repository/acount_user_repository.dart';
import '../firebase_options.dart';

/// Funcion de alto nivel para la recepción de mensajes en background
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // print('>>>la data es: ${message.data}');

  if (message.notification != null) {
    // Msg con Notificacion
  }
  FlutterRingtonePlayer.playNotification();
}

class PushMsg {

  String? fcmToken;
  FirebaseMessaging? messaging;
  final _userEm = AcountUserRepository();

  /// Inicializamos el servicio de Messanging
  Future<void> init() async {

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    messaging = FirebaseMessaging.instance;
    if(messaging != null) {
      fcmToken = await messaging!.getToken();
      if(fcmToken != null) {
        await _userEm.setTokenMessaging(fcmToken!);
      }
      _listenerOnMessage();
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    }
  }

  /// Recibiendo mensajes en foreground
  void _listenerOnMessage() {

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      //print('>>>la data es: ${message.data}');

      if (message.notification != null) {
        // Msg con Notificacion
        //print('>>>${message.notification}');
      }
      FlutterRingtonePlayer.playNotification();
    });
  }
}