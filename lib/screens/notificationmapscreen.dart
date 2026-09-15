import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:alxgration_speedometer/speedometer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:location/location.dart';

import 'package:maktrogps/config/static.dart';
import 'package:maktrogps/data/datasources.dart';
import 'package:maktrogps/mapconfig/CommonMethod.dart';
import 'package:maktrogps/mapconfig/CustomColor.dart';
import 'package:maktrogps/ui/reusable/global_widget.dart';
import 'dart:ui' as ui;
import 'package:image/image.dart' as IMG;
import 'package:http/http.dart' as http;
import 'package:flutter_animarker/flutter_map_marker_animation.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/constant.dart';
import '../../mvvm/view_model/objects.dart';
import '../../utils/MapUtils.dart';
import 'browser_module_old/browser.dart';
class notificationmapscreen extends StatefulWidget {
  @override
  _notificationmapscreen createState() => _notificationmapscreen();
}

class _notificationmapscreen extends State<notificationmapscreen>{


  late SharedPreferences prefs;
  bool isshowvehicledetail = true;
  @override
  void initState() {
    super.initState();
    checkPreference();
    _loadMarkerIcon();
  }
  void checkPreference() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0D3D65),
        title: Text(
          StaticVarMethod.deviceName.isNotEmpty ? StaticVarMethod.deviceName : "Localisation de l'Alerte",
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          _buildGoogleMap(StaticVarMethod.lat, StaticVarMethod.lng, 90, "7857858", 0),
          if (isshowvehicledetail) _buildItem(),
        ],
      ),
    );
  }

  Map<String, String> _getAlertSpecificInfo() {
    final eventName = "${StaticVarMethod.type} ${StaticVarMethod.message} ${StaticVarMethod.detail}".toLowerCase();
    final message = StaticVarMethod.message;
    final detail = StaticVarMethod.detail;
    final speedVal = StaticVarMethod.speed;

    String extractParentheses(String src) {
      final regExp = RegExp(r'\((.*?)\)');
      final match = regExp.firstMatch(src);
      if (match != null && match.groupCount >= 1) {
        return match.group(1)!.trim();
      }
      return "";
    }

    String extractDuration(String src) {
      final paren = extractParentheses(src);
      if (paren.isNotEmpty && !paren.toLowerCase().contains("kph") && !paren.toLowerCase().contains("km/h")) {
        return paren;
      }
      final regExp = RegExp(r'\b(\d+:\d+(?::\d+)?|\d+\s*(?:min|mins|m|hour|hours|h|day|days|d|sec|secs|s))\b', caseSensitive: false);
      final match = regExp.firstMatch(src);
      if (match != null) {
        return match.group(0)!;
      }
      if (detail.isNotEmpty && detail != "null") {
        return detail;
      }
      return "";
    }

    if (eventName.contains("overspeed") || eventName.contains("vitesse")) {
      String val = "";
      if (speedVal.isNotEmpty && speedVal != "null" && speedVal != "0") {
        val = "$speedVal km/h";
      } else {
        val = extractParentheses(message);
        if (val.isEmpty) val = detail;
      }
      return {
        "label": "Speed_label".tr,
        "value": val.isNotEmpty ? val : (speedVal != "0" ? "$speedVal km/h" : ""),
      };
    } else if (eventName.contains("idle") || eventName.contains("ralenti")) {
      String val = extractDuration(message);
      return {
        "label": "Idle_duration_label".tr,
        "value": val,
      };
    } else if (eventName.contains("stop") || eventName.contains("stationné") || eventName.contains("arrêt")) {
      String val = extractDuration(message);
      return {
        "label": "Stop_duration_label".tr,
        "value": val,
      };
    } else if (eventName.contains("ignition duration") || eventName.contains("durée de contact") || eventName.contains("ignition_duration")) {
      String val = extractDuration(message);
      return {
        "label": "Ignition_duration_label".tr,
        "value": val,
      };
    } else if (eventName.contains("offline duration") || eventName.contains("offline") || eventName.contains("inactif") || eventName.contains("hors ligne")) {
      String val = extractDuration(message);
      return {
        "label": "Offline_duration_label".tr,
        "value": val,
      };
    } else if (eventName.contains("geofence") || eventName.contains("zone")) {
      String val = extractParentheses(message);
      if (val.isEmpty) val = detail;
      return {
        "label": "Geofence_label".tr,
        "value": val,
      };
    } else if (eventName.contains("driver") || eventName.contains("conducteur")) {
      String val = extractParentheses(message);
      if (val.isEmpty) val = detail;
      return {
        "label": "Driver_label".tr,
        "value": val,
      };
    }

    String fallbackVal = extractParentheses(message);
    if (fallbackVal.isEmpty && speedVal.isNotEmpty && speedVal != "null" && speedVal != "0") {
      fallbackVal = "$speedVal km/h";
    }
    return {
      "label": "Alert_detail_label".tr,
      "value": fallbackVal.isNotEmpty ? fallbackVal : (detail != "null" ? detail : ""),
    };
  }

  Widget _buildItem() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final info = _getAlertSpecificInfo();
    final infoLabel = info["label"] ?? "";
    final infoValue = info["value"] ?? "";
    final subhead = infoValue.isNotEmpty ? "$infoLabel: $infoValue" : infoLabel;

    final eventName = "${StaticVarMethod.type} ${StaticVarMethod.message}".toLowerCase();
    Color accentColor = const Color(0xFF3B82F6);
    IconData eventIcon = Icons.notifications_active_rounded;

    if (eventName.contains("overspeed") || eventName.contains("vitesse")) {
      accentColor = const Color(0xFFEF4444);
      eventIcon = Icons.speed_rounded;
    } else if (eventName.contains("geofence") || eventName.contains("zone")) {
      accentColor = const Color(0xFF8B5CF6);
      eventIcon = Icons.fence_rounded;
    } else if (eventName.contains("ignition on") || eventName.contains("contact allumé") || eventName.contains("engine_on") || eventName.contains("engine on")) {
      accentColor = const Color(0xFF22C55E);
      eventIcon = Icons.vpn_key_rounded;
    } else if (eventName.contains("ignition off") || eventName.contains("contact éteint") || eventName.contains("engine_off") || eventName.contains("engine off")) {
      accentColor = const Color(0xFFF59E0B);
      eventIcon = Icons.vpn_key_off_rounded;
    } else if (eventName.contains("stop") || eventName.contains("stationné") || eventName.contains("parked")) {
      accentColor = const Color(0xFFF59E0B);
      eventIcon = Icons.local_parking_rounded;
    } else if (eventName.contains("offline") || eventName.contains("inactif")) {
      accentColor = const Color(0xFF64748B);
      eventIcon = Icons.portable_wifi_off_rounded;
    } else if (eventName.contains("sos") || eventName.contains("panic")) {
      accentColor = const Color(0xFFDC2626);
      eventIcon = Icons.error_outline_rounded;
    } else if (eventName.contains("fuel") || eventName.contains("carburant")) {
      accentColor = const Color(0xFF0EA5E9);
      eventIcon = Icons.local_gas_station_rounded;
    }

    return Positioned(
      bottom: 24,
      right: 16,
      left: 16,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.4 : 0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    eventIcon,
                    color: accentColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        StaticVarMethod.deviceName.isNotEmpty
                            ? StaticVarMethod.deviceName
                            : "Véhicule",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subhead.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            subhead,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: accentColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isshowvehicledetail = false;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: isDark ? Colors.white70 : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            if (StaticVarMethod.message.isNotEmpty && StaticVarMethod.message != "null")
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, size: 16, color: Color(0xFFF59E0B)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        StaticVarMethod.message,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white70 : const Color(0xFF334155),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

            if (StaticVarMethod.time.isNotEmpty && StaticVarMethod.time != "null")
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(Icons.access_time_rounded, size: 16, color: Color(0xFF94A3B8)),
                    const SizedBox(width: 8),
                    Text(
                      StaticVarMethod.time,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on_rounded, size: 16, color: Color(0xFF2563EB)),
                const SizedBox(width: 8),
                Expanded(
                  child: addressLoad(
                    StaticVarMethod.lat.toString(),
                    StaticVarMethod.lng.toString(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  BitmapDescriptor _markerIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);

  void _loadMarkerIcon() async {
    try {
      Uint8List? markerIconBytes = await getBytesFromAsset("assets/nepalicon/map-alert-point.png", 80);
      if (markerIconBytes != null && mounted) {
        setState(() {
          _markerIcon = BitmapDescriptor.fromBytes(markerIconBytes);
        });
      }
    } catch (_) {}
  }

  Widget _buildGoogleMap(lat, lng, course, imei, speed) {
    double initialLat = (lat != null && lat is num && lat != 0.0) ? (lat as num).toDouble() : 33.5731;
    double initialLng = (lng != null && lng is num && lng != 0.0) ? (lng as num).toDouble() : -7.5898;

    return GoogleMap(
      compassEnabled: true,
      rotateGesturesEnabled: true,
      scrollGesturesEnabled: true,
      tiltGesturesEnabled: true,
      zoomControlsEnabled: true,
      zoomGesturesEnabled: true,
      myLocationButtonEnabled: false,
      myLocationEnabled: false,
      mapToolbarEnabled: false,
      padding: const EdgeInsets.only(bottom: 220, top: 10),
      mapType: MapType.normal,
      initialCameraPosition: CameraPosition(
        zoom: 15.5,
        target: LatLng(initialLat, initialLng),
      ),
      markers: <Marker>{
        Marker(
          markerId: MarkerId(imei.toString()),
          icon: _markerIcon,
          position: LatLng(initialLat, initialLng),
          onTap: () {
            setState(() {
              isshowvehicledetail = true;
            });
          },
        )
      },
    );
  }









  Widget addressLoad(String lat, String lng) {
    return FutureBuilder<String>(
        future: gpsapis.geocode(lat, lng),
        builder: (context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData) {
            return Container(
              //color: Colors.red,
              height: 35,
              width: 305,
              padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
              child: Text(
                (snapshot.data!.replaceAll('"', '')),
                style: TextStyle(
                    color: Colors.black, fontFamily: "Popins", fontSize: 13),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
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
  String address = "View Address";
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
}

Future<BitmapDescriptor> getMarkerIcon(String imagePath,String infoText,Color color,double rotateDegree) async {
  final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(pictureRecorder);

  //size
  Size canvasSize = Size(700.0,220.0);
  Size markerSize = Size(140.0,140.0);



  final Paint infoPaint = Paint()..color = Colors.white;
  final Paint infoStrokePaint = Paint()..color = color;
  final double infoHeight = 70.0;
  final double strokeWidth = 2.0;

 // final Paint markerPaint = Paint()..color = color.withOpacity(0);
  final double shadowWidth = 30.0;

  final Paint borderPaint = Paint()..color = color..strokeWidth=2.0..style = PaintingStyle.stroke;

  final double imageOffset = shadowWidth*.5;

  canvas.translate(canvasSize.width/2, canvasSize.height/2+infoHeight/2);

  // Add shadow circle
  // canvas.drawOval(Rect.fromLTWH(-markerSize.width/2, -markerSize.height/2, markerSize.width, markerSize.height), markerPaint);
  // // Add border circle
  // canvas.drawOval(Rect.fromLTWH(-markerSize.width/2+shadowWidth, -markerSize.height/2+shadowWidth, markerSize.width-2*shadowWidth, markerSize.height-2*shadowWidth), borderPaint);

  // Oval for the image
  Rect oval = Rect.fromLTWH(-markerSize.width/2+.5* shadowWidth, -markerSize.height/2+.5*shadowWidth, markerSize.width-shadowWidth, markerSize.height-shadowWidth);

  //save canvas before rotate
  canvas.save();

  double rotateRadian = (pi/180.0)*rotateDegree;

  //Rotate Image
  canvas.rotate(rotateRadian);

  // Add path for oval image
  canvas.clipPath(Path()
    ..addOval(oval));

  // Add image
  ui.Image image;
  image = await getImageFromPath(imagePath);
  // if(imagePath.contains("arrow-ack.png")){
  //   image = await getImageFromPath("assets/nepalicon/map-alert-point.png");
  // }else{
  //   image = await getImageFromPathUrl(imagePath);
  //
  // }
  paintImage(canvas: canvas,image: image, rect: oval, fit: BoxFit.fitHeight);

  canvas.restore();


  // Convert canvas to image
  final ui.Image markerAsImage = await pictureRecorder.endRecording().toImage(
      canvasSize.width.toInt(),
      canvasSize.height.toInt()
  );

  // Convert image to bytes
  final ByteData? byteData = await markerAsImage.toByteData(format: ui.ImageByteFormat.png);
  final Uint8List? uint8List = byteData?.buffer.asUint8List();

  return BitmapDescriptor.fromBytes(uint8List!);
}


Future<ui.Image> getImageFromPath(String imagePath) async {
  //File imageFile = File(imagePath);
  var bd = await rootBundle.load(imagePath);
  Uint8List imageBytes = Uint8List.view(bd.buffer);

  final Completer<ui.Image> completer = new Completer();

  ui.decodeImageFromList(imageBytes, (ui.Image img) {
    return completer.complete(img);
  });

  return completer.future;
}


Future<ui.Image> getImageFromPathUrl(String imagePath) async {
  //File imageFile = File(imagePath);
  final response = await http.Client().get(Uri.parse(imagePath));
  final bytes = response.bodyBytes;
//  var bd = await rootBundle.load(imagePath);
  //Uint8List imageBytes = Uint8List.view(bd.buffer);

  final Completer<ui.Image> completer = new Completer();

  ui.decodeImageFromList(bytes, (ui.Image img) {
    return completer.complete(img);
  });

  return completer.future;
}
