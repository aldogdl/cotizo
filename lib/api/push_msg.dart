import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

import '../firebase_options.dart';

/// Funcion de alto nivel para la recepción de mensajes en background
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print('>>>>>>Mensaje recibido en background!');
  print('>>>la data es: ${message.data}');

  if (message.notification != null) {
    print('>>>>>>El Message tambien contiene una notificacion background:');
    print('>>>${message.notification}');
  }
  FlutterRingtonePlayer.playNotification();
}

class PushMsg {

  // eamdzP-XQiGWEaNwnw4IVN:APA91bH0ThMju6WgJXymqO1KRkUokwUJ3rPCJPNI6BT9zYf8Ef8pFwjZnxbDEgnw0FMRcQio6eiE33dKHjSLKKh3QQn-ww1mnSFLrzg17ZSLHrvCE0d1787S6_LPl-ejBoBEBsMMwVsA
  String? fcmToken;
  FirebaseMessaging? messaging;

  /// Inicializamos el servicio de Messanging
  Future<void> init() async {

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    messaging = FirebaseMessaging.instance;
    if(messaging != null) {
      fcmToken = await messaging!.getToken();
      print(fcmToken);
      _listenerOnMessage();
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    }
  }

  /// Recibiendo mensajes en foreground
  void _listenerOnMessage() {

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('>>>>>>Mensaje recibido en foreground!');
      print('>>>la data es: ${message.data}');

      if (message.notification != null) {
        print('>>>>>>El Message tambien contiene una notificacion foreground:');
        print('>>>${message.notification}');
      }
      FlutterRingtonePlayer.playNotification();
    });
  }
}