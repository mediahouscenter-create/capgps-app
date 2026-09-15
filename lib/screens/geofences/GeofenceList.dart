import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maktrogps/data/datasources.dart';
import 'package:maktrogps/data/model/PermissionModel.dart';
import 'package:maktrogps/model/User.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/model/GeofenceModel.dart';
import 'GeofenceAdd.dart';

class GeofenceListPage extends StatefulWidget {
  const GeofenceListPage({super.key});

  @override
  State<StatefulWidget> createState() => _GeofenceListPageState();
}

class _GeofenceListPageState extends State<GeofenceListPage> {
  GoogleMapController? mapController;
  Timer? _timer;
  bool addFenceVisible = false;
  bool deleteFenceVisible = false;
  bool addClicked = false;
  SharedPreferences? prefs;
  User? user;
  int? deleteFenceId;
  bool isLoading = true;
  List<Geofence> fenceList = [];
  List<int> selectedFenceList = [];
  Marker? newFenceMarker;

  @override
  void initState() {
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
    getFences();
    if (mounted) setState(() {});
  }

  void removeFence(id) {}

  void updateFence(id) {
    fenceList.clear();
    selectedFenceList.clear();
    GeofencePermModel permissionModel = GeofencePermModel();
    permissionModel.deviceId = 23;
    permissionModel.geofenceId = id;
  }

  void getFences() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    gpsapis.getGeoFences().then((value) {
      if (value != null) {
        fenceList.clear();
        fenceList.addAll(value);
        isLoading = false;
        if (mounted) setState(() {});
      } else {
        isLoading = false;
        if (mounted) {
          setState(() {});
          Fluttertoast.showToast(
            msg: "Aucun géorepérage trouvé",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.orange,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      }
    }).catchError((_) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    if (_timer != null) {
      _timer!.cancel();
    }
    super.dispose();
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
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF2563EB), size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Géorepérage",
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF0F172A),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Refresh Action
          IconButton(
            onPressed: () {
              fenceList.clear();
              getFences();
            },
            icon: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E3A8A).withOpacity(0.4) : const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.refresh_rounded,
                color: Color(0xFF3B82F6),
                size: 20,
              ),
            ),
          ),

          // Add Geofence Action
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GeofenceAddPage()),
              ).then((_) {
                fenceList.clear();
                getFences();
              });
            },
            icon: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withOpacity(0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF2563EB)),
            )
          : fenceList.isEmpty
              ? _buildEmptyState(isDark)
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: fenceList.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final fence = fenceList[index];
                    return fenceCard(fence, context, isDark);
                  },
                ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E3A8A).withOpacity(0.4) : const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.fence_rounded,
                color: Color(0xFF3B82F6),
                size: 36,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Aucun géorepérage trouvé",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Appuyez sur le bouton + pour créer une nouvelle zone de géorepérage.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget fenceCard(Geofence fence, BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          // Left Icon Badge
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E3A8A).withOpacity(0.4) : const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.fence_rounded,
              color: Color(0xFF3B82F6),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fence.name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Zone de géorepérage",
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),

          // Chevron Right
          const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFFCBD5E1),
            size: 22,
          ),
        ],
      ),
    );
  }
}

class FenceArguments extends Object {
  Geofence? fenceModel;
  int? deviceId;
  String? name;

  FenceArguments({this.fenceModel, this.deviceId, this.name});
}
