import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maktrogps/provider/theme_changer_provider.dart';
import 'package:maktrogps/theme/app_theme.dart';

import 'package:maktrogps/utils/LocalNotificationService.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config/static.dart';
import 'screens/splashscreen.dart';
import 'firebase_options.dart';
import 'getx_localization/languages.dart';
import 'mvvm/view_model/objects.dart';

class MyHttpoverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

///Receive message when app is in background solution for on message
Future<void> backgroundHandler(RemoteMessage message) async {
  print(message.data.toString());
  print(message.notification!.title);
  LocalNotificationService.display(message);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      name: "NavFleet", options: DefaultFirebaseOptions.currentPlatform);
  await Permission.notification.isDenied.then((value) {
    if (value) {
      Permission.notification.request();
    }
  });
  FirebaseMessaging.onBackgroundMessage(backgroundHandler);
  HttpOverrides.global = MyHttpoverrides();
  StaticVarMethod.pref_static = await SharedPreferences.getInstance();
  runApp(const MyHomePage(title: "title"));
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<void> messageHandler() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      LocalNotificationService.display(event);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    // initPlatformState();
    // secureScreen();
    checkPreference();
    super.initState();

    if (Platform.isIOS) {
      FirebaseMessaging.instance.requestPermission();
    }

    LocalNotificationService.initialize(context);

    ///gives you the message on which user taps
    ///and it opened the app from terminated state
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        final routeFromMessage = message.data["route"];
        LocalNotificationService.display(message);
        Navigator.of(context).pushNamed(routeFromMessage);
      }
    });

    messageHandler();

    ///When the app is in background but opened and user taps
    ///on the notification
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      final routeFromMessage = message.data["route"];
      LocalNotificationService.display(message);
      Navigator.of(context).pushNamed(routeFromMessage);
    });

    getToken();
  }

  void checkPreference() async {
    StaticVarMethod.pref_static = await SharedPreferences.getInstance();
  }

  Future<void> getDeviceTokenToSendNotification() async {
    String? fcmToken = await await FirebaseMessaging.instance.getToken();
    StaticVarMethod.notificationToken = fcmToken.toString();
    //deviceTokenToSendPushNotification = token.toString();
    print("Token Value: " + StaticVarMethod.notificationToken);
  }

  Future<void> getToken() async {
    String? fcmToken = await FirebaseMessaging.instance.getToken();
  }

  @override
  Widget build(BuildContext context) {
    getDeviceTokenToSendNotification();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => theme_changer_provider()),
        ChangeNotifierProvider(create: (_) => ObjectStore()),
      ],
      child: Builder(builder: (context) {
        final themeChanger = Provider.of<theme_changer_provider>(context);
        String lang = StaticVarMethod.pref_static?.getString('language_code') ?? 'fr';
        String country = StaticVarMethod.pref_static?.getString('country_code') ?? (lang == 'ar' ? 'SA' : (lang == 'en' ? 'US' : 'CA'));
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: themeChanger.thememode,
          translations: languages(),
          locale: Locale(lang, country),
          fallbackLocale: const Locale('fr', 'CA'),

          // locale: Locale('ar',"SA"),
          // fallbackLocale: Locale('ar',"SA"),
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: SplashScreen(),
          // home: tasks(),
          builder: EasyLoading.init(),
        );
      }),
    );
  }
}
