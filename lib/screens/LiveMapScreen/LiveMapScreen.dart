import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:math' as m;
import 'dart:ui' as ui;
import 'package:alxgration_speedometer/speedometer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:maktrogps/data/datasources.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:maktrogps/data/model/devices.dart';
import 'package:maktrogps/screens/lockscreenNew.dart';
import 'package:maktrogps/screens/playbackselection.dart';
import 'package:maktrogps/screens/reports/vehicle_info.dart';
import 'package:maktrogps/utils/MapUtils.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vector_math/vector_math.dart' as v;
import 'package:url_launcher/url_launcher.dart';

import '../../../config/constant.dart';
import '../../../config/static.dart';
import '../../../mapconfig/CustomColor.dart';
import '../../../mvvm/view_model/objects.dart';
import '../../../ui/reusable/Mycolor/MyColor.dart';
import '../reports/kmdetail.dart';

class LiveMapScreen extends StatefulWidget {
  LiveMapScreen({Key? key}) : super(key: key);

  @override
  _LiveMapScreenState createState() => _LiveMapScreenState();
}

class _LiveMapScreenState extends State<LiveMapScreen>
    with TickerProviderStateMixin {
  Completer<GoogleMapController> _controller = Completer();

  MapType _currentMapType = MapType.normal;
  Color _mapTypeBackgroundColor = MyColor.primaryColor;
  Color _mapTypeForegroundColor = MyColor.whiteColor;
  Color _mainColor = const Color(0xff2e414b);
  double currentZoom = 15.0;
  bool _trafficEnabled = false;
  List<Marker> _markers = <Marker>[];

  DriverData? driverData;
  bool pageDestoryed = false;
  List<LatLng> polylineCoordinates = [];
  Map<PolylineId, Polyline> polylines = {};
  Timer? _timer;
  Timer? _timer2;
  double todayDistance = 0;
  double averageSpeed = 0;
  double maxSpeed = 0;
  double spentFuel = 0;
  double startOdometer = 0;
  double endOdometer = 0;
  int engineHours = 0;
  bool isLoading = true;
  bool noData = false;
  List<LatLng> newPolylinesData = [];
  List<LatLng> parkPolylinesData = [];

  Color _trafficBackgroundButtonColor = CustomColor.primaryColor;
  Color _trafficForegroundButtonColor = Colors.white;
  late GoogleMapController mapController;

  bool isFirst = true;
  bool first = true;

  double _dialogHeight = 320.0;
  int _selectedPeriod = 0;
  late GoogleMapController _mapController;
  LatLng? oldPin;

  double _dialogHeightShare = 330.0;
  int _selectedPeriodShare = 0;

  DateTime _selectedToShareDate = DateTime.now();
  DateTime _selectedFromDate = DateTime.now();
  DateTime _selectedToDate = DateTime.now();
  TimeOfDay _selectedFromTime = TimeOfDay.now();
  TimeOfDay _selectedToTime = TimeOfDay.now();

  Animation<double>? _animation;
  final _mapMarkerSC = StreamController<List<Marker>>();
  StreamSink<List<Marker>> get _mapMarkerSink => _mapMarkerSC.sink;
  Stream<List<Marker>> get mapMarkerStream => _mapMarkerSC.stream;
  AnimationController? animationController;
  Set<Circle> _circles = Set<Circle>();
  bool isParked = false;
  String? markerId;
  bool parkingEvent = false;
  bool eventUpdated = false;
  String? eventId;
  String stopTime = "0 s";
  String runTime = "0 s";
  String idleTime = "0 s";
  String inactiveTime = "0 s";
  bool lockStatus = false;

  static const CameraPosition _initialRegion = CameraPosition(
    target: LatLng(0, 0),
    zoom: 14,
  );
  bool _statusbarLoading = true;
  List<deviceItems> devicesList = [];
  late ObjectStore objectStore;
  @override
  void initState() {
    super.initState();
    // drawPolyline();
    // drawPolyline2();
  }

  void drawPolyline() async {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
        width: 3,
        polylineId: id,
        color: Colors.blueAccent,
        points: polylineCoordinates);
    polylines[id] = polyline;
    setState(() {});
  }

  void drawPolyline2() async {
    PolylineId id = const PolylineId("polyAnim");
    Polyline polyline = Polyline(
        width: 3,
        polylineId: id,
        color: Colors.blueAccent,
        points: newPolylinesData);
    polylines[id] = polyline;
    setState(() {});
  }

  void drawPolyline3() async {
    PolylineId id = const PolylineId("polyPark");
    Polyline polyline = Polyline(
        width: 3,
        polylineId: id,
        color: Colors.blueAccent,
        points: parkPolylinesData);
    polylines[id] = polyline;
    setState(() {});
  }

  String address = "Voir l'adresse";

  Future<void> getAddressFromNominatim(double lat, double lng) async {
    try {
      final response = await http.get(
        Uri.parse('https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&zoom=18&addressdetails=1'),
        headers: {
          'User-Agent': 'FlutterGPSApp/1.0',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['display_name'] != null) {
          if (mounted) {
            setState(() {
              address = data['display_name'];
            });
          }
          print("Nominatim address found: ${data['display_name']}");
        }
      }
    } catch (e) {
      print("Nominatim geocoding error: $e");
    }
  }

  String getAddress(lat, lng) {
    if (lat != null && lng != null) {
      gpsapis.getGeocoder(lat, lng).then((value) => {
        print("API Response Status: ${value.statusCode}"),
        print("API Response Body: ${value.body}"),
        if (value != null && value.statusCode == 200 && value.body.isNotEmpty && value.body != "-")
          {
            if (mounted) {
              setState(() {
                address = value.body.trim();
              })
            }
          }
        else
          {
            // Fallback to Nominatim if primary geocoding returns "-" or fails
            print("Primary geocoding returned '-', using Nominatim fallback"),
            getAddressFromNominatim(double.parse(lat.toString()), double.parse(lng.toString())),
          }
      }).catchError((error) {
        print("Error getting address: $error");
        // Use fallback geocoding
        getAddressFromNominatim(double.parse(lat.toString()), double.parse(lng.toString()));
      });
    } else {
      if (mounted) {
        setState(() {
          address = "Adresse introuvable";
        });
      }
    }
    print("Address request for: lat=$lat, lng=$lng");
    return address;
  }

  void _onMapTypeButtonPressed() {
    setState(() {
      _currentMapType =
      _currentMapType == MapType.normal ? MapType.hybrid : MapType.normal;
      _mapTypeBackgroundColor = _currentMapType == MapType.normal
          ? MyColor.primaryColor
          : MyColor.whiteColor;
      _mapTypeForegroundColor = _currentMapType == MapType.normal
          ? MyColor.whiteColor
          : MyColor.primaryColor;
    });
  }

  void _trafficEnabledPressed() {
    setState(() {
      _trafficEnabled = _trafficEnabled == false ? true : false;
      _trafficBackgroundButtonColor =
      _trafficEnabled == false ? MyColor.whiteColor : MyColor.primaryColor;

      _trafficForegroundButtonColor =
      _trafficEnabled == false ? MyColor.primaryColor : MyColor.whiteColor;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("L'état du trafic a changé")));
    });
  }

  void reload() async {
    // Reload functionality can be implemented here if needed
  }

  @override
  void dispose() {
    pageDestoryed = true;
    if (_timer != null) {
      _timer!.cancel();
    }
    if (_timer2 != null) {
      _timer2!.cancel();
    }
    if (animationController != null) {
      animationController!.dispose();
    }
    super.dispose();
  }

  currentMapStatus(CameraPosition position) {
    currentZoom = position.zoom;
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  late double lati;
  late double lngi;
  String fUpdateTime = 'Not Found';
  String fspeed = '0';
  int? speedo = 0;
  String ftotalDistance = 'Not Found';
  String fstopDuration = 'Not Found';

  void updateMarker(deviceItems devicelist) async {
    var iconPath;
    var color;
    var label;
    int? speed = int.tryParse(devicelist.speed.toString());

    lati = devicelist.lat!.toDouble();
    lngi = devicelist.lng!.toDouble();
    fUpdateTime = devicelist.time.toString();
    fspeed = devicelist.speed.toString();
    // fspeed= (int.parse(devicelist.speed.toString())/1.6093).toStringAsFixed(0);
    speedo = int.tryParse(devicelist.speed.toString());
    ftotalDistance = devicelist.totalDistance.toString();
    fstopDuration = devicelist.stopDuration.toString();
    // String replacePath = category.replaceAll("img/markers/objects/land-", "");
    // String replacePath2 = replacePath.replaceAll(".svg", "");
    // String finalImg = replacePath2.replaceAll(RegExp('[^A-Za-z]'),'');

    Uint8List markerIcon;
    try {
      if (MediaQuery.of(context).size.aspectRatio > 0.55) {
        markerIcon = await getBytesFromAsset(iconPath, 40);
      } else {
        markerIcon = await getBytesFromAsset(iconPath, 60);
      }
    } catch (e) {
      String other = devicelist.deviceData!.traccar!.other.toString();
      String ignition = "false";
      if (other.contains("<ignition>")) {
        const start = "<ignition>";
        const end = "</ignition>";
        final startIndex = other.indexOf(start);
        final endIndex = other.indexOf(end, startIndex + start.length);
        ignition = other.substring(startIndex + start.length, endIndex);
      }
      // Check if device is offline first
      if (devicelist.online.toString().toLowerCase().contains("offline") ||
          devicelist.time.toString().toLowerCase().contains("not connected")) {
        colormain = Colors.black.withValues(alpha: 0.5);
        iconPath = "assets/tbtrack/car_topstop.png";
        color = Colors.black;
        label = devicelist.name.toString();
        if (StaticVarMethod.pref_static!
            .get(devicelist.deviceData!.imei.toString()) !=
            null)
          iconPath = "assets/tbtrack/" +
              StaticVarMethod.pref_static!
                  .get(devicelist.deviceData!.imei.toString())
                  .toString() +
              "topstop.png";
      }
      // Green - Moving (speed > 0)
      else if (int.tryParse(devicelist.speed.toString())! > 0) {
        colormain = Colors.green.withValues(alpha: 0.5);
        iconPath = "assets/tbtrack/car_toprunning.png";
        color = Colors.green;
        label = devicelist.name.toString() +
            '(' +
            devicelist.speed!.toString() +
            ' km)';
        if (StaticVarMethod.pref_static!
            .get(devicelist.deviceData!.imei.toString()) !=
            null)
          iconPath = "assets/tbtrack/" +
              StaticVarMethod.pref_static!
                  .get(devicelist.deviceData!.imei.toString())
                  .toString() +
              "toprunning.png";
      }
      // Yellow - Idle (ignition on but not moving)
      else if (ignition.contains("true") &&
          double.parse(devicelist.speed.toString()) < 1.0) {
        colormain = const Color(0xFFFFB000).withValues(alpha: 0.5);
        iconPath = 'assets/tbtrack/car_topidle.png';
        color = Colors.yellow;
        label = devicelist.name.toString();
        if (StaticVarMethod.pref_static!
            .get(devicelist.deviceData!.imei.toString()) !=
            null)
          iconPath = "assets/tbtrack/" +
              StaticVarMethod.pref_static!
                  .get(devicelist.deviceData!.imei.toString())
                  .toString() +
              "topidle.png";
      }
      // Red - Stopped (ignition off, not moving)
      else {
        color = Colors.red;
        colormain = Colors.red.withValues(alpha: 0.5);
        iconPath = "assets/tbtrack/car_topstop.png";
        label = devicelist.name.toString();
        if (StaticVarMethod.pref_static!
            .get(devicelist.deviceData!.imei.toString()) !=
            null)
          iconPath = "assets/tbtrack/" +
              StaticVarMethod.pref_static!
                  .get(devicelist.deviceData!.imei.toString())
                  .toString() +
              "topstop.png";
      }
      if (MediaQuery.of(context).size.aspectRatio > 0.55) {
        markerIcon = await getBytesFromAsset(iconPath, 40);
      } else {
        markerIcon = await getBytesFromAsset(iconPath, 60);
      }
    }

    var pinPosition = LatLng(double.parse(devicelist.lat.toString()),
        double.parse(devicelist.lng.toString()));

    if (first) {
      CameraPosition cPosition = CameraPosition(
        target: LatLng(double.parse(devicelist.lat.toString()),
            double.parse(devicelist.lng.toString())),
        zoom: currentZoom,
      );

      final pickupMarker = Marker(
        markerId: MarkerId(StaticVarMethod.imei.toString()),
        position: pinPosition,
        rotation: double.parse(devicelist.course.toString()),
        icon: BitmapDescriptor.fromBytes(markerIcon),
      );

      //Adding a delay and then showing the marker on screen
      await Future.delayed(const Duration(milliseconds: 500));

      _markers.add(pickupMarker);
      _mapMarkerSink.add(_markers);

      oldPin = LatLng(double.parse(devicelist.lat.toString()),
          double.parse(devicelist.lng.toString()));

      final GoogleMapController controller = await _controller.future;
      controller.moveCamera(CameraUpdate.newCameraPosition(cPosition));
      first = false;
    }
    // var pinPosition =  LatLng(
    //     double.parse(value.data![0][2]), double.parse(value.data![0][3]));
    // _markers.removeWhere((m) => m.markerId.value == args.imei);

    getAddress(double.parse(devicelist.lat.toString()),
        double.parse(devicelist.lng.toString()));
    if (!first) {
      Future.delayed(const Duration(seconds: 2)).then((value) {
        if (oldPin != pinPosition) {
          animateCar(
              oldPin!.latitude,
              oldPin!.longitude,
              pinPosition.latitude,
              pinPosition.longitude,
              _mapMarkerSink,
              this,
              _mapController,
              markerIcon);
        }
      });
    }
  }

  animateCar(
      double fromLat, //Starting latitude
      double fromLong, //Starting longitude
      double toLat, //Ending latitude
      double toLong, //Ending longitude
      StreamSink<List<Marker>>
      mapMarkerSink, //Stream build of map to update the UI
      TickerProvider
      provider, //Ticker provider of the widget. This is used for animation
      GoogleMapController controller,
      markerIcon //Google map controller of our widget
      ) async {
    final double bearing =
    getBearing(LatLng(fromLat, fromLong), LatLng(toLat, toLong));

    _markers.clear();

    var carMarker = Marker(
        markerId: const MarkerId("driverMarker"),
        position: LatLng(fromLat, fromLong),
        icon: BitmapDescriptor.fromBytes(markerIcon),
        anchor: const Offset(0.5, 0.5),
        flat: true,
        rotation: bearing,
        draggable: false);

    //Adding initial marker to the start location.
    _markers.add(carMarker);
    mapMarkerSink.add(_markers);
    animationController = AnimationController(
      duration: const Duration(seconds: 10), //Animation duration of marker
      vsync: provider, //From the widget
    );

    Tween<double> tween = Tween(begin: 0, end: 1);

    _animation = tween.animate(animationController!)
      ..addListener(() async {
        //We are calculating new latitude and logitude for our marker
        final v = _animation!.value;
        double lng = v * toLong + (1 - v) * fromLong;
        double lat = v * toLat + (1 - v) * fromLat;
        LatLng newPos = LatLng(lat, lng);

        //Removing old marker if present in the marker array
        if (_markers.contains(carMarker)) _markers.remove(carMarker);

        //New marker location
        carMarker = Marker(
            markerId: const MarkerId("driverMarker"),
            position: newPos,
            icon: BitmapDescriptor.fromBytes(markerIcon),
            anchor: const Offset(0.5, 0.5),
            flat: true,
            rotation: bearing,
            draggable: false);

        //Adding new marker to our list and updating the google map UI.
        _markers.add(carMarker);
        mapMarkerSink.add(_markers);
        newPolylinesData.add(carMarker.position);
        oldPin = newPos;
        //Moving the google camera to the new animated location.
        // controller.animateCamera(CameraUpdate.newCameraPosition(
        //     CameraPosition(target: newPos, zoom: currentZoom)));
      });

    polylineCoordinates.add(oldPin!);
    animationController!.forward();
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(toLat, toLong), zoom: currentZoom)));
    newPolylinesData.clear();
    if (polylineCoordinates.length > 20) {
      polylineCoordinates.removeRange(0, 10);
    }
    // Future.delayed(Duration(seconds: 7)).then((value) => {
    //   controller.animateCamera(CameraUpdate.newCameraPosition(
    //       CameraPosition(target: LatLng(toLat, toLong), zoom: currentZoom)))
    // });
  }

  double getBearing(LatLng begin, LatLng end) {
    double lat = (begin.latitude - end.latitude).abs();
    double lng = (begin.longitude - end.longitude).abs();

    if (begin.latitude < end.latitude && begin.longitude < end.longitude) {
      return v.degrees(m.atan(lng / lat));
    } else if (begin.latitude >= end.latitude &&
        begin.longitude < end.longitude) {
      return (90 - v.degrees(m.atan(lng / lat))) + 90;
    } else if (begin.latitude >= end.latitude &&
        begin.longitude >= end.longitude) {
      return v.degrees(m.atan(lng / lat)) + 180;
    } else if (begin.latitude < end.latitude &&
        begin.longitude >= end.longitude) {
      return (90 - v.degrees(m.atan(lng / lat))) + 270;
    }
    return -1;
  }

  @override
  Widget build(BuildContext context) {
    objectStore = Provider.of<ObjectStore>(context);
    devicesList = objectStore.objects;

    deviceItems? devicemodel;
    final matching = devicesList.where((i) =>
        i.deviceData?.imei != null &&
        i.deviceData!.imei!.contains(StaticVarMethod.imei));
    if (matching.isNotEmpty) {
      devicemodel = matching.first;
      updateMarker(devicemodel);
      isLoading = false;
      noData = false;
    } else {
      isLoading = false;
      noData = true;
    }

    final double boxImageSize = (MediaQuery.of(context).size.width / 12);

    return SafeArea(
        child: Scaffold(
          body: !isLoading
              ? !noData
              ? Stack(children: <Widget>[
            buildMap(),
            //speedometer(),

            Positioned(
              bottom: 220,
              left: 16,
              child: Container(
                width: 75,
                height: 75,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white,
                      Colors.grey.shade50,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    width: 3,
                    color: const Color(0xff0344a0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      fspeed,
                      style: const TextStyle(
                        color: Color(0xff0344a0),
                        fontWeight: FontWeight.w800,
                        fontSize: 24,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'km/h',
                      style: TextStyle(
                        color: Color(0xff0344a0),
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Positioned(
              top: 80,
              right: 16,
              child: GestureDetector(
                onTap: () {
                  _onMapTypeButtonPressed();
                },
                child: Container(
                  padding: const EdgeInsets.all(5),
                  width: 36,
                  height: 36,
                  decoration: new BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.rectangle,
                    // borderRadius:BorderRadius.only(topLeft:Radius.circular(8),topRight:Radius.circular(8)),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      const BoxShadow(
                        color: Colors.black26,
                        // blurRadius: 10.0,
                        //offset: const Offset(0.0, 10.0),
                      ),
                    ],
                  ),
                  // color: Colors.white,
                  //color: Color(0x99FFFFFF),
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    child: ClipRRect(
                        borderRadius:
                        const BorderRadius.all(Radius.circular(0)),
                        child: Image.asset(
                          "assets/images/layers.png",
                          height: 1,
                          width: 1,
                          color: const Color(0xff0D3D65),
                        )),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 120,
              right: 16,
              child: GestureDetector(
                onTap: () {
                  _trafficEnabledPressed();
                },
                child: Container(
                  padding: const EdgeInsets.all(5),
                  width: 36,
                  height: 36,
                  decoration: new BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.rectangle,
                    // borderRadius:BorderRadius.only(topLeft:Radius.circular(8),topRight:Radius.circular(8)),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      const BoxShadow(
                        color: Colors.black26,
                        // blurRadius: 10.0,
                        //offset: const Offset(0.0, 10.0),
                      ),
                    ],
                  ),
                  // color: Colors.white,
                  //color: Color(0x99FFFFFF),
                  child: const Icon(
                    Icons.traffic_outlined,
                    color: Color(0xff0D3D65),
                    size: 25,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 160,
              right: 16,
              child: GestureDetector(
                onTap: () async {
                  //var location = await currentLocation.getLocation();
                  String url ="https://www.google.com/maps/dir/?api=1&destination="
                      + (StaticVarMethod.lat.toString() + ","
                          + StaticVarMethod.lng.toString()) + "&travelmode=walking";
                  // String url ="https://www.google.com/maps/dir/?api=1&destination="
                  //     + ("31.5121208" + ","
                  //         + "74.3189183") + "&travelmode=walking";
                  //https://www.google.com/maps/dir/31.5121208,74.3189183/31.5082421,74.315528/@31.5101906,74.3150513,17z/data=!3m1!4b1!4m2!4m1!3e2
                  //final url="https://www.google.com/maps/dir/"+ StaticVarMethod.lat.toString() + ","+ StaticVarMethod.lng.toString() + "/"+location.latitude.toString()+","+location.longitude.toString()+"/@"+location.latitude.toString()+","+location.longitude.toString()+",15z/data=!4m2!4m1!3e0";
                  //final url ='https://www.google.streetview:cbll=${StaticVarMethod.lat},${StaticVarMethod.lng}';
                  if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(Uri.parse(url));
                  } else {
                    throw 'Could not launch $url';
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(5),
                  width: 36,
                  height: 36,
                  decoration: new BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.rectangle,
                    // borderRadius:BorderRadius.only(topLeft:Radius.circular(8),topRight:Radius.circular(8)),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      const BoxShadow(
                        color: Colors.black26,
                        // blurRadius: 10.0,
                        //offset: const Offset(0.0, 10.0),
                      ),
                    ],
                  ),
                  // color: Colors.white,
                  //color: Color(0x99FFFFFF),
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    child: ClipRRect(
                        borderRadius:
                        const BorderRadius.all(Radius.circular(0)),
                        child: Image.asset(
                          "assets/images/arrow.png",
                          height: 1,
                          width: 1,
                          color: const Color(0xff0D3D65),
                        )),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 200,
              right: 16,
              child: GestureDetector(
                onTap: () async {
                  final url =
                      'https://maps.google.com/maps?q=&layer=c&cbll=${StaticVarMethod.lat},${StaticVarMethod.lng}&cbp=11,0,0,0,0,';
                  /*      if (await canLaunchUrl(Uri.parse(url))) {
                  await launchUrl(Uri.parse(url));
                } else {
                  throw 'Could not launch $url';
                }*/

                  MapUtils.openMap(url);

                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) => Browser(
                  //           dashboardName: "Street View",
                  //           dashboardURL: url,
                  //         )));
                },
                child: Container(
                  padding: const EdgeInsets.all(5),
                  width: 36,
                  height: 36,
                  decoration: new BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.rectangle,
                    // borderRadius:BorderRadius.only(topLeft:Radius.circular(8),topRight:Radius.circular(8)),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      const BoxShadow(
                        color: Colors.black26,
                        // blurRadius: 10.0,
                        //offset: const Offset(0.0, 10.0),
                      ),
                    ],
                  ),
                  // color: Colors.white,
                  //color: Color(0x99FFFFFF),
                  child: const Icon(
                    FontAwesomeIcons.streetView,
                    color: Color(0xff0D3D65),
                    size: 20,
                  ),
                ),
              ),
            ),

            Positioned(
              top: 240,
              right: 16,
              child: GestureDetector(
                onTap: () async {
                  final url =
                      'https://www.google.com/maps/search/?api=1&query=${StaticVarMethod.lat},${StaticVarMethod.lng}';
                  /*   if (await canLaunchUrl(Uri.parse(url))) {
                  await launchUrl(Uri.parse(url));
                } else {
                  throw 'Could not launch $url';
                }*/

                  MapUtils.openMap(url);
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) => Browser(
                  //           dashboardName: "Location",
                  //           dashboardURL: url,
                  //         )));
                },
                child: Container(
                  padding: const EdgeInsets.all(5),
                  width: 36,
                  height: 36,
                  decoration: new BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.rectangle,
                    // borderRadius:BorderRadius.only(topLeft:Radius.circular(8),topRight:Radius.circular(8)),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      const BoxShadow(
                        color: Colors.black26,
                        // blurRadius: 10.0,
                        //offset: const Offset(0.0, 10.0),
                      ),
                    ],
                  ),
                  // color: Colors.white,
                  //color: Color(0x99FFFFFF),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    child: ClipRRect(
                        borderRadius:
                        const BorderRadius.all(Radius.circular(0)),
                        child: Image.asset(
                          "assets/images/parallelarrow.png",
                          height: 1,
                          width: 1,
                          color: const Color(0xff0D3D65),
                        )),
                  ),
                ),
              ),
            ),
            // Positioned(
            //   top: 260,
            //   right: 16,
            //   child: GestureDetector(
            //     onTap: () async {
            //       getLocation();
            //     },
            //     child: Container(
            //       padding: const EdgeInsets.all(5),
            //       width: 36,
            //       height: 36,
            //       decoration: new BoxDecoration(
            //         color: Colors.white,
            //         shape: BoxShape.rectangle,
            //         // borderRadius:BorderRadius.only(topLeft:Radius.circular(8),topRight:Radius.circular(8)),
            //         borderRadius: BorderRadius.circular(30),
            //         boxShadow: [
            //           const BoxShadow(
            //             color: Colors.black26,
            //             // blurRadius: 10.0,
            //             //offset: const Offset(0.0, 10.0),
            //           ),
            //         ],
            //       ),
            //       // color: Colors.white,
            //       //color: Color(0x99FFFFFF),
            //       child: Container(
            //         padding: const EdgeInsets.all(3),
            //         child: ClipRRect(
            //             borderRadius:
            //                 const BorderRadius.all(Radius.circular(0)),
            //             child: Image.asset(
            //               "assets/images/mylocation1.png",
            //               height: 1,
            //               width: 1,
            //               color: const Color(0xff0D3D65),
            //             )),
            //       ),
            //     ),
            //   ),
            // ),
            Positioned(
              top: 280,
              right: 16,
              child: GestureDetector(
                onTap: () async {
                  setState(() {
                    _mapController.animateCamera(
                        CameraUpdate.newLatLngZoom(LatLng(lati, lngi), 17));
                  });
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Marqueur le plus récent")));
                },
                child: Container(
                  padding: const EdgeInsets.all(5),
                  width: 36,
                  height: 36,
                  decoration: new BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.rectangle,
                    // borderRadius:BorderRadius.only(topLeft:Radius.circular(8),topRight:Radius.circular(8)),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      const BoxShadow(
                        color: Colors.black,
                        // blurRadius: 10.0,
                        //offset: const Offset(0.0, 10.0),
                      ),
                    ],
                  ),
                  // color: Colors.white,
                  //color: Color(0x99FFFFFF),
                  child: const Icon(
                    Icons.refresh,
                    color: Colors.black,
                    size: 25,
                  ),
                ),
              ),
            ),

            Positioned(
              top: 320,
              right: 16,
              child: GestureDetector(
                onTap: () async {
                  final url =
                      'https://www.google.com/maps/search/?api=1&query=${StaticVarMethod.lat},${StaticVarMethod.lng}';
                  await Share.share(url, subject: 'Location');
                },
                child: Container(
                  padding: const EdgeInsets.all(5),
                  width: 36,
                  height: 36,
                  decoration: new BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.rectangle,
                    // borderRadius:BorderRadius.only(topLeft:Radius.circular(8),topRight:Radius.circular(8)),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      const BoxShadow(
                        color: Colors.black26,
                        // blurRadius: 10.0,
                        //offset: const Offset(0.0, 10.0),
                      ),
                    ],
                  ),
                  // color: Colors.white,
                  //color: Color(0x99FFFFFF),
                  child: const Icon(
                    Icons.share,
                    color: Colors.black,
                    size: 25,
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: 460,
              left: 16,
              child: GestureDetector(
                onTap: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => lockscreenNew()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(5),
                  width: 36,
                  height: 36,
                  decoration: new BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.rectangle,
                    //borderRadius:BorderRadius.only(topLeft:Radius.circular(8),topRight:Radius.circular(8)),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      const BoxShadow(
                        color: Colors.black26,
                        // blurRadius: 10.0,
                        //offset: const Offset(0.0, 10.0),
                      ),
                    ],
                  ),
                  // color: Colors.white,
                  //color: Color(0x99FFFFFF),
                  child: const Icon(
                    Icons.lock_person,
                    //color: Colors.white,
                    size: 25,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 420,
              left: 16,
              child: GestureDetector(
                onTap: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => playbackselection()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(5),
                  width: 36,
                  height: 36,
                  decoration: new BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.rectangle,
                    //borderRadius:BorderRadius.only(topLeft:Radius.circular(8),topRight:Radius.circular(8)),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      const BoxShadow(
                        color: Colors.black26,
                        // blurRadius: 10.0,
                        //offset: const Offset(0.0, 10.0),
                      ),
                    ],
                  ),
                  // color: Colors.white,
                  //color: Color(0x99FFFFFF),
                  child: const Icon(
                    Icons.play_circle,
                    color: Colors.black,
                    size: 25,
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: 380,
              left: 16,
              child: GestureDetector(
                onTap: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => kmdetail()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(5),
                  width: 36,
                  height: 36,
                  decoration: new BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.rectangle,
                    //borderRadius:BorderRadius.only(topLeft:Radius.circular(8),topRight:Radius.circular(8)),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      const BoxShadow(
                        color: Colors.black26,
                        // blurRadius: 10.0,
                        //offset: const Offset(0.0, 10.0),
                      ),
                    ],
                  ),
                  // color: Colors.white,
                  //color: Color(0x99FFFFFF),
                  child: Image.asset(
                      "assets/speedoicon/assets_images_kmicon.png",
                      height: 20,
                      width:
                      20), /*Icon(Icons.refresh,
                  color: Colors.white,
                  size: 25,*/
                ),
              ),
            ),
            Positioned(
              bottom: 340,
              left: 16,
              child: GestureDetector(
                onTap: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => vehicle_info()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(5),
                  width: 36,
                  height: 36,
                  decoration: new BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.rectangle,
                    //borderRadius:BorderRadius.only(topLeft:Radius.circular(8),topRight:Radius.circular(8)),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      const BoxShadow(
                        color: Colors.black26,
                        // blurRadius: 10.0,
                        //offset: const Offset(0.0, 10.0),
                      ),
                    ],
                  ),
                  // color: Colors.white,
                  //color: Color(0x99FFFFFF),
                  child: Image.asset(
                      "assets/images/icons8-info-popup-100.png",
                      height: 20,
                      width:
                      20), /*Icon(Icons.refresh,
                  color: Colors.white,
                  size: 25,*/
                ),
              ),
            ),
            (_statusbarLoading)
                ? _showStatusPopup(devicemodel, boxImageSize)
                : _showvehiclestatus(),
            mainView()
          ])
              : const Center(child: Text("noData"))
              : const Center(
            child: CircularProgressIndicator(),
          ),
        ));
  }

  Color? colormain = Colors.red.withValues(alpha: 0.5);
  Widget mainView() {
    String status = fUpdateTime;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  colormain ?? const Color(0xff0344a0),
                  (colormain ?? const Color(0xff0344a0)).withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        StaticVarMethod.deviceName.toUpperCase(),
                        style: const TextStyle(
                          fontFamily: "Sofia",
                          fontWeight: FontWeight.w900,
                          fontSize: 16.0,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: (speedo! > 0) ? Colors.greenAccent : Colors.white70,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              status,
                              style: const TextStyle(
                                fontFamily: "Sofia",
                                fontSize: 11.0,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernSensor(String assetPath, String label, String value, double imageSize) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xff0344a0).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Image.asset(
            assetPath,
            height: imageSize,
            width: imageSize,
            color: const Color(0xff0344a0),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 8,
            color: SOFT_GREY,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 9,
            color: Color(0xff0344a0),
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void getLocation() async {
    // Location functionality can be implemented here if needed
  }

  Widget speedometer() {
    return Positioned(
        top: 70,
        left: 0,
        right: 0,
        child: Speedometer(
          size: 50,
          minValue: 0,
          maxValue: 160,
          currentValue: speedo!,
          barColor: Colors.black87,
          pointerColor: Colors.red,
          displayText: "" + speedo.toString() + " km",
          displayTextStyle: const TextStyle(
              fontSize: 9,
              color: Colors.black,
              fontFamily: 'digital_font',
              fontWeight: FontWeight.bold),
          displayNumericStyle: const TextStyle(
              fontSize: 9,
              color: Colors.red,
              fontFamily: 'digital_font',
              fontWeight: FontWeight.bold,
              height: 40),
          onComplete: () {
            print("ON COMPLETE");
          },
        ));
  }

  Widget buildMap() {
    final googleMap = StreamBuilder<List<Marker>>(
        stream: mapMarkerStream,
        builder: (context, snapshot) {
          return GoogleMap(
            gestureRecognizers: Set()
              ..add(Factory<PanGestureRecognizer>(() => PanGestureRecognizer()))
              ..add(Factory<ScaleGestureRecognizer>(
                      () => ScaleGestureRecognizer()))
              ..add(Factory<TapGestureRecognizer>(() => TapGestureRecognizer()))
              ..add(Factory<VerticalDragGestureRecognizer>(
                      () => VerticalDragGestureRecognizer()))
              ..add(Factory<HorizontalDragGestureRecognizer>(
                      () => HorizontalDragGestureRecognizer())),
            mapType: _currentMapType,
            trafficEnabled: _trafficEnabled,
            initialCameraPosition: _initialRegion,
            rotateGesturesEnabled: false,
            tiltGesturesEnabled: false,
            mapToolbarEnabled: false,
            myLocationEnabled: false,
            onCameraMove: currentMapStatus,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            minMaxZoomPreference: const MinMaxZoomPreference(0, 20),
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              _mapController = controller;
            },
            polylines: Set<Polyline>.of(polylines.values),
            markers: Set<Marker>.of(snapshot.data ?? []),
            padding: const EdgeInsets.all(50),
            // circles: _circles,
          );
        });

    return Stack(
      children: <Widget>[
        Container(child: googleMap),
      ],
    );
  }

  Widget _showStatusPopup(deviceItems? devicemodel, double boxImageSize) {
    if (devicemodel == null) return const SizedBox.shrink();
    String other = devicemodel.deviceData?.traccar?.other?.toString() ?? "";
    String ignition = "true";
    String enginehours = "0h";
    String sat = "9";
    String totaldistance = "0";
    String distance = "0";

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
    }
    if (other.contains("<distance>")) {
      const start = "<distance>";
      const end = "</distance>";
      final startIndex = other.indexOf(start);
      final endIndex = other.indexOf(end, startIndex + start.length);
      distance = other.substring(startIndex + start.length, endIndex);
    }
    double imageSize = MediaQuery.of(context).size.width / 25;
    return (_statusbarLoading)
        ? Positioned(
      bottom: 20,
      right: 10,
      left: 10,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.grey.shade50],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(25)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                    color: Colors.black.withValues(alpha: 0.15))
              ]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              // Drag handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      StaticVarMethod.deviceName,
                      style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xff0344a0),
                          fontWeight: FontWeight.bold),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (mounted) {
                          setState(() {
                            _statusbarLoading = !_statusbarLoading;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: const Color(0xff0344a0),
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Status badge
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: (speedo! > 0)
                      ? Colors.green.withValues(alpha: 0.15)
                      : Colors.grey.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      (speedo! > 0) ? Icons.play_arrow_rounded : Icons.stop_rounded,
                      color: (speedo! > 0) ? Colors.green : Colors.grey.shade700,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      (speedo! > 0) ? 'En mouvement' : 'Arrêté',
                      style: TextStyle(
                        fontSize: 12,
                        color: (speedo! > 0) ? Colors.green : Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      fstopDuration,
                      style: TextStyle(
                        fontSize: 11,
                        color: (speedo! > 0) ? Colors.green.shade700 : Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.shade200, width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildModernSensor(
                      "assets/sensorsicon/engineon.png",
                      "Moteur",
                      (ignition.contains("true")) ? "Marche" : "Arrêt",
                      imageSize,
                    ),
                    _buildModernSensor(
                      "assets/sensorsicon/locationon.png",
                      "GPS",
                      sat,
                      imageSize,
                    ),
                    _buildModernSensor(
                      "assets/sensorsicon/speedometeron.png",
                      "Odomètre",
                      "$totaldistance km",
                      imageSize,
                    ),
                    _buildModernSensor(
                      "assets/sensorsicon/hour24on.png",
                      "Heures moteur",
                      "$enginehours h",
                      imageSize,
                    ),
                  ],
                ),
              ),

              GestureDetector(
                onTap: () async {
                  // Can be used to open maps or fetch address
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xff0344a0).withValues(alpha: 0.1),
                        const Color(0xff0344a0).withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: const Color(0xff0344a0).withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xff0344a0),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.location_on_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Localisation actuelle',
                              style: TextStyle(
                                fontSize: 10,
                                color: SOFT_GREY,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              address,
                              style: const TextStyle(
                                fontSize: 12,
                                fontFamily: 'Roboto',
                                color: Color(0xFF212121),
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    )
        : _showvehiclestatus();
  }

  Widget _showvehiclestatus() {
    return Positioned(
      bottom: 30,
      right: 0,
      left: 0,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          // padding: EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 40),

          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                    blurRadius: 20,
                    offset: Offset.zero,
                    color: Colors.grey.withValues(alpha: 0.5))
              ]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                //margin: EdgeInsets.fromLTRB(6, 10, 6, 1),
                  padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                  child: GestureDetector(
                      onTap: () {
                        setState(() {
                          if (_statusbarLoading) {
                            _statusbarLoading = false;
                          } else {
                            _statusbarLoading = true;
                          }
                        });
                        Fluttertoast.showToast(
                            msg: 'Up', toastLength: Toast.LENGTH_SHORT);
                      },
                      child: Icon(Icons.arrow_circle_up,
                          color: _mainColor, size: 40.0))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _showStatusPopup1() {
    final matching = devicesList.where((i) =>
        i.deviceData?.imei != null &&
        i.deviceData!.imei!.contains(StaticVarMethod.imei));
    if (matching.isEmpty) return const SizedBox.shrink();
    var devicelist = matching.first;

    return Positioned(
      bottom: 0,
      right: 0,
      left: 0,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          padding: const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 0),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                    blurRadius: 20,
                    offset: Offset.zero,
                    color: Colors.grey.withValues(alpha: 0.5))
              ]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                //  margin: EdgeInsets.fromLTRB(6, 1, 6, 1),

                child: Row(children: [
                  Expanded(
                      child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0),
                          ),
                          elevation: 0,
                          color: Colors.white,
                          child: Container(
                            //margin: EdgeInsets.fromLTRB(6, 6, 6, 6),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  ClipRRect(
                                      borderRadius:
                                      const BorderRadius.all(Radius.circular(4)),
                                      child: Image.asset(
                                          "assets/images/Address.png",
                                          height: 25,
                                          width: 25)),
                                  Expanded(
                                    child: Container(
                                      margin: const EdgeInsets.only(
                                          left: 20, right: 25, top: 5, bottom: 15),
                                      child: Column(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              address = "Loading....";
                                              // setState(() {});
                                              getAddress(lati, lngi);
                                            },
                                            child: RichText(
                                              maxLines: 5,
                                              //textAlign: TextAlign.start,
                                              overflow: TextOverflow.ellipsis,
                                              text: TextSpan(
                                                  text: address,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xff8E8E8E),
                                                    //fontWeight: FontWeight.bold
                                                  ),
                                                  children: [
                                                    /* TextSpan(
                text:eventList[index].message.toString() == "null" ? "" : eventList[index].message.toString(),
                style: TextStyle(

                    fontWeight: FontWeight.w400),
              )*/
                                                  ]),
                                            ), /*Text(address,
                                                  style: TextStyle(
                                                      fontSize: 12, color: Colors.blue),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis)*/
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ))))
                ]),
              ),
              (devicelist.sensors!.isNotEmpty)
                  ? Container(
                  height: (devicelist.sensors!.length > 5) ? 150 : 90,
                  child: GridView.count(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    primary: false,
                    childAspectRatio: 1,
                    shrinkWrap: true,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 8,
                    crossAxisCount: 5,
                    children: List.generate(devicelist.sensors!.length,
                            (int index) {
                          return GridItem(devicelist.sensors![index]);
                        }),
                  ))
                  : Center(
                child: Container(
                    margin: const EdgeInsets.fromLTRB(20, 6, 1, 6),
                    height: 50,
                    width: 45,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        const BoxShadow(
                          color: Colors.black26,
                          blurRadius: 2.0,
                          offset: Offset(0.5, 4.0),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          margin: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                          child: ClipRRect(
                              child: Image.asset(
                                "assets/sensorsicon/engineon.png",
                                height: 13,
                                width: 13,
                                color: const Color(0xff0D3D65),
                              )),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 0),
                                child: const Text(
                                  'Ignition',
                                  style: TextStyle(
                                    fontSize: 7,
                                    fontWeight: FontWeight.normal,
                                    color: Color(0xff0D3D65),
                                  ),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: 2),
                                child: Text(
                                  (speedo! > 0) ? 'ON' : 'OFF',
                                  style: const TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.normal,
                                    color: Color(0xff0D3D65),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget GridItem(Sensors model) {
    return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            const BoxShadow(
              color: Colors.black26,
              blurRadius: 2.0,
              offset: Offset(0.5, 4.0),
            ),
          ],
        ),
        child: Column(children: <Widget>[
          model.type.toString().toLowerCase() == 'ignition'
              ? Image.asset(
            "assets/sensorsicon/engineon.png",
            height: 16,
            color: themeDark,
          )
              : model.type.toString().toLowerCase() == 'odometer'
              ? Image.asset("assets/sensorsicon/speedometeron.png",
              height: 16)
              : model.type.toString().toLowerCase() == 'battery'
              ? const Icon(
            FontAwesomeIcons.batteryFull,
            size: 16,
            color: themeDark,
          )
              : model.type.toString().toLowerCase() == 'charge'
              ? const Icon(
            Icons.battery_charging_full,
            size: 16,
            color: themeDark,
          )
              : model.type.toString().toLowerCase() == 'engine lock'
              ? const Icon(
            Icons.hourglass_bottom_rounded,
            size: 16,
            color: themeDark,
          )
              : model.type.toString().toLowerCase() == 'gps'
              ? const Icon(
            Icons.gps_fixed_outlined,
            size: 16,
            color: themeDark,
          )
              : model.type.toString().toLowerCase() == 'gsm'
              ? Image.asset(
            "assets/sensorsicon/connectedon.png",
            height: 16,
            color: themeDark,
          )
              : model.type.toString().toLowerCase() ==
              'moving'
              ? const Icon(
            Icons.moving_outlined,
            size: 16,
            color: themeDark,
          )
              : model.type
              .toString()
              .toLowerCase() ==
              'gps starting km'
              ? const Icon(
            Icons.gps_fixed_outlined,
            size: 16,
            color: themeDark,
          )
              : model.type
              .toString()
              .toLowerCase() ==
              'temp'
              ? const Icon(
            FontAwesomeIcons
                .temperatureLow,
            size: 16,
            color: themeDark,
          )
              : model.type
              .toString()
              .toLowerCase() ==
              'engine_hours'
              ? const Icon(
            Icons.alarm,
            size: 16,
            color: themeDark,
          )
              : const Icon(
            Icons
                .charging_station,
            size: 16,
            color: themeDark,
          ),
          //Icon(Icons.engineering,size:imageSize),
          // Image.asset("assets/sensorsicon/engineon.png", height: imageSize,width: imageSize),
          Text(model.name.toString(),
              style: const TextStyle(fontSize: 6, height: 1.5, color: themeDark)),
          Text("${model.value.toString()}",
              style: const TextStyle(fontSize: 7, height: 1, color: themeDark))
        ]));
  }
}
