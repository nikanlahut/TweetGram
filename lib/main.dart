import 'package:deneme_app/pages/unknownWelcome.dart';
import 'package:deneme_app/pages/welcomeNoFirebase.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:deneme_app/pages/HomePage.dart';
import 'package:firebase_core/firebase_core.dart';

void main()
{
  WidgetsFlutterBinding.ensureInitialized();
  //await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if(snapshot.hasError) {
          print('Cannot connect to firebase: '+snapshot.error);
          return MaterialApp(
            home: WelcomeViewNoFB(),
          );
        }
        if(snapshot.connectionState == ConnectionState.done) {
          print('Firebase connected');
          return AppBase();
        }

        return MaterialApp(
          home: UnknownWelcome(),
        );
      }
    );
  }
}

class AppBase extends StatelessWidget {
  const AppBase({
    Key key,
  }) : super(key: key);

  static FirebaseAnalytics  analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: <NavigatorObserver>[observer],
    title: 'TweetGram',
    debugShowCheckedModeBanner: false,
    theme: ThemeData
    (
    scaffoldBackgroundColor: Colors.black,
    dialogBackgroundColor: Colors.black,
    primarySwatch: Colors.grey,
    cardColor: Colors.white70,
    accentColor: Colors.black,
    ),
      home: HomePage(analytics: analytics, observer: observer),
    );
  }
}
