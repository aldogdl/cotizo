import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:go_router/go_router.dart';

import 'package:cotizo/config/my_rutas.dart';
import 'package:cotizo/entity/push_in_entity.dart';
import '../entity/orden_entity.dart';
import '../services/my_http.dart';
import '../repository/acount_user_repository.dart';
import '../firebase_options.dart';

@pragma('vm:entry-point')
FlutterLocalNotificationsPlugin? flnp;
@pragma('vm:entry-point')
FirebaseMessaging? messaging;
const String _idC = 'ANETCHANNEL';
const String _nameC = 'oportunidades.de.venta';
const String _desC = 'Entérate de las nuevas oportunidades de venta';

/// Funcion de alto nivel para la recepción de mensajes en background
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (message.notification != null) {
    // Msg con Notificacion
    // print('>>>${message.notification}');
  }
  FlutterRingtonePlayer.playNotification();
}

///
@pragma('vm:entry-point')
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

@pragma('vm:entry-point')
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
  
  ///
  Future<void> _configLocalNotiff() async {

    if(Platform.isAndroid) {

      flnp = FlutterLocalNotificationsPlugin();
      const initSettings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher')
      );
      await flnp!.initialize(
        initSettings,
        onDidReceiveNotificationResponse: notifOnResumeHandler
      );

      await flnp!.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _idC, _nameC, description: _desC, importance: Importance.max, playSound: true,
            showBadge: true
          )
        );
    }
  }

  ///
  Future<NotificationDetails> getDetails({String url = ''}) async {

    StyleInformation? pic;
    if(url.isNotEmpty) {

      final bitmap = await MyHttp.getImagePzaFromServer(url);
      if(bitmap.isNotEmpty) {
        pic = BigPictureStyleInformation(
          ByteArrayAndroidBitmap(bitmap),
          largeIcon: const DrawableResourceAndroidBitmap('ic_launcher'),
          hideExpandedLargeIcon: false,
        );
      }
    }

    final androidDetail = AndroidNotificationDetails(
      _idC, _nameC,
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      visibility: NotificationVisibility.public,
      largeIcon: const DrawableResourceAndroidBitmap('ic_launcher'),
      styleInformation: pic,
      ticker: 'ticker'
    );

    return NotificationDetails(android: androidDetail);
  }

  ///
  Future<void> makePushInt(OrdenEntity? orden) async {

    late NotificationDetails detalles;
    int id = 0;
    String titulo = 'Oportunidad de Venta';
    String subtitulo = 'Tienes más piezas para cotizar :)\nAutoparNet Informa.';
    if(orden != null) {
      id = orden.id;
      final pza = orden.piezas.first;
      detalles = await getDetails(url: orden.fotos[pza.id]!.first);
      titulo = '${pza.piezaName} ${pza.posicion}';
      subtitulo = '¿Tendrás esta pieza para vender?';
    }else{
      detalles = await getDetails();
    }
    
    await FlutterRingtonePlayer.playNotification();
    await flnp!.show(
      id, titulo, subtitulo, detalles,
      payload: 'cache:$id',
    );
  }

  ///
  Future<void> makePushInterno(PushInEntity push, {bool mute = false}) async {

    late NotificationDetails detalles;
    if(push.imgBig != '0') {
      detalles = await getDetails(url: push.imgBig);
    }else{
      detalles = await getDetails();
    }
    
    if(!mute) {
      await FlutterRingtonePlayer.playNotification();
    }

    await flnp!.show(
      push.id, push.titulo, push.subtitulo, detalles,
      payload: push.payload,
    );
  }

  ///
  void notifOnResumeHandler(NotificationResponse notificationResponse) {

    final ctx = MyRutas.rutas.routerDelegate.navigatorKey.currentContext;
    if(notificationResponse.payload != null) {
      if(!notificationResponse.payload!.contains('cache')) {
        if(ctx != null) {
          ctx.go('/cotizo/${notificationResponse.payload}');
        }
      }
    }
  }
}