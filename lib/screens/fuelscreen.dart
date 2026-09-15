import 'dart:async';
import 'dart:math';

import 'package:calendar_timeline/calendar_timeline.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:maktrogps/config/static.dart';
import 'package:maktrogps/data/datasources.dart';
import 'package:maktrogps/data/model/devices.dart';
import 'package:maktrogps/data/model/history.dart';
import 'package:maktrogps/screens/fuelplayback.dart';
import 'package:maktrogps/mapconfig/CommonMethod.dart';
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

class fuelscreen extends StatefulWidget {
  @override
  _listscreen createState() => _listscreen();
}

class _listscreen extends State<fuelscreen>
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
  int _selectedperiod = 0;
  DateTime _selectedFromDate = DateTime.now();
  DateTime _selectedToDate = DateTime.now();

  var selectedToTime = TimeOfDay.fromDateTime(DateTime.now());
  var selectedTripInfoToTime = TimeOfDay.fromDateTime(DateTime.now());
  var selectedFromTime = TimeOfDay.fromDateTime(DateTime.now());
  var selectedFromTimeequel = TimeOfDay.fromDateTime(DateTime.now());
  var selectedTripInfoFromTime = TimeOfDay.fromDateTime(DateTime.now());
  // var fromTime=        DateFormat("HH:mm").format(DateTime.now());
  var fromTime = "00:05";
  var fromTripInfoTime = DateFormat("HH:mm:ss").format(DateTime.now());
  var toTime = DateFormat("HH:mm").format(DateTime.now());
  var toTripInfoTime = DateFormat("HH:mm:ss").format(DateTime.now());

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
    // StaticVarMethod.devicelist.clear();
    objectStore = Provider.of<ObjectStore>(context);
    _vehiclesData = objectStore.objects;
    _runningVehicles = [];
    _idleVehicles = [];
    _stoppedVehicles = [];
    _inactiveVehicles = [];
    _expiredVehicles = [];
    _offlineVehicles = [];

    if (_vehiclesData.isNotEmpty) {
      _vehiclesData_duplicate.clear();
      _vehiclesData_sorted.clear();
      _vehiclesData_sorted.addAll(_vehiclesData);

      if (filtertext != "All") {
        for (int i = 0; i < _vehiclesData_sorted.length; i++) {
          deviceItems model = _vehiclesData_sorted.elementAt(i);

          String other = model.deviceData!.traccar!.other.toString();
          String ignition = "false";
          String stopDuration = model.stopDuration.toString();
          int hours = 0;
          if (other.contains("<ignition>")) {
            const start = "<ignition>";
            const end = "</ignition>";
            final startIndex = other.indexOf(start);
            final endIndex = other.indexOf(end, startIndex + start.length);
            ignition = other.substring(startIndex + start.length, endIndex);
          }
          if (stopDuration.toString().contains("h")) {
            const end = "h";
            final endIndex = stopDuration.indexOf(end);
            String result = stopDuration.substring(0, endIndex);
            hours = int.parse(result);
          }

          if (filtertext == "Offline") {
            // if (model.online.toString().toLowerCase().contains("offline") && !model.time.toString().toLowerCase().contains("Not connected") && !model.time.toString().toLowerCase().contains("Expired")/*hours>23 */&& ignition.contains("false")) {
            if (model.online.toString().contains("offline") &&
                !model.time.toString().contains("Not connected") &&
                !model.time.toString().contains("Expired")) {
              _vehiclesData_duplicate.add(_vehiclesData_sorted.elementAt(i));
              print('Offline');
            }
          } else if (filtertext == "Idle") {
            if (ignition.contains("true") &&
                !model.online.toString().contains("offline") &&
                double.parse(model.speed.toString()) < 1.0) {
              _vehiclesData_duplicate.add(_vehiclesData_sorted.elementAt(i));
              print('Idle');
            }
          } else if (filtertext == "In Active") {
            if (model.online.toString().toLowerCase().contains("offline") &&
                model.time.toString().toLowerCase().contains("not connected")) {
              _vehiclesData_duplicate.add(_vehiclesData_sorted.elementAt(i));
              print('In Active');
            }
          } else if (filtertext == "Running") {
            if (model.online.toString().toLowerCase().contains("online")) {
              _vehiclesData_duplicate.add(_vehiclesData_sorted.elementAt(i));
              print('online');
            }
          } else if (filtertext == "Stopped") {
            if (ignition.contains("false") &&
                model.time.toString().toLowerCase() != "not connected" &&
                double.parse(model.speed.toString()) < 1.0) {
              _vehiclesData_duplicate.add(_vehiclesData_sorted.elementAt(i));
              print('stoppedvehile');
            }
          } else if (filtertext == "expire") {
            if (model.time.toString().toLowerCase().contains("expire")) {
              _vehiclesData_duplicate.add(_vehiclesData_sorted.elementAt(i));
              print('expire');
            }
          } else {
            if (model.name.toString().toLowerCase().contains(filtertext
                    .toLowerCase()) /*||
                  model.devicedata!.first.imei!.contains(query.toLowerCase())*/
                ) {
              _vehiclesData_duplicate.add(_vehiclesData_sorted.elementAt(i));
              print('item exists');
            }
          }
        }
      } else {
        _vehiclesData_duplicate.addAll(_vehiclesData);
      }

      StaticVarMethod.devicelist = _vehiclesData;

      for (int i = 0; i < StaticVarMethod.devicelist.length; i++) {
        deviceItems model = StaticVarMethod.devicelist.elementAt(i);
        String other = model.deviceData!.traccar!.other.toString();
        String stopDuration = model.stopDuration.toString();
        String ignition = "false";
        int hours = 0;
        if (other.contains("<ignition>")) {
          const start = "<ignition>";
          const end = "</ignition>";
          final startIndex = other.indexOf(start);
          final endIndex = other.indexOf(end, startIndex + start.length);
          ignition = other.substring(startIndex + start.length, endIndex);
        }
        if (stopDuration.toString().contains("h")) {
          const end = "h";
          final endIndex = stopDuration.indexOf(end);
          //String h = stopDuration.substring(endIndex);
          String result = stopDuration.substring(0, endIndex);
          hours = int.parse(result);
          // print(h);
        }

        //  if (model.online.toString().toLowerCase().contains("offline") && !model.time.toString().toLowerCase().contains("Not connected") && !model.time.toString().toLowerCase().contains("Expired")/*hours>23 */&& ignition.contains("false")) {
        // if (hours >23 && ignition.contains("false")) {
        if (model.online.toString().contains("offline") &&
            !model.time.toString().contains("Not connected") &&
            !model.time.toString().contains("Expired")) {
          _offlineVehicles.add(StaticVarMethod.devicelist.elementAt(i));
          print('offline');
        } else if (model.time.toString().toLowerCase().contains("expire")) {
          _expiredVehicles.add(StaticVarMethod.devicelist.elementAt(i));
          // Future.delayed(Duration.zero, () => showAlert(context,model.name.toString()));
          print('expire');
        } else if (ignition.contains("true") &&
            !model.online.toString().contains("offline") &&
            double.parse(model.speed.toString()) < 1.0) {
          _idleVehicles.add(StaticVarMethod.devicelist.elementAt(i));
        } else if (model.online.toString().toLowerCase().contains("offline") &&
            model.time.toString().toLowerCase().contains("not connected")) {
          _inactiveVehicles.add(StaticVarMethod.devicelist.elementAt(i));
        } else if (model.online.toString().toLowerCase().contains("online")) {
          _runningVehicles.add(StaticVarMethod.devicelist.elementAt(i));
        } else if (ignition.contains("false") &&
            model.time.toString().toLowerCase() != "not connected" &&
            double.parse(model.speed.toString()) < 1.0) {
          _stoppedVehicles.add(StaticVarMethod.devicelist.elementAt(i));
        }
      }

      _loading = false;
    } else {
      print("not available");
      _loading = false;
      _vehiclesData_duplicate.clear();
      _vehiclesData_sorted.clear();
    }

    final double boxImageSize = (MediaQuery.of(context).size.width / 12);
    print("list Builder");
    Widget? _child;
    if (_loading == true) {
      _child = const Center(child: CircularProgressIndicator());
    } else if (_vehiclesData_duplicate.isNotEmpty) {
      _child = new RefreshIndicator(
        onRefresh: refreshData,
        child: (_loading == true)
            ? _shimmerLoading.buildShimmerContent()
            : devicesListwidget(boxImageSize),
      );
    } else if (_vehiclesData_duplicate.isEmpty) {
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
        automaticallyImplyLeading: false,
        elevation: 0,
        title: (_searchEnabled)
            ? Container(
                child: TextFormField(
                  controller: _etSearch,
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade800 /*Colors.white*/),
                  onChanged: (value) {
                    setState(() {
                      print('text changed');
                      if (value.isNotEmpty) {
                        filterSearchResults(value);
                      } else {
                        _vehiclesData.clear();
                        filtertext = "All";
                        // setState(() {
                        //_getData();
                        print("full list");
                        //  });
                      }
                    });
                  },
                  decoration: InputDecoration(
                    fillColor: Colors.transparent,
                    filled: true,
                    hintText: 'Enter device name or IMEI'.tr,
                    hintStyle: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade800 /*Colors.white*/),
                    prefixIcon: Icon(Icons.search,
                        color: Colors.black /*Colors.white*/, size: 18),
                    suffixIcon: (_etSearch.text == '')
                        ? null
                        : GestureDetector(
                            onTap: () {
                              filtertext = "All";
                              //setState(() {
                              //_getData();
                              _etSearch = TextEditingController(text: '');
                              _searchEnabled =
                                  _searchEnabled == false ? true : false;
                              //  });
                            },
                            child: Icon(Icons.close,
                                color: Colors.grey[500], size: 16)),
                    focusedBorder: UnderlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        borderSide: BorderSide(color: Colors.grey[200]!)),
                    enabledBorder: UnderlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      borderSide: BorderSide(color: Colors.grey[200]!),
                    ),
                  ),
                ),
              )
            //  : /*Center(child: Text("List of Vehicles")),*/ Image.asset(StaticVarMethod.listimageurl, height: 40),
            : buildCacheNetworkImage(
                width: 100, height: 100, url: StaticVarMethod.splashimageurl),
        // backgroundColor: themeDark,
        backgroundColor: Colors.grey.shade50,

        actions: [
          IconButton(
              icon: Icon(
                (_searchEnabled) ? Icons.clear_rounded : Icons.search,
                color: Colors.grey.shade800 /*Colors.white*/,
                size: 35,
              ),
              onPressed: () {
                setState(() {
                  filtertext = "All";
                  //setState(() {
                  // _getData();
                  _etSearch = TextEditingController(text: '');
                  _searchEnabled = _searchEnabled == false ? true : false;
                });
              }),
        ],
      ),
      body: _child,
    );
  }

  void showAlert(BuildContext context, String name) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: SizedBox(
                height: 50,
                child: Stack(
                  children: [
                    Positioned(
                        top: 50,
                        child: Container(
                          height: 50,
                          width: 100,
                          color: Colors.red,
                        )),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        height: 50,
                        width: 100,
                        decoration: ShapeDecoration(
                          shape: CircleBorder(),
                          color: Colors.yellow,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ));
  }

/*
  Widget radioStar(String txt, int index) {
    return GestureDetector(
      onTap: () {

        setState(() {
          starIndex = index;
          _tabIndex = index;
          if(index ==0){
            filterSearchResults("All");
          }else if(index ==1){
            filterSearchResults("online");
          }
          else if(index ==2){
            filterSearchResults("stoppedvehile");
          }

          else if(index ==3){
            filterSearchResults("In Active");
          }
          else if(index ==4){
            filterSearchResults("expire");
          }
        });
        Fluttertoast.showToast(msg: 'Click TabBar', toastLength: Toast.LENGTH_SHORT);
        print('idx : '+_tabIndex.toString());

      },
      child: Container(
          padding: EdgeInsets.fromLTRB(12, 6, 12, 6),
          margin: EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
              color: starIndex == index ? themeDark : Colors.white,
              border: Border.all(
                  width: 1.0,
                  color: starIndex == index ? themeDark : themeDark),
              borderRadius: BorderRadius.all(Radius.circular(7))),
          child: index == 0
              ? Text(txt, style: TextStyle(color: starIndex == index ? Colors.white : themeDark ))
              : Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(txt, style: TextStyle(color: starIndex == index ? Colors.white : themeDark )),
              SizedBox(width: 2),
              //Icon(Icons.star, color: starIndex == index ? Colors.white : Colors.yellow[700], size: 12),
            ],
          )),
    );
  }
*/

  Widget devicesListwidget(double boxImageSize) {
    return ScrollablePositionedList.builder(
      key: _listKey,
      padding: EdgeInsets.fromLTRB(0, 0, 0, 120),
      itemCount: _vehiclesData_duplicate.length,
      itemBuilder: (context, index) =>
          _buildItem(_vehiclesData_duplicate[index], boxImageSize, index),
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

  void filterSearchResults(String query) {
    filtertext = query;
    print("inside filter");
    _vehiclesData_duplicate.clear();
    if (query.isNotEmpty && query != "All") {
      for (int i = 0; i < _vehiclesData_sorted.length; i++) {
        deviceItems model = _vehiclesData_sorted.elementAt(i);

        String other = model.deviceData!.traccar!.other.toString();
        String ignition = "false";
        String stopDuration = model.stopDuration.toString();
        int hours = 0;
        if (other.contains("<ignition>")) {
          const start = "<ignition>";
          const end = "</ignition>";
          final startIndex = other.indexOf(start);
          final endIndex = other.indexOf(end, startIndex + start.length);
          ignition = other.substring(startIndex + start.length, endIndex);
        }
        if (stopDuration.toString().contains("h")) {
          const end = "h";
          final endIndex = stopDuration.indexOf(end);
          String result = stopDuration.substring(0, endIndex);
          hours = int.parse(result);
        }

        if (filtertext == "Offline") {
          //  if (hours>23 && ignition.contains("false")) {
          // if (model.online.toString().toLowerCase().contains("offline") && !model.time.toString().toLowerCase().contains("Not connected") && !model.time.toString().toLowerCase().contains("Expired")/*hours>23 */&& ignition.contains("false")) {
          if (model.online.toString().contains("offline") &&
              !model.time.toString().contains("Not connected") &&
              !model.time.toString().contains("Expired")) {
            _vehiclesData_duplicate.add(_vehiclesData_sorted.elementAt(i));
            print('Offline');
          }
        } else if (query == "Idle") {
          if (ignition.contains("true") &&
              !model.online.toString().contains("offline") &&
              double.parse(model.speed.toString()) < 1.0) {
            _vehiclesData_duplicate.add(_vehiclesData_sorted.elementAt(i));
            print('Idle');
          }
        } else if (filtertext == "In Active") {
          if (model.online.toString().toLowerCase().contains("offline") &&
              model.time.toString().toLowerCase().contains("not connected")) {
            _vehiclesData_duplicate.add(_vehiclesData_sorted.elementAt(i));
            print('Offline');
          }
        } else if (query == "Running") {
          if (model.online.toString().toLowerCase().contains("online")) {
            _vehiclesData_duplicate.add(_vehiclesData_sorted.elementAt(i));
            print('Running');
          }
        } else if (query == "Stopped") {
          if (ignition.contains("false") &&
              model.time.toString().toLowerCase() != "not connected" &&
              double.parse(model.speed.toString()) < 1.0) {
            _vehiclesData_duplicate.add(_vehiclesData_sorted.elementAt(i));
            print('Stopped');
          }
        } else if (query == "expire") {
          if (model.time.toString().toLowerCase().contains("expire")) {
            _vehiclesData_duplicate.add(_vehiclesData_sorted.elementAt(i));
            print('expire');
          }
        } else {
          if (model.name.toString().toLowerCase().contains(query
                  .toLowerCase()) /*||
                  model.devicedata!.first.imei!.contains(query.toLowerCase())*/
              ) {
            _vehiclesData_duplicate.add(_vehiclesData_sorted.elementAt(i));
            print('item exists');
          }
        }
      }

      setState(() {});
    } else {
      if (query == "All") {
        _vehiclesData_duplicate.addAll(_vehiclesData_sorted);
        print('All');
      }
    }
  }

  Color randomColor() =>
      Color((Random().nextDouble() * 0xFFFFFF).toInt() << 0).withOpacity(1.0);

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
    var expirationdate = productData.deviceData!.expirationDate.toString();
    String iconpathurl = productData.icon!.path.toString();
    iconpathurl = StaticVarMethod.baseurlall + "/" + iconpathurl;

    if (expirationdate.contains("expire")) {
      expirationdate = "Expired";
    } else if (expirationdate.contains("null")) {
      expirationdate = "Not Found";
    } else {
      DateTime lastUpdate = DateTime.parse(expirationdate);
      expirationdate =
          DateFormat('MM-dd-yyyy').format(lastUpdate.toLocal()).toString();
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
      // iconpath = 'assets/tbtrack/truck_sidestop.png';
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

    // String deviceweight="N/A";
    // if(productData.sensors!.length>0){
    //   for(int i = 0; i < productData.sensors!.length; i++){
    //     var name= productData.sensors![i].name.toString();
    //     var type= productData.sensors![i].type.toString();
    //
    //     if(name.contains("weight") || name.contains("Weight") || type.contains("load_calibration")){
    //       deviceweight=productData.sensors![i].value!.toString();
    //
    //     }
    //
    //   }
    // }

    // <info><event>0</event><sat>13</sat><hdop>0.9</hdop><odometer>678030</odometer>
    // <status>61</status><ignition>false</ignition><input>0</input><output>0</output>
    // <power>12.51</power><battery>4.07</battery><adc2>0</adc2><adc3>0</adc3><sequence>80</sequence>
    // <distance>0</distance><totaldistance>639240.95</totaldistance><motion>false</motion>
    // <valid>true</valid><enginehours>51916</enginehours><gsmsignal>13</gsmsignal></info>

    return GestureDetector(
      onTap: () {
        StaticVarMethod.deviceName = productData.name.toString();
        StaticVarMethod.deviceId = productData.id.toString();
        StaticVarMethod.imei = productData.deviceData!.imei.toString();
        StaticVarMethod.simno = productData.deviceData!.simNumber.toString();
        StaticVarMethod.lat = productData.lat!.toDouble();
        StaticVarMethod.lng = productData.lng!.toDouble();
        StaticVarMethod.devicestatus = devicestatus;
        StaticVarMethod.devicestatuscolor = statuscolor;

        // if(productData.sensors!.length>0){
        //   for(int i = 0; i < productData.sensors!.length; i++){
        //    var name= productData.sensors![i].name.toString();
        //    var type= productData.sensors![i].type.toString();
        //
        //    if(name.contains("weight") || name.contains("Weight") || type.contains("load_calibration") || type.contains("fuel_calibration")){
        //      StaticVarMethod.deviceweight=productData.sensors![i].value!;
        //
        //    }
        //
        //   }
        // }
        showModalBottomSheet<void>(
          context: context,
          //isDismissible: false,
          //barrierColor: Colors.transparent,
          backgroundColor: Colors.transparent,
          builder: (BuildContext context) {
            return Container(
                //color: Colors.transparent,
                height: MediaQuery.of(context).size.height / 1.5,
                child: _showbottomPopup());
          },
        );
        //Fluttertoast.showToast(msg: 'Click ${productData.name}', toastLength: Toast.LENGTH_SHORT);
      },
      child: Container(
        margin: EdgeInsets.fromLTRB(3, 10, 3, 0),
        //padding:EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 2,
          color: Color(0xffEFEEF8),
          child: Container(
            decoration: BoxDecoration(
              /*border: Border(
                  bottom: BorderSide(
                    color: Colors.grey[200]!,
                    width: 1.0,
                  )
              ),*/
              color: Color(0xffEFEEF8),
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            padding: EdgeInsets.fromLTRB(10, 2, 10, 0),
            margin: EdgeInsets.only(left: 5),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    // ClipRRect(
                    //   borderRadius: BorderRadius.all(Radius.circular(10)),
                    //
                    //   child:Image.asset("assets/rotatingicon/2.png", height: boxImageSize,width: boxImageSize)),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            margin: EdgeInsets.only(top: 0),
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              // color: (carstatus.contains("online"))? Colors.green.withOpacity(0.3):Colors.red.withOpacity(0.3),

                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                            ),
                            child: Image.asset(iconpath, height: 60, width: 60)

                            // child: buildCacheNetworkImage(width: 40, height: 40, url: iconpathurl),
                            ),
                      ],
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Container(
                      height: 25,
                      width: 60,
                      child: Text(
                        '' + productData.deviceData!.name.toString(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff494C60),
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _showbottomPopup() {
    //double imageSize = MediaQuery.of(context).size.width/10;
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter mystate) {
      return Container(
        margin: EdgeInsets.only(left: 0, right: 0, bottom: 0),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(10)),
        child: Container(
          padding: EdgeInsets.only(left: 15, right: 15, top: 1, bottom: 30),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(20)),

              //borderRadius: BorderRadius.only(topLeft:Radius.circular(20),topRight:Radius.circular(20) ),
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
                  margin: EdgeInsets.only(top: 12),
                  child: Center(
                    child: Text('' + StaticVarMethod.deviceName,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.bold)),
                  )),
              // Container(
              //     margin: EdgeInsets.only(top: 12),
              //       child: Text('Filter',
              //           style: TextStyle(color: Colors.black,fontSize: 15)),
              // ),
              // Container(
              //   margin: EdgeInsets.only(top: 12),
              //   child: Row(
              //     children: [
              //
              //       Expanded(
              //           child: OutlinedButton(
              //               onPressed: () {
              //                 setState(() {
              //                   _selectedperiod = 0;
              //                   showReport();
              //                 });
              //               },
              //               style: ButtonStyle(
              //                   minimumSize: MaterialStateProperty.all(
              //                       Size(0, 40)
              //                   ),
              //                   overlayColor: MaterialStateProperty.all(Colors.transparent),
              //                   shape: MaterialStateProperty.all(
              //                       RoundedRectangleBorder(
              //                         borderRadius: BorderRadius.circular(20.0),
              //                       )
              //                   ),
              //                   side: MaterialStateProperty.all(
              //                     BorderSide(
              //                         color: Colors.grey,
              //                         width: 1.0
              //                     ),
              //                   )
              //               ),
              //               child: Text(
              //                 'Last Hours',
              //                 style: TextStyle(
              //                     color: Colors.grey,
              //                     //fontWeight: FontWeight.bold,
              //                     fontSize: 15
              //                 ),
              //                 textAlign: TextAlign.center,
              //               )
              //           )
              //
              //       ),
              //       SizedBox(
              //         width: 10,
              //       ),
              //       Expanded(
              //           child: OutlinedButton(
              //               onPressed: () {
              //
              //                 setState(() {
              //                   _selectedperiod = 1;
              //                   showReport();
              //                 });
              //               },
              //               style: ButtonStyle(
              //                   minimumSize: MaterialStateProperty.all(
              //                       Size(0, 40)
              //                   ),
              //                   overlayColor: MaterialStateProperty.all(Colors.transparent),
              //                   shape: MaterialStateProperty.all(
              //                       RoundedRectangleBorder(
              //                         borderRadius: BorderRadius.circular(20.0),
              //                       )
              //                   ),
              //                   side: MaterialStateProperty.all(
              //                     BorderSide(
              //                         color: Colors.grey,
              //                         width: 1.0
              //                     ),
              //                   )
              //               ),
              //               child: Text(
              //                 'Today',
              //                 style: TextStyle(
              //                     color: Colors.grey,
              //                     //fontWeight: FontWeight.bold,
              //                     fontSize: 15
              //                 ),
              //                 textAlign: TextAlign.center,
              //               )
              //           )
              //
              //       ),
              //       SizedBox(
              //         width: 10,
              //       ),
              //       Expanded(
              //           child:OutlinedButton(
              //               onPressed: () {
              //                 setState(() {
              //                   _selectedperiod = 2;
              //                   showReport();
              //                 });
              //               },
              //               style: ButtonStyle(
              //                   minimumSize: MaterialStateProperty.all(
              //                       Size(0, 40)
              //                   ),
              //                   overlayColor: MaterialStateProperty.all(Colors.transparent),
              //                   shape: MaterialStateProperty.all(
              //                       RoundedRectangleBorder(
              //                         borderRadius: BorderRadius.circular(20.0),
              //                       )
              //                   ),
              //                   side: MaterialStateProperty.all(
              //                     BorderSide(
              //                         color: Colors.grey,
              //                         width: 1.0
              //                     ),
              //                   )
              //               ),
              //               child: Text(
              //                 'Yesterday',
              //                 style: TextStyle(
              //                     color: Colors.grey,
              //                     //fontWeight: FontWeight.bold,
              //                     fontSize: 15
              //                 ),
              //                 textAlign: TextAlign.center,
              //               )
              //           )
              //       ),
              //       SizedBox(
              //         width: 10,
              //       ),
              //
              //     ],
              //   ),
              // ),
              // Container(
              //   margin: EdgeInsets.only(top: 12),
              //   child: Row(
              //     children: [
              //
              //       Expanded(
              //           child: OutlinedButton(
              //               onPressed: () {
              //                 setState(() {
              //                   _selectedperiod = 3;
              //                   showReport();
              //                 });
              //               },
              //               style: ButtonStyle(
              //                   minimumSize: MaterialStateProperty.all(
              //                       Size(0, 40)
              //                   ),
              //                   overlayColor: MaterialStateProperty.all(Colors.transparent),
              //                   shape: MaterialStateProperty.all(
              //                       RoundedRectangleBorder(
              //                         borderRadius: BorderRadius.circular(20.0),
              //                       )
              //                   ),
              //                   side: MaterialStateProperty.all(
              //                     BorderSide(
              //                         color: Colors.grey,
              //                         width: 1.0
              //                     ),
              //                   )
              //               ),
              //               child: Text(
              //                 'Before 2 days',
              //                 style: TextStyle(
              //                     color: Colors.grey,
              //                     //fontWeight: FontWeight.bold,
              //                     fontSize: 11
              //                 ),
              //                 textAlign: TextAlign.center,
              //               )
              //           )
              //
              //       ),
              //       SizedBox(
              //         width: 10,
              //       ),
              //       Expanded(
              //           child: OutlinedButton(
              //               onPressed: () {
              //                 setState(() {
              //                   _selectedperiod = 4;
              //                 });
              //               },
              //               style: ButtonStyle(
              //                   minimumSize: MaterialStateProperty.all(
              //                       Size(0, 40)
              //                   ),
              //                   overlayColor: MaterialStateProperty.all(Colors.transparent),
              //                   shape: MaterialStateProperty.all(
              //                       RoundedRectangleBorder(
              //                         borderRadius: BorderRadius.circular(20.0),
              //                       )
              //                   ),
              //                   side: MaterialStateProperty.all(
              //                     BorderSide(
              //                         color: Colors.grey,
              //                         width: 1.0
              //                     ),
              //                   )
              //               ),
              //               child: Text(
              //                 'Last 7 days',
              //                 style: TextStyle(
              //                     color: Colors.grey,
              //                     //fontWeight: FontWeight.bold,
              //                     fontSize: 11
              //                 ),
              //                 textAlign: TextAlign.center,
              //               )
              //           )
              //
              //       ),
              //       SizedBox(
              //         width: 10,
              //       ),
              //       Expanded(
              //           child:OutlinedButton(
              //               onPressed: () {
              //                 /* Navigator.push(
              //               context,
              //               MaterialPageRoute(
              //                   builder: (context) => mainmapscreen()),
              //             );*/
              //                 //Fluttertoast.showToast(msg: 'Item has been added to Shopping Cart');
              //               },
              //               style: ButtonStyle(
              //                   minimumSize: MaterialStateProperty.all(
              //                       Size(0, 40)
              //                   ),
              //                   overlayColor: MaterialStateProperty.all(Colors.transparent),
              //                   shape: MaterialStateProperty.all(
              //                       RoundedRectangleBorder(
              //                         borderRadius: BorderRadius.circular(20.0),
              //                       )
              //                   ),
              //                   side: MaterialStateProperty.all(
              //                     BorderSide(
              //                         color: Colors.grey,
              //                         width: 1.0
              //                     ),
              //                   )
              //               ),
              //               child: Text(
              //                 'Last Week',
              //                 style: TextStyle(
              //                     color: Colors.grey,
              //                     //fontWeight: FontWeight.bold,
              //                     fontSize: 15
              //                 ),
              //                 textAlign: TextAlign.center,
              //               )
              //           )
              //       ),
              //       SizedBox(
              //         width: 10,
              //       ),
              //
              //     ],
              //   ),
              // ),
              // Container(
              //   margin: EdgeInsets.only(top: 12),
              //   child: Row(
              //     children: [
              //
              //       Expanded(
              //           child:OutlinedButton(
              //               onPressed: () {
              //                 setState(() {
              //                   _selectedperiod = 5;
              //                 });
              //               },
              //               style: ButtonStyle(
              //                   minimumSize: MaterialStateProperty.all(
              //                       Size(0, 40)
              //                   ),
              //                   overlayColor: MaterialStateProperty.all(Colors.transparent),
              //                   shape: MaterialStateProperty.all(
              //                       RoundedRectangleBorder(
              //                         borderRadius: BorderRadius.circular(20.0),
              //                       )
              //                   ),
              //                   side: MaterialStateProperty.all(
              //                     BorderSide(
              //                         color: Colors.grey,
              //                         width: 1.0
              //                     ),
              //                   )
              //               ),
              //               child: Text(
              //                 'Select Custom Date & Time',
              //                 style: TextStyle(
              //                     color: Colors.grey,
              //                     //fontWeight: FontWeight.bold,
              //                     fontSize: 15
              //                 ),
              //                 textAlign: TextAlign.center,
              //               )
              //           )
              //       ),
              //       SizedBox(
              //         width: 3,
              //       ),
              //
              //     ],
              //   ),
              // ),
              // _selectedperiod == 5
              //     ?Container(
              //     child: new Column(
              //       children: <Widget>[
              //         Row(
              //           mainAxisAlignment:
              //           MainAxisAlignment.spaceBetween,
              //           children: <Widget>[
              //             ElevatedButton(
              //               //color: CustomColor.primaryColor,
              //               onPressed: () => _selectFromDate(
              //                   context, setState),
              //               child: Text(
              //                   formatReportDate(
              //                       _selectedFromDate),
              //                   style: TextStyle(
              //                       color: Colors.white)),
              //             ),
              //             ElevatedButton(
              //               // color: CustomColor.primaryColor,
              //               onPressed: () {setState(() {
              //                 _fromTime(context);  });
              //
              //               },
              //               /*style: ElevatedButton.styleFrom(
              //                 backgroundColor: Colors.red,
              //                 animationDuration: 3
              //                 ),*/
              //               child: Text(
              //                   formatReportTime(
              //                       selectedFromTime),
              //                   style: TextStyle(
              //                       backgroundColor: Colors.grey,
              //                       color: Colors.white)),
              //             ),
              //           ],
              //         ),
              //         Row(
              //           mainAxisAlignment:
              //           MainAxisAlignment.spaceBetween,
              //           children: <Widget>[
              //             ElevatedButton(
              //               //color: CustomColor.primaryColor,
              //               onPressed: () =>
              //                   _selectToDate(context, setState),
              //               child: Text(
              //                   formatReportDate(_selectedToDate),
              //                   style: TextStyle(
              //                       color: Colors.white)),
              //             ),
              //             ElevatedButton(
              //               // color: CustomColor.primaryColor,
              //               onPressed: () {setState(() {
              //                 _toTime(context);  });
              //
              //               },
              //               child: Text(
              //                   formatReportTime(selectedToTime),
              //                   style: TextStyle(
              //                       color: Colors.white)),
              //             ),
              //           ],
              //         )
              //       ],
              //     ))
              //     :Container(),

              CalendarTimeline(
                initialDate: DateTime.now(),
                firstDate: DateTime(2023, 10, 01),
                lastDate: DateTime(2025, 11, 20),
                onDateSelected: (date) {
                  StaticVarMethod.fromdate =
                      DateFormat('yyyy-MM-dd').format(date);
                  StaticVarMethod.todate =
                      DateFormat('yyyy-MM-dd').format(date);

                  //StaticVarMethod.todate = DateFormat('yyyy-MM-dd').format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day+1));
                  // StaticVarMethod.fromtime =  DateFormat("HH:mm:ss").format(DateTime(DateTime.now().hour-14));
                  StaticVarMethod.fromtime = "00:01";
                  StaticVarMethod.totime = "23:59";
                  // StaticVarMethod.totime =  DateFormat("HH:mm:ss").format(DateTime(DateTime.now().hour+12));

                  //    DateFormat("HH:mm:ss").format(DateTime(DateTime.now().hour-8));
                  //  StaticVarMethod.totime = toTime;
                  print(date);
                  print(date);
                  print(date);

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => fuelplayback()),
                  );
                },
                leftMargin: 20,
                monthColor: Colors.blueGrey,
                dayColor: Colors.teal[200],
                activeDayColor: Colors.white,
                activeBackgroundDayColor: Colors.redAccent[100],
                locale: 'en_ISO',
              ),
              Container(
                margin: EdgeInsets.all(10),
                child: Text(
                  'Select Custom Date & Time',
                  style: TextStyle(
                      color: Colors.grey,
                      //fontWeight: FontWeight.bold,
                      fontSize: 15),
                  textAlign: TextAlign.center,
                ),
              ),
              Container(

                  // margin: EdgeInsets.all(20),
                  child: new Column(
                children: <Widget>[
                  Container(

                      //  margin: EdgeInsets.all(20),
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueGrey.shade900,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 15, vertical: 15),
                            textStyle: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        //color: CustomColor.primaryColor,
                        onPressed: () => _selectFromDate(context, setState),
                        child: Text(formatReportDate(_selectedFromDate),
                            style: TextStyle(color: Colors.white)),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueGrey.shade900,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 15, vertical: 15),
                            textStyle: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        // color: CustomColor.primaryColor,
                        onPressed: () {
                          setState(() {
                            _fromTime(context);
                          });
                        },
                        /*style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              animationDuration: 3
                              ),*/
                        child: Text(
                            (selectedFromTimeequel == selectedFromTime)
                                ? "00:00"
                                : formatReportTime(selectedFromTime),
                            style: TextStyle(
                                //backgroundColor: Colors.blue,
                                color: Colors.white)),
                      ),
                    ],
                  )),
                  Container(
                      margin: EdgeInsets.only(top: 20 /*,right: 20*/),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueGrey.shade900,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 15),
                                textStyle: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            //color: CustomColor.primaryColor,
                            onPressed: () => _selectToDate(context, setState),
                            child: Text(formatReportDate(_selectedToDate),
                                style: TextStyle(color: Colors.white)),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueGrey.shade900,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 15),
                                textStyle: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            // color: CustomColor.primaryColor,
                            onPressed: () {
                              setState(() {
                                _toTime(context);
                              });
                            },
                            child: Text(formatReportTime(selectedToTime),
                                style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      )),
                ],
              )),

              Container(
                margin: EdgeInsets.symmetric(vertical: 8),
                alignment: Alignment.center,
                child: OutlinedButton.icon(
                  onPressed: () {
                    _selectedperiod = 9;
                    showReport();
                    // Fluttertoast.showToast(msg: 'Press Outline Button', toastLength: Toast.LENGTH_SHORT);
                  },
                  style: ButtonStyle(
                      minimumSize: MaterialStateProperty.all(Size(0, 40)),
                      overlayColor: MaterialStateProperty.all(Colors.grey),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      )),
                      side: MaterialStateProperty.all(
                        BorderSide(color: Colors.grey, width: 1.0),
                      )),
                  icon: Icon(
                    Icons.play_arrow,
                    size: 24.0,
                    color: Colors.grey,
                  ),
                  label: Text('ViewPlaybackHistory'.tr,
                      style: TextStyle(
                          color: Colors.grey,
                          //fontWeight: FontWeight.bold,
                          fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      );
    });
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
      initialTime: selectedFromTime,
    );
    if (picked != null && picked != selectedFromTime)
      setState(() {
        selectedFromTime = picked;
        var hour = selectedFromTime.hour;
        var minute = selectedFromTime.minute;
        if (hour.toString().length == 1 && minute.toString().length == 1) {
          fromTime = "0$hour:0$minute";
          print(fromTime);
        } else if (hour.toString().length == 1) {
          fromTime = "0$hour:$minute";
          print(fromTime);
        } else if (minute.toString().length == 1) {
          fromTime = "$hour:0$minute";
          print(fromTime);
        } else {
          fromTime = "$hour:$minute";
          print(fromTime);
        }

        //var formattedDate = "${picked.year}-${picked.month}-${picked.day}";
      });
  }

  Future<Null> _toTime(BuildContext context) async {
    var picked = await showTimePicker(
      context: context,
      initialTime: selectedToTime,
    );
    if (picked != null && picked != selectedToTime)
      setState(() {
        selectedToTime = picked;
        var hour = selectedToTime.hour;
        var minute = selectedToTime.minute;
        if (hour.toString().length == 1 && minute.toString().length == 1) {
          toTime = "0$hour:0$minute";
          print(toTime);
        } else if (hour.toString().length == 1) {
          toTime = "0$hour:$minute";
          print(toTime);
        } else if (minute.toString().length == 1) {
          toTime = "$hour:0$minute";
          print(toTime);
        } else {
          toTime = "$hour:$minute";
          print(toTime);
        }

        //  TimeOfDayFormat.H_colon_mm.toString();
        //var formattedDate = "${picked.year}-${picked.month}-${picked.day}";
      });
  }

  void showReport() {
    if (_selectedperiod == 0) {
      StaticVarMethod.fromdate = formatDateReport(DateFormat('yyyy-MM-dd')
          .format(DateTime(
              DateTime.now().year, DateTime.now().month, DateTime.now().day)));
      StaticVarMethod.todate = formatDateReport(DateFormat('yyyy-MM-dd').format(
          DateTime(
              DateTime.now().year, DateTime.now().month, DateTime.now().day)));
      StaticVarMethod.fromtime = "00:00";
      StaticVarMethod.totime = "11:59";
    } else if (_selectedperiod == 1) {
      StaticVarMethod.fromdate = formatDateReport(DateFormat('yyyy-MM-dd')
          .format(DateTime(
              DateTime.now().year, DateTime.now().month, DateTime.now().day)));
      StaticVarMethod.todate = formatDateReport(DateFormat('yyyy-MM-dd').format(
          DateTime(
              DateTime.now().year, DateTime.now().month, DateTime.now().day)));
      StaticVarMethod.fromtime = "00:00";
      StaticVarMethod.totime = "11:59";
    } else if (_selectedperiod == 2) {
      StaticVarMethod.fromdate = formatDateReport(DateFormat('yyyy-MM-dd')
          .format(DateTime(DateTime.now().year, DateTime.now().month,
              DateTime.now().day - 1)));
      StaticVarMethod.todate = formatDateReport(DateFormat('yyyy-MM-dd').format(
          DateTime(
              DateTime.now().year, DateTime.now().month, DateTime.now().day)));
      StaticVarMethod.fromtime = "00:00";
      StaticVarMethod.totime = "11:59";
    } else if (_selectedperiod == 3) {
      StaticVarMethod.fromdate = formatDateReport(DateFormat('yyyy-MM-dd')
          .format(DateTime(DateTime.now().year, DateTime.now().month,
              DateTime.now().day - 2)));
      StaticVarMethod.todate = formatDateReport(DateFormat('yyyy-MM-dd').format(
          DateTime(
              DateTime.now().year, DateTime.now().month, DateTime.now().day)));
      StaticVarMethod.fromtime = "00:00";
      StaticVarMethod.totime = "23:59";
    } else if (_selectedperiod == 4) {
      StaticVarMethod.fromdate = formatDateReport(DateFormat('yyyy-MM-dd')
          .format(DateTime(DateTime.now().year, DateTime.now().month,
              DateTime.now().day - 7)));
      StaticVarMethod.todate = formatDateReport(DateFormat('yyyy-MM-dd').format(
          DateTime(
              DateTime.now().year, DateTime.now().month, DateTime.now().day)));
      StaticVarMethod.fromtime = "00:00";
      StaticVarMethod.totime = "23:59";
    } else {
      String fromDate = formatDateReport(_selectedFromDate.toString());
      String toDate = formatDateReport(_selectedToDate.toString());
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

    //Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => fuelplayback()),
    );
    // getReport(StaticVarMethod.deviceId,StaticVarMethod.fromdate,StaticVarMethod.fromtime,StaticVarMethod.todate,StaticVarMethod.totime);
    /* Navigator.pushNamed(context, "/reportList",
        arguments: ReportArguments(device['id'], fromDate, fromTime,
            toDate, toTime, device["name"], 0));*/
  }

  // add marker
  Set<Marker> getmarkers(double lat, double lng, double course, String imei) {
    // void _addMarker(double lat, double lng,int index) {
    LatLng position = LatLng(lat, lng);

    // set initial marker
    markers.add(Marker(
      markerId: MarkerId(imei),
      anchor: Offset(0.5, 0.5),
      position: position,
      rotation: course,
      /*  infoWindow: InfoWindow(title: 'This is marker 1'),
      onTap: () {
        Fluttertoast.showToast(msg: 'Click marker', toastLength: Toast.LENGTH_SHORT);
      },*/
      icon: _markerDirection,
    ));

    if (_controller != null) {
      _controller!
          .animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, lng), 15));
    }

    return markers;
  }
  /*void _recenterall(){
    CameraUpdate u2=CameraUpdate.newLatLngBounds(LatLngBounds([]), 50);
    this._controller!.moveCamera(u2).then((void v){
      _check(u2,this._controller!);
    });
  }*/

  /* start additional function for camera update
  - we get this function from the internet
  - if we don't use this function, the camera will not work properly (Zoom to marker sometimes not work)
  */
  void _check(CameraUpdate u, GoogleMapController c) async {
    c.moveCamera(u);
    _controller!.moveCamera(u);
    LatLngBounds l1 = await c.getVisibleRegion();
    LatLngBounds l2 = await c.getVisibleRegion();

    if (l1.southwest.latitude == -90 || l2.southwest.latitude == -90)
      _check(u, c);
  }

  // when the Google Maps Camera is change, get the current position
  void _onGeoChanged(CameraPosition position) {
    _currentZoom = position.zoom;
  }

  // build google maps to used inside widget
  Widget _buildGoogleMap(double lat, double lng, double course, String imei) {
    return Container(
        height: 200,
        child: GoogleMap(
          mapType: MapType.normal,
          trafficEnabled: false,
          //compassEnabled: true,
          rotateGesturesEnabled: true,
          scrollGesturesEnabled: true,
          tiltGesturesEnabled: true,
          zoomControlsEnabled: false,
          zoomGesturesEnabled: true,
          myLocationButtonEnabled: false,
          myLocationEnabled: true,
          mapToolbarEnabled: true,
          markers: getmarkers(lat, lng, course, imei),
          //markers: Set.of((_marker != null) ? [_marker!] : []),
          initialCameraPosition: CameraPosition(
            target: LatLng(lat, lng),
            zoom: _currentZoom,
          ),
          // onCameraMove: _onGeoChanged,
          onCameraMove: (cameraPosition) {
            lat = cameraPosition.target.longitude; //gets the center longitude
            lng = cameraPosition.target.latitude; //gets the center lattitude
          },
          onMapCreated: (GoogleMapController controller) {
            _controller = controller;
            //_timerDummy = Timer(Duration(milliseconds: 300), () {
            setState(() {
              _mapLoading = true;

              _controller!.animateCamera(
                  CameraUpdate.newLatLngZoom(LatLng(lat, lng), 17));
              Fluttertoast.showToast(
                  msg:
                      '_controller.animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, lng), 17));',
                  toastLength: Toast.LENGTH_SHORT);
              /* Future.delayed(Duration(seconds: 1), () async {
              GoogleMapController controller = await _mapController.future;
              controller.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: LatLng(lat, lng),
                    zoom: 17.0,
                  ),
                ),
              );
            });*/
              /*_controller?.animateCamera(
                CameraUpdate.newCameraPosition(
                    CameraPosition(target:LatLng(lat, lng), zoom: 17)
                  //17 is new zoom level
                )
            );*/

              /*CameraUpdate u2 = CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(lat, lng), zoom: 15));

            this._controller.moveCamera(u2).then((void v) {
              _check(u2, this._controller);
            });*/
              //getmarkers(lat, lng,index);
              //_addMarker(lat, lng,index);
            });
            //  });
          },
          onTap: (pos) {
            print('currentZoom : ' + _currentZoom.toString());
          },
        ));
  }

  //
  // Widget _buildGoogleMap() {
  //   return
  //     Container(
  //       height: 80,
  //       child:GoogleMap(
  //         mapType: MapType.normal,
  //         trafficEnabled: false,
  //         compassEnabled: false,
  //         rotateGesturesEnabled: true,
  //         scrollGesturesEnabled: true,
  //         tiltGesturesEnabled: true,
  //         zoomControlsEnabled: false,
  //         zoomGesturesEnabled: true,
  //         myLocationButtonEnabled: false,
  //         myLocationEnabled: true,
  //         mapToolbarEnabled: false,
  //         markers: Set<Marker>.of(_allMarker.values),
  //         initialCameraPosition: CameraPosition(
  //           target: _initialPosition,
  //           zoom: _currentZoom,
  //         ),
  //         onCameraMove: _onGeoChanged,
  //         onCameraIdle: (){
  //           if(_isBound==false && _doneListing==true) {
  //             _isBound = true;
  //             CameraUpdate u2=CameraUpdate.newLatLngBounds(_boundsFromLatLngList(_latlng), 50);
  //             this._controller.moveCamera(u2).then((void v){
  //               _check(u2,this._controller);
  //             });
  //           }
  //         },
  //         onMapCreated: (GoogleMapController controller) {
  //           _controller = controller;
  //
  //           // we use timer for this demo
  //           // in the real application, get all marker from database
  //           // Get the marker from API and add the marker here
  //           _timerDummy = Timer(Duration(seconds: 0), () {
  //
  //             setState(() {
  //               _mapLoading = false;
  //
  //               // add all marker here
  //               /*   for (int i = 0; i < StaticVarMethod.devicelist.length; i++) {
  //
  //               if(StaticVarMethod.devicelist[i].lat != 0) {
  //
  //                   var color;
  //                   if(StaticVarMethod.devicelist[i].online!.contains('online')){
  //                     color=Colors.green;
  //                   }else if(productData.speed! > 0){
  //                     color=Colors.green;
  //                   }else{
  //                     color=Colors.red;
  //                   }
  //                   double lat = StaticVarMethod.devicelist[i].lat as double;
  //                   double lng = StaticVarMethod.devicelist[i].lng as double;
  //                   //double angle =  StaticVarMethod.devicelist[i].course as double;
  //                   LatLng position = LatLng(lat, lng);
  //                   _latlng.add(position);
  //                   _createImageLabel(label: StaticVarMethod.devicelist[i].name.toString(), imageIcon: _iconFacebook,course :StaticVarMethod.devicelist[i].course.toDouble(),color: color).then((BitmapDescriptor customIcon) {
  //                       setState(() {
  //                       _mapLoading = false;
  //                     _allMarker[MarkerId(i.toString())] = Marker(
  //                     markerId: MarkerId(i.toString()),
  //                     position: position,
  //                     //rotation: 0.0,
  //                     infoWindow: InfoWindow(
  //                         title: 'This is marker ' + (i + 1).toString()),
  //                     onTap: () {
  //                       Fluttertoast.showToast(
  //                           msg: 'Click marker ' + (i + 1).toString(),
  //                           toastLength: Toast.LENGTH_SHORT);
  //                     },
  //                     icon:  customIcon
  //                   );
  //                   });
  //                   });
  //                   if (i == StaticVarMethod.devicelist.length - 1) {
  //                     _doneListing = true;
  //                   }
  //
  //               }
  //
  //
  //           }*/
  //               updateMarker();
  //               // zoom to all marker
  //               if(_isBound==false && _doneListing==true) {
  //                 _isBound = true;
  //                 CameraUpdate u2=CameraUpdate.newLatLngBounds(_boundsFromLatLngList(_latlng), 100);
  //                 this._controller.moveCamera(u2).then((void v){
  //                   _check(u2,this._controller);
  //                 });
  //               }
  //               _mapLoading = false;
  //             });
  //
  //           });
  //         },
  //         onTap: (pos){
  //           print('currentZoom : '+_currentZoom.toString());
  //         },
  //       ),
  //     );
  // }
  //
  // updateMarker(){
  //
  //   Fluttertoast.showToast(
  //       msg: 'Click marker ' + ( 1).toString(),
  //       toastLength: Toast.LENGTH_SHORT);
  //   //_allMarker.clear();
  //   for (int i = 0; i < StaticVarMethod.devicelist.length; i++) {
  //
  //     if(StaticVarMethod.devicelist[i].lat != 0) {
  //
  //       var color;
  //       var label;
  //
  //       if(productData.speed!.toInt() > 0){
  //         color=Colors.green;
  //         label= StaticVarMethod.devicelist[i].name.toString() + '('+productData.speed!.toString()+' km)';
  //       }
  //       else  if(StaticVarMethod.devicelist[i].online!.contains('online')){
  //         color=Colors.green;
  //         label= StaticVarMethod.devicelist[i].name.toString();
  //
  //       }else{
  //         color=Colors.red;
  //         label= StaticVarMethod.devicelist[i].name.toString();
  //       }
  //       double lat = StaticVarMethod.devicelist[i].lat as double;
  //       double lng = StaticVarMethod.devicelist[i].lng as double;
  //       //double angle =  StaticVarMethod.devicelist[i].course as double;
  //       LatLng position = LatLng(lat, lng);
  //       _latlng.add(position);
  //       _createImageLabel(label: label,course :StaticVarMethod.devicelist[i].course.toDouble(),color: color).then((BitmapDescriptor customIcon) {
  //         if (mounted) {
  //           setState(() {
  //             _mapLoading = false;
  //             _allMarker[MarkerId(i.toString())] = Marker(
  //                 markerId: MarkerId(i.toString()),
  //                 position: position,
  //                 //rotation: 0.0,
  //                 infoWindow: InfoWindow(
  //                     title: 'This is marker ' + (i + 1).toString()),
  //                 onTap: () {
  //                   Fluttertoast.showToast(
  //                       msg: 'Click marker ' + (i + 1).toString(),
  //                       toastLength: Toast.LENGTH_SHORT);
  //                 },
  //                 anchor: Offset(0.5, 0.5),
  //                 icon:  customIcon
  //             );
  //           });
  //         }
  //
  //       });
  //       if (i == StaticVarMethod.devicelist.length - 1) {
  //         _doneListing = true;
  //       }
  //
  //     }
  //
  //
  //   }
  // }
  //
  // Set<Marker> getmarkers()  {
  //
  //
  // /*  return await BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: .5),
  //       "assets/icons/igniton.png"
  //   );*/
  // /*  for(int mrk = 0; mrk < vehicleList.length; mrk++){
  //     _setMarkerIcon() async {
  //       if(vehicleList[mrk].ignition == true){
  //         _markerIcon = await BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: .5),
  //             "assets/icons/igniton.png"
  //         );
  //       } else if(vehicleList[mrk].ignition == true && vehicleList[mrk].motion == false){
  //         _markerIcon = await BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: .5),
  //             "assets/icons/ignitidle.png"
  //         );
  //       } else if(vehicleList[mrk].ignition != true){
  //         _markerIcon = await BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: .5),
  //             "assets/icons/ignitoff.png"
  //         );
  //
  //       }
  //
  //
  //       return _markerIcon;
  //     }
  //     if(vehicleList[mrk].ignition == true && vehicleList[mrk].motion == false){
  //       markers.add(
  //           Marker(
  //             markerId: MarkerId(vehicleList[mrk].location.toString()),
  //             position: LatLng(vehicleList[mrk].latitude!.toDouble(), vehicleList[mrk].longitude!.toDouble()),
  //             icon:  _idlemarkerIcon,
  //             rotation: vehicleList[mrk].heading!.toDouble(),
  //             infoWindow: InfoWindow(
  //               title: vehicleList[mrk].location,
  //             ),
  //           )
  //       );
  //     }
  //     else if(vehicleList[mrk].ignition == true && vehicleList[mrk].motion == true){
  //       markers.add(
  //           Marker(
  //             markerId: MarkerId(vehicleList[mrk].location.toString()),
  //             position: LatLng(vehicleList[mrk].latitude!.toDouble(), vehicleList[mrk].longitude!.toDouble()),
  //             icon:  _markerIcon,
  //             rotation: vehicleList[mrk].heading!.toDouble(),
  //             infoWindow: InfoWindow(
  //               title: vehicleList[mrk].location,
  //             ),
  //           )
  //       );
  //     }
  //     else if(vehicleList[mrk].ignition != true) {
  //       markers.add(
  //           Marker(
  //
  //             markerId: MarkerId(vehicleList[mrk].location.toString()),
  //             position: LatLng(vehicleList[mrk].latitude!.toDouble(), vehicleList[mrk].longitude!.toDouble()),
  //             icon:  _offmarkerIcon,
  //             rotation: vehicleList[mrk].heading!.toDouble(),
  //             infoWindow: InfoWindow(
  //               title: vehicleList[mrk].location,
  //             ),
  //           )
  //       );
  //     }
  //
  //
  //   }*/
  //
  //  /* markers.add(
  //       Marker(
  //         markerId: MarkerId(vehicleList[mrk].location.toString()),
  //         position: LatLng(vehicleList[mrk].latitude!.toDouble(), vehicleList[mrk].longitude!.toDouble()),
  //         icon:  _idlemarkerIcon,
  //         rotation: vehicleList[mrk].heading!.toDouble(),
  //         infoWindow: InfoWindow(
  //           title: vehicleList[mrk].location,
  //         ),
  //       )
  //   );*/
  //   return markers;
  // }

  Future refreshData() async {
    // setState(() {
    //   _vehiclesData.clear();
    //   _loading = true;
    //   //_getData();
    // });
  }

  Widget kmandfueldetail(int deviceId) {
    var dev = deviceId;
    return FutureBuilder<History>(
        future: gpsapis.getHistory(deviceId),
        builder: (context, AsyncSnapshot<History> snapshot) {
          if (snapshot.hasData) {
            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 11, 0, 0),
                  child: Text(
                    snapshot.data!.distanceSum.toString() + ' km',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.black,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 11, 0, 0),
                  child: Text(
                    '0.00',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            );
          } else {
            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 11, 0, 0),
                  child: Text(
                    '0 km',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.black,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 11, 0, 0),
                  child: Text(
                    '0.00',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            );
          }
        });
  }

  String address = "Clik here for address!";
  String getAddress(lat, lng) {
    if (lat != null) {
      gpsapis.getGeocoder(lat, lng).then((value) => {
            if (value != null)
              {
                address = value.body,
                setState(() {}),
              }
            else
              {address = "Address not found"}
          });
    } else {
      address = "Address not found";
    }
    print(address);
    return address;
  }

  Widget addressLoad(String lat, String lng) {
    return FutureBuilder<String>(
        future: gpsapis.geocode(lat, lng),
        builder: (context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData) {
            return Container(
              //color: Colors.red,
              height: 35,
              width: 310,
              padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: Text(
                (snapshot.data!.replaceAll('"', '')),
                style: TextStyle(
                    color: Colors.black, fontFamily: "Popins", fontSize: 9),
              ),
            );
            // return Text(snapshot.data!.replaceAll('"', ''),
            //   style: TextStyle(
            //       color: Colors.black,
            //       fontFamily: "Popins",
            //       fontSize: 9),);
          } else {
            return Text("loading...");
          }
        });
  }

  launchWhatsApp(num, text) async {
    final link = WhatsAppUnilink(
      //  phoneNumber: num,
      text: text,
    );
    await launch('$link');
  }

  void _poidialogPopup(BuildContext context) {
    double imageSize = MediaQuery.of(context).size.width / 15;
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Center(
                child: Text('NearBy POI', style: TextStyle(fontSize: 12))),
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                    margin: EdgeInsets.only(top: 1, bottom: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: Column(
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  final url =
                                      'https://maps.google.com/maps?q=atm&cbll=${StaticVarMethod.lat},${StaticVarMethod.lng}';
                                  MapUtils.openMap(url);
                                  Navigator.of(context).pop();
                                },
                                child: Container(
                                    child: Column(children: <Widget>[
                                  Image.asset(
                                      "assets/nepalicon/atm_machine.png",
                                      height: imageSize,
                                      width: imageSize),
                                  Text('ATM',
                                      style:
                                          TextStyle(fontSize: 10, height: 2.0))
                                ])),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  final url =
                                      'https://maps.google.com/maps?q=Petrol Pump&cbll=${StaticVarMethod.lat},${StaticVarMethod.lng}';
                                  MapUtils.openMap(url);
                                  Navigator.of(context).pop();
                                },
                                child: Container(

                                    //color: Color(0x99FFFFFF),
                                    child: Column(children: <Widget>[
                                  Image.asset(
                                      "assets/nepalicon/petrol_pump.png",
                                      height: imageSize,
                                      width: imageSize),
                                  Text('Petrol Pump',
                                      style:
                                          TextStyle(fontSize: 10, height: 2.0))
                                ])),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  final url =
                                      'https://maps.google.com/maps?q=Gas Station&cbll=${StaticVarMethod.lat},${StaticVarMethod.lng}';
                                  MapUtils.openMap(url);
                                  Navigator.of(context).pop();
                                },
                                child: Container(
                                    child: Column(children: <Widget>[
                                  Image.asset("assets/nepalicon/gas_pump.png",
                                      height: imageSize, width: imageSize),
                                  Text('Gas Station',
                                      style:
                                          TextStyle(fontSize: 10, height: 2.0))
                                ])),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  final url =
                                      'https://maps.google.com/maps?q=Charge Station&cbll=${StaticVarMethod.lat},${StaticVarMethod.lng}';
                                  MapUtils.openMap(url);
                                  Navigator.of(context).pop();
                                },
                                child: Container(
                                    child: Column(children: <Widget>[
                                  Image.asset(
                                      "assets/nepalicon/battery_volt.png",
                                      height: imageSize,
                                      width: imageSize),
                                  Text('Charge Station',
                                      style:
                                          TextStyle(fontSize: 10, height: 2.0))
                                ])),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )),
                Container(
                    margin: EdgeInsets.only(/*top: 12,*/ bottom: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: Column(
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  final url =
                                      'https://maps.google.com/maps?q=Police Station&cbll=${StaticVarMethod.lat},${StaticVarMethod.lng}';
                                  MapUtils.openMap(url);
                                  Navigator.of(context).pop();
                                },
                                child: Container(
                                    child: Column(children: <Widget>[
                                  Image.asset(
                                      "assets/nepalicon/police_station.png",
                                      height: imageSize,
                                      width: imageSize),
                                  Text('Police Station',
                                      style:
                                          TextStyle(fontSize: 10, height: 2.0))
                                ])),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  final url =
                                      'https://maps.google.com/maps?q=Restaurant&cbll=${StaticVarMethod.lat},${StaticVarMethod.lng}';
                                  MapUtils.openMap(url);
                                  Navigator.of(context).pop();
                                },
                                child: Container(
                                    child: Column(children: <Widget>[
                                  Image.asset("assets/nepalicon/restaurant.png",
                                      height: imageSize, width: imageSize),
                                  Text('Restaurant',
                                      style:
                                          TextStyle(fontSize: 10, height: 2.0))
                                ])),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  final url =
                                      'https://maps.google.com/maps?q=hospital&cbll=${StaticVarMethod.lat},${StaticVarMethod.lng}';
                                  MapUtils.openMap(url);
                                  Navigator.of(context).pop();
                                },
                                child: Container(
                                    child: Column(children: <Widget>[
                                  Image.asset("assets/nepalicon/hospital.png",
                                      height: imageSize, width: imageSize),
                                  Text('Medical',
                                      style:
                                          TextStyle(fontSize: 10, height: 2.0))
                                ])),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  final url =
                                      'https://maps.google.com/maps?q=Restroom&cbll=${StaticVarMethod.lat},${StaticVarMethod.lng}';
                                  MapUtils.openMap(url);
                                  Navigator.of(context).pop();
                                },
                                child: Container(
                                    child: Column(children: <Widget>[
                                  Image.asset("assets/nepalicon/hotel.png",
                                      height: imageSize, width: imageSize),
                                  Text('Restroom',
                                      style:
                                          TextStyle(fontSize: 10, height: 2.0))
                                ])),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )),
              ]),
            ],
          );
        });
  }
}
