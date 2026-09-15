
import 'dart:async';
import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:maktrogps/config/static.dart';

import 'package:maktrogps/mapconfig/CommonMethod.dart';

import 'package:maktrogps/data/gpsserver/datasources.dart';

import 'package:http/http.dart' as http;

import '../../config/global_style.dart';
import '../../data/model/PositionHistory.dart';

class kmdetail_tanzim extends StatefulWidget {
  @override
  _kmdetailState createState() => _kmdetailState();
}

class _kmdetailState extends State<kmdetail_tanzim> {
  // initialize reusable widget
  // final _reusableWidget = ReusableWidget();


  int _selectedperiod = 0;

  String _selectedReport = "";

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

  Timer? _timerDummy;

  String today="Searching....";
  String yesterday="Searching....";
  String last7day="Searching....";
  String thismonth="Searching....";
  String allkmdetail="View KM";

  bool _loading = true;

  @override
  void initState() {
    super.initState();


    showReport1(1, "Today");
    //showReport1(1, "yesterday");
    //showReport1(2, "2 day ago");
    // showReport1(3, "3 day ago");
    _timerDummy = Timer(const Duration(seconds: 2), () => showReport1(2,"yesterday"));
    _timerDummy = Timer(const Duration(seconds: 4), () => showReport1(3,"2 day ago"));
   // _timerDummy = Timer(Duration(seconds: 6), () => showReport1(4,"3 day ago"));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        elevation: 0,
        iconTheme: const IconThemeData(
          color: GlobalStyle.appBarIconThemeColor,
        ),
        systemOverlayStyle: GlobalStyle.appBarSystemOverlayStyle,
        centerTitle: true,
        title: const Text('Mileage Info options', style: GlobalStyle.appBarTitle),
        backgroundColor: GlobalStyle.appBarBackgroundColor,
        //bottom: _reusableWidget.bottomAppBar(),
      ),
      body: ListView(
        children: [
          _buildimeiInformation(),
          _summarydetail(),
          _buildDatetimepicker(),

          // _reusableWidget.divider1(),
          //_reusableWidget.deliveryInformation(),
          //_reusableWidget.divider1(),
          //_buildOrderSummary(),
          // _reusableWidget.divider1(),
          //_buildTotalSummary(),
        ],
      ),
    );
  }

  Widget _buildimeiInformation(){
    return Container(
      color: Colors.grey[100],
      padding: const EdgeInsets.all(16),
      margin:const EdgeInsets.only(left: 10,right: 10),
      child: Center(

          child: Text(''+StaticVarMethod.deviceName, style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 14
          ))

      ),
    );
  }

  Widget _summarydetail() {


    return Column(
      children: [
        Container(
          height: 50,
          decoration: const BoxDecoration(
              color: Colors.white
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [

              const Text("TODAY:",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black,fontSize: 18),),
              Text(today,style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.black,fontSize: 18),),


            ],
          ),
        ),
        const SizedBox(height: 10,),
        Container(
          height: 50,
          decoration: const BoxDecoration(
              color: Colors.white
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [

              const Text("YESTERDAY:",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black,fontSize: 18),),
              Text(yesterday,style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.black,fontSize: 18),),


            ],
          ),
        ),
        const SizedBox(height: 10,),
        Container(
          height: 50,
          decoration: const BoxDecoration(
              color: Colors.white
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [

              const Text("LAST 7 DAY:",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black,fontSize: 18),),
              Text(last7day,style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.black,fontSize: 18),),


            ],
          ),
        ),
        const SizedBox(height: 10,),
        // Container(
        //   height: 50,
        //   decoration: BoxDecoration(
        //       color: Colors.white
        //   ),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //     children: [
        //
        //       Text("THIS WEEK:",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black,fontSize: 18),),
        //       Text(thismonth,style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black,fontSize: 18),),
        //
        //
        //     ],
        //   ),
        // )
      ],
    );

    // return Container(
    //   padding: EdgeInsets.only(left: 10,right: 10,top: 0,bottom: 40),
    //
    //   decoration: BoxDecoration(
    //     color: Colors.grey.shade100,
    //     /* borderRadius: BorderRadius.all(Radius.circular(20)),
    //       boxShadow: <BoxShadow>[
    //         BoxShadow(
    //             blurRadius: 20,
    //             offset: const Offset(0.0, 10.0)
    //            // color: Colors.grey.withOpacity(0.5)
    //         )
    //       ]*/),
    //   child: Column(
    //     crossAxisAlignment: CrossAxisAlignment.start,
    //     mainAxisAlignment: MainAxisAlignment.start,
    //     children: <Widget>[
    //
    //
    //
    //
    //       Center(
    //         child: Container(
    //           height: 50,
    //           decoration: BoxDecoration(
    //             color: Colors.white
    //           ),
    //           child: Padding(
    //             padding: const EdgeInsets.all(8.0),
    //             child: Row(
    //               crossAxisAlignment: CrossAxisAlignment.start,
    //
    //               children: [
    //                 Container(
    //                   //margin: EdgeInsets.only(top: 5),
    //                   child: Text(today,
    //                       style: TextStyle(
    //                         fontSize: 12,
    //                         fontWeight: FontWeight.bold,
    //                         // fontFamily: 'digital_font'
    //
    //                       )),
    //                 ),
    //                 Text("Today",
    //                     style: TextStyle(
    //                       fontSize: 12,
    //
    //                       //fontWeight: FontWeight.bold,
    //                       // height: 1.7,
    //                       //fontFamily: 'digital_font'
    //                     )),
    //
    //               ],
    //             ),
    //           ),
    //         ),
    //       ),
    //
    //
    //       Container(
    //         margin: EdgeInsets.fromLTRB(1, 12, 1, 1),
    //         child: Row(
    //             children: [
    //               Expanded(
    //                   child:Card(
    //                       shape: RoundedRectangleBorder(
    //                         borderRadius: BorderRadius.circular(20),
    //                       ),
    //                       elevation: 5,
    //                       color: Colors.white,
    //                       child: Container(
    //                         //margin: EdgeInsets.fromLTRB(6, 6, 6, 6),
    //                           margin: EdgeInsets.all(10),
    //                           child: Row(
    //                             mainAxisAlignment: MainAxisAlignment.start,
    //                             crossAxisAlignment: CrossAxisAlignment.start,
    //                             children: <Widget>[
    //
    //
    //                               Expanded(
    //                                 child: Column(
    //                                   crossAxisAlignment: CrossAxisAlignment.start,
    //                                   children: [
    //                                     Container(
    //                                       //margin: EdgeInsets.only(top: 5),
    //                                       child: Text(today,
    //                                           style: TextStyle(
    //                                             fontSize: 12,
    //                                             fontWeight: FontWeight.bold,
    //                                             // fontFamily: 'digital_font'
    //
    //                                           )),
    //                                     ),
    //                                     Container(
    //                                       margin: EdgeInsets.only(top: 5),
    //                                       child: Text("Today",
    //                                           style: TextStyle(
    //                                             fontSize: 12,
    //
    //                                             //fontWeight: FontWeight.bold,
    //                                             // height: 1.7,
    //                                             //fontFamily: 'digital_font'
    //                                           )),
    //                                     ),
    //                                   ],
    //                                 ),
    //                               ),
    //                               SizedBox(
    //                                 width: 5,
    //                               ),
    //                               ClipRRect(
    //                                   borderRadius:
    //                                   BorderRadius.all(Radius.circular(4)),
    //                                   child: Image.asset("assets/nepalicon/route_.png", height: 25,width: 25)),
    //                             ],
    //                           )
    //                       ))
    //               ),
    //               SizedBox(
    //                 width: 30,
    //               ),
    //               Expanded(
    //                   child:Card(
    //                       shape: RoundedRectangleBorder(
    //                         borderRadius: BorderRadius.circular(20),
    //                       ),
    //                       elevation: 5,
    //                       color: Colors.white,
    //                       child: Container(
    //                           margin: EdgeInsets.all(10),
    //                           // margin: EdgeInsets.fromLTRB(6, 6, 6, 6),
    //                           child: Row(
    //                             mainAxisAlignment: MainAxisAlignment.start,
    //                             crossAxisAlignment: CrossAxisAlignment.start,
    //                             children: <Widget>[
    //
    //
    //
    //                               Expanded(
    //                                 child: Column(
    //                                   crossAxisAlignment: CrossAxisAlignment.start,
    //                                   children: [
    //                                     Container(
    //                                       // margin: EdgeInsets.only(top: 5),
    //                                       child: Text(yesterday,
    //                                           style: TextStyle(
    //                                               fontSize: 12,
    //                                               //height: 0.8,
    //                                               // fontFamily: 'digital_font'
    //                                               fontWeight: FontWeight.bold
    //                                           )),
    //                                     ),
    //                                     Container(
    //                                       margin: EdgeInsets.only(top: 5),
    //                                       child: Text('Yesterday',
    //                                           style: TextStyle(
    //                                             fontSize: 12,
    //
    //                                             //fontWeight: FontWeight.bold,
    //                                             //height: 1.7,
    //                                             //fontFamily: 'digital_font'
    //                                           )),
    //                                     ),
    //                                   ],
    //                                 ),
    //                               ),
    //                               SizedBox(
    //                                 width: 10,
    //                               ),
    //                               ClipRRect(
    //                                   borderRadius:
    //                                   BorderRadius.all(Radius.circular(4)),
    //                                   child: Image.asset("assets/nepalicon/route_.png", height: 25,width: 25)),
    //                             ],
    //                           )
    //                       ))
    //               ),
    //             ]
    //         ),
    //       ),
    //
    //       Container(
    //         margin: EdgeInsets.fromLTRB(1, 12, 1, 1),
    //         child: Row(
    //             children: [
    //               Expanded(
    //                   child:Card(
    //                       shape: RoundedRectangleBorder(
    //                         borderRadius: BorderRadius.circular(20),
    //                       ),
    //                       elevation: 5,
    //                       color: Colors.white,
    //                       child: Container(
    //                         // margin: EdgeInsets.fromLTRB(6, 6, 6, 6),
    //                           margin: EdgeInsets.all(10),
    //                           child: Row(
    //                             mainAxisAlignment: MainAxisAlignment.start,
    //                             crossAxisAlignment: CrossAxisAlignment.start,
    //                             children: <Widget>[
    //
    //
    //                               Expanded(
    //                                 child: Column(
    //                                   crossAxisAlignment: CrossAxisAlignment.start,
    //                                   children: [
    //                                     Container(
    //                                       margin: EdgeInsets.only(top: 5),
    //                                       child: Text(last7day,
    //                                           style: TextStyle(
    //                                             fontSize: 12,
    //                                             fontWeight: FontWeight.bold,
    //                                             //fontFamily: 'digital_font'
    //
    //                                           )),
    //                                     ),
    //                                     Container(
    //                                       margin: EdgeInsets.only(top: 5),
    //                                       child: Text('Last 7 Day',
    //                                           style: TextStyle(
    //                                             fontSize: 12,
    //
    //                                             //fontWeight: FontWeight.bold,
    //                                             // height: 1.7,
    //                                             //fontFamily: 'digital_font'
    //                                           )),
    //                                     ),
    //                                   ],
    //                                 ),
    //                               ),
    //                               SizedBox(
    //                                 width: 15,
    //                               ),
    //                               ClipRRect(
    //                                   borderRadius:
    //                                   BorderRadius.all(Radius.circular(4)),
    //                                   child: Image.asset("assets/nepalicon/route_.png", height: 25,width: 25)
    //                               ),
    //                             ],
    //                           )
    //                       ))
    //               ),
    //               SizedBox(
    //                 width: 30,
    //               ),
    //               Expanded(
    //                   child:Card(
    //                       shape: RoundedRectangleBorder(
    //                         borderRadius: BorderRadius.circular(20),
    //                       ),
    //                       elevation: 5,
    //                       color: Colors.white,
    //                       child: Container(
    //                         //margin: EdgeInsets.fromLTRB(6, 6, 6, 6),
    //                           margin: EdgeInsets.all(10),
    //                           child: Row(
    //                             mainAxisAlignment: MainAxisAlignment.start,
    //                             crossAxisAlignment: CrossAxisAlignment.start,
    //                             children: <Widget>[
    //
    //                               Expanded(
    //                                 child: Column(
    //                                   crossAxisAlignment: CrossAxisAlignment.start,
    //                                   children: [
    //                                     Container(
    //                                       // margin: EdgeInsets.only(top: 5),
    //                                       child: Text(thismonth,
    //                                           style: TextStyle(
    //                                               fontSize: 12,
    //                                               //height: 0.8,
    //                                               // fontFamily: 'digital_font'
    //                                               fontWeight: FontWeight.bold
    //                                           )),
    //                                     ),
    //                                     Container(
    //                                       margin: EdgeInsets.only(top: 5),
    //                                       child: Text('This Month',
    //                                           style: TextStyle(
    //                                             fontSize: 12,
    //
    //                                             //fontWeight: FontWeight.bold,
    //                                             // height: 1.7,
    //                                             //fontFamily: 'digital_font'
    //                                           )),
    //                                     ),
    //                                   ],
    //                                 ),
    //                               ),
    //                               SizedBox(
    //                                 width: 2,
    //                               ),
    //                               ClipRRect(
    //                                   borderRadius:
    //                                   BorderRadius.all(Radius.circular(20)),
    //                                   child: Image.asset("assets/nepalicon/route_.png", height: 25,width: 25)),
    //
    //                             ],
    //                           )
    //                       ))
    //               ),
    //             ]
    //         ),
    //       ),
    //
    //
    //     ],
    //   ),
    // );
  }
  Widget _buildDatetimepicker(){
    double imageSize = MediaQuery.of(context).size.width/12;


    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10,),
          const Text("START"),
          const SizedBox(height: 10,),

          GestureDetector(
            onTap: (){
              _selectFromDate(context, setState);
            },
            child: Container(
              height: 50,
              width: double.infinity,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(width: 1,color: Colors.black)
              ),child: Center(child: Text(formatReportDate(_selectedFromDate),style: const TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),),
            ),
          ),
          const SizedBox(height: 10,),
          const Text("END"),
          const SizedBox(height: 10,),

          GestureDetector(
            onTap: (){
              // _selectFromDate(context, setState);
              _selectToDate(context, setState);
            },
            child: Container(
              height: 50,
              width: double.infinity,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(width: 1,color: Colors.black)
              ),child: Center(child: Text(formatReportDate(_selectedToDate),style: const TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),),
            ),
          ),
          const SizedBox(height: 20,),



          _loading?Center(child: Text(allkmdetail,style: const TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 18))):const Center(child: Text("Searching",style: TextStyle(color: Colors.black,fontSize: 18),)),
          const SizedBox(height: 20,),
          GestureDetector(
            onTap: (){
              setState(() {
                _loading=false;
              });
              showReport1(8,"all");
            },
            child: Align(
              alignment: Alignment.center,
              child: Container(
                height: 50,
                width: 200,
                decoration: BoxDecoration(
                  color: const Color(0xffD3D3D3),
                  borderRadius: BorderRadius.circular(8),
                ),child: const Center(child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("Search",style: TextStyle(color: Colors.black,fontSize: 18),),
              )),
              ),
            ),
          ),

          //     Container(
          //
          //       // margin: EdgeInsets.all(20),
          //         child: new Column(
          //           children: <Widget>[
          //             Container(
          //
          //                 margin: EdgeInsets.all(20),
          //                 child:   Row(
          //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //                   children: <Widget>[
          //                     ElevatedButton(
          //
          //                       style: ElevatedButton.styleFrom(
          //                           backgroundColor: Colors.blueGrey.shade900,
          //                           shape: RoundedRectangleBorder(
          //                             borderRadius: BorderRadius.circular(30.0),
          //                           ),
          //                           padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          //                           textStyle: TextStyle(
          //                               fontSize: 16,
          //                               fontWeight: FontWeight.bold)),
          //                       //color: CustomColor.primaryColor,
          //                       onPressed: () => _selectFromDate(
          //                           context, setState),
          //                       child: Text(
          //                           formatReportDate(
          //                               _selectedFromDate),
          //                           style: TextStyle(
          //                               color: Colors.white)),
          //                     ),
          //                     ElevatedButton(
          //                       style: ElevatedButton.styleFrom(
          //                           backgroundColor: Colors.blueGrey.shade900,
          //                           shape: RoundedRectangleBorder(
          //                             borderRadius: BorderRadius.circular(30.0),
          //                           ),
          //                           padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          //                           textStyle: TextStyle(
          //                               fontSize: 16,
          //                               fontWeight: FontWeight.bold)),
          //                       // color: CustomColor.primaryColor,
          //                       onPressed: () {setState(() {
          //                         _fromTime(context);  });
          //
          //                       },
          //                       /*style: ElevatedButton.styleFrom(
          //                         backgroundColor: Colors.red,
          //                         animationDuration: 3
          //                         ),*/
          //                       child: Text(
          //                           formatReportTime(
          //                               selectedFromTime),
          //                           style: TextStyle(
          //                             //backgroundColor: Colors.blue,
          //                               color: Colors.white)),
          //                     ),
          //                   ],
          //                 )
          //             ),
          //             Container(
          //
          //                 margin: EdgeInsets.only(left: 20,right: 20),
          //                 child: Row(
          //                   mainAxisAlignment:
          //                   MainAxisAlignment.spaceBetween,
          //                   children: <Widget>[
          //                     ElevatedButton(
          //                       style: ElevatedButton.styleFrom(
          //                           backgroundColor: Colors.blueGrey.shade900,
          //                           shape: RoundedRectangleBorder(
          //                             borderRadius: BorderRadius.circular(30.0),
          //                           ),
          //                           padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          //                           textStyle: TextStyle(
          //                               fontSize: 16,
          //                               fontWeight: FontWeight.bold)),
          //                       //color: CustomColor.primaryColor,
          //                       onPressed: () =>
          //                           _selectToDate(context, setState),
          //                       child: Text(
          //                           formatReportDate(_selectedToDate),
          //                           style: TextStyle(
          //                               color: Colors.white)),
          //                     ),
          //                     ElevatedButton(
          //
          //                       style: ElevatedButton.styleFrom(
          //                           backgroundColor: Colors.blueGrey.shade900,
          //                           shape: RoundedRectangleBorder(
          //                             borderRadius: BorderRadius.circular(30.0),
          //                           ),
          //                           padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          //                           textStyle: TextStyle(
          //                               fontSize: 16,
          //                               fontWeight: FontWeight.bold)),
          //                       // color: CustomColor.primaryColor,
          //                       onPressed: () {setState(() {
          //                         _toTime(context);  });
          //
          //                       },
          //                       child: Text(
          //                           formatReportTime(selectedToTime),
          //                           style: TextStyle(
          //                               color: Colors.white)),
          //                     ),
          //                   ],
          //                 )
          //             ),
          //           ],
          //         )),
          //     Container(
          //   margin:EdgeInsets.all(10) ,
          //   padding: EdgeInsets.only(left: 15,right: 15,top: 10,bottom: 30),
          //
          //   decoration: BoxDecoration(
          //       color: Colors.white,
          //       borderRadius: BorderRadius.all(Radius.circular(20)),
          //       boxShadow: <BoxShadow>[
          //         BoxShadow(
          //             blurRadius: 20,
          //             offset: Offset.zero,
          //             color: Colors.grey.withOpacity(0.5))
          //       ]),
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     mainAxisAlignment: MainAxisAlignment.start,
          //     children: <Widget>[
          //
          //
          //
          //
          //
          //
          //
          //       Container(
          //         margin: EdgeInsets.all(20),
          //         //alignment: Alignment.center,
          //         child:   ElevatedButton(
          //
          //             style: ElevatedButton.styleFrom(
          //                 backgroundColor: Colors.blueGrey.shade900,
          //                 shape: RoundedRectangleBorder(
          //                   borderRadius: BorderRadius.circular(30.0),
          //                 ),
          //                 padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          //                 textStyle: TextStyle(
          //                     fontSize: 16,
          //                     fontWeight: FontWeight.bold)),
          //             onPressed: () {
          //               setState(() {
          //                 _loading=false;
          //               });
          //               showReport1(8,"all");
          //               // Fluttertoast.showToast(msg: 'Press Outline Button', toastLength: Toast.LENGTH_SHORT);
          //             },
          //             child: Row(
          //                 mainAxisAlignment:
          //                 MainAxisAlignment.center,
          //                 children: <Widget>[
          //                   Icon(
          //                     Icons.file_copy_outlined,
          //                     size: 24.0,color: Colors.grey,
          //                   ),
          //                   (_loading)?Text(allkmdetail ,
          //                       style: TextStyle(
          //                           color: Colors.white)):CircularProgressIndicator(),
          //                 ]
          //             )/**/
          //
          //         ),
          //       ),
          //
          //     ],
          //   ),
          // )


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
    String fromDate;
    String toDate;
    String fromTime;
    String toTime;

    DateTime current = DateTime.now();

    String month;
    String day;
    if (current.month < 10) {
      month = "0" + current.month.toString();
    } else {
      month = current.month.toString();
    }

    if (current.day < 10) {
      day = "0" + current.day.toString();
    } else {
      day = current.day.toString();
    }

    if (_selectedperiod == 1) {
      String today;

      int dayCon = current.day + 1;
      if (dayCon <= 10) {
        today = "0" + dayCon.toString();
      } else {
        today = dayCon.toString();
      }

      var date = DateTime.parse("${current.year}-"
          "$month-"
          "$today "
          "00:00:00");
      fromDate = formatDateReport(DateTime.now().toString());
      toDate = formatDateReport(date.toString());
      fromTime = "00:00:00";
      toTime = "00:00:00";

      StaticVarMethod.fromdate = formatDateReport(DateTime.now().toString());
      StaticVarMethod.todate = formatDateReport(date.toString());
      StaticVarMethod.fromtime =  "00:00";
      StaticVarMethod.totime =  "00:00";
    } else if (_selectedperiod == 2) {
      String yesterday;

      int dayCon = current.day - 1;
      if (current.day <= 10) {
        yesterday = "0" + dayCon.toString();
      } else {
        yesterday = dayCon.toString();
      }

      var start = DateTime.parse("${current.year}-"
          "$month-"
          "$yesterday "
          "00:00:00");

      var end = DateTime.parse("${current.year}-"
          "$month-"
          "$yesterday "
          "24:00:00");

      fromDate = formatDateReport(start.toString());
      toDate = formatDateReport(end.toString());
      fromTime = "00:00:00";
      toTime = "00:00:00";
      StaticVarMethod.fromdate = formatDateReport(start.toString());
      StaticVarMethod.todate = formatDateReport(end.toString());
      StaticVarMethod.fromtime =  "00:00";
      StaticVarMethod.totime =  "00:00";
    }
    else if (_selectedperiod == 3)
    {
      String sevenDay, currentDayString;
      int dayCon = current.day - current.weekday;
      int currentDay = current.day;
      if (dayCon < 10) {
        sevenDay = "0" + dayCon.abs().toString();
      } else {
        sevenDay = dayCon.toString();
      }
      if (currentDay < 10) {
        currentDayString = "0" + currentDay.toString();
      } else {
        currentDayString = currentDay.toString();
      }

      var start = DateTime.parse("${current.year}-"
          "$month-"
          "$sevenDay "
          "00:00:00");

      var end = DateTime.parse("${current.year}-"
          "$month-"
          "$currentDayString "
          "24:00:00");

      fromDate = formatDateReport(start.toString());
      toDate = formatDateReport(end.toString());
      fromTime = "00:00:00";
      toTime = "00:00:00";
      StaticVarMethod.fromdate =DateFormat('yyyy-MM-dd').format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day -7));
      StaticVarMethod.todate = DateFormat('yyyy-MM-dd').format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day));;
      StaticVarMethod.fromtime =  "00:00";
      StaticVarMethod.totime =  "20:00";
    }
    else if (_selectedperiod == 4)
    {
      String sevenDay, currentDayString;
      int dayCon = current.day - 7;
      int currentDay = current.day;
      if (dayCon < 10) {
        sevenDay = "0" + dayCon.abs().toString();
      } else {
        sevenDay = dayCon.toString();
      }
      if (currentDay < 10) {
        currentDayString = "0" + currentDay.toString();
      } else {
        currentDayString = currentDay.toString();
      }

      var start = DateTime.parse("${current.year}-"
          "$month-"
          "$sevenDay "
          "00:00:00");

      var end = DateTime.parse("${current.year}-"
          "$month-"
          "$currentDayString "
          "24:00:00");

      fromDate = formatDateReport(start.toString());
      toDate = formatDateReport(end.toString());
      fromTime = "00:00:00";
      toTime = "00:00:00";
      StaticVarMethod.fromdate = formatDateReport(start.toString());
      StaticVarMethod.todate = formatDateReport(end.toString());
      StaticVarMethod.fromtime =  "00:00";
      StaticVarMethod.totime =  "00:00";
    }
    else if (_selectedperiod == 5)
    {
      String sevenDay, currentDayString;
      int dayCon = current.day - 15;
      int currentDay = current.day - 7;
      if (dayCon < 10) {
        sevenDay = "0" + dayCon.abs().toString();
      } else {
        sevenDay = dayCon.toString();
      }
      if (currentDay < 10) {
        currentDayString = "0" + currentDay.toString();
      } else {
        currentDayString = currentDay.toString();
      }

      var start = DateTime.parse("${current.year}-"
          "$month-"
          "$sevenDay "
          "00:00:00");

      var end = DateTime.parse("${current.year}-"
          "$month-"
          "$currentDayString "
          "24:00:00");

      fromDate = formatDateReport(start.toString());
      toDate = formatDateReport(end.toString());
      fromTime = "00:00:00";
      toTime = "00:00:00";
      StaticVarMethod.fromdate = formatDateReport(start.toString());
      StaticVarMethod.todate = formatDateReport(end.toString());
      StaticVarMethod.fromtime =  "00:00";
      StaticVarMethod.totime =  "00:00";
    }
    else {
      String startMonth, endMoth;
      if (_selectedFromDate.month < 10) {
        startMonth = "0" + _selectedFromDate.month.toString();
      } else {
        startMonth = _selectedFromDate.month.toString();
      }

      if (_selectedToDate.month < 10) {
        endMoth = "0" + _selectedToDate.month.toString();
      } else {
        endMoth = _selectedToDate.month.toString();
      }

      String startHour, endHour;
      if (selectedFromTime.hour < 10) {
        startHour = "0" + selectedFromTime.hour.toString();
      } else {
        startHour = selectedFromTime.hour.toString();
      }

      String startMin, endMin;
      if (selectedFromTime.minute < 10) {
        startMin = "0" + selectedFromTime.minute.toString();
      } else {
        startMin = selectedFromTime.minute.toString();
      }

      if (selectedToTime.minute < 10) {
        endMin = "0" + selectedToTime.minute.toString();
      } else {
        endMin = selectedToTime.minute.toString();
      }

      if (selectedToTime.hour < 10) {
        endHour = "0" + selectedToTime.hour.toString();
      } else {
        endHour = selectedToTime.hour.toString();
      }

      String startDay, endDay;
      if (_selectedFromDate.day <= 10) {
        if (_selectedFromDate.day == 10) {
          startDay = _selectedFromDate.day.toString();
        } else {
          startDay = "0" + _selectedFromDate.day.toString();
        }
      } else {
        startDay = _selectedFromDate.day.toString();
      }

      if (_selectedToDate.day <= 10) {
        if (_selectedToDate.day == 10) {
          endDay = _selectedToDate.day.toString();
        } else {
          endDay = "0" + _selectedToDate.day.toString();
        }
      } else {
        endDay = _selectedToDate.day.toString();
      }

      var start = DateTime.parse("${_selectedFromDate.year}-"
          "$startMonth-"
          "$startDay "
          "$startHour:"
          "$startMin:"
          "00");

      var end = DateTime.parse("${_selectedToDate.year}-"
          "$endMoth-"
          "$endDay "
          "$endHour:"
          "$endMin:"
          "00");

      fromDate = formatDateReport(start.toString());
      toDate = formatDateReport(end.toString());
      fromTime = formatTimeReport(start.toString());
      toTime = formatTimeReport(end.toString());

      StaticVarMethod.fromdate = formatDateReport(start.toString());
      StaticVarMethod.todate = formatDateReport(end.toString());
      StaticVarMethod.fromtime = formatTimeReport(start.toString());
      StaticVarMethod.totime = formatTimeReport(end.toString());
    }

    print(fromDate);
    print(toDate);

    getReport(_selectedperiod,StaticVarMethod.deviceId,StaticVarMethod.fromdate,StaticVarMethod.fromtime,StaticVarMethod.todate,StaticVarMethod.totime,currentday);

  }

  var route=[];

  Future<PositionHistory?> getReport(int deviceid,String deviceID, String fromDate,
      String fromTime, String toDate, String toTime, String currentday ) async {
    final response = await http.get(Uri.parse(StaticVarMethod.baseurlall+"/api/get_history?lang=en&user_api_hash=${StaticVarMethod.user_api_hash}&from_date=$fromDate&from_time=$fromTime&to_date=$toDate&to_time=$toTime&device_id=$deviceID"));
    print(response.request);
    if (response.statusCode == 200) {
      print(
          "dod${StaticVarMethod.baseurlall+"/api/get_history?lang=en&user_api_hash=${StaticVarMethod.user_api_hash}&from_date=$fromDate&from_time=$fromTime&to_date=$toDate&to_time=$toTime&device_id=$deviceID"}");
      var value= PositionHistory.fromJson(json.decode(response.body));
      if (value!.items?.length != 0)
      {

        setState(() {

          // top_speed=value.top_speed.toString();
          // top_speed=value.top_speed.toString();
          // move_duration=value.move_duration.toString();
          // stop_duration=value.stop_duration.toString();
          // fuel_consumption=value.fuel_consumption.toString();
          String distance_sum=value.distance_sum.toString();

          var text=double.parse(distance_sum.replaceAll(RegExp("[a-zA-Z:\s]"), ""));

          if(deviceid==1){

            today = distance_sum ;
            //today=history.routeLength.toString() +"km";
          }else if(deviceid==2){
            yesterday=distance_sum ;
          }
          else if(deviceid==3){
            last7day=distance_sum ;
          }
          else if(deviceid==4){
            thismonth=distance_sum;
          }
          else if(deviceid==8) {
            _loading=true;
            allkmdetail=distance_sum;
            _timerDummy = Timer(const Duration(seconds: 8), () => updatestatus());
          }else{
            _loading=true;
            allkmdetail="Searching....";
          }



        });
      } else if(deviceid==8) {
        setState(() {
          _loading=true;
          allkmdetail="Searching....";
          _timerDummy = Timer(const Duration(seconds: 8), () => updatestatus());
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
  // Future<void> getReport(int deviceid, String fromDate,
  //     String fromTime, String toDate, String toTime, String currentday) async{
  //   var history;
  //   //route.clear();
  //   gpsserverapis.getfn_history( StaticVarMethod.imei,  fromDate,
  //       fromTime,  toDate,  toTime)
  //       .then((response) {
  //     if (response != null) {
  //       if (response.statusCode == 200) {
  //         var jsonData = json.decode(response.body);
  //
  //         history=History.fromJson(json.decode(response.body));
  //         // https://maktrogps.com/api/api.php?api=user&key=FE27B8364272A4AAFB5484BA9D9115D7&cmd=OBJECT_GET_ROUTE,359510088088450,2022-12-22 00:00,2022-12-23 00:00,1
  //         route=history.route;
  //         if(route.length>0){
  //           setState(() {
  //
  //             if(deviceid==1){
  //
  //               today = history.routeLength.toStringAsFixed(2) +" km";
  //               //today=history.routeLength.toString() +"km";
  //             }else if(deviceid==2){
  //               yesterday=history.routeLength.toStringAsFixed(2) +" km";
  //             }
  //             else if(deviceid==3){
  //               last7day=history.routeLength.toStringAsFixed(2) +" km";
  //             }
  //             else if(deviceid==4){
  //               thismonth=history.routeLength.toStringAsFixed(2) +" km";
  //             }
  //             else if(deviceid==8) {
  //               _loading=true;
  //               allkmdetail=history.routeLength.toStringAsFixed(2) +" km";
  //               _timerDummy = Timer(Duration(seconds: 8), () => updatestatus());
  //             }else{
  //                 _loading=true;
  //                 allkmdetail="Not Found!!";
  //             }
  //
  //
  //
  //           });
  //         } else if(deviceid==8) {
  //           setState(() {
  //             _loading=true;
  //             allkmdetail="Not Found!!";
  //             _timerDummy = Timer(Duration(seconds: 8), () => updatestatus());
  //           });
  //
  //
  //         }
  //
  //       } else {
  //       }
  //     } else {
  //
  //     }
  //   });
  //   // var hash=StaticVarMethod.user_api_hash;
  //   // StaticVarMethod.devicelistweb =await gpsserverapis.getDevicesList(hash);
  //   //updateMarker();
  // }
  //

  void updatestatus(){
    setState(() {
      _loading=true;
      allkmdetail="View KM";
    });

  }
}



