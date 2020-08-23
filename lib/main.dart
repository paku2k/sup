import 'package:flutter/material.dart';
import 'screens/auth_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/main_screen.dart';
import 'ui-helper.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'package:firebase_analytics/observer.dart';

FirebaseAnalytics analytics;

void main() {
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

        floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: Colors.lightBlueAccent),
        primarySwatch: Colors.purple,
        accentColor: Colors.blueAccent,
        buttonColor: Colors.lightBlueAccent,

        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: StreamBuilder(stream: FirebaseAuth.instance.onAuthStateChanged, builder: (context, snapshot) {
        if(snapshot.hasData){
          return MainScreen();
        }
        return MainScreen();

      },),
    );
  }
}
