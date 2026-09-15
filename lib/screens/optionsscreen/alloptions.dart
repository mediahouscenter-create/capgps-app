
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:maktrogps/config/static.dart';
import 'package:maktrogps/screens/playback.dart';
import 'package:maktrogps/screens/playbackselection.dart';
import 'package:maktrogps/screens/reports/kmdetail.dart';
import 'package:maktrogps/screens/reports/reportselection.dart';
import 'package:maktrogps/screens/reports/vehicle_info.dart';

import '../../config/constant.dart';
import '../../config/global_style.dart';
import '../livetrack.dart';

class alloptionsPage extends StatefulWidget {
  @override
  _alloptionsPageState createState() => _alloptionsPageState();
}

class _alloptionsPageState extends State<alloptionsPage> {
  // initialize reusable widget
  // final _reusableWidget = ReusableWidget();
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: GlobalStyle.appBarIconThemeColor,
        ),
        systemOverlayStyle: GlobalStyle.appBarSystemOverlayStyle,
        centerTitle: true,
        title: Text(''+StaticVarMethod.deviceName, style: GlobalStyle.appBarTitle),
        backgroundColor: GlobalStyle.appBarBackgroundColor,
        //bottom: _reusableWidget.bottomAppBar(),
      ),
      body: ListView(
        children: [
          _buildimeiInformation(),
          _buildmenuInformation(),
          _buildsimInformation(),
          // _reusableWidget.divider1(),
          //_reusableWidget.deliveryInformation(),
          //_reusableWidget.divider1(),
          //_buildOrderSummary(),
          // _reusableWidget.divider1(),
          _buildTotalSummary(),
        ],
      ),
    );
  }

  Widget _buildimeiInformation(){
    return Container(
      color: Colors.grey[100],
      padding: const EdgeInsets.all(16),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('IMEI', style: TextStyle(
              color: Colors.black,
              fontSize: 12
          )),
          Text(''+StaticVarMethod.imei, style: const TextStyle(
              color: Colors.black,
              fontSize: 12
          ))
        ],
      ),
    );
  }
  Widget _buildsimInformation(){
    return Container(
      color: Colors.grey[100],
      padding: const EdgeInsets.all(16),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Sim Number', style: TextStyle(
              color: Colors.black,
              fontSize: 12
          )),
          Text(''+StaticVarMethod.simno, style: const TextStyle(
              color: Colors.black,
              fontSize: 12
          ))
        ],
      ),
    );
  }

  Widget _buildmenuInformation(){
    double imageSize = MediaQuery.of(context).size.width/12;
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
          children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: Column(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => livetrack()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),

                      decoration: new BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.rectangle,
                        borderRadius:const BorderRadius.all(Radius.circular(15)),
                        // borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          const BoxShadow(
                            color: Colors.black26,
                             blurRadius: 10.0,
                            //offset: const Offset(0.0, 10.0),
                          ),
                        ],
                      ),
                      // color: Colors.white,
                      //color: Color(0x99FFFFFF),
                      child:   Column(
                          children: <Widget>[
                            Image.asset("assets/images/movingdurationicon.png", height: imageSize,width: imageSize),
                            const Text('Live Map',  style: TextStyle(
                                fontSize: 12,height: 1.5, color: SOFT_BLUE))
                       ]
                      )
                    ),
                  ),


                ],
              ),
            ),
            Expanded(
              child: Column(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => kmdetail()),
                      );
                    },
                    child: Container(
                        padding: const EdgeInsets.all(8),

                        decoration: new BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.rectangle,
                          borderRadius:const BorderRadius.all(Radius.circular(15)),
                          // borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            const BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10.0,
                              //offset: const Offset(0.0, 10.0),
                            ),
                          ],
                        ),
                        // color: Colors.white,
                        //color: Color(0x99FFFFFF),
                        child:   Column(
                            children: <Widget>[
                              Image.asset("assets/images/icons8-bar-chart-100.png", height: imageSize,width: imageSize),
                              const Text('KM Detail',  style: TextStyle(
                                  fontSize: 12,height: 1.5, color: SOFT_BLUE))
                            ]
                        )
                    ),
                  ),
                ],

              ),
            ),
            Expanded(
              child: Column(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => playbackselection()),
                      );
                    },
                    child: Container(
                        padding: const EdgeInsets.all(8),

                        decoration: new BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.rectangle,
                          borderRadius:const BorderRadius.all(Radius.circular(15)),
                          // borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            const BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10.0,
                              //offset: const Offset(0.0, 10.0),
                            ),
                          ],
                        ),
                        // color: Colors.white,
                        //color: Color(0x99FFFFFF),
                        child:   Column(
                            children: <Widget>[
                              Image.asset("assets/images/icons8-play-100.png", height: imageSize,width: imageSize),
                              const Text('Playback',  style: TextStyle(
                                  fontSize: 12,height: 1.5, color: SOFT_BLUE))
                            ]
                        )
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => vehicle_info()),
                      );

                      //_onMapTypeButtonPressed();
                    },
                    child: Container(
                        padding: const EdgeInsets.all(8),

                        decoration: new BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.rectangle,
                          borderRadius:const BorderRadius.all(Radius.circular(15)),
                          // borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            const BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10.0,
                              //offset: const Offset(0.0, 10.0),
                            ),
                          ],
                        ),
                        // color: Colors.white,
                        //color: Color(0x99FFFFFF),
                        child:   Column(
                            children: <Widget>[
                              Image.asset("assets/images/icons8-info-popup-100.png", height: imageSize,width: imageSize),
                              const Text('Vehicle Info',  style: TextStyle(
                                  fontSize: 12,height: 1.5, color: SOFT_BLUE))
                            ]
                        )
                    ),
                  ),
                ],
              ),
            ),
          ],
        )
      ]),
    );
  }


  Widget _buildTotalSummary(){
    return Container(
      margin: const EdgeInsets.all(5),
      child: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => livetrack()),
              );
            },
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                      width: 1,
                      color: Colors.grey[300]!
                  ),
                  borderRadius: const BorderRadius.all(
                      Radius.circular(10) //         <--- border radius here
                  )
              ),
              child:const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lock_rounded, color: SOFT_BLUE),
                      SizedBox(width: 12),
                      Text('Live Tracking', style: TextStyle(fontWeight: FontWeight.bold
                      )),
                    ],
                  ),
                  Icon(Icons.chevron_right, size: 20, color: SOFT_BLUE),
                ],
              )
            ),
          ),
          const SizedBox(height: 4),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PlaybackPage()),
              );
            },
            child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                        width: 1,
                        color: Colors.grey[300]!
                    ),
                    borderRadius: const BorderRadius.all(
                        Radius.circular(10) //         <--- border radius here
                    )
                ),
                child:const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.replay_rounded, color: SOFT_BLUE),
                        SizedBox(width: 12),
                        Text('Playback', style: TextStyle(fontWeight: FontWeight.bold
                        )),
                      ],
                    ),
                    Icon(Icons.chevron_right, size: 20, color: SOFT_BLUE),
                  ],
                )
            ),
          ),
          const SizedBox(height: 4),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: (){

              Navigator.push(
                  context,
                  MaterialPageRoute(
                  builder: (context) => reportselection()),
              );

            },
            child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                        width: 1,
                        color: Colors.grey[300]!
                    ),
                    borderRadius: const BorderRadius.all(
                        Radius.circular(10) //         <--- border radius here
                    )
                ),
                child:const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.stacked_bar_chart, color: SOFT_BLUE),
                        SizedBox(width: 12),
                        Text('Reports', style: TextStyle( fontWeight: FontWeight.bold
                        )),
                      ],
                    ),
                    Icon(Icons.chevron_right, size: 20, color: SOFT_BLUE),
                  ],
                )
            ),
          ),
          const SizedBox(height: 4),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: (){
              Fluttertoast.showToast(
                  msg: 'Comming soon ',
                  toastLength: Toast.LENGTH_SHORT);
            },
            child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                        width: 1,
                        color: Colors.grey[300]!
                    ),
                    borderRadius: const BorderRadius.all(
                        Radius.circular(10) //         <--- border radius here
                    )
                ),
                child:const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.share_sharp, color: SOFT_BLUE),
                        SizedBox(width: 12),
                        Text('Share Location', style: TextStyle(fontWeight: FontWeight.bold
                        )),
                      ],
                    ),
                    Icon(Icons.chevron_right, size: 20, color: SOFT_BLUE),
                  ],
                )
            ),
          ),

          Divider(
            height: 32,
            color: Colors.grey[400],
          ),
        ],
      ),
    );
  }
}



