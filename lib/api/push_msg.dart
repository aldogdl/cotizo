import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

import '../repository/acount_user_repository.dart';
import '../firebase_options.dart';

/// Funcion de alto nivel para la recepción de mensajes en background
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (message.notification != null) {
    // Msg con Notificacion
    // print('>>>${message.notification}');
  }
  FlutterRingtonePlayer.playNotification();
}

/// Funcion de alto nivel para la recepción de mensajes en background
void notifBackgroundHandler(NotificationResponse notificationResponse) {

  // Se supone que en el playload vendra una serie de codigos para ver que hacer
  // print(notificationResponse.payload);
}

class PushMsg {

  String? fcmToken;
  AuthorizationStatus? authPush;
  FirebaseMessaging? messaging;
  FlutterLocalNotificationsPlugin? flnp;
  final _userEm = AcountUserRepository();

  /// Inicializamos el servicio de Messanging
  Future<void> init() async {
    
    if(Platform.isAndroid) {

      flnp = FlutterLocalNotificationsPlugin();
      // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
      const initConfAndroid = AndroidInitializationSettings('ic_launcher');
      const initSettings = InitializationSettings(android: initConfAndroid);
      await flnp!.initialize(
        initSettings,
        onDidReceiveNotificationResponse: notifBackgroundHandler
      );

      const channel = AndroidNotificationChannel(
        'ANETCHANNEL',
        'com.google.firebase.messaging.default_notification_channel_id',
        description: 'Este canal es usado para agregar importancia a las notificaciones',
        importance: Importance.max,
      );

      await flnp!.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    }

    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    
    messaging = FirebaseMessaging.instance;
    if(messaging != null) {

      await _permisos();
      fcmToken = await messaging!.getToken();
      if(fcmToken != null) {
        await _userEm.setTokenMessaging(fcmToken!);
      }
      _listenerOnMessage();
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    }
  }

  ///
  Future<bool> _permisos() async {

    NotificationSettings? settings;
    if(messaging != null) {
      settings = await messaging!.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
    }

    if(settings != null) {
      authPush = settings.authorizationStatus;
      if(settings.authorizationStatus == AuthorizationStatus.authorized) {
        return true;
      }
    }
    return false;
  }

  /// Recibiendo mensajes en foreground
  void _listenerOnMessage() async {

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {

      String? titulo = '[?] Tendrás estas Refacciones...';
      String? descripcion = 'Uno de nuestros cientos de clientes nos ha solicitado refacciones.\n¡AutoparNet trabajando para ti!.';
      if (message.notification != null) {
        // Msg con Notificacion
        titulo = message.notification!.title;
        descripcion = message.notification!.body;        
      }

      const details = AndroidNotificationDetails(
        'ANETCHANNEL', 'com.google.firebase.messaging.default_notification_channel_id',
        channelDescription: 'Este canal es usado para agregar importancia a las notificaciones',
        importance: Importance.max,
        priority: Priority.high,
        icon: 'ic_launcher',
        ticker: 'ticker'
      );

      var pay = 'from local'; 
      if(descripcion!.contains('cod:')) {
        final partes = descripcion.split('cod:');
        pay = partes.last;
      }
      const notificationDetails = NotificationDetails(android: details);
      flnp!.show(0, titulo, descripcion, notificationDetails, payload: pay);
      
      FlutterRingtonePlayer.playNotification();
    });
  }

}