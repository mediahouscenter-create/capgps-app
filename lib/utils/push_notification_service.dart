import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:maktrogps/config/static.dart';


class PushNotificationService {
  static FirebaseMessaging? _fcm;

  static Future initialise() async {
    if (_fcm == null) {
      _fcm = FirebaseMessaging.instance;
    }

    _fcm!.requestPermission();

    // FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    //
    // const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    // final DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings();
    //
    // final InitializationSettings initializationSettings = InitializationSettings(
    //   android: initializationSettingsAndroid,
    //   iOS: initializationSettingsIOS,
    // );

  //  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // bool isEnabled = await UserRepository.isNotificationEnabled();
    // String username = await UserRepository.getUsername();
    bool isEnabled = true;
    //String username = await StaticVarMethod.pref_static!.getString('email')!;

    String username = StaticVarMethod.username;
   // String str = "#@F&L^&%U##T#T@#ER###CA@#@M*(PU@&#S%^%2324@*(^&";

   // String username =  StaticVarMethod.notificationToken;
    username = username.replaceAll(RegExp('[^A-Za-z0-9]'), '');
    print(username); //Output: FLUTTERCAMPUS2324
    //String username = "shoaib1234";

    if (username == null) {
      return;
    }

    if (isEnabled == null || isEnabled) {
      _fcm!.subscribeToTopic(username).then((_) {
        print("subscribed to topic " + username);
      });
    } else {
      _fcm!.unsubscribeFromTopic(username).then((_) {
        print("unsubscribed to topic " + username);
      });
    }
  }
}
