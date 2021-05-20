import 'package:deneme_app/utils/crashlytics.dart';
import 'package:deneme_app/widgets/HeaderWidget.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {

  FirebaseCrashlytics crashlytics = FirebaseCrashlytics.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: Text('Crash Page'),
    centerTitle: true,
    ),
    body: Center(
    child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    OutlinedButton(
    onPressed: () {
    customCrashLog('I pressed a wrong button');
    crashApp();
    },
    child: const Text('CRASH IT!!!!'),
    ),
    ],
    ),
    ),
    );
  }
}

class NotificationsItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

  }
}