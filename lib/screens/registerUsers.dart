import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:maktrogps/mvvm/view_model/objects.dart';
import 'package:provider/provider.dart';

import 'dart:collection';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../utils/LocalNotificationService.dart';
import '../data/datasources.dart';

class registerUsers extends StatefulWidget {

  @override
  _registerUsersState createState() => _registerUsersState();
}

class _registerUsersState extends State<registerUsers> {


  TextEditingController _phoneFieldController = TextEditingController();
  TextEditingController _passwprdFieldController = TextEditingController();
  @override
  initState() {

    super.initState();
  }



  @override
  Widget build(BuildContext context) {


    return Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          title: Padding(
              padding: const EdgeInsets.only(top: 0.0, left: 2.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Center(
                    child: Text('Dashboard',
                      style: TextStyle(
                          fontFamily: "Sofia",
                          fontWeight: FontWeight.w900,
                          fontSize: 20.0,
                          color: Colors.black),
                    ),
                  ),

                ],
              )
          ),
          backgroundColor: Colors.white,
        ),
        body: dashboardView()
    );
  }

  Widget dashboardView(){
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Device Registraion Process"),
                Icon(Icons.edit_calendar_rounded)
              ],
            ),
          ),
          // SizedBox(height: 10,),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _phoneFieldController,
              decoration: InputDecoration(
                hintText: 'Enter Mobile Number',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          // SizedBox(width: 5,),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: '+08800',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          // SizedBox(height: 10,),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Device IMEI',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          SizedBox(height: 10,),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller:_passwprdFieldController,
              decoration: InputDecoration(
                hintText: 'Device Password',
                border: OutlineInputBorder(),
              ),
            ),
          ),
              Container(
              padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(

      borderRadius: BorderRadius.circular(20),
      boxShadow: [
      BoxShadow(
      color: Colors.white.withOpacity(0.5),
      spreadRadius: 1,
      blurRadius: 1,
      offset: Offset(0, 3),
      ),
      ],
      border: Border.all(
      color: Colors.black, // Adjust the color of the border
      width: 1.0, // Adjust the width of the border
      ),

      ),
      child: Text(
      'Verification Process',
      style: TextStyle(fontSize: 20.0),
      ),
              ),
          // SizedBox(height: 10,),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'OTP Verification',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          // SizedBox(height: 10,),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Select Subscription Package',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          ElevatedButton(onPressed: (){
            _register();
          }, child: Text("submitt"))


      ],


      ),
    );
  }

  void _register() async {


      try {

        var result = await gpsapis.getRegister(
           "tayyab","email",_phoneFieldController.text, _passwprdFieldController.text);

        print(result);
        print(result);
        var data = json.decode(result.body);

        if (data['status'] == 0) {
          Navigator.pop(context);
          var errorMessages = data['errors']['email'][0];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessages),
              backgroundColor: Colors.red,
            ),
          );
        }

        if (data['status'] == 1) {
          // Navigator.pop(context);


          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Registration Successful'),
              backgroundColor: Colors.green,
            ),
          );

          String password= data['item']["password_to_email"].toString();

          String text=  'Your App Login and password\n\n'+
              'email:  '+"shoaib2.ue@gmail.com"+
              '\n\n password:  '+password;


          var result = await gpsapis.sendwhatsappsms(
              _phoneFieldController.text,text);
          print(password);
          print(password);

          Navigator.pop(context);
          //navigate to setup device page
          // Navigator.pushReplacement(
          //     context,
          //     MaterialPageRoute(
          //         builder: (context) => SetupDevice(
          //               isFromRegisterPage: true,
          //             )));
        }
      } catch (e) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Something went wrong'),
            backgroundColor: Colors.red,
          ),
        );
      }

  }

}
