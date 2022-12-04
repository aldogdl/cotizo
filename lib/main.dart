import 'package:cotizo/vars/globals.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'config/my_rutas.dart';
import 'config/sngs_manager.dart';
import 'providers/gest_data_provider.dart';
import 'providers/ordenes_provider.dart';
import 'providers/signin_provider.dart';

void main() async {
  
  WidgetsFlutterBinding.ensureInitialized();
  sngManager();
  await Hive.initFlutter();
  
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


class MyApp extends StatelessWidget {
  
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp
    ]);
    final globals = Globals();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: globals.bgAppBar,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: globals.bgAppBar,
      systemNavigationBarIconBrightness: Brightness.light
    ));

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual, overlays: [
        SystemUiOverlay.top, SystemUiOverlay.bottom
      ]
    );

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
      routerConfig: MyRutas.rutas,
    );
  }

}
