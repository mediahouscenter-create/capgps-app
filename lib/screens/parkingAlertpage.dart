
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';

import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:maktrogps/config/static.dart';


class parkingAlertpage extends StatefulWidget {
  @override
  _parkingAlertpageState createState() => _parkingAlertpageState();
}
class _parkingAlertpageState extends State<parkingAlertpage> {


  @override
  void initState() {
    super.initState();
    playalarm();
  }

  @override
  void dispose() {

    super.dispose();
  }

  AudioPlayer player = AudioPlayer();
 playalarm() async{
    String audioasset = "assets/audio/police.mp3";
    ByteData bytes = await rootBundle.load(audioasset); //load sound from assets
    Uint8List  soundbytes = bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
   // int result = await player.playBytes(soundbytes);
  await player.play(AssetSource(audioasset));

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: Platform.isIOS?SystemUiOverlayStyle.light:SystemUiOverlayStyle(
            statusBarIconBrightness: Brightness.light
        ),
        child: Stack(
          children: [

            Container(
              height:MediaQuery.of(context).size.height,
              decoration: const BoxDecoration(
                  image: DecorationImage(image: AssetImage("assets/images/sacreen3.jpg",),fit: BoxFit.cover,opacity: 0.70,)
              ),
            ),


            Center(
              child: Column(
                children: [
                  GestureDetector(
                      onTap: (){
                        //Navigator.of(context).pop();
                        player.pause();
                        Navigator.pop(context);
                      },
                      child: Container(
                        margin: EdgeInsets.fromLTRB(10, 400, 10, 0),
                        height: 50,
                        width: 200,
                        decoration: BoxDecoration(
                            color: Colors.purple,
                            borderRadius: BorderRadius.circular(10)
                        ),
                        child:Center(
                          child: Text(
                            StaticVarMethod.deviceName,style: TextStyle(fontSize: 20,color: Colors.white,fontWeight:FontWeight.bold),
                          ),
                        ),
                      )
                  ),
                  GestureDetector(
                    onTap: (){

                      print("exit");
                      Fluttertoast.showToast(
                          msg: "Parking mode Off",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.redAccent,
                          textColor: Colors.white,
                          fontSize: 16.0);
                      player.pause();
                      Navigator.pop(context);
                     // Navigator.of(context).pop();

                    },
                    child: Container(
                      margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                      height: 50,
                      width: 200,
                      decoration: BoxDecoration(
                          color: Colors.grey,

                          //  border: Border.all(width: 1.8,color: Colors.lightBlue),
                          borderRadius: BorderRadius.circular(30)
                      ),
                      child:Center(
                        child: Text(
                          'EXIT',style: TextStyle(fontSize: 20,color: Colors.white,fontWeight: FontWeight.bold,),


                        ),




                      ),
                    ),
                  ),
                ],
              ),
            ),







          ],


        ),

      ),
    );
  }
}




















