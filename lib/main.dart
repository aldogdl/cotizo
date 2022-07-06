import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'config/my_rutas.dart';
import 'config/sngs_manager.dart';
import 'firebase_options.dart';
import 'providers/gest_data_provider.dart';
import 'providers/ordenes_provider.dart';
import 'providers/signin_provider.dart';
import 'vars/globals.dart';

void main() async {
  
  WidgetsFlutterBinding.ensureInitialized();
  sngManager();
  await Hive.initFlutter();
  final global = getIt<Globals>();
  
  // Get a specific camera from the list of available cameras.
  final cameras = await availableCameras();
  global.firstCamera = cameras.first;
  runApp(const MiddleApp());
}

class MiddleApp extends StatelessWidget {

  const MiddleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SignInProvider()),
        ChangeNotifierProvider(create: (context) => OrdenesProvider()),
        ChangeNotifierProvider(create: (context) => GestDataProvider()),
      ],
      child: const MyApp(),
    );
  }
}


class MyApp extends StatefulWidget {

  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}


class _MyAppState extends State<MyApp> {

  @override
  void initState() {

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown
    ]);

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF202c33),
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Color.fromARGB(255, 13, 21, 26),
      systemNavigationBarIconBrightness: Brightness.light
    ));

    return MaterialApp.router(
      title: 'Autoparnet Cotizo',
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData(
        primarySwatch: Colors.green,
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate
      ],
      supportedLocales: const[Locale('es', 'ES_MX')],
      routeInformationProvider: MyRutas.rutas.routeInformationProvider,
      routeInformationParser: MyRutas.rutas.routeInformationParser,
      routerDelegate: MyRutas.rutas.routerDelegate,
    );
  }
}