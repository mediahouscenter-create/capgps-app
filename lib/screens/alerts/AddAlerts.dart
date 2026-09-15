import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maktrogps/config/static.dart';
import 'package:maktrogps/data/datasources.dart';
import 'package:maktrogps/data/model/device_data.dart';
import 'package:maktrogps/data/model/devices.dart';
import 'package:maktrogps/screens/AssignFenceScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../theme/CustomColor.dart';
import '../../model/User.dart';

class AddAlertsPage extends StatefulWidget {
  final String? defaultType;
  final bool isTypeLocked;

  const AddAlertsPage({Key? key, this.defaultType, this.isTypeLocked = false}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AddAlertsPageState();
}

class _AddAlertsPageState extends State<AddAlertsPage> {
  Timer? _timer;
  SharedPreferences? prefs;
  User? user;
  bool isLoading = false;

  List<String> selectedDevices = [];
  List<String> types = [];
  String selectedType = "Types";
  String _searchQuery = "";
  final TextEditingController _nameCtl = TextEditingController();
  final TextEditingController _typeCtl = TextEditingController();
  final TextEditingController _searchCtl = TextEditingController();

  void typeList() {
    types = <String>[
      "Overspeed",
      "Stop Duration",
      "Offline Duration",
      "Ignition Duration",
      "Idle Duration",
      "Geofence In",
      "Geofence Out",
      "Geofence In/Out",
      "Start of movement",
      "SOS",
      "Fuel(Fill/Theft)",
      "Driver change unauthorized"
    ];
  }

  @override
  void initState() {
    super.initState();
    if (widget.defaultType != null && widget.defaultType!.isNotEmpty) {
      selectedType = widget.defaultType!;
    }
    getUser();
    getFences();
    typeList();
  }

  void getFences() async {
    gpsapis.getGeoFences().then((value) {
      if (value != null) {
        fenceList.addAll(value);
        setState(() {});
      } else {
        isLoading = false;
        setState(() {});
      }
    });
  }

  getUser() async {
    prefs = await SharedPreferences.getInstance();
    String? userJson = prefs!.getString("user");
    if (userJson != null) {
      final parsed = json.decode(userJson);
      user = User.fromJson(parsed);
    }
    setState(() {});
  }

  void addAlert() {
    if (selectedType == "Types") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez sélectionner un type d'alerte")),
      );
      return;
    }
    if (selectedDevices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez sélectionner au moins un appareil")),
      );
      return;
    }

    _showProgress(true);
    String backendType = "overspeed";
    String typeValueKey = "";

    switch (selectedType) {
      case "Overspeed":
        backendType = "overspeed";
        typeValueKey = "overspeed";
        break;
      case "Stop Duration":
        backendType = "stop_duration";
        typeValueKey = "stop_duration";
        break;
      case "Offline Duration":
        backendType = "offline_duration";
        typeValueKey = "offline_duration";
        break;
      case "Ignition Duration":
        backendType = "ignition_duration";
        typeValueKey = "ignition_duration";
        break;
      case "Idle Duration":
        backendType = "idle_duration";
        typeValueKey = "idle_duration";
        break;
      case "Geofence In":
        backendType = "geofence_in";
        break;
      case "Geofence Out":
        backendType = "geofence_out";
        break;
      case "Geofence In/Out":
        backendType = "geofence_inout";
        break;
      case "Start of movement":
        backendType = "move_start";
        break;
      case "SOS":
        backendType = "sos";
        break;
      case "Fuel(Fill/Theft)":
        backendType = "custom";
        break;
      case "Driver change unauthorized":
        backendType = "driver";
        break;
      default:
        backendType = selectedType.toLowerCase().replaceAll(' ', '_');
    }

    String nameVal = _nameCtl.text.trim().isNotEmpty ? _nameCtl.text.trim() : selectedType;

    String request;
    if (backendType == "types" ||
        backendType == "move_start" ||
        backendType == "moving" ||
        backendType == "sos" ||
        backendType == "custom" ||
        backendType == "driver" ||
        backendType == "fuel" ||
        backendType == "driver_change") {
      request = "&name=$nameVal&type=$backendType&${selectedDevices.join("&")}";
    } else if (backendType.startsWith("geofence_")) {
      request =
          "&name=$nameVal&type=$backendType&zone=0&${selectedFenceList.join("&")}&${selectedDevices.join("&")}";
    } else {
      String val = _typeCtl.text.trim().isNotEmpty ? _typeCtl.text.trim() : "10";
      request =
          "&name=$nameVal&type=$backendType&$typeValueKey=$val&${selectedDevices.join("&")}";
    }

    gpsapis.addAlert(request).then((value) {
      _showProgress(false);
      if (value.statusCode == 200) {
        bool isSuccess = true;
        String? serverErrorMsg;
        try {
          final resData = json.decode(value.body);
          if (resData is Map) {
            if (resData.containsKey('status') && (resData['status'] == 0 || resData['status'] == false || resData['status'] == "0")) {
              isSuccess = false;
              if (resData['errors'] is Map) {
                final Map errs = resData['errors'];
                serverErrorMsg = errs.values.map((v) => v is List ? v.join(", ") : v.toString()).join(" | ");
              } else if (resData['message'] != null) {
                serverErrorMsg = resData['message'].toString();
              }
            }
          }
        } catch (_) {}

        if (isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('alertCreated'.tr)),
          );
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(serverErrorMsg ?? 'Erreur lors de la création de l\'alerte')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la création de l\'alerte')),
        );
      }
    }).catchError((err) {
      _showProgress(false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $err')),
      );
    });
  }

  @override
  void dispose() {
    _nameCtl.dispose();
    _typeCtl.dispose();
    _searchCtl.dispose();
    super.dispose();
    if (_timer != null) {
      _timer!.cancel();
    }
  }

  void showFenceDialog(BuildContext context) {
    fenceList.clear();
    selectedFenceList.clear();
    bool loading = true;
    Dialog simpleDialog = Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          if (fenceList.isEmpty) {
            gpsapis.getGeoFences().then((value) {
              if (value != null) {
                fenceList.addAll(value);
                loading = false;
                setState(() {});
              } else {
                loading = false;
                setState(() {});
              }
            });
          }
          return AssignFenceScreen(context, setState, loading);
        },
      ),
    );
    showDialog(
        context: context, builder: (BuildContext context) => simpleDialog);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredDevices = StaticVarMethod.devicelist.where((device) {
      final name = device.name?.toLowerCase() ?? "";
      return name.contains(_searchQuery.toLowerCase());
    }).toList();

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
          "addAlerts".tr,
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF0F172A),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Card 1: Type and Value Configuration
            Container(
              padding: const EdgeInsets.all(20),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name Section Label
                  Text(
                    "Nom".tr,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),

                  Container(
                    height: 52,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E3A8A).withOpacity(0.4) : const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.edit_outlined,
                            color: Color(0xFF3B82F6),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _nameCtl,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                            decoration: InputDecoration(
                              hintText: "Nom de l'alerte".tr,
                              hintStyle: TextStyle(
                                fontSize: 14,
                                color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Type Section Label
                  Text(
                    "Type".tr,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Type Dropdown Container
                  Container(
                    height: 52,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E3A8A).withOpacity(0.4) : const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.notifications_none_rounded,
                            color: Color(0xFF3B82F6),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: selectedType != "Types" ? selectedType : null,
                              hint: Text(
                                "Types",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                ),
                              ),
                              icon: widget.isTypeLocked
                                  ? const Icon(
                                      Icons.lock_outline_rounded,
                                      color: Color(0xFF94A3B8),
                                      size: 20,
                                    )
                                  : const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: Color(0xFF64748B),
                                      size: 22,
                                    ),
                              items: types.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: widget.isTypeLocked
                                  ? null
                                  : (value) {
                                      setState(() {
                                        selectedType = value!;
                                      });
                                    },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Sélectionnez le type d'alerte".tr,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),

                  // Geofences selector if Geofence selected
                  if (selectedType == "Geofence In" ||
                      selectedType == "Geofence Out" ||
                      selectedType == "Geofence In/Out") ...[
                    const SizedBox(height: 14),
                    GestureDetector(
                      onTap: () => showFenceDialog(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Sélectionner GeoFences".tr,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                            Icon(Icons.map, color: CustomColor.primaryColor, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // Value Section Field
                  const SizedBox(height: 16),
                  Text(
                    "Valeur".tr,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),

                  Container(
                    height: 52,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E3A8A).withOpacity(0.4) : const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.tag_rounded,
                            color: Color(0xFF3B82F6),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _typeCtl,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                            decoration: InputDecoration(
                              hintText: "Entrez la valeur".tr,
                              hintStyle: TextStyle(
                                fontSize: 14,
                                color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Card 2: Devices Selection Card
            Container(
              padding: const EdgeInsets.all(20),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Vehicles".tr,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Search input bar
                  Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.search_rounded,
                          color: Color(0xFF94A3B8),
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchCtl,
                            onChanged: (val) {
                              setState(() {
                                _searchQuery = val;
                              });
                            },
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                            decoration: InputDecoration(
                              hintText: "Rechercher un appareil".tr,
                              hintStyle: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF94A3B8),
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Devices list
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredDevices.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 20,
                      thickness: 1,
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFF8FAFC),
                    ),
                    itemBuilder: (context, index) {
                      final device = filteredDevices[index];
                      final deviceKey = "devices[]=${device.id}";
                      final isSelected = selectedDevices.contains(deviceKey);

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              selectedDevices.remove(deviceKey);
                            } else {
                              selectedDevices.add(deviceKey);
                            }
                          });
                        },
                        child: Container(
                          color: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              // Checkbox
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFF2563EB) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(6),
                                  border: isSelected
                                      ? null
                                      : Border.all(
                                          color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                                          width: 2,
                                        ),
                                ),
                                child: isSelected
                                    ? const Icon(
                                        Icons.check_rounded,
                                        color: Colors.white,
                                        size: 16,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 14),

                              // Car icon squircle
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1E3A8A).withOpacity(0.4) : const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.directions_car_filled_rounded,
                                  color: Color(0xFF3B82F6),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Device name
                              Expanded(
                                child: Text(
                                  device.name ?? "",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                                  ),
                                ),
                              ),

                              // Chevron Right
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: Color(0xFFCBD5E1),
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  elevation: 4,
                  shadowColor: const Color(0xFF2563EB).withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: addAlert,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.save_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      "Enregistrer".tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
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
