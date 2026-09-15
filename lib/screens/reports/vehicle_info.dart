
import 'dart:convert';

import 'package:calendar_timeline/calendar_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:maktrogps/config/static.dart';
import 'package:maktrogps/data/model/PositionHistory.dart';
import 'package:maktrogps/data/model/history.dart';
import 'package:maktrogps/mapconfig/CommonMethod.dart';
import 'package:http/http.dart' as http;



class vehicle_info extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _vehicle_infoState();
}

class _vehicle_infoState extends State<vehicle_info> {



  DateTime _selectedFromDate = DateTime.now();
  DateTime _selectedToDate = DateTime.now();

  var selectedToTime =  TimeOfDay.fromDateTime(DateTime.now());
  var selectedTripInfoToTime =  TimeOfDay.fromDateTime(DateTime.now());
  var selectedFromTime =  TimeOfDay.fromDateTime(DateTime.now());
  var selectedTripInfoFromTime =  TimeOfDay.fromDateTime(DateTime.now());
  var fromTime=        DateFormat("HH:mm:ss").format(DateTime.now());
  var fromTripInfoTime=        DateFormat("HH:mm:ss").format(DateTime.now());
  var toTime=  DateFormat("HH:mm:ss").format(DateTime.now());
  var toTripInfoTime=  DateFormat("HH:mm:ss").format(DateTime.now());
  String distance_sum="Loading..";
  String top_speed="Loading..";
  String move_duration="Loading..";
  String stop_duration="Loading..";
  String fuel_consumption="Loading..";
  var startdate;
  var enddate;
  int _selectedperiod = 0;
  @override
  initState() {

    super.initState();

    showReport1(0, "Today");
  }


  @override
  void dispose() {

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(''+StaticVarMethod.deviceName,
            style: const TextStyle(color: Colors.black,fontSize: 15)),
        iconTheme: const IconThemeData(
          color: Colors.black, //change your color here
        ),
        actions: <Widget>[
          // action button

        ],
        backgroundColor: Colors.white,
      ),
      body: ListView(
          children: <Widget>[


        playBackControls(),
            _buildDatetimepicker(),
      ]),
    );
  }

  Widget playBackControls() {

    return Container(
      padding: const EdgeInsets.only(left: 10,right: 10,top: 30,bottom: 40),

      decoration: BoxDecoration(
          color: Colors.grey.shade200,
         /* borderRadius: BorderRadius.all(Radius.circular(20)),
          boxShadow: <BoxShadow>[
            BoxShadow(
                blurRadius: 20,
                offset: const Offset(0.0, 10.0)
               // color: Colors.grey.withOpacity(0.5)
            )
          ]*/),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[


          Container(
            //  margin: EdgeInsets.fromLTRB(80, 1, 80, 1),

            child: Row(
                children: [
                  Expanded(
                      child:Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 2,
                          color: Colors.white,
                          child: Container(
                              margin: const EdgeInsets.fromLTRB(6, 6, 6, 6),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  ClipRRect(
                                      borderRadius:
                                      const BorderRadius.all(Radius.circular(4)),
                                      child: Image.asset("assets/mapicon/route-start.png", height: 40,width: 40)),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          //margin: EdgeInsets.only(top: 5),
                                          child: Text('Route Start'.tr,
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                 // fontFamily: 'digital_font'

                                              )),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.only(top: 5),
                                          child: Text(''+startdate.toString(),
                                              style: const TextStyle(
                                                  fontSize: 12,

                                                  //fontWeight: FontWeight.bold,
                                                 // height: 1.7,
                                                  //fontFamily: 'digital_font'
                                              )),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              )
                          ))
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  Expanded(
                      child:Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 2,
                          color: Colors.white,
                          child: Container(
                              margin: const EdgeInsets.fromLTRB(6, 6, 6, 6),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  ClipRRect(
                                      borderRadius:
                                      const BorderRadius.all(Radius.circular(4)),
                                      child: Image.asset("assets/mapicon/route-end.png", height: 40,width: 40)),

                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          // margin: EdgeInsets.only(top: 5),
                                          child: Text('Route End'.tr,
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  //height: 0.8,
                                                 // fontFamily: 'digital_font'
                                                 fontWeight: FontWeight.bold
                                              )),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.only(top: 5),
                                          child: Text(''+enddate.toString(),
                                              style: const TextStyle(
                                                fontSize: 12,

                                                //fontWeight: FontWeight.bold,
                                                //height: 1.7,
                                                //fontFamily: 'digital_font'
                                              )),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              )
                          ))
                  ),
                ]
            ),
          ),

          Container(
          //  margin: EdgeInsets.fromLTRB(80, 1, 80, 1),

            child: Row(
                children: [
                  Expanded(
                      child:Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 2,
                          color: Colors.white,
                          child: Container(
                              margin: const EdgeInsets.fromLTRB(6, 6, 6, 6),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  ClipRRect(
                                      borderRadius:
                                      const BorderRadius.all(Radius.circular(4)),
                                      child: Image.asset("assets/mapicon/route-length.png", height: 40,width: 40)),
                                  const SizedBox(
                                    width: 15,
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(top: 5),
                                          child: Text('Route Length'.tr,
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  //fontFamily: 'digital_font'

                                              )),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.only(top: 5),
                                          child: Text(''+distance_sum,
                                              style: const TextStyle(
                                                fontSize: 12,

                                                //fontWeight: FontWeight.bold,
                                                // height: 1.7,
                                                //fontFamily: 'digital_font'
                                              )),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              )
                          ))
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  Expanded(
                      child:Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 2,
                          color: Colors.white,
                          child: Container(
                              margin: const EdgeInsets.fromLTRB(6, 6, 6, 6),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  ClipRRect(
                                      borderRadius:
                                      const BorderRadius.all(Radius.circular(4)),
                                      child: Image.asset("assets/images/icons8-clock-100.png", height: 40,width: 40)),
                                  const SizedBox(
                                    width: 2,
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          // margin: EdgeInsets.only(top: 5),
                                          child: Text('Top Speed'.tr,
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  //height: 0.8,
                                                 // fontFamily: 'digital_font'
                                                 fontWeight: FontWeight.bold
                                              )),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.only(top: 5),
                                          child: Text(''+top_speed,
                                              style: const TextStyle(
                                                fontSize: 12,

                                                //fontWeight: FontWeight.bold,
                                                // height: 1.7,
                                                //fontFamily: 'digital_font'
                                              )),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              )
                          ))
                  ),
                ]
            ),
          ),

          Container(
            //margin: EdgeInsets.fromLTRB(12, 6, 12, 6),

            child: Row(
                children: [
                  Expanded(
                      child:Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 2,
                          color: Colors.white,
                          child: Container(
                              margin: const EdgeInsets.fromLTRB(6, 6, 6, 6),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  ClipRRect(
                                      borderRadius:
                                      const BorderRadius.all(Radius.circular(4)),
                                      child: Image.asset("assets/images/movingdurationicon.png", height: 40,width: 40)),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(top: 5),
                                          child: Text('Move Time'.tr,
                                              style: const TextStyle(
                                                fontSize: 12,

                                                fontWeight: FontWeight.bold,
                                                //fontFamily: 'digital_font'

                                              )),
                                        ),
                                        Container(
                                          // margin: EdgeInsets.only(top: 5),
                                          child: Row(
                                            children: [
                                              /*Icon(Icons.location_on,
                                                      color: Colors.blue, size: 12),*/
                                              Text(''+move_duration,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    height: 1.8,
                                                    //color: Colors.blue
                                                    fontWeight: FontWeight.bold,
                                                  ))
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              )
                          ))
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  Expanded(
                      child:Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 2,
                          color: Colors.white,
                          child: Container(
                              margin: const EdgeInsets.fromLTRB(6, 6, 6, 6),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  ClipRRect(
                                      borderRadius:
                                      const BorderRadius.all(Radius.circular(4)),
                                      child: Image.asset("assets/images/stopdurationicon.png", height: 40,width: 40)),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          // margin: EdgeInsets.only(top: 5),
                                          child: Text('Stop Time'.tr,
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  //height: 0.8,
                                                  // fontFamily: 'digital_font'
                                                  fontWeight: FontWeight.bold
                                              )),
                                        ),
                                        Container(
                                          // margin: EdgeInsets.only(top: 5),
                                          child: Row(
                                            children: [
                                              /*Icon(Icons.location_on,
                                                      color: Colors.blue, size: 12),*/
                                              Text(''+stop_duration,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    height: 1.8,
                                                    //color: Colors.blue
                                                    //fontWeight: FontWeight.bold,
                                                  ))
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              )
                          ))
                  ),
                  // Expanded(
                  //     child:Card(
                  //         shape: RoundedRectangleBorder(
                  //           borderRadius: BorderRadius.circular(10),
                  //         ),
                  //         elevation: 2,
                  //         color: Colors.white,
                  //         child: Container(
                  //             margin: EdgeInsets.fromLTRB(12, 6, 12, 6),
                  //             child: Row(
                  //               mainAxisAlignment: MainAxisAlignment.start,
                  //               crossAxisAlignment: CrossAxisAlignment.start,
                  //               children: <Widget>[
                  //                 ClipRRect(
                  //                     borderRadius:
                  //                     BorderRadius.all(Radius.circular(4)),
                  //                     child: Image.asset("assets/images/speedometer1.png", height: 25,width: 25)),
                  //                 SizedBox(
                  //                   width: 10,
                  //                 ),
                  //                 Expanded(
                  //                   child: Column(
                  //                     crossAxisAlignment: CrossAxisAlignment.start,
                  //                     children: [
                  //                       /* Text(
                  //                         '_productData[index].name',
                  //                         style: TextStyle(
                  //                             fontSize: 13,
                  //                             color: Colors.blue
                  //                         ),
                  //                         maxLines: 3,
                  //                         overflow: TextOverflow.ellipsis,
                  //                       ),*/
                  //                       Container(
                  //                         margin: EdgeInsets.only(top: 5),
                  //                         child: Text(''+top_speed,
                  //                             style: TextStyle(
                  //                                 fontSize: 10,
                  //                                 fontWeight: FontWeight.bold,
                  //                                 fontFamily: 'digital_font'
                  //                             )),
                  //                       ),
                  //                       Container(
                  //                        // margin: EdgeInsets.only(top: 5),
                  //                         child: Row(
                  //                           children: [
                  //                             /*Icon(Icons.location_on,
                  //                                 color: Colors.blue, size: 12),*/
                  //                             Text('Top Speed',
                  //                                 style: TextStyle(
                  //                                     fontSize: 11,
                  //                                     //color: Colors.blue
                  //                                   fontWeight: FontWeight.bold,
                  //                                 ))
                  //                           ],
                  //                         ),
                  //                       ),
                  //                       /*  Container(
                  //                         margin: EdgeInsets.only(top: 5),
                  //                         child: Row(
                  //                           children: [
                  //                             // _globalWidget.createRatingBar(rating: _productData[index].rating!, size: 12),
                  //                             Text('(tests)', style: TextStyle(
                  //                                 fontSize: 11,
                  //                                 color: Colors.blue
                  //                             ))
                  //                           ],
                  //                         ),
                  //                       ),
                  //                       Container(
                  //                         margin: EdgeInsets.only(top: 5),
                  //                         child: Text(' '+'Sale',
                  //                             style: TextStyle(
                  //                                 fontSize: 11,
                  //                                 color: Colors.blue
                  //                             )),
                  //                       ),*/
                  //                     ],
                  //                   ),
                  //                 )
                  //               ],
                  //             ))
                  //     )
                  // )
                ]
            ),
          ),

          Container(
            //margin: EdgeInsets.fromLTRB(12, 6, 12, 6),

            child: Row(
                children: [
                  Expanded(
                      child:Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 2,
                          color: Colors.white,
                          child: Container(
                              margin: const EdgeInsets.fromLTRB(6, 6, 6, 6),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  const ClipRRect(
                                      borderRadius:
                                      BorderRadius.all(Radius.circular(4)),
                                     child: Icon(Icons.fire_truck,
                                         color: Colors.blue, size: 40),
                                     // child: Image.asset("assets/images/movingdurationicon.png", height: 40,width: 40)
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(top: 5),
                                          child: Text('Total Weight'.tr,
                                              style: const TextStyle(
                                                fontSize: 12,

                                                fontWeight: FontWeight.bold,
                                                //fontFamily: 'digital_font'

                                              )),
                                        ),
                                        Container(
                                          // margin: EdgeInsets.only(top: 5),
                                          child: Row(
                                            children: [
                                              /*Icon(Icons.location_on,
                                                      color: Colors.blue, size: 12),*/
                                              Text(''+StaticVarMethod.deviceweight,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    height: 1.8,
                                                    //color: Colors.blue
                                                    fontWeight: FontWeight.bold,
                                                  ))
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              )
                          ))
                  ),


                ]
            ),
          ),
          const Divider(
            height: 32,
            // color: Colors.grey[400],
          ),

          Container(
              margin: const EdgeInsets.only(top: 12),
                child: Text('Filter'.tr,
                    style: const TextStyle(color: Colors.black,fontSize: 15)),
          ),
          Container(
            margin: const EdgeInsets.only(top: 12),
            child: Row(
              children: [


                Expanded(
                    child: OutlinedButton(
                        onPressed: () {
                          distance_sum="Loading..";
                          top_speed="Loading..";
                          move_duration="Loading..";
                          stop_duration="Loading..";
                          fuel_consumption="Loading..";
                          setState(() {
                           // showReport();
                            _selectedperiod = 0;
                            showReport1(0, "Today");
                          });
                        },
                        style: ButtonStyle(
                            minimumSize: MaterialStateProperty.all(
                                const Size(0, 40)
                            ),
                            overlayColor: MaterialStateProperty.all(Colors.transparent),
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                )
                            ),
                            side: MaterialStateProperty.all(
                              const BorderSide(
                                  color: Colors.grey,
                                  width: 1.0
                              ),
                            )
                        ),
                        child: Text(
                          'Today'.tr,
                          style: const TextStyle(
                              color: Colors.grey,
                              //fontWeight: FontWeight.bold,
                              fontSize: 15
                          ),
                          textAlign: TextAlign.center,
                        )
                    )

                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                    child:OutlinedButton(
                        onPressed: () {
                           distance_sum="Loading..";
                           top_speed="Loading..";
                           move_duration="Loading..";
                           stop_duration="Loading..";
                           fuel_consumption="Loading..";
                          setState(() {
                            _selectedperiod = 1;
                            showReport1(1, "Yesterday");
                          });
                        },
                        style: ButtonStyle(
                            minimumSize: MaterialStateProperty.all(
                                const Size(0, 40)
                            ),
                            overlayColor: MaterialStateProperty.all(Colors.transparent),
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                )
                            ),
                            side: MaterialStateProperty.all(
                              const BorderSide(
                                  color: Colors.grey,
                                  width: 1.0
                              ),
                            )
                        ),
                        child: Text(
                          'Yesterday'.tr,
                          style: const TextStyle(
                              color: Colors.grey,
                              //fontWeight: FontWeight.bold,
                              fontSize: 15
                          ),
                          textAlign: TextAlign.center,
                        )
                    )
                ),
                const SizedBox(
                  width: 10,
                ),

              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 12),
            child: Row(
              children: [


                Expanded(
                    child: OutlinedButton(
                        onPressed: () {
                          distance_sum="Loading..";
                          top_speed="Loading..";
                          move_duration="Loading..";
                          stop_duration="Loading..";
                          fuel_consumption="Loading..";
                          setState(() {
                            // showReport();
                            _selectedperiod = 4;
                            showReport1(4, "Last 7 Days");
                          });
                        },
                        style: ButtonStyle(
                            minimumSize: MaterialStateProperty.all(
                                const Size(0, 40)
                            ),
                            overlayColor: MaterialStateProperty.all(Colors.transparent),
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                )
                            ),
                            side: MaterialStateProperty.all(
                              const BorderSide(
                                  color: Colors.grey,
                                  width: 1.0
                              ),
                            )
                        ),
                        child: Text(
                          'Last 7 Days'.tr,
                          style: const TextStyle(
                              color: Colors.grey,
                              //fontWeight: FontWeight.bold,
                              fontSize: 11
                          ),
                          textAlign: TextAlign.center,
                        )
                    )

                ),

              ],
            ),
          ),



          // CalendarTimeline(
          //   initialDate: DateTime.now(),
          //   firstDate: DateTime(2023, 10, 01),
          //   lastDate: DateTime(2025, 11, 20),
          //   onDateSelected: (date) {
          //
          //     distance_sum="Loading..";
          //     top_speed="Loading..";
          //     move_duration="Loading..";
          //     stop_duration="Loading..";
          //     fuel_consumption="Loading..";
          //     setState(() {
          //     });
          //     StaticVarMethod.fromdate = DateFormat('yyyy-MM-dd').format(date);
          //     StaticVarMethod.todate = DateFormat('yyyy-MM-dd').format(date);
          //
          //     //StaticVarMethod.todate = DateFormat('yyyy-MM-dd').format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day+1));
          //     // StaticVarMethod.fromtime =  DateFormat("HH:mm:ss").format(DateTime(DateTime.now().hour-14));
          //     StaticVarMethod.fromtime =  "12:01";
          //     StaticVarMethod.totime ="23:59";
          //     // StaticVarMethod.totime =  DateFormat("HH:mm:ss").format(DateTime(DateTime.now().hour+12));
          //
          //     //    DateFormat("HH:mm:ss").format(DateTime(DateTime.now().hour-8));
          //     //  StaticVarMethod.totime = toTime;
          //     print(date);
          //     print(date);
          //     print(date);
          //
          //     getReport1(StaticVarMethod.deviceId,StaticVarMethod.fromdate,StaticVarMethod.fromtime,StaticVarMethod.todate,StaticVarMethod.totime,"Custom");
          //
          //     // Navigator.push(
          //     //   context,
          //     //   MaterialPageRoute(
          //     //       builder: (context) => PlaybackPage()),
          //     // );
          //
          //   },
          //   leftMargin: 20,
          //   monthColor: Colors.blueGrey,
          //   dayColor: Colors.teal[200],
          //   activeDayColor: Colors.white,
          //   activeBackgroundDayColor: Colors.redAccent[100],
          //   dotsColor: Color(0xFF333A47),
          //   selectableDayPredicate: (date) => date.day != 23,
          //   locale: 'en_ISO',
          // ),
          // const Center(child: Text('Sensores', style: GlobalStyle.courierTitle)),
          // Divider(
          //   height: 32,
          //   // color: Colors.grey[400],
          // ),
          // Container(
          //   //margin: EdgeInsets.fromLTRB(12, 6, 12, 6),
          //
          //   child: Row(
          //       children: [
          //
          //
          //         Expanded(
          //             child:Card(
          //                 shape: RoundedRectangleBorder(
          //                   borderRadius: BorderRadius.circular(10),
          //                 ),
          //                 elevation: 2,
          //                 color: Colors.white,
          //                 child: Container(
          //                     margin: EdgeInsets.fromLTRB(12, 6, 12, 6),
          //                     child: Row(
          //                       mainAxisAlignment: MainAxisAlignment.start,
          //                       crossAxisAlignment: CrossAxisAlignment.start,
          //                       children: <Widget>[
          //                         ClipRRect(
          //                             borderRadius:
          //                             BorderRadius.all(Radius.circular(4)),
          //                             child: Image.asset("assets/images/routeicon.png", height: 50,width: 50)),
          //                         SizedBox(
          //                           width: 10,
          //                         ),
          //                         Expanded(
          //                           child: Column(
          //                             crossAxisAlignment: CrossAxisAlignment.start,
          //                             children: [
          //                                Text(
          //                                     '_productData[index].name',
          //                                     style: TextStyle(
          //                                         fontSize: 13,
          //                                         color: Colors.blue
          //                                     ),
          //                                     maxLines: 3,
          //                                     overflow: TextOverflow.ellipsis,
          //                                   ),
          //                               Container(
          //                                 margin: EdgeInsets.only(top: 5),
          //                                 child: Text('distance_sum',
          //                                     style: TextStyle(
          //                                         fontSize: 13,
          //                                         fontWeight: FontWeight.bold,
          //                                         fontFamily: 'digital_font'
          //                                     )),
          //                               ),
          //                                 Container(
          //                                     margin: EdgeInsets.only(top: 5),
          //                                     child: Row(
          //                                       children: [
          //                                         Icon(Icons.location_on,
          //                                             color: Colors.blue, size: 12),
          //                                         Text(' ',
          //                                             style: TextStyle(
          //                                                 fontSize: 11,
          //                                                 color: Colors.blue
          //                                             ))
          //                                       ],
          //                                     ),
          //                                   ),
          //                                   Container(
          //                                     margin: EdgeInsets.only(top: 5),
          //                                     child: Row(
          //                                       children: [
          //                                         // _globalWidget.createRatingBar(rating: _productData[index].rating!, size: 12),
          //                                         Text('(tests)', style: TextStyle(
          //                                             fontSize: 11,
          //                                             color: Colors.blue
          //                                         ))
          //                                       ],
          //                                     ),
          //                                   ),
          //                                   Container(
          //                                     margin: EdgeInsets.only(top: 5),
          //                                     child: Text(' '+'Sale',
          //                                         style: TextStyle(
          //                                             fontSize: 11,
          //                                             color: Colors.blue
          //                                         )),
          //                                   ),
          //                             ],
          //                           ),
          //                         )
          //                       ],
          //                     ))
          //             )
          //         ),
          //         SizedBox(
          //           width: 30,
          //         ),
          //         Expanded(
          //             child:Card(
          //                 shape: RoundedRectangleBorder(
          //                   borderRadius: BorderRadius.circular(10),
          //                 ),
          //                 elevation: 2,
          //                 color: Colors.white,
          //                 child: Container(
          //                     margin: EdgeInsets.fromLTRB(6, 6, 1, 6),
          //                     child: Row(
          //                       mainAxisAlignment: MainAxisAlignment.start,
          //                       crossAxisAlignment: CrossAxisAlignment.start,
          //                       children: <Widget>[
          //                         ClipRRect(
          //                             borderRadius:
          //                             BorderRadius.all(Radius.circular(4)),
          //                             child: Image.asset("assets/images/speedometer1.png", height: 50,width: 50)),
          //                         SizedBox(
          //                           width: 1,
          //                         ),
          //                         Expanded(
          //                           child: Column(
          //                             crossAxisAlignment: CrossAxisAlignment.start,
          //                             children: [
          //                                Text(
          //                                     '_productData[index].name',
          //                                     style: TextStyle(
          //                                         fontSize: 13,
          //                                         color: Colors.blue
          //                                     ),
          //                                     maxLines: 3,
          //                                     overflow: TextOverflow.ellipsis,
          //                                   ),
          //                               Container(
          //                                 margin: EdgeInsets.only(top: 5),
          //                                 child: Text('top_speed',
          //                                     style: TextStyle(
          //                                         fontSize: 10,
          //                                         fontWeight: FontWeight.bold,
          //                                         fontFamily: 'digital_font'
          //                                     )),
          //                               ),
          //                               Container(
          //                                 // margin: EdgeInsets.only(top: 5),
          //                                 child: Row(
          //                                   children: [
          //                                     Icon(Icons.location_on,
          //                                             color: Colors.blue, size: 12),
          //                                     Text('Top Speed',
          //                                         style: TextStyle(
          //                                           fontSize: 10,
          //                                           //color: Colors.blue
          //                                           fontWeight: FontWeight.bold,
          //                                         ))
          //                                   ],
          //                                 ),
          //                               ),
          //                                 Container(
          //                                     margin: EdgeInsets.only(top: 5),
          //                                     child: Row(
          //                                       children: [
          //                                         // _globalWidget.createRatingBar(rating: _productData[index].rating!, size: 12),
          //                                         Text('(tests)', style: TextStyle(
          //                                             fontSize: 11,
          //                                             color: Colors.blue
          //                                         ))
          //                                       ],
          //                                     ),
          //                                   ),
          //                                   Container(
          //                                     margin: EdgeInsets.only(top: 5),
          //                                     child: Text(' '+'Sale',
          //                                         style: TextStyle(
          //                                             fontSize: 11,
          //                                             color: Colors.blue
          //                                         )),
          //                                   ),
          //                             ],
          //                           ),
          //                         )
          //                       ],
          //                     ))
          //             )
          //         )
          //       ]
          //   ),
          // ),

        ],
      ),
    );
  }


  Widget _buildDatetimepicker(){
    double imageSize = MediaQuery.of(context).size.width/12;
    return Container(
      margin:const EdgeInsets.all(10) ,
      padding: const EdgeInsets.only(left: 15,right: 15,top: 10,bottom: 30),

      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          boxShadow: <BoxShadow>[
            BoxShadow(
                blurRadius: 20,
                offset: Offset.zero,
                color: Colors.grey.withOpacity(0.5))
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[


          Container(

            // margin: EdgeInsets.all(20),
              child: new Column(
                children: <Widget>[
                  Container(

                      margin: const EdgeInsets.all(20),
                      child:   Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          ElevatedButton(

                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueGrey.shade900,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                                textStyle: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                            //color: CustomColor.primaryColor,
                            onPressed: () => _selectFromDate(
                                context, setState),
                            child: Text(
                                formatReportDate(
                                    _selectedFromDate),
                                style: const TextStyle(
                                    color: Colors.white)),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueGrey.shade900,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                                textStyle: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                            // color: CustomColor.primaryColor,
                            onPressed: () {setState(() {
                              _fromTime(context);  });

                            },
                            /*style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              animationDuration: 3
                              ),*/
                            child: Text(
                                formatReportTime(
                                    selectedFromTime),
                                style: const TextStyle(
                                  //backgroundColor: Colors.blue,
                                    color: Colors.white)),
                          ),
                        ],
                      )
                  ),
                  Container(

                      margin: const EdgeInsets.only(left: 20,right: 20),
                      child: Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueGrey.shade900,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                                textStyle: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                            //color: CustomColor.primaryColor,
                            onPressed: () =>
                                _selectToDate(context, setState),
                            child: Text(
                                formatReportDate(_selectedToDate),
                                style: const TextStyle(
                                    color: Colors.white)),
                          ),
                          ElevatedButton(

                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueGrey.shade900,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                                textStyle: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                            // color: CustomColor.primaryColor,
                            onPressed: () {setState(() {
                              _toTime(context);  });

                            },
                            child: Text(
                                formatReportTime(selectedToTime),
                                style: const TextStyle(
                                    color: Colors.white)),
                          ),
                        ],
                      )
                  ),
                ],
              )),
          Container(
            margin: const EdgeInsets.all(20),
            //alignment: Alignment.center,
            child:   ElevatedButton(

                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey.shade900,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                onPressed: () {
                  distance_sum="Loading..";
                  top_speed="Loading..";
                  move_duration="Loading..";
                  stop_duration="Loading..";
                  fuel_consumption="Loading..";
                  setState(() {
                    // showReport();
                    _selectedperiod = 8;
                    showReport1(8, "All");
                  });
                  // Fluttertoast.showToast(msg: 'Press Outline Button', toastLength: Toast.LENGTH_SHORT);
                },
                child: Row(
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    children: <Widget>[
                      const Icon(
                        Icons.file_copy_outlined,
                        size: 24.0,color: Colors.grey,
                      ),
                      Text("View Detail".tr ,
                          style: const TextStyle(
                              color: Colors.white)),
                    ]
                )/**/

            ),
          ),

        ],
      ),
    );
  }

  //date time picker
  Future<void> _selectFromDate(
      BuildContext context, StateSetter setState) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _selectedFromDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != _selectedFromDate)
      setState(() {
        _selectedFromDate = picked;
      });
  }

  Future<void> _selectToDate(BuildContext context, StateSetter setState) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _selectedToDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != _selectedToDate)
      setState(() {
        _selectedToDate = picked;
      });
  }

  Future<Null> _fromTime(BuildContext context) async {
    var picked = await showTimePicker(
      context: context,
      initialTime:selectedFromTime,

    );
    if (picked != null && picked != selectedFromTime)
      setState(() {
        selectedFromTime = picked;
        var hour= selectedFromTime.hour;
        var minute= selectedFromTime.minute;
        fromTime ="$hour:$minute:00";
        print(fromTime);
        //var formattedDate = "${picked.year}-${picked.month}-${picked.day}";
      });
  }

  Future<Null> _toTime(BuildContext context) async {
    var picked = await showTimePicker(
      context: context,
      initialTime:selectedToTime,

    );
    if (picked != null && picked != selectedToTime)
      setState(() {
        selectedToTime = picked;
        var hour= selectedToTime.hour;
        var minute= selectedToTime.minute;
        toTime ="$hour:$minute:00";
        //  TimeOfDayFormat.H_colon_mm.toString();
        //var formattedDate = "${picked.year}-${picked.month}-${picked.day}";
      });
  }
  void showReport1(int _selectedperiod,String currentday) {


    if (_selectedperiod == 0) {


      StaticVarMethod.fromdate = formatDateReport(DateFormat('yyyy-MM-dd').format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)));
      StaticVarMethod.todate = formatDateReport(DateFormat('yyyy-MM-dd').format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)));
      StaticVarMethod.fromtime =  "00:00";
      StaticVarMethod.totime =  "11:59";
    }
    else if (_selectedperiod == 1) {


      StaticVarMethod.fromdate = formatDateReport(DateFormat('yyyy-MM-dd').format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day-1)));
      StaticVarMethod.todate = formatDateReport(DateFormat('yyyy-MM-dd').format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)));
      StaticVarMethod.fromtime =  "00:00";
      StaticVarMethod.totime =  "11:59";
    } else if (_selectedperiod == 2) {

      StaticVarMethod.fromdate = formatDateReport(DateFormat('yyyy-MM-dd').format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day -1)));
      StaticVarMethod.todate = formatDateReport(DateFormat('yyyy-MM-dd').format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)));
      StaticVarMethod.fromtime =  "00:00";
      StaticVarMethod.totime =  "11:59";
    } else if (_selectedperiod == 3) {

      StaticVarMethod.fromdate = formatDateReport(DateFormat('yyyy-MM-dd').format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day -2)));
      StaticVarMethod.todate = formatDateReport(DateFormat('yyyy-MM-dd').format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)));
      StaticVarMethod.fromtime =  "00:00";
      StaticVarMethod.totime =  "23:59";
    }
    else if (_selectedperiod == 4) {

      StaticVarMethod.fromdate = formatDateReport(DateFormat('yyyy-MM-dd').format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day -7)));
      StaticVarMethod.todate = formatDateReport(DateFormat('yyyy-MM-dd').format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)));
      StaticVarMethod.fromtime =  "00:00";
      StaticVarMethod.totime =  "23:59";
    }
    else {

      String fromDate = formatDateReport(_selectedFromDate.toString());
      String  toDate = formatDateReport(_selectedToDate.toString());
      // String fromTime = selectedFromTime.toString();
      // String toTime = selectedToTime.toString();

      StaticVarMethod.fromdate = fromDate;
      StaticVarMethod.todate = toDate;
      //StaticVarMethod.fromtime =  "00:00";
      //StaticVarMethod.totime =  "11:59";
      StaticVarMethod.fromtime = fromTime;
      StaticVarMethod.totime = toTime;
      // StaticVarMethod.fromdate = formatDateReport(_selectedFromDate.toString());
      // StaticVarMethod.todate = formatDateReport(_selectedToDate.toString());
      // StaticVarMethod.fromtime = formatTimeReport(selectedFromTime.toString());
      // StaticVarMethod.totime = formatTimeReport(selectedToTime.toString());
    }



    getReport1(StaticVarMethod.deviceId,StaticVarMethod.fromdate,StaticVarMethod.fromtime,StaticVarMethod.todate,StaticVarMethod.totime,currentday);


  }

  // void showReport1(int _selectedperiod,String currentday) {
  //   String fromDate;
  //   String toDate;
  //   String fromTime;
  //   String toTime;
  //
  //   DateTime current = DateTime.now();
  //
  //   String month;
  //   String day;
  //   if (current.month < 10) {
  //     month = "0" + current.month.toString();
  //   } else {
  //     month = current.month.toString();
  //   }
  //
  //   if (current.day < 10) {
  //     day = "0" + current.day.toString();
  //   } else {
  //     day = current.day.toString();
  //   }
  //
  //   if (_selectedperiod == 0) {
  //     String today;
  //
  //     int dayCon = current.day + 1;
  //     if (dayCon <= 10) {
  //       today = "0" + dayCon.toString();
  //     } else {
  //       today = dayCon.toString();
  //     }
  //
  //     var date = DateTime.parse("${current.year}-"
  //         "$month-"
  //         "$today "
  //         "00:00:00");
  //     fromDate = formatDateReport(DateTime.now().toString());
  //     toDate = formatDateReport(date.toString());
  //     fromTime = "00:00:00";
  //     toTime = "00:00:00";
  //
  //     StaticVarMethod.fromdate = formatDateReport(DateTime.now().toString());
  //     StaticVarMethod.todate = formatDateReport(date.toString());
  //     StaticVarMethod.fromtime =  "00:00";
  //     StaticVarMethod.totime =  "00:00";
  //   } else if (_selectedperiod == 1) {
  //     String yesterday;
  //
  //     int dayCon = current.day - 1;
  //     if (current.day <= 10) {
  //       yesterday = "0" + dayCon.toString();
  //     } else {
  //       yesterday = dayCon.toString();
  //     }
  //
  //     var start = DateTime.parse("${current.year}-"
  //         "$month-"
  //         "$yesterday "
  //         "00:00:00");
  //
  //     var end = DateTime.parse("${current.year}-"
  //         "$month-"
  //         "$yesterday "
  //         "24:00:00");
  //
  //     fromDate = formatDateReport(start.toString());
  //     toDate = formatDateReport(end.toString());
  //     fromTime = "00:00:00";
  //     toTime = "00:00:00";
  //     StaticVarMethod.fromdate = formatDateReport(start.toString());
  //     StaticVarMethod.todate = formatDateReport(end.toString());
  //     StaticVarMethod.fromtime =  "00:00";
  //     StaticVarMethod.totime =  "00:00";
  //   } else if (_selectedperiod == 2) {
  //     String yesterday;
  //
  //     int dayCon = current.day - 2;
  //     if (current.day <= 10) {
  //       yesterday = "0" + dayCon.toString();
  //     } else {
  //       yesterday = dayCon.toString();
  //     }
  //
  //     var start = DateTime.parse("${current.year}-"
  //         "$month-"
  //         "$yesterday "
  //         "00:00:00");
  //
  //     var end = DateTime.parse("${current.year}-"
  //         "$month-"
  //         "$yesterday "
  //         "24:00:00");
  //
  //     fromDate = formatDateReport(start.toString());
  //     toDate = formatDateReport(end.toString());
  //     fromTime = "00:00:00";
  //     toTime = "00:00:00";
  //     StaticVarMethod.fromdate = formatDateReport(start.toString());
  //     StaticVarMethod.todate = formatDateReport(end.toString());
  //     StaticVarMethod.fromtime =  "00:00";
  //     StaticVarMethod.totime =  "00:00";
  //   }
  //   else if (_selectedperiod == 3) {
  //     String yesterday;
  //
  //     int dayCon = current.day - 3;
  //     if (current.day <= 10) {
  //       yesterday = "0" + dayCon.toString();
  //     } else {
  //       yesterday = dayCon.toString();
  //     }
  //
  //     var start = DateTime.parse("${current.year}-"
  //         "$month-"
  //         "$yesterday "
  //         "00:00:00");
  //
  //     var end = DateTime.parse("${current.year}-"
  //         "$month-"
  //         "$yesterday "
  //         "24:00:00");
  //
  //     fromDate = formatDateReport(start.toString());
  //     toDate = formatDateReport(end.toString());
  //     fromTime = "00:00:00";
  //     toTime = "00:00:00";
  //     StaticVarMethod.fromdate = formatDateReport(start.toString());
  //     StaticVarMethod.todate = formatDateReport(end.toString());
  //     StaticVarMethod.fromtime =  "00:00";
  //     StaticVarMethod.totime =  "00:00";
  //   }
  //   else if (_selectedperiod == 4) {
  //     String sevenDay, currentDayString;
  //     int dayCon = current.day - current.weekday;
  //     int currentDay = current.day;
  //     if (dayCon < 10) {
  //       sevenDay = "0" + dayCon.abs().toString();
  //     } else {
  //       sevenDay = dayCon.toString();
  //     }
  //     if (currentDay < 10) {
  //       currentDayString = "0" + currentDay.toString();
  //     } else {
  //       currentDayString = currentDay.toString();
  //     }
  //
  //     var start = DateTime.parse("${current.year}-"
  //         "$month-"
  //         "$sevenDay "
  //         "00:00:00");
  //
  //     var end = DateTime.parse("${current.year}-"
  //         "$month-"
  //         "$currentDayString "
  //         "24:00:00");
  //
  //     fromDate = formatDateReport(start.toString());
  //     toDate = formatDateReport(end.toString());
  //     fromTime = "00:00:00";
  //     toTime = "00:00:00";
  //     StaticVarMethod.fromdate = formatDateReport(start.toString());
  //     StaticVarMethod.todate = formatDateReport(end.toString());
  //     StaticVarMethod.fromtime =  "00:00";
  //     StaticVarMethod.totime =  "00:00";
  //   } else {
  //     String startMonth, endMoth;
  //     if (_selectedFromDate.month < 10) {
  //       startMonth = "0" + _selectedFromDate.month.toString();
  //     } else {
  //       startMonth = _selectedFromDate.month.toString();
  //     }
  //
  //     if (_selectedToDate.month < 10) {
  //       endMoth = "0" + _selectedToDate.month.toString();
  //     } else {
  //       endMoth = _selectedToDate.month.toString();
  //     }
  //
  //     String startHour, endHour;
  //     if (selectedFromTime.hour < 10) {
  //       startHour = "0" + selectedFromTime.hour.toString();
  //     } else {
  //       startHour = selectedFromTime.hour.toString();
  //     }
  //
  //     String startMin, endMin;
  //     if (selectedFromTime.minute < 10) {
  //       startMin = "0" + selectedFromTime.minute.toString();
  //     } else {
  //       startMin = selectedFromTime.minute.toString();
  //     }
  //
  //     if (selectedToTime.minute < 10) {
  //       endMin = "0" + selectedToTime.minute.toString();
  //     } else {
  //       endMin = selectedToTime.minute.toString();
  //     }
  //
  //     if (selectedToTime.hour < 10) {
  //       endHour = "0" + selectedToTime.hour.toString();
  //     } else {
  //       endHour = selectedToTime.hour.toString();
  //     }
  //
  //     String startDay, endDay;
  //     if (_selectedFromDate.day <= 10) {
  //       if (_selectedFromDate.day == 10) {
  //         startDay = _selectedFromDate.day.toString();
  //       } else {
  //         startDay = "0" + _selectedFromDate.day.toString();
  //       }
  //     } else {
  //       startDay = _selectedFromDate.day.toString();
  //     }
  //
  //     if (_selectedToDate.day <= 10) {
  //       if (_selectedToDate.day == 10) {
  //         endDay = _selectedToDate.day.toString();
  //       } else {
  //         endDay = "0" + _selectedToDate.day.toString();
  //       }
  //     } else {
  //       endDay = _selectedToDate.day.toString();
  //     }
  //
  //     var start = DateTime.parse("${_selectedFromDate.year}-"
  //         "$startMonth-"
  //         "$startDay "
  //         "$startHour:"
  //         "$startMin:"
  //         "00");
  //
  //     var end = DateTime.parse("${_selectedToDate.year}-"
  //         "$endMoth-"
  //         "$endDay "
  //         "$endHour:"
  //         "$endMin:"
  //         "00");
  //
  //     fromDate = formatDateReport(start.toString());
  //     toDate = formatDateReport(end.toString());
  //     fromTime = formatTimeReport(start.toString());
  //     toTime = formatTimeReport(end.toString());
  //
  //     StaticVarMethod.fromdate = formatDateReport(start.toString());
  //     StaticVarMethod.todate = formatDateReport(end.toString());
  //     StaticVarMethod.fromtime = formatTimeReport(start.toString());
  //     StaticVarMethod.totime = formatTimeReport(end.toString());
  //   }
  //
  //   print(fromDate);
  //   print(toDate);
  //
  //   // Navigator.pop(context);
  //
  //   getReport1(StaticVarMethod.deviceId,StaticVarMethod.fromdate,StaticVarMethod.fromtime,StaticVarMethod.todate,StaticVarMethod.totime,currentday);
  //   /* Navigator.pushNamed(context, "/reportList",
  //       arguments: ReportArguments(device['id'], fromDate, fromTime,
  //           toDate, toTime, device["name"], 0));*/
  //
  // }


  Future<void> getHistory(String deviceID, String fromDate,
      String fromTime, String toDate, String toTime, String currentday) async {
    final response = await http.get(Uri.parse(StaticVarMethod.baseurlall+"/api/get_history?lang=en&user_api_hash=${StaticVarMethod.user_api_hash}&from_date=$fromDate&from_time=$fromTime&to_date=$toDate&to_time=$toTime&device_id=$deviceID"));
    if (response.statusCode == 200) {
      try {
        List<AllItems> list = [];
        var history = History.fromJson(json.decode(response.body));
        for (var i = 0; i < history.items!.length; i++) {
          for (var p in history.items![i].items ?? []) {
            list.add(p);
          }
        }
      } catch (Ex) {
        print(Ex);
        print("Error occurred");
        //History model = new  History();
       // return model;
      }
    } else {
      print(response.statusCode);
      /* List<History> list=[];
      return list;*/
      //History model = new  History();
      //return model;
    }
  }
  Future<PositionHistory?> getReport1(String deviceID, String fromDate,
      String fromTime, String toDate, String toTime, String currentday ) async {
    final response = await http.get(Uri.parse(StaticVarMethod.baseurlall+"/api/get_history?lang=en&user_api_hash=${StaticVarMethod.user_api_hash}&from_date=$fromDate&from_time=$fromTime&to_date=$toDate&to_time=$toTime&device_id=$deviceID"));
    print(response.request);
    if (response.statusCode == 200) {
      print(
          "dod${StaticVarMethod.baseurlall+"/api/get_history?lang=en&user_api_hash=${StaticVarMethod.user_api_hash}&from_date=$fromDate&from_time=$fromTime&to_date=$toDate&to_time=$toTime&device_id=$deviceID"}");
      var value= PositionHistory.fromJson(json.decode(response.body));
      if (value!.items?.length != 0)
      {
        /* value.items?.forEach((element) {
          var startdate= element['show'];
          var enddate= element['show'];
          element['items'].forEach((element) {
            element['show'].last;
            element['show'].last;
          });
        });*/

          startdate= value.items!.first;
          enddate= value.items!.last;

         startdate=startdate['show'];
         enddate=enddate['show'];




        setState(() {
          top_speed=value.top_speed.toString();
          move_duration=value.move_duration.toString();
          stop_duration=value.stop_duration.toString();
          fuel_consumption=value.fuel_consumption.toString();
          distance_sum=value.distance_sum.toString();

        });


      }
      else
      {
        // _timer.cancel(),
        /*   AlertDialogCustom().showAlertDialog(
            context,
            'NoData',
            'Failed',
            'Ok');*/
      }
    } else {
      print(response.statusCode);
      return null;
    }
  }

}
