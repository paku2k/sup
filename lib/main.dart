import 'package:flutter/material.dart';
import 'screens/auth_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/main_screen.dart';
import 'screens/list_screen.dart';
import 'ui-helper.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'package:firebase_analytics/observer.dart';

FirebaseAnalytics analytics;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  analytics = FirebaseAnalytics();
  Crashlytics.instance.enableInDevMode = true; // turn this off after seeing reports in in the console.
  FlutterError.onError = Crashlytics.instance.recordFlutterError;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Flutter Demo',

      theme: ThemeData(
        

        floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: Colors.deepOrangeAccent),
        primarySwatch: Colors.lightBlue,
        accentColor: Colors.deepOrangeAccent,
        buttonColor: Color(0xFF1BAFC5),
        fontFamily: 'Raleway',
        textTheme: ThemeData.light().textTheme.copyWith(
          bodyText1: TextStyle(
            color: Color.fromRGBO(20, 51, 51, 1),
          ),
          bodyText2: TextStyle(
            color: Color.fromRGBO(20, 51, 51, 1),
          ),
          headline6: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.normal,
              fontFamily: 'RobotoCondensed'),
        ),

        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: StreamBuilder(stream: FirebaseAuth.instance.onAuthStateChanged, builder: (context, snapshot) {
        if(snapshot.hasData){
          return MainScreen();
        }
        return AuthScreen();

      },),
    );
  }
}
