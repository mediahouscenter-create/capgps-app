import 'dart:async';
import 'dart:collection';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:maktrogps/data/datasources.dart';
import 'package:maktrogps/data/model/events.dart';
import 'package:maktrogps/mvvm/view_model/objects.dart';
import 'package:maktrogps/screens/livetrack.dart';
import 'package:maktrogps/screens/notification_screen.dart';
import 'package:maktrogps/screens/playbackselection.dart';
import 'package:maktrogps/screens/reports/reportselection.dart';
import 'package:maktrogps/theme/CustomColor.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/static.dart';
import '../data/model/devices.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  int touchedIndex = -1;
  Map<String, dynamic> devicesSettingsList = HashMap();
  int key = 0;
  SharedPreferences? prefs;

  List<deviceItems> _inactiveVehicles = [];
  List<deviceItems> _allVehicles = [];
  List<deviceItems> _runningVehicles = [];
  List<deviceItems> _idleVehicles = [];
  List<deviceItems> _expiredVehicles = [];
  List<deviceItems> _stoppedVehicles = [];
  List<deviceItems> _offlineVehicles = [];
  List<EventsData> eventList = [];
  List<EventsData> _todayEvents = [];

  List<EventsData> _geofencealets = [];
  List<EventsData> _overspeedalets = [];
  List<EventsData> _idlealets = [];
  List<EventsData> _stopalets = [];
  List<EventsData> _ignitiononalets = [];
  List<EventsData> _ignitionoffalets = [];

  List<deviceItems> devicesList = [];
  late ObjectStore objectStore;

  @override
  void initState() {
    getnotiList();
    checkPreference();
    super.initState();
  }

  void checkPreference() async {
    prefs = await SharedPreferences.getInstance();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    _runningVehicles = [];
    _idleVehicles = [];
    _stoppedVehicles = [];
    _inactiveVehicles = [];
    _expiredVehicles = [];
    _allVehicles = [];
    _offlineVehicles = [];

    objectStore = Provider.of<ObjectStore>(context);
    devicesList = objectStore.objects;
    _allVehicles = devicesList;

    for (int i = 0; i < devicesList.length; i++) {
      deviceItems model = devicesList.elementAt(i);
      String other = model.deviceData?.traccar?.other?.toString() ?? "";
      String stopDuration = model.stopDuration?.toString() ?? "";
      String ignition = "false";
      int hours = 0;
      int difference = 1000;

      var expirationdate = model.deviceData?.expirationDate?.toString() ?? "";
      if (expirationdate.contains("expire")) {
        expirationdate = "Expired";
      } else if (expirationdate.contains("null") || expirationdate.isEmpty) {
        expirationdate = "Not Found";
      } else {
        DateTime? date = DateTime.tryParse(expirationdate);
        if (date != null) {
          final date2 = DateTime.now();
          difference = daysBetween(date2, date);
        }
      }

      if (other.contains("<ignition>")) {
        const start = "<ignition>";
        const end = "</ignition>";
        final startIndex = other.indexOf(start);
        final endIndex = other.indexOf(end, startIndex + start.length);
        if (startIndex != -1 && endIndex != -1) {
          ignition = other.substring(startIndex + start.length, endIndex);
        }
      }

      if (stopDuration.contains("h")) {
        const end = "h";
        final endIndex = stopDuration.indexOf(end);
        if (endIndex != -1) {
          String result = stopDuration.substring(0, endIndex);
          hours = int.tryParse(result) ?? 0;
        }
      }

      double speedVal = double.tryParse(model.speed?.toString() ?? "0") ?? 0.0;

      if (model.time.toString().toLowerCase().contains("expire") || difference <= 15) {
        _expiredVehicles.add(devicesList.elementAt(i));
      } else if (model.online.toString().contains("offline") &&
          !model.time.toString().contains("Not connected") &&
          !model.time.toString().contains("Expired")) {
        _offlineVehicles.add(devicesList.elementAt(i));
      } else if (model.time.toString().toLowerCase().contains("expire")) {
        _expiredVehicles.add(devicesList.elementAt(i));
      } else if (ignition.contains("true") &&
          !model.online.toString().contains("offline") &&
          speedVal < 1.0) {
        _idleVehicles.add(devicesList.elementAt(i));
      } else if (model.online.toString().toLowerCase().contains("offline") &&
          model.time.toString().toLowerCase().contains("not connected")) {
        _inactiveVehicles.add(devicesList.elementAt(i));
      } else if (model.online.toString().toLowerCase().contains("online")) {
        _runningVehicles.add(devicesList.elementAt(i));
      } else if (ignition.contains("false") &&
          model.time.toString().toLowerCase() != "not connected" &&
          speedVal < 1.0) {
        _stoppedVehicles.add(devicesList.elementAt(i));
      }
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? CustomColor.primaryDark : const Color(0xFFF8FAFC),
      body: dashboardView(isDark),
    );
  }

  Widget dashboardView(bool isDark) {
    if (objectStore.isLoading || (_allVehicles.isEmpty && objectStore.isLoading)) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 58,
              height: 58,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.35 : 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const CircularProgressIndicator(
                color: Color(0xFF3B82F6),
                strokeWidth: 3.5,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              "Chargement des véhicules...".tr,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      );
    }

    return SafeArea(
      child: Column(
        children: [
          // Header section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tableau de bord'.tr,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 24.0,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Aperçu global de votre flotte'.tr,
                        style: TextStyle(
                          fontSize: 12.0,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    InkWell(
                      onTap: () async {
                        Fluttertoast.showToast(msg: "Actualisation...");
                        await getnotiList();
                        if (mounted) setState(() {});
                        Fluttertoast.showToast(msg: "Données actualisées avec succès");
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
                    if (prefs != null && prefs!.getString("PREF_SUPPORT_NO") != null) ...[
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () {
                          launch("tel://${prefs!.getString("PREF_SUPPORT_NO")}");
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: CustomColor.primaryGradient,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: CustomColor.primaryAccent.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.support_agent_outlined, color: Colors.white, size: 22),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: RefreshIndicator(
              color: CustomColor.primaryAccent,
              onRefresh: () async {
                Fluttertoast.showToast(msg: "Actualisation...");
                await getnotiList();
                if (mounted) setState(() {});
                Fluttertoast.showToast(msg: "Données actualisées avec succès");
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  fleetStatus(isDark),
                  const SizedBox(height: 16),
                  alertStatus(isDark),
                  const SizedBox(height: 90), // Bottom padding for floating nav
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget fleetStatus(bool isDark) {
    double all = _allVehicles.length.toDouble(),
        offline = _offlineVehicles.length.toDouble(),
        moving = _runningVehicles.length.toDouble(),
        idle = _idleVehicles.length.toDouble(),
        stop = _stoppedVehicles.length.toDouble(),
        disconnect = 0,
        noData = _inactiveVehicles.length.toDouble(),
        expired = _expiredVehicles.length.toDouble();

    final rawData = <_PieData>[
      _PieData('Running'.tr, moving, moving.toStringAsFixed(0), CustomColor.statusDriving),
      _PieData('Idle'.tr, idle, idle.toStringAsFixed(0), CustomColor.statusIdle),
      _PieData('Stopped'.tr, stop, stop.toStringAsFixed(0), CustomColor.statusOffline),
      _PieData('Offline'.tr, offline, offline.toStringAsFixed(0), const Color(0xFF38BDF8)),
      _PieData('Expired'.tr, expired, expired.toStringAsFixed(0), CustomColor.statusExpired),
    ];

    // Filter out zero value slices for a cleaner, gap-free pie
    final dataMap = rawData.where((d) => d.yData > 0).toList();
    final chartData = dataMap.isNotEmpty ? dataMap : [_PieData('Aucun', 1, '0', Colors.grey)];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0x2638BDF8) : const Color(0xFFE2E8F0),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.35 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: CustomColor.primaryAccent.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.pie_chart_rounded,
                      size: 16,
                      color: CustomColor.primaryAccent,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'FleetStatus'.tr,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      CustomColor.primaryAccent.withOpacity(0.18),
                      CustomColor.primaryAccent.withOpacity(0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: CustomColor.primaryAccent.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  'Total'.tr + ': ${all.toInt()}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: CustomColor.primaryAccent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Animated Glowing Doughnut Chart
              SizedBox(
                height: 160,
                width: 145,
                child: SfCircularChart(
                  margin: EdgeInsets.zero,
                  annotations: <CircularChartAnnotation>[
                    CircularChartAnnotation(
                      widget: Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (isDark ? const Color(0xFF0F172A) : Colors.white).withOpacity(0.9),
                          border: Border.all(
                            color: CustomColor.primaryAccent.withOpacity(0.35),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: CustomColor.primaryAccent.withOpacity(0.15),
                              blurRadius: 14,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              all.toInt().toString(),
                              style: TextStyle(
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                height: 1.1,
                              ),
                            ),
                            Text(
                              'Vehicles'.tr,
                              style: TextStyle(
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  series: <DoughnutSeries<_PieData, String>>[
                    DoughnutSeries<_PieData, String>(
                      animationDuration: 1500,
                      explode: true,
                      explodeOffset: '10%',
                      explodeGesture: ActivationMode.singleTap,
                      radius: '96%',
                      innerRadius: '70%',
                      dataSource: chartData,
                      xValueMapper: (_PieData data, _) => data.xData,
                      yValueMapper: (_PieData data, _) => data.yData,
                      pointColorMapper: (_PieData data, _) => data.color,
                      cornerStyle: CornerStyle.bothCurve,
                      strokeColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                      strokeWidth: 2,
                    )
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Status Breakdown Glass Cards
              Expanded(
                child: Column(
                  children: [
                    _buildStatusRow("Running".tr, moving.toInt(), all, CustomColor.statusDriving, isDark),
                    const SizedBox(height: 5),
                    _buildStatusRow("Idle".tr, idle.toInt(), all, CustomColor.statusIdle, isDark),
                    const SizedBox(height: 5),
                    _buildStatusRow("Stopped".tr, stop.toInt(), all, CustomColor.statusOffline, isDark),
                    const SizedBox(height: 5),
                    _buildStatusRow("Offline".tr, offline.toInt(), all, const Color(0xFF38BDF8), isDark),
                    const SizedBox(height: 5),
                    _buildStatusRow("Expired".tr, expired.toInt(), all, CustomColor.statusExpired, isDark),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, int count, double total, Color color, bool isDark) {
    double pct = total > 0 ? (count / total) * 100 : 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.08 : 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.18),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.6),
                  blurRadius: 3,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(width: 3),
          Text(
            '(${pct.round()}%)',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }

  Widget alertStatus(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0x2638BDF8) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Alerts'.tr,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              InkWell(
                onTap: eventList.isNotEmpty
                    ? () {
                        StaticVarMethod.eventList = eventList;
                        StaticVarMethod.notificationback = false;
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => NotificationsPage()),
                        );
                      }
                    : null,
                child: Text(
                  'ViewAll'.tr,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: eventList.isNotEmpty ? CustomColor.primaryAccent : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          loadEventsData1(isDark),
        ],
      ),
    );
  }

  Widget loadEventsData1(bool isDark) {
    final displayEvents = _todayEvents.isNotEmpty ? _todayEvents : eventList;
    final isClickable = displayEvents.isNotEmpty;

    return Column(
      children: [
        // Today's Alerts banner
        GestureDetector(
          onTap: isClickable
              ? () {
                  StaticVarMethod.eventList = displayEvents;
                  StaticVarMethod.notificationback = false;
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NotificationsPage()),
                  );
                }
              : null,
          child: Opacity(
            opacity: isClickable ? 1.0 : 0.6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF97316), Color(0xFFF59E0B)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF97316).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.notifications_active_rounded, color: Colors.white, size: 22),
                      const SizedBox(width: 12),
                      Text(
                        "TodayAlerts".tr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      displayEvents.length.toString(),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFF97316),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Grid of alert cards
        Row(
          children: [
            _buildAlertCard(
              Icons.fence_rounded,
              "Geofence".tr,
              _geofencealets.length,
              const [Color(0xFF8B5CF6), Color(0xFF6366F1)],
              () {
                StaticVarMethod.eventList = _geofencealets;
                StaticVarMethod.notificationback = false;
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotificationsPage()),
                );
              },
              isDark,
            ),
            const SizedBox(width: 10),
            _buildAlertCard(
              Icons.speed_rounded,
              "Overspeed".tr,
              _overspeedalets.length,
              const [Color(0xFFEF4444), Color(0xFFF43F5E)],
              () {
                StaticVarMethod.eventList = _overspeedalets;
                StaticVarMethod.notificationback = false;
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotificationsPage()),
                );
              },
              isDark,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildAlertCard(
              Icons.pause_circle_rounded,
              "ExcessIdle".tr,
              _idlealets.length,
              const [Color(0xFFF59E0B), Color(0xFFD97706)],
              () {
                StaticVarMethod.eventList = _idlealets;
                StaticVarMethod.notificationback = false;
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotificationsPage()),
                );
              },
              isDark,
            ),
            const SizedBox(width: 10),
            _buildAlertCard(
              Icons.local_parking_rounded,
              "Parked".tr,
              _stopalets.length,
              const [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
              () {
                StaticVarMethod.eventList = _stopalets;
                StaticVarMethod.notificationback = false;
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotificationsPage()),
                );
              },
              isDark,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildAlertCard(
              Icons.vpn_key_rounded,
              "IgnitionOn".tr,
              _ignitiononalets.length,
              const [Color(0xFF10B981), Color(0xFF059669)],
              () {
                StaticVarMethod.eventList = _ignitiononalets;
                StaticVarMethod.notificationback = false;
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotificationsPage()),
                );
              },
              isDark,
            ),
            const SizedBox(width: 10),
            _buildAlertCard(
              Icons.vpn_key_off_rounded,
              "IgnitionOff".tr,
              _ignitionoffalets.length,
              const [Color(0xFF64748B), Color(0xFF475569)],
              () {
                StaticVarMethod.eventList = _ignitionoffalets;
                StaticVarMethod.notificationback = false;
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotificationsPage()),
                );
              },
              isDark,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAlertCard(
    IconData icon,
    String label,
    int count,
    List<Color> gradientColors,
    VoidCallback onTap,
    bool isDark,
  ) {
    final isClickable = count >= 1;

    return Expanded(
      child: GestureDetector(
        onTap: isClickable ? onTap : null,
        child: Opacity(
          opacity: isClickable ? 1.0 : 0.5,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A).withOpacity(0.6) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? const Color(0x1F38BDF8) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isClickable
                          ? gradientColors
                          : [Colors.grey.shade400, Colors.grey.shade500],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isClickable
                              ? (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155))
                              : Colors.grey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        count.toString(),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: isClickable
                              ? (isDark ? Colors.white : const Color(0xFF0F172A))
                              : Colors.grey,
                        ),
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

  Future<void> getnotiList() async {
    gpsapis api = gpsapis();
    try {
      eventList = await api.getEventsList(StaticVarMethod.user_api_hash);
      _todayEvents.clear();
      _geofencealets.clear();
      _overspeedalets.clear();
      _idlealets.clear();
      _stopalets.clear();
      _ignitiononalets.clear();
      _ignitionoffalets.clear();

      if (eventList.isNotEmpty) {
        final now = DateTime.now();
        final todayStr = DateFormat('yyyy-MM-dd').format(now);
        final todayAltStr = DateFormat('dd-MM-yyyy').format(now);

        for (int i = 0; i < eventList.length; i++) {
          EventsData model = eventList.elementAt(i);
          String time = model.time?.toString() ?? "";
          if (time.contains(todayStr) || time.contains(todayAltStr)) {
            _todayEvents.add(model);
          }

          String name = (model.name ?? model.message ?? "").toLowerCase();
          if (name.contains("geofence") || name.contains("geofance") || name.contains("zone")) {
            _geofencealets.add(model);
          } else if (name.contains("overspeed") || name.contains("vitesse")) {
            _overspeedalets.add(model);
          } else if (name.contains("idle") || name.contains("ralenti")) {
            _idlealets.add(model);
          } else if (name.contains("stop") || name.contains("stationné")) {
            _stopalets.add(model);
          } else if (name.contains("ignition on") || name.contains("contact allumé")) {
            _ignitiononalets.add(model);
          } else if (name.contains("ignition off") || name.contains("contact éteint")) {
            _ignitionoffalets.add(model);
          }
        }
        if (mounted) {
          setState(() {});
        }
      }
    } catch (e) {}
  }
}

class _PieData {
  _PieData(this.xData, this.yData, this.text, this.color);
  final String xData;
  final num yData;
  final String text;
  final Color color;
}
