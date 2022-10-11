import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

import '../repository/acount_user_repository.dart';
import '../firebase_options.dart';


FlutterLocalNotificationsPlugin? flnp;
FirebaseMessaging? messaging;
const String _idC = 'ANETCHANNEL';
const String _nameC = 'oportunidades.de.venta';
const String _desC = 'Entérate de las nuevas oportunidades de venta';

/// Funcion de alto nivel para la recepción de mensajes en background
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await _configLocalNotiff();

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

///
Future<void> _configLocalNotiff() async {

  if(Platform.isAndroid) {

    flnp = FlutterLocalNotificationsPlugin();
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('ic_launcher')
    );
    await flnp!.initialize(
      initSettings,
      onDidReceiveNotificationResponse: notifBackgroundHandler
    );

    await flnp!.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(
        const AndroidNotificationChannel(
          _idC, _nameC, description: _desC, importance: Importance.max, playSound: true,
        )
      );
  }
}

///
void _showNotiff(RemoteMessage message) {

  String? titulo = '[?] Tendrás estas Refacciones...';
  String? descripcion = 'Uno de nuestros cientos de clientes nos ha solicitado refacciones.\n¡AutoparNet trabajando para ti!.';
  if (message.notification != null) {
    titulo = message.notification!.title;
    descripcion = message.notification!.body;        
  }

  var pay = 'from local'; 
  if(descripcion!.contains('cod:')) {
    final partes = descripcion.split('cod:');
    pay = partes.last;
  }
  const detalles = NotificationDetails(
    android: AndroidNotificationDetails(
      _idC, _nameC, channelDescription: _desC,
      importance: Importance.max,
      priority: Priority.high,
      icon: 'ic_launcher'
    )
  );
  flnp!.show(0, titulo, descripcion, detalles, payload: pay);
}


class PushMsg {

  String? fcmToken;
  AuthorizationStatus? authPush;  
  final _userEm = AcountUserRepository();
  
  /// Inicializamos el servicio de Messanging
  Future<void> init() async {
    
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await _configLocalNotiff();

    messaging = FirebaseMessaging.instance;
    if(messaging != null) {

      await _permisos();
      fcmToken = await messaging!.getToken();
      if(fcmToken != null) {
        await _userEm.setTokenMessaging(fcmToken!);
      }
      _listenerOnMessage();
      _onRefreshToken();
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
      _showNotiff(message);
      FlutterRingtonePlayer.playNotification();
    });
  }

  /// Recibiendo mensajes en foreground
  void _onRefreshToken() async {

    messaging!.onTokenRefresh.listen((newToken) async {
      await _userEm.setTokenMessaging(newToken);
    });
  }

}