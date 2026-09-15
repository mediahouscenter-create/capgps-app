import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maktrogps/screens/alerts/AddAlerts.dart';
import 'package:maktrogps/theme/CustomColor.dart';
import 'package:maktrogps/model/Alert.dart';
import 'package:maktrogps/model/User.dart';
import 'package:maktrogps/data/datasources.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AlertListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AlertListPageState();
}

class _AlertListPageState extends State<AlertListPage> {
  Timer? _timer;
  SharedPreferences? prefs;
  User? user;
  bool isLoading = false;
  List<Alert> alertList = [];

  @override
  initState() {
    super.initState();
    getUser();
  }

  getUser() async {
    prefs = await SharedPreferences.getInstance();
    String? userJson = prefs!.getString("user");
    if (userJson != null) {
      final parsed = json.decode(userJson);
      user = User.fromJson(parsed);
    }
    getAlerts();
    setState(() {});
  }

  void removeAlert(Alert alert) {
    _showProgress(true);
    alertList.clear();

    Map<String, String> requestBody = <String, String>{
      'id': alert.id.toString(),
      'active': "false"
    };
    gpsapis.activateAlert(requestBody).then((value) => {
          if (value.statusCode == 200)
            {
              getAlerts(),
              _showProgress(false),
            }
          else
            {
              _showProgress(false),
            }
        });
  }

  void activateAlert(Alert alert) {
    _showProgress(true);
    alertList.clear();
    alert.devices!.join(',');
    Map<String, String> requestBody = <String, String>{
      'id': alert.id.toString(),
      'active': "true"
    };
    gpsapis.activateAlert(requestBody).then((value) => {
          if (value.statusCode == 200)
            {
              getAlerts(),
              _showProgress(false),
            }
          else
            {
              _showProgress(false),
            }
        });
  }

  void getAlerts() async {
    _showProgress(true);
    gpsapis.getAlertList().then((value) {
      if (value != null) {
        alertList.addAll(value);
        _showProgress(false);
        setState(() {});
      } else {
        isLoading = false;
        setState(() {});
        _showProgress(false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('alertsNotFound'.tr)));
      }
    });
  }

  void deleteAlert(id) {
    _showProgress(true);
    gpsapis.destroyAlert(id).then((value) => {
          _showProgress(false),
          alertList.clear(),
          getAlerts(),
          setState(() {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('Alerte supprimée'.tr)));
          }),
        });
  }

  @override
  void dispose() {
    super.dispose();
    if (_timer != null) {
      _timer!.cancel();
    }
  }

  Map<String, dynamic> _getAlertIconInfo(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('over') || lower.contains('vitesse') || lower.contains('speed')) {
      return {
        'icon': Icons.notifications_rounded,
        'bg': const Color(0xFFEFF6FF),
        'color': const Color(0xFF3B82F6),
      };
    } else if (lower.contains('marche') || lower.contains('moving') || lower.contains('mouvement')) {
      return {
        'icon': Icons.trending_up_rounded,
        'bg': const Color(0xFFF0FDF4),
        'color': const Color(0xFF10B981),
      };
    } else if (lower.contains('ooo') || lower.contains('idle') || lower.contains('ralenti')) {
      return {
        'icon': Icons.warning_amber_rounded,
        'bg': const Color(0xFFFFFBEB),
        'color': const Color(0xFFF59E0B),
      };
    } else if (lower.contains('fence') || lower.contains('zone') || lower.contains('geo')) {
      return {
        'icon': Icons.location_on_rounded,
        'bg': const Color(0xFFF5F3FF),
        'color': const Color(0xFF8B5CF6),
      };
    } else if (lower.contains('park') || lower.contains('stationne')) {
      return {
        'icon': Icons.directions_car_rounded,
        'bg': const Color(0xFFECFEFF),
        'color': const Color(0xFF06B6D4),
      };
    } else if (lower.contains('stop') || lower.contains('arrêt')) {
      return {
        'icon': Icons.stop_circle_rounded,
        'bg': const Color(0xFFFEF2F2),
        'color': const Color(0xFFEF4444),
      };
    }
    return {
      'icon': Icons.notifications_rounded,
      'bg': const Color(0xFFEFF6FF),
      'color': const Color(0xFF3B82F6),
    };
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF10B981), size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Alerts".tr,
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF0F172A),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddAlertsPage()),
                ).then((value) {
                  alertList.clear();
                  getAlerts();
                });
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF064E3B).withOpacity(0.3) : const Color(0xFFF0FDF4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: Color(0xFF10B981),
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
      body: alertList.isEmpty
          ? Center(
              child: Text(
                "Aucune alerte disponible".tr,
                style: TextStyle(
                  color: isDark ? Colors.white70 : const Color(0xFF64748B),
                  fontSize: 15,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: alertList.length,
              itemBuilder: (context, index) {
                final alert = alertList[index];
                return alertCard(alert, context);
              },
            ),
    );
  }

  Widget alertCard(Alert alert, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconInfo = _getAlertIconInfo(alert.name ?? "");
    final bool isActive = alert.active.toString() == "1" || alert.active.toString() == "true";

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon Box
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: isDark ? (iconInfo['bg'] as Color).withOpacity(0.15) : (iconInfo['bg'] as Color),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              iconInfo['icon'] as IconData,
              color: iconInfo['color'] as Color,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),

          // Title & Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.name ?? "",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive ? const Color(0xFF10B981) : Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isActive ? "Alerte activée" : "Alerte désactivée",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Checkbox / Toggle
          GestureDetector(
            onTap: () {
              if (isActive) {
                removeAlert(alert);
              } else {
                activateAlert(alert);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFF1D4ED8) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: isActive
                    ? null
                    : Border.all(
                        color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                        width: 2,
                      ),
              ),
              child: isActive
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 18,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),

          // Delete Button
          GestureDetector(
            onTap: () => deleteAlert(alert.id),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFF8FAFC),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.delete_outline_rounded,
                size: 18,
                color: isDark ? Colors.white70 : const Color(0xFF475569),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showProgress(bool status) async {
    if (status) {
      return showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Row(
              children: [
                const CircularProgressIndicator(),
                Container(
                  margin: const EdgeInsets.only(left: 12),
                  child: Text(('sharedLoading').tr),
                ),
              ],
            ),
          );
        },
      );
    } else {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }
  }
}

class AlertArguments extends Object {
  Alert? alertModel;
  int? deviceId;
  String? name;

  AlertArguments({this.alertModel, this.deviceId, this.name});
}
