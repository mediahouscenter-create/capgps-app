import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:maktrogps/config/static.dart';
import 'package:maktrogps/data/datasources.dart';
import 'package:maktrogps/data/model/PlayBackRoute.dart';
import 'package:maktrogps/data/model/PositionHistory.dart';
import 'package:maktrogps/data/model/history.dart';
import 'package:maktrogps/mapconfig/CommonMethod.dart';
import 'package:maktrogps/mapconfig/CustomColor.dart';

class fuelplayback extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _PlaybackPageState();
}

class _PlaybackPageState extends State<fuelplayback> {
  late GoogleMapController mapController;
  double currentZoom = 14.0;
  late StreamController<dynamic> _postsController;
  late Timer timerPlayBack;
  late List<PlayBackRoute> routeList = [];
  late List<PlayBackRoute> tripList = [];
  late bool isLoading;
  double pinPillPosition = 0;


  int playbackTime = 600;
  List<LatLng> polylineCoordinates = [];
  Map<PolylineId, Polyline> polylines = {};

  var selectedToTime = TimeOfDay.fromDateTime(DateTime.now());
  var selectedTripInfoToTime = TimeOfDay.fromDateTime(DateTime.now());
  var selectedFromTime = TimeOfDay.fromDateTime(DateTime.now());
  var selectedTripInfoFromTime = TimeOfDay.fromDateTime(DateTime.now());
  var fromTime = DateFormat("HH:mm:ss").format(DateTime.now());
  var fromTripInfoTime = DateFormat("HH:mm:ss").format(DateTime.now());
  var toTime = DateFormat("HH:mm:ss").format(DateTime.now());
  var toTripInfoTime = DateFormat("HH:mm:ss").format(DateTime.now());
  String distance_sum = "loading ..";
  String top_speed = "loading ..";
  String move_duration = "loading ..";
  String stop_duration = "loading ..";
  String fuel_consumption = "loading ..";
  String fuel_cost = "loading ..";

  bool isshowvehicledetail = false;
  @override
  initState() {
    // gethistory(StaticVarMethod.deviceId,StaticVarMethod.fromdate,StaticVarMethod.fromtime,StaticVarMethod.todate,StaticVarMethod.totime);

    getReport(
        StaticVarMethod.deviceId,
        StaticVarMethod.fromdate,
        StaticVarMethod.fromtime,
        StaticVarMethod.todate,
        StaticVarMethod.totime);
    super.initState();
  }


  Future<PositionHistory?> getReport(String deviceID, String fromDate,
      String fromTime, String toDate, String toTime) async {
    print("reports start");
    // final response = await http.get(Uri.parse(StaticVarMethod.baseurlall+"/api/get_history?lang=en&user_api_hash=${StaticVarMethod.user_api_hash}&from_date=$fromDate&from_time=$fromTime&to_date=$toDate&to_time=$toTime&device_id=$deviceID"));
    // print(response.request);
    final Uri apiUrl = Uri.parse(StaticVarMethod.baseurlall +
        "/api/get_history?lang=en&user_api_hash=${StaticVarMethod.user_api_hash}&from_date=" +
        StaticVarMethod.fromdate +
        "&from_time=" +
        StaticVarMethod.fromtime +
        "&to_date=" +
        StaticVarMethod.todate +
        "&to_time=" +
        StaticVarMethod.totime +
        "&device_id=" +
        StaticVarMethod.deviceId +
        "");
    final response = await http.get(apiUrl).timeout(const Duration(minutes: 5));
    print(response.request);
    if (response.statusCode == 200) {
      print(
          "dod${StaticVarMethod.baseurlall + "/api/get_history?lang=en&user_api_hash=${StaticVarMethod.user_api_hash}&from_date=$fromDate&from_time=$fromTime&to_date=$toDate&to_time=$toTime&device_id=$deviceID"}");
      var value = PositionHistory.fromJson(json.decode(response.body));

      if (value!.items?.length != 0) {

        isshowvehicledetail=true;
        if (mounted) {
          setState(() {
            top_speed = value.top_speed.toString();

            // if(top_speed != "null" || top_speed != "0" ){
            //   top_speed= (int.parse(value.top_speed.toString())/1.6093).toStringAsFixed(0);
            // }else{
            //   top_speed= "0";
            // }

            // top_speed=value.top_speed.toString();
            move_duration = value.move_duration.toString();
            stop_duration = value.stop_duration.toString();
            fuel_consumption = value.fuel_consumption.toString();
            distance_sum = value.distance_sum.toString();

            String aStr = distance_sum.replaceAll(new RegExp(r"[^0-9.]"),''); // '23'
            //aStr = a.replaceAll(new RegExp(r'[^0-9]'),''); // '23'

            double distance= double.parse(aStr);

            fuel_consumption=(distance/13).toStringAsFixed(2)+' lit';
            fuel_cost=((distance/13)*273).toStringAsFixed(2)+' Rupees';
            print(aStr);
           // alert(res); // 667000
          });
        }
        // drawPolyline();
      }else{

        print("No data found");

    Fluttertoast.showToast(
    msg: "No data found!!!",
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.CENTER,
    timeInSecForIosWeb: 2,
    backgroundColor: Colors.green,
    textColor: Colors.white,
    fontSize: 16.0);
      }
    } else {
      print("Error reports start");
      print(response.statusCode);
      return null;
    }
  }

  String start = "not valable";
  String end = "not valable";
  String distance = "not valable";
  String time = "not valable";
  String lat = "not valable";
  String lng = "not valable";
  String avgspeed = "not valable";

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('' + StaticVarMethod.deviceName,
            style: TextStyle(color: Colors.black)),
        iconTheme: IconThemeData(

           
          color: Colors.black, //change your color here
        ),
        actions: <Widget>[],
        backgroundColor: Colors.transparent,
      ),
      body: Stack(children: <Widget>[



        (isshowvehicledetail)?Container(
          margin: EdgeInsets.only(left: 10, right: 10, bottom: 0, top: 10),
          height: 320,
          width: 350,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(10)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 1.0,
                //offset: const Offset(2.0, 2.0),
              ),
            ],
          ),
          child: Column(
            //crossAxisAlignment: CrossAxisAlignment.stretch,
            //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                height: 10,
              ),
              Text('' + StaticVarMethod.deviceName,
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),

              Divider(
                color: Colors.grey[200],
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    //margin: EdgeInsets.fromLTRB(10, 10, 0, 5),
                    child: Row(
                      children: [
                        Image.asset(
                            "assets/speedoicon/calendar.png",
                            height: 15,
                            width: 15,color: Colors.grey[500]),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          'From : ',
                          style: TextStyle(
                              fontFamily: "Sofia",
                              fontWeight: FontWeight.normal,
                              fontSize: 12.0,
                              color: Colors.grey[500]),
                        ),
                        Text(
                          StaticVarMethod.fromdate,
                          style: TextStyle(
                              fontFamily: "Sofia",
                              fontWeight: FontWeight.bold,
                              fontSize: 12.0,
                              color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    //margin: EdgeInsets.fromLTRB(10, 10, 0, 5),
                    child: Row(
                      children: [
                        Image.asset(
                            "assets/speedoicon/calendar.png",
                            height: 15,
                            width: 15,color: Colors.grey[500]),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          'To : ',
                          style: TextStyle(
                              fontFamily: "Sofia",
                              fontWeight: FontWeight.normal,
                              fontSize: 12.0,
                              color: Colors.grey[500]),
                        ),
                        Text(
                          StaticVarMethod.todate,
                          style: TextStyle(
                              fontFamily: "Sofia",
                              fontWeight: FontWeight.bold,
                              fontSize: 12.0,
                              color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Divider(
                color: Colors.grey[200],
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                child: Row(
                  children: [
                    Image.asset(
                        "assets/speedoicon/calendar.png",
                        height: 15,
                        width: 15,color: Colors.grey[500]),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      'Distance : ',
                      style: TextStyle(
                          fontFamily: "Sofia",
                          fontWeight: FontWeight.normal,
                          fontSize: 12.0,
                          color: Colors.grey[500]),
                    ),
                    Text(
                      distance_sum ,
                      style: TextStyle(
                          fontFamily: "Sofia",
                          fontWeight: FontWeight.bold,
                          fontSize: 12.0,
                          color: Colors.black),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(10, 10, 0, 0),
                child: Row(
                  children: [
                    Image.asset(
                        "assets/speedoicon/gasoline-pump.png",
                        height: 15,
                        width: 15,color: Colors.grey[500]),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      'Fuel Used : ',
                      style: TextStyle(
                          fontFamily: "Sofia",
                          fontWeight: FontWeight.normal,
                          fontSize: 12.0,
                          color: Colors.grey[500]),
                    ),
                    Text(
                      fuel_consumption,
                      style: TextStyle(
                          fontFamily: "Sofia",
                          fontWeight: FontWeight.bold,
                          fontSize: 12.0,
                          color: Colors.black),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(10, 10, 0, 0),
                child: Row(
                  children: [
                    Image.asset(
                        "assets/speedoicon/gasoline-pump.png",
                        height: 15,
                        width: 15,color: Colors.grey[500]),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      'Fuel Cost : ',
                      style: TextStyle(
                          fontFamily: "Sofia",
                          fontWeight: FontWeight.normal,
                          fontSize: 12.0,
                          color: Colors.grey[500]),
                    ),
                    Text(
                      fuel_cost,
                      style: TextStyle(
                          fontFamily: "Sofia",
                          fontWeight: FontWeight.bold,
                          fontSize: 12.0,
                          color: Colors.black),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(10, 10, 0, 0),
                child: Row(
                  children: [
                    Image.asset(
                        "assets/speedoicon/price-up.png",
                        height: 15,
                        width: 15,color: Colors.grey[500]),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      'Fuel Price : ',
                      style: TextStyle(
                          fontFamily: "Sofia",
                          fontWeight: FontWeight.normal,
                          fontSize: 12.0,
                          color: Colors.grey[500]),
                    ),
                    Text(
                      '273 Rupees',
                      style: TextStyle(
                          fontFamily: "Sofia",
                          fontWeight: FontWeight.bold,
                          fontSize: 12.0,
                          color: Colors.black),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(10, 10, 0, 0),
                child: Row(
                  children: [
                    Image.asset(
                        "assets/speedoicon/high-speed.png",
                        height: 15,
                        width: 15,color: Colors.grey[500]),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      'Vehicle Average : ',
                      style: TextStyle(
                          fontFamily: "Sofia",
                          fontWeight: FontWeight.normal,
                          fontSize: 12.0,
                          color: Colors.grey[500]),
                    ),
                    Text(
                      '13.0 Km/l',
                      style: TextStyle(
                          fontFamily: "Sofia",
                          fontWeight: FontWeight.bold,
                          fontSize: 12.0,
                          color: Colors.black),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(10, 10, 0, 0),
                child: Row(
                  children: [
                    Image.asset(
                        "assets/speedoicon/refresh-page-option.png",
                        height: 15,
                        width: 15,color: Colors.grey[500]),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      'Move Duration : ',
                      style: TextStyle(
                          fontFamily: "Sofia",
                          fontWeight: FontWeight.normal,
                          fontSize: 12.0,
                          color: Colors.grey[500]),
                    ),
                    Text(
                      move_duration,
                      style: TextStyle(
                          fontFamily: "Sofia",
                          fontWeight: FontWeight.bold,
                          fontSize: 12.0,
                          color: Colors.black),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(10, 10, 0, 0),
                child: Row(
                  children: [
                    Image.asset(
                        "assets/speedoicon/stop-button.png",
                        height: 15,
                        width: 15,color: Colors.grey[500]),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      'Stop Duration : ',
                      style: TextStyle(
                          fontFamily: "Sofia",
                          fontWeight: FontWeight.normal,
                          fontSize: 12.0,
                          color: Colors.grey[500]),
                    ),
                    Text(
                      stop_duration,
                      style: TextStyle(
                          fontFamily: "Sofia",
                          fontWeight: FontWeight.bold,
                          fontSize: 12.0,
                          color: Colors.black),
                    ),
                  ],
                ),
              ),


            ],
          ),
        ):Center(child: CircularProgressIndicator(),)


      ]),
    );
  }




}

