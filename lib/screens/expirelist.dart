import 'dart:async';

import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:maktrogps/config/static.dart';
import 'package:maktrogps/data/model/devices.dart';

import 'package:maktrogps/ui/reusable/global_function.dart';
import 'package:maktrogps/ui/reusable/global_widget.dart';
import 'package:maktrogps/ui/reusable/shimmer_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';
import '../../mvvm/view_model/objects.dart';

class expirelistscreen extends StatefulWidget {
  @override
  _expirelistscreen createState() => _expirelistscreen();
}

class _expirelistscreen extends State<expirelistscreen>
    with SingleTickerProviderStateMixin {
  // initialize global function and global widget
  final _globalFunction = GlobalFunction();
  final _globalWidget = GlobalWidget();
  final _shimmerLoading = ShimmerLoading();
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  PersistentBottomSheetController? _bottomSheetController;

  String filtertext = "All";
  bool _loading = true;

  final Completer<GoogleMapController> _mapController = Completer();
  Set<Marker> markers = new Set();

  Color _color1 = Color(0xff777777);
  Color _color2 = Color(0xFF515151);
  Color _topSearchColor = Colors.white;
  List<deviceItems> _vehiclesData = [];
  List<deviceItems> _vehiclesData_sorted = [];
  List<deviceItems> _vehiclesData_duplicate = [];
  // _listKey is used for AnimatedList
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  TextEditingController _etSearch = TextEditingController();

  int _tabIndex = 0;

  GoogleMapController? _controller;
  bool _mapLoading = true;
  static Color primaryDark = const Color.fromARGB(255, 13, 61, 101);
  double _currentZoom = 14;

//  final LatLng _initialPosition = LatLng(-6.168033, 106.900467);

  Marker? _marker;

  late BitmapDescriptor _markerDirection;
  void _setSourceAndDestinationIcons() async {
    _markerDirection = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/images/direction.png');
  }

  List<String> carstatusList = [
    'Tous les véhicules'.tr,
    'Running'.tr,
    'Stopped'.tr,
    'Idle'.tr,
    'Offline'.tr,
    'InActive'.tr,
    'Expired'.tr
  ];
  int starIndex = 0;
  Color CHARCOAL = Color(0xFF515151);
  bool _searchEnabled = false;
  List<deviceItems> _inactiveVehicles = [];
  List<deviceItems> _runningVehicles = [];
  List<deviceItems> _idleVehicles = [];
  List<deviceItems> _offlineVehicles = [];
  List<deviceItems> _stoppedVehicles = [];
  List<deviceItems> _expiredVehicles = [];
  late SharedPreferences prefs;
  late ObjectStore objectStore;

  // KmandfuelHistoryBloc kmhistorybloc = KmandfuelHistoryBloc();
  @override
  void initState() {
    // kmhistorybloc.add(KmandfuelHistoryInitialFetchEvent());
    checkPreference();
    _setSourceAndDestinationIcons();
    super.initState();
  }

  void checkPreference() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  void dispose() {
    _etSearch.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double boxImageSize = (MediaQuery.of(context).size.width / 12);
    print("list Builder");
    Widget? _child;

    if (StaticVarMethod.expirelist.isNotEmpty) {
      _child = devicesListwidget(boxImageSize);
    } else if (StaticVarMethod.expirelist.isEmpty) {
      _child = new RefreshIndicator(
        onRefresh: refreshData,
        child: (_loading == true)
            ? _shimmerLoading.buildShimmerContent()
            : Container(),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        // automaticallyImplyLeading: false,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        elevation: 0,
        title: Image.asset(StaticVarMethod.listimageurl, height: 40),
        // backgroundColor: themeDark,
        backgroundColor: Colors.grey.shade50,
      ),
      body: _child,
    );
  }

  Widget devicesListwidget(double boxImageSize) {
    return ScrollablePositionedList.builder(
      key: _listKey,
      padding: EdgeInsets.fromLTRB(0, 0, 0, 120),
      itemCount: StaticVarMethod.expirelist.length,
      itemBuilder: (context, index) =>
          _buildItem(StaticVarMethod.expirelist[index], boxImageSize, index),
      itemScrollController: itemScrollController,
      itemPositionsListener: itemPositionsListener,
    );
    /*AnimatedList(
      key: _listKey,
      initialItemCount: _vehiclesData_duplicate.length,
      physics: AlwaysScrollableScrollPhysics(),
      itemBuilder: (context, index, animation) {
        return _buildItem(_vehiclesData_duplicate[index], boxImageSize, animation, index);
      },
    );*/
  }

  Widget _buildItem(deviceItems productData, boxImageSize, index) {
    double imageSize = MediaQuery.of(context).size.width / 25;
    double lat = productData.lat!.toDouble();
    double lng = productData.lng!.toDouble();
    double course = productData.course!.toDouble();
    int speed = productData.speed!.toInt();
    String imei = productData.deviceData!.imei.toString();
    String carstatus = productData.online!.toString();
    String time = productData.time.toString();
    Color statuscolor = Colors.red;
    var expirationdate = "";
    if (!productData.deviceData!.expirationDate.toString().contains("expire") ||
        productData.deviceData!.expirationDate.toString() != "null" ||
        productData.deviceData!.expirationDate.toString() != null) {
      DateTime lastUpdate =
          DateTime.parse(productData.deviceData!.expirationDate.toString());
      expirationdate =
          DateFormat('dd-MM-yyyy').format(lastUpdate.toLocal()).toString();
    }
    if (speed > 0) {
      statuscolor = Colors.green;
    } else {
      statuscolor = Colors.red;
    }
    String other = productData.deviceData!.traccar!.other.toString();
    String ignition = "false";
    String enginehours = "0h";
    String sat = "0";
    String totaldistance = "0";
    String distance = "0";
    String devicestatus = "0";
    String stopDuration = productData.stopDuration.toString();
    int hours = 0;
    if (other.contains("<ignition>")) {
      const start = "<ignition>";
      const end = "</ignition>";
      final startIndex = other.indexOf(start);
      final endIndex = other.indexOf(end, startIndex + start.length);
      ignition = other.substring(startIndex + start.length, endIndex);
    }
    if (other.contains("<enginehours>")) {
      const start = "<enginehours>";
      const end = "</enginehours>";
      final startIndex = other.indexOf(start);
      final endIndex = other.indexOf(end, startIndex + start.length);
      int hours =
          int.parse(other.substring(startIndex + start.length, endIndex));
      enginehours = (hours / 3600).toStringAsFixed(2);
    }
    if (other.contains("<sat>")) {
      const start = "<sat>";
      const end = "</sat>";
      final startIndex = other.indexOf(start);
      final endIndex = other.indexOf(end, startIndex + start.length);
      sat = other.substring(startIndex + start.length, endIndex);
    }
    if (other.contains("<totaldistance>")) {
      const start = "<totaldistance>";
      const end = "</totaldistance>";
      final startIndex = other.indexOf(start);
      final endIndex = other.indexOf(end, startIndex + start.length);
      double dis =
          double.parse(other.substring(startIndex + start.length, endIndex));
      totaldistance = (dis / 1000).toStringAsFixed(2);
      // totaldistance = other.substring(startIndex + start.length, endIndex);
    }
    if (other.contains("<distance>")) {
      const start = "<distance>";
      const end = "</distance>";
      final startIndex = other.indexOf(start);
      final endIndex = other.indexOf(end, startIndex + start.length);
      distance = other.substring(startIndex + start.length, endIndex);
    }

    // String iconpath = 'assets/vehcileIcon/truck_sidestop.png';
    String iconpath = 'assets/vehcileIcon/car_sidestop.png';

    if (stopDuration.toString().contains("h")) {
      const end = "h";
      final endIndex = stopDuration.indexOf(end);
      //String h = stopDuration.substring(endIndex);
      String result = stopDuration.substring(0, endIndex);
      hours = int.parse(result);
      print(result);
      // print(h);
    }

    // if (hours >23 && ignition.contains("false")) {
    // if (productData.online.toString().contains("offline") && !productData.time.toString().contains("Not connected") && !productData.time.toString().contains("Expired")) {
    if (productData.online.toString().contains("offline") &&
        !productData.time.toString().contains("Not connected") &&
        !productData.time.toString().contains("Expired")) {
      // iconpath = 'assets/vehcileIcon/truck_sideinactive.png';
      iconpath = 'assets/vehcileIcon/car_sideinactive.png';
      devicestatus = "Not connected";
      if (StaticVarMethod.pref_static!
              .get(productData.deviceData!.imei.toString()) !=
          null)
        iconpath = "assets/vehcileIcon/" +
            StaticVarMethod.pref_static!
                .get(productData.deviceData!.imei.toString())
                .toString() +
            "sideinactive.png";
    } else if (productData.time!.contains('Not connected')) {
      //iconpath = 'assets/vehcileIcon/truck_sidenodata.png';
      iconpath = 'assets/vehcileIcon/car_sidenodata.png';
      devicestatus = "Not connected";
      if (StaticVarMethod.pref_static!
              .get(productData.deviceData!.imei.toString()) !=
          null)
        iconpath = "assets/vehcileIcon/" +
            StaticVarMethod.pref_static!
                .get(productData.deviceData!.imei.toString())
                .toString() +
            "sidenodata.png";
    } else if (productData.speed!.toInt() > 0) {
      //iconpath = 'assets/vehcileIcon/truck_siderunning.png';
      iconpath = 'assets/vehcileIcon/car_siderunning.png';
      devicestatus = "Moving";
      if (StaticVarMethod.pref_static!
              .get(productData.deviceData!.imei.toString()) !=
          null)
        iconpath = "assets/vehcileIcon/" +
            StaticVarMethod.pref_static!
                .get(productData.deviceData!.imei.toString())
                .toString() +
            "siderunning.png";
    } else if (ignition.contains("true") &&
        !productData.online.toString().contains("offline") &&
        double.parse(productData.speed.toString()) < 1.0) {
      //iconpath = 'assets/vehcileIcon/truck_sideidle.png';
      iconpath = 'assets/vehcileIcon/car_sideidle.png';
      devicestatus = "Idle";
      if (StaticVarMethod.pref_static!
              .get(productData.deviceData!.imei.toString()) !=
          null)
        iconpath = "assets/vehcileIcon/" +
            StaticVarMethod.pref_static!
                .get(productData.deviceData!.imei.toString())
                .toString() +
            "sideidle.png";
    } else if (productData.online!.contains('online')) {
      // iconpath = 'assets/vehcileIcon/truck_siderunning.png';
      iconpath = 'assets/vehcileIcon/car_siderunning.png';
      devicestatus = "Online";
      if (StaticVarMethod.pref_static!
              .get(productData.deviceData!.imei.toString()) !=
          null)
        iconpath = "assets/vehcileIcon/" +
            StaticVarMethod.pref_static!
                .get(productData.deviceData!.imei.toString())
                .toString() +
            "siderunning.png";
    } else {
      // iconpath = 'assets/vehcileIcon/truck_sidestop.png';
      iconpath = 'assets/vehcileIcon/car_sidestop.png';

      devicestatus = "Stopped";
      if (StaticVarMethod.pref_static!
              .get(productData.deviceData!.imei.toString()) !=
          null)
        iconpath = "assets/vehcileIcon/" +
            StaticVarMethod.pref_static!
                .get(productData.deviceData!.imei.toString())
                .toString() +
            "sidestop.png";
    }

    return GestureDetector(
      onTap: () {},
      child: Container(
        // height: 100,
        margin: EdgeInsets.fromLTRB(10, 10, 10, 0),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        //padding:EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(25.0)),
          ),
          padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
          margin: EdgeInsets.only(left: 5),
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Padding(
                //   padding: const EdgeInsets.fromLTRB(0, 35, 8, 15),
                //   child:  Image.asset("assets/vehcileIcon/outlinedcircle.png",
                //       height: 8,width: 8),
                // ),
                Container(
                  child: Text(
                    '' + productData.deviceData!.name.toString(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff494C60),
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                Container(
                  child: Text(
                    "Expiry Date: " + expirationdate,
                    style: TextStyle(fontSize: 12, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
                /* Container(
                                margin: EdgeInsets.only(left: 120,top: 20),
                                child: TextButton(
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                                          (Set<MaterialState> states) => Colors.red,
                                    ),
                                    overlayColor: MaterialStateProperty.all(Colors.transparent),
                                    shape: MaterialStateProperty.all(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(5),
                                        )
                                    ),
                                  ),
                                  onPressed: () {

                                    // Fluttertoast.showToast(msg: 'Click login', toastLength: Toast.LENGTH_SHORT);
                                  },
                                  child:  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [

                                      Text(
                                        'Renew',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.white),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),

                                ),
                              )*/

                /*Text("Expire on",style: TextStyle(
                                fontSize: 9,
                                color: SOFT_GREY
                            )
                            )*/
              ]),
        ),
      ),
    );
  }

  Future refreshData() async {
    // setState(() {
    //   _vehiclesData.clear();
    //   _loading = true;
    //   //_getData();
    // });
  }

  launchWhatsApp(num, text) async {
    final link = WhatsAppUnilink(
      //  phoneNumber: num,
      text: text,
    );
    await launch('$link');
  }
}
