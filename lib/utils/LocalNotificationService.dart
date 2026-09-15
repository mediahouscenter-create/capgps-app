import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';


late SharedPreferences prefs;
class LocalNotificationService {

  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static void initialize(BuildContext context) {
    final InitializationSettings initializationSettings =
    InitializationSettings(
        android: AndroidInitializationSettings("@mipmap/ic_launcher"));

    _notificationsPlugin.initialize(initializationSettings,onDidReceiveNotificationResponse: (route) async{
      if(route != null){
        Navigator.of(context).pushNamed(route.toString());
      }
    });
  }

  static void display(RemoteMessage message) async {

    try {

      prefs = await SharedPreferences.getInstance();
      final id = DateTime.now().millisecondsSinceEpoch ~/1000;

      final NotificationDetails notificationDetails = NotificationDetails(
          android: AndroidNotificationDetails(
            "easyapproach",
            "easyapproach channel",
            //"this is our channel",
            importance: Importance.max,
            priority: Priority.high,
          )
      );

      // String audioasset = "assets/audio/ignitiononnoti.mp3";
      // String msg=message.notification!.title.toString();
      // AudioPlayer player = AudioPlayer();
      // if(msg.contains("Ignition On")  || message.notification!.body.toString().contains("Ignition On")){
      //   audioasset = "assets/audio/ignitiononnoti.mp3";
      // }
      // else if(msg.contains("Ignition off") ||msg.contains("OFF") || message.notification!.body.toString().contains("Ignition off")){
      //   audioasset = "assets/audio/ignitiononnoti.mp3";
      // }else if(msg.contains("Idle") || message.notification!.body.toString().contains("Idle")){
      //   audioasset = "assets/audio/idlenoti.mp3";
      // }else if(msg.contains("overspeed") || message.notification!.body.toString().contains("overspeed")){
      //   audioasset = "assets/audio/overspeeding.mp3";
      // }
      // else{
      //
      //   audioasset = "assets/audio/powerdisconnected.mpeg";
      // //  audioasset = "assets/audio/notification.mp3";
      // }
      // ByteData bytes = await rootBundle.load(audioasset); //load sound from assets
      // Uint8List  soundbytes = bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
      // int result = await player.playBytes(soundbytes);
      // if(result == 1){ //play success
      //   print("Sound playing successful.");
      //   print("notification!.title"+msg);
      //   print("message.notification!.body"+message.notification!.body.toString());
      // }else{
      //   print("Error while playing sound.");
      //
      // }


      var lat=message.data["latitude"];
      var lng=message.data["longitude"];
      List<Placemark> placemarks = await placemarkFromCoordinates(double.parse(lat), double.parse(lng));

      var address=placemarks[0].name.toString()+ " " +placemarks[0].locality.toString()+ " "+placemarks[0].subAdministrativeArea.toString()+ " "+placemarks[0].administrativeArea.toString()+ " "+placemarks[0].country.toString();

      var text1 = message.notification!.title.toString();
      var text2 = message.notification!.body.toString();
      var text3 = message.notification!;


      // bool _val= prefs.getBool("notival")!;
      // if(_val){
        await _notificationsPlugin.show(
          id,
          message.notification!.title,
          message.notification!.body.toString() +"   \n"+address,

          notificationDetails,
          payload: message.data["route"],
        );
      // }else{
      //
      // }

    } on Exception catch (e) {
      print(e);
    }
  }
}




// import 'dart:typed_data';
//
// import 'package:audioplayers/audioplayers.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/Services.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:maktrogps/config/static.dart';
// import 'package:maktrogps/data/model/devices.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:text_to_speech/text_to_speech.dart';
//
// late SharedPreferences prefs;
// class LocalNotificationService {
//
//   static final FlutterLocalNotificationsPlugin _notificationsPlugin =
//   FlutterLocalNotificationsPlugin();
//
//   static void initialize(BuildContext context) {
//     final InitializationSettings initializationSettings =
//     InitializationSettings(
//         android: AndroidInitializationSettings("@mipmap/ic_launcher"));
//
//     // _notificationsPlugin.initialize(initializationSettings,onSelectNotification: (String? route) async{
//     //   if(route != null){
//     //     Navigator.of(context).pushNamed(route);
//     //   }
//     // });
//   }
//
//   static void display(RemoteMessage message) async {
//
//     try {
//       TextToSpeech tts = TextToSpeech();
//       prefs = await SharedPreferences.getInstance();
//       final id = DateTime.now().millisecondsSinceEpoch ~/1000;
//
//       final NotificationDetails notificationDetails = NotificationDetails(
//           android: AndroidNotificationDetails(
//             "easyapproach",
//             "easyapproach channel",
//             //"this is our channel",
//             importance: Importance.max,
//             priority: Priority.high,
//           )
//       );
//
//       // String audioasset = "assets/audio/ignitiononnoti.mp3";
//       // String msg=message.notification!.title.toString();
//       // AudioPlayer player = AudioPlayer();
//       // if(msg.contains("Ignition On")  || message.notification!.body.toString().contains("Ignition On")){
//       //   audioasset = "assets/audio/ignitiononnoti.mp3";
//       // }
//       // else if(msg.contains("Ignition off") ||msg.contains("OFF") || message.notification!.body.toString().contains("Ignition off")){
//       //   audioasset = "assets/audio/ignitiononnoti.mp3";
//       // }else if(msg.contains("Idle") || message.notification!.body.toString().contains("Idle")){
//       //   audioasset = "assets/audio/idlenoti.mp3";
//       // }else if(msg.contains("overspeed") || message.notification!.body.toString().contains("overspeed")){
//       //   audioasset = "assets/audio/overspeeding.mp3";
//       // }
//       // else{
//       //
//       //   audioasset = "assets/audio/powerdisconnected.mpeg";
//       // //  audioasset = "assets/audio/notification.mp3";
//       // }
//       // ByteData bytes = await rootBundle.load(audioasset); //load sound from assets
//       // Uint8List  soundbytes = bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
//       // int result = await player.playBytes(soundbytes);
//       // if(result == 1){ //play success
//       //   print("Sound playing successful.");
//       //   print("notification!.title"+msg);
//       //   print("message.notification!.body"+message.notification!.body.toString());
//       // }else{
//       //   print("Error while playing sound.");
//       //
//       // }
//       String text = message.notification!.title.toString();
//       tts.speak(text);
//
//       print(text); //Output: FLUTTERCAMPUS2324
//       await _notificationsPlugin.show(
//         id,
//         message.notification!.title,
//         message.notification!.body,
//         notificationDetails,
//         payload: message.data["route"],
//       );
//       // bool _val= prefs.getBool("notival")!;
//       // if(_val){
//       // for (int i = 0; i < StaticVarMethod.devicelist.length; i++) {
//       //   deviceItems model = StaticVarMethod.devicelist.elementAt(i);
//       //
//       //   if (message.notification!.title.toString().contains(model.name.toString())) {
//
//
//       //   }
//       // }
//
//       // }else{
//       //
//       // }
//
//     } on Exception catch (e) {
//       print(e);
//     }
//   }
// }