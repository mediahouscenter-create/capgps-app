import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maktrogps/config/static.dart';
import 'package:maktrogps/data/datasources.dart';
import 'package:maktrogps/data/model/events.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:maktrogps/theme/CustomColor.dart';
import 'notificationmapscreen.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  var _isLoading = true;
  List<EventsData> eventList = [];
  Timer? _timerDummy;

  @override
  void initState() {
    if (StaticVarMethod.notificationback) {
      _isLoading = true;
      getnotiList();
    } else {
      _isLoading = false;
    }

    _timerDummy = Timer.periodic(const Duration(seconds: 10), (Timer t) {
      if (StaticVarMethod.notificationback && mounted) {
        getnotiList();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? CustomColor.primaryDark : const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Title section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Notifications'.tr,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 24.0,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      letterSpacing: -0.5,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      getnotiList(showToast: true);
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: const Icon(Icons.refresh_rounded, color: CustomColor.primaryAccent, size: 22),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: RefreshIndicator(
                color: CustomColor.primaryAccent,
                onRefresh: () async {
                  await getnotiList(showToast: true);
                },
                child: StaticVarMethod.eventList.isNotEmpty
                    ? listView(isDark)
                    : (_isLoading)
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: CustomColor.primaryAccent,
                            ),
                          )
                        : SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Container(
                              height: MediaQuery.of(context).size.height * 0.7,
                              child: noNotificationScreen(isDark),
                            ),
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timerDummy?.cancel();
    super.dispose();
  }

  Widget listView(bool isDark) {
    return ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 90),
        itemCount: StaticVarMethod.eventList.length,
        itemBuilder: (BuildContext context, int index) {
          return listViewItems(index, isDark);
        });
  }

  Widget listViewItems(int index, bool isDark) {
    final event = StaticVarMethod.eventList[index];
    final eventName = event.message?.toString().toLowerCase() ?? "";

    Color accentColor = CustomColor.primaryAccent;
    IconData eventIcon = Icons.notifications_active_rounded;

    if (eventName.contains("overspeed") || eventName.contains("vitesse")) {
      accentColor = CustomColor.statusOffline;
      eventIcon = Icons.speed_rounded;
    } else if (eventName.contains("geofence") || eventName.contains("zone")) {
      accentColor = const Color(0xFF8B5CF6);
      eventIcon = Icons.fence_rounded;
    } else if (eventName.contains("ignition on") || eventName.contains("contact allumé")) {
      accentColor = CustomColor.statusDriving;
      eventIcon = Icons.vpn_key_rounded;
    } else if (eventName.contains("stop") || eventName.contains("stationné")) {
      accentColor = CustomColor.statusParking;
      eventIcon = Icons.local_parking_rounded;
    }

    return GestureDetector(
      onTap: () {
        double parseCoord(dynamic val) {
          if (val == null) return 0.0;
          if (val is double) return val;
          if (val is int) return val.toDouble();
          return double.tryParse(val.toString()) ?? 0.0;
        }

        double lat = parseCoord(event.latitude);
        double lng = parseCoord(event.longitude);

        if (lat == 0.0 || lng == 0.0) {
          try {
            final dev = StaticVarMethod.devicelist.firstWhere(
              (d) => d.id?.toString() == event.deviceId?.toString() || d.deviceData?.id?.toString() == event.deviceId?.toString(),
            );
            if (dev.lat != null) lat = dev.lat!.toDouble();
            if (dev.lng != null) lng = dev.lng!.toDouble();
          } catch (_) {}
        }

        StaticVarMethod.lat = lat;
        StaticVarMethod.lng = lng;
        StaticVarMethod.deviceName = event.deviceName?.toString() ?? "";
        StaticVarMethod.type = event.type?.toString() ?? "";
        StaticVarMethod.message = event.message?.toString() ?? "";
        StaticVarMethod.detail = event.detail?.toString() ?? "";
        StaticVarMethod.time = event.time?.toString() ?? "";
        StaticVarMethod.speed = event.speed?.toString() ?? "0";

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => notificationmapscreen()),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0x2638BDF8) : const Color(0xFFE2E8F0),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.25 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 46,
              width: 46,
              margin: const EdgeInsetsDirectional.only(top: 16, start: 16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor.withOpacity(0.12),
                border: Border.all(color: accentColor.withOpacity(0.3)),
              ),
              child: Icon(
                eventIcon,
                size: 22,
                color: accentColor,
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsetsDirectional.fromSTEB(14, 14, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.deviceName.toString(),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      event.message.toString(),
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 13,
                          color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          event.time.toString(),
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> getnotiList({bool showToast = false}) async {
    if (showToast) {
      Fluttertoast.showToast(msg: "Actualisation...");
    }
    _isLoading = true;
    if (mounted) setState(() {});
    gpsapis api = gpsapis();
    try {
      eventList = await api.getEventsList(StaticVarMethod.user_api_hash);
      StaticVarMethod.eventList = eventList;
      _isLoading = false;
      if (mounted) setState(() {});
      if (showToast) {
        Fluttertoast.showToast(msg: "Données actualisées avec succès");
      }
    } catch (e) {
      _isLoading = false;
      if (mounted) setState(() {});
    }
  }

  Widget noNotificationScreen(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: CustomColor.primaryAccent.withOpacity(0.12),
                border: Border.all(color: CustomColor.primaryAccent.withOpacity(0.3)),
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                size: 64,
                color: CustomColor.primaryAccent,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Aucune nouvelle notification".tr,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 20.0,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "Vous n'avez actuellement aucune notification non lue.".tr,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14.0,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
