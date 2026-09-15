import 'dart:async';
import 'dart:math';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:blinking_text/blinking_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:maktrogps/bloc/kmandfuelhistory/bloc/kmandfuelhistory_bloc.dart';
import 'package:maktrogps/config/constant.dart';
import 'package:maktrogps/config/static.dart';
import 'package:maktrogps/data/datasources.dart';
import 'package:maktrogps/data/model/Services.dart';
import 'package:maktrogps/data/model/devices.dart';
import 'package:maktrogps/data/model/services_model.dart';
import 'package:maktrogps/ui/reusable/cache_image_network.dart';

import 'package:maktrogps/ui/reusable/global_function.dart';
import 'package:maktrogps/ui/reusable/global_widget.dart';
import 'package:maktrogps/ui/reusable/shimmer_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:maktrogps/utils/MapUtils.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';
import '../../mvvm/view_model/objects.dart';

class serviceslistscreen extends StatefulWidget {
  @override
  _serviceslistscreen createState() => _serviceslistscreen();
}

class _serviceslistscreen extends State<serviceslistscreen>
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

  late SharedPreferences prefs;
  late ObjectStore objectStore;

  KmandfuelHistoryBloc kmhistorybloc = KmandfuelHistoryBloc();
  @override
  void initState() {
     kmhistorybloc.add(KmandfuelHistoryInitialFetchEvent());
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

    if (StaticVarMethod.serviceslist.isNotEmpty) {
      _child = devicesListwidget(boxImageSize);
    } else if (StaticVarMethod.serviceslist.isEmpty) {
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
      itemCount: StaticVarMethod.serviceslist.length,
      itemBuilder: (context, index) =>
          _buildItem(StaticVarMethod.serviceslist[index], boxImageSize, index),
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

  Widget _buildItem(services_model productData, boxImageSize, index) {
    double imageSize = MediaQuery.of(context).size.width / 25;

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
          child: Column(children: [
            Row(
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
                      '' + productData.devicename.toString(),
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
                      "imei : " + productData.imei.toString(),
                      style: TextStyle(fontSize: 12, color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ]),
            Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: Text(
                      '' + productData.name.toString(),
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
                      "Status : " + productData.value.toString(),
                      style: TextStyle(fontSize: 12, color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ]),
          ]),
        ),
      ),
    );
  }

  Future refreshData() async {
    setState(() {
      _vehiclesData.clear();
      _loading = true;
      //_getData();
    });
  }

  launchWhatsApp(num, text) async {
    final link = WhatsAppUnilink(
      //  phoneNumber: num,
      text: text,
    );
    await launch('$link');
  }
}
