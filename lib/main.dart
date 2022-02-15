import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:overlay_support/overlay_support.dart';

import 'model/pushnotification_model.dart';
import 'notification_badge.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return OverlaySupport(
        child: MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home:  HomeScreen(),
        )
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  late FirebaseMessaging _messaging;
  late int _totalNotificationCounter;


  //model
  PushNotification? _notificationInfo;

  //register for notification
  void registerNotification() async {
    await Firebase.initializeApp();

    //instance for Firebase messaging
    _messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {

        PushNotification notification = PushNotification(
          title: message.notification!.title,
          body: message.notification!.body,
          dataTitle: message.data['title'],
          dataBody: message.data['body'],
        );


        setState(() {
          _totalNotificationCounter++;
          _notificationInfo = notification;
        });

        if (notification != null) {
          showSimpleNotification(Text(_notificationInfo!.title!),
            leading: NotificationBadge(totalNotification: _totalNotificationCounter),
            subtitle: Text(_notificationInfo!.body!),
            background: Colors.white,
            duration: Duration(seconds: 2),
          );
        }
      });
    }
    else {
      print('permission declined by user');
    }
  }

  // AndroidNotificationDetails androidNotificationsDetails = const AndroidNotificationDetails(
  //   'your other channel id',
  //   'your other channel name',
  //   importance: Importance.high,
  //   priority: Priority.high,
  //   enableLights: true,
  //   playSound: true,
  //   sound: RawResourceAndroidNotificationSound('notification'),
  // );

  //check the initial message that we receive
  checkForInitialMessage() async {
    await Firebase.initializeApp();
    RemoteMessage? initialMessage =
    await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      PushNotification notification = PushNotification (
        title: initialMessage.notification!.title,
        body: initialMessage.notification!.body,
        dataTitle: initialMessage.data['title'],
        dataBody: initialMessage.data['body'],
      );
      setState(() {
        _totalNotificationCounter++;
        _notificationInfo = notification;
      });
    }
  }

  @override
  void initState() {
    registerNotification();
    _totalNotificationCounter = 0;
    super.initState();
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(top: 500),
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.blueAccent,Color(0xffE5E5E5),],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
          )
        ),
        child: Column(
          children: const [
            Center(
              child: Text(
                "Firebase Notification Testing",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 30
                ),
              ),
            )
            // Text('FlutterPushNotification',
            //   textAlign: TextAlign.center,
            //   style: TextStyle(
            //     color: Colors.blue,
            //     fontSize: 20,
            //   ),
            // ),
            // SizedBox(
            //   height: 12,
            // ),

            // NotificationBadge(totalNotification: _totalNotificationCounter),
            // _notificationInfo != null ? Column(
            //   crossAxisAlignment: CrossAxisAlignment.center,
            //   children: [
            //     Text('TITLE: ${_notificationInfo!.dataTitle ?? _notificationInfo!.title}',
            //       style: TextStyle(
            //         fontWeight: FontWeight.bold,
            //         fontSize: 16,
            //       ),
            //     ),
            //     SizedBox(
            //       height: 9,
            //     ),
            //     Text('BODY: ${_notificationInfo!.dataBody ?? _notificationInfo!.body}',
            //       style: TextStyle(
            //         fontWeight: FontWeight.bold,
            //         fontSize: 16,
            //       ),),
            //   ],
            // ) : Container(),
          ],
        ),
      ),
    );
  }
}