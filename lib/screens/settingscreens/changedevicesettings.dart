import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:maktrogps/config/static.dart';
import 'package:maktrogps/data/datasources.dart';
import 'package:maktrogps/data/model/devices.dart';
import 'package:shared_preferences/shared_preferences.dart';

class changedevicesettings extends StatefulWidget {
  const changedevicesettings({super.key});

  @override
  _changedevicesettingsState createState() => _changedevicesettingsState();
}

class _changedevicesettingsState extends State<changedevicesettings> {
  final List<String> _devicesListstr = [];
  String device_id = "", imei = "", devicename = "", changetext = "";
  String? protocol,
      name,
      map_arrows6,
      map_icon7,
      tail_color8,
      tail_points9,
      model12,
      odometertype15,
      enginehourtype16,
      odometer17,
      enginehour18,
      fcr19,
      accuracy21;

  late SharedPreferences prefs;

  @override
  void initState() {
    getdeviesList();
    super.initState();
  }

  Future<void> getdeviesList() async {
    prefs = await SharedPreferences.getInstance();
    _devicesListstr.clear();
    for (int i = 0; i < StaticVarMethod.devicelist.length; i++) {
      if (StaticVarMethod.devicelist.elementAt(i).name != null) {
        _devicesListstr.add(StaticVarMethod.devicelist.elementAt(i).name!);
      }
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  void showtoast() {
    Fluttertoast.showToast(
      msg: 'Veuillez sélectionner un véhicule en premier!'.tr,
      toastLength: Toast.LENGTH_LONG,
      backgroundColor: Colors.orange,
    );
  }

  String _mapPrefixToCategory(String prefix) {
    if (prefix.contains("truck")) return "truck";
    if (prefix.contains("bike") || prefix.contains("motorcycle")) return "motorcycle";
    if (prefix.contains("bus")) return "bus";
    if (prefix.contains("ambulance")) return "ambulance";
    if (prefix.contains("tractor")) return "tractor";
    if (prefix.contains("pickup")) return "pickup";
    return "car";
  }

  Future<void> _saveIconSelection(String prefix, String iconId) async {
    if (imei.isEmpty && device_id.isEmpty) {
      showtoast();
      return;
    }

    if (imei.isNotEmpty) {
      await prefs.setString(imei, prefix);
      await prefs.setString("icon_$imei", prefix);
    }
    if (device_id.isNotEmpty) {
      await prefs.setString(device_id, prefix);
      await prefs.setString("icon_$device_id", prefix);
    }

    try {
      String category = _mapPrefixToCategory(prefix);
      final dev = StaticVarMethod.devicelist.firstWhere(
        (d) => d.id.toString() == device_id || d.deviceData?.imei == imei,
        orElse: () => deviceItems(),
      );

      if (dev.toJson().isNotEmpty && dev.id != null) {
        Map<String, dynamic> fullDevicePayload = Map<String, dynamic>.from(dev.toJson());
        await gpsapis.updateTraccarDevice(int.parse(dev.id.toString()), fullDevicePayload, category);
      }
      await gpsapis.editdevice(device_id, devicename, imei, icon_id: iconId);
    } catch (e) {
      print("Error updating device icon on server: $e");
    }

    Fluttertoast.showToast(
      msg: 'Icône du véhicule mise à jour avec succès!'.tr,
      toastLength: Toast.LENGTH_LONG,
      backgroundColor: Colors.green,
    );
    if (mounted) {
      setState(() {});
    }
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
          "ChangeDeviceSetting".tr,
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF0F172A),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Card 1: Vehicle Selection
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
                    "Vehicle".tr,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Dropdown Container
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
                            Icons.directions_car_filled_rounded,
                            color: Color(0xFF3B82F6),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownSearch<String>(
                            items: _devicesListstr,
                            dropdownDecoratorProps: DropDownDecoratorProps(
                              dropdownSearchDecoration: InputDecoration(
                                hintText: "Sélectionner un véhicule".tr,
                                hintStyle: TextStyle(
                                  fontSize: 14,
                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                            onChanged: (dynamic value) {
                              if (value != null) {
                                for (int i = 0; i < StaticVarMethod.devicelist.length; i++) {
                                  if (StaticVarMethod.devicelist.elementAt(i).name!.contains(value)) {
                                    imei = StaticVarMethod.devicelist.elementAt(i).deviceData!.imei.toString();
                                    devicename = StaticVarMethod.devicelist.elementAt(i).name.toString();
                                    device_id = StaticVarMethod.devicelist.elementAt(i).id.toString();
                                    break;
                                  }
                                }
                                setState(() {
                                  getfnsettign();
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Card 2: Configuration Actions
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
                    "Options de configuration".tr,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Option 1: Change Icon
                  _buildSettingOptionTile(
                    isDark: isDark,
                    icon: Icons.directions_car_rounded,
                    title: "Changer l'icône".tr,
                    subtitle: devicename.isNotEmpty ? "Véhicule: $devicename" : "Sélectionner une nouvelle icône".tr,
                    onTap: () {
                      if (imei.isNotEmpty) {
                        _showPopup(context);
                      } else {
                        showtoast();
                      }
                    },
                  ),

                  Divider(
                    height: 24,
                    thickness: 1,
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                  ),

                  // Option 2: Change Name
                  _buildSettingOptionTile(
                    isDark: isDark,
                    icon: Icons.edit_note_rounded,
                    title: "Changer le nom".tr,
                    subtitle: devicename.isNotEmpty ? devicename : "Modifier le nom du véhicule".tr,
                    onTap: () {
                      if (imei.isNotEmpty) {
                        _showEdit(context, "Change Name");
                      } else {
                        showtoast();
                      }
                    },
                  ),

                  Divider(
                    height: 24,
                    thickness: 1,
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                  ),

                  // Option 3: Change Odometer
                  _buildSettingOptionTile(
                    isDark: isDark,
                    icon: Icons.speed_rounded,
                    title: "Changer le kilométrage".tr,
                    subtitle: "Ajuster l'odomètre de l'appareil".tr,
                    onTap: () {
                      if (imei.isNotEmpty) {
                        _showEdit(context, "Change odometer");
                      } else {
                        showtoast();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingOptionTile({
    required bool isDark,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E3A8A).withOpacity(0.4) : const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF3B82F6),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFFCBD5E1),
            size: 22,
          ),
        ],
      ),
    );
  }

  // Modern Popup for Icon Selection
  void _showPopup(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final iconsList = [
      {'name': 'Moto', 'prefix': 'bike_', 'id': '4', 'asset': 'assets/vehcileIcon/bike_sidestop.png'},
      {'name': 'Voiture', 'prefix': 'car_', 'id': '1', 'asset': 'assets/vehcileIcon/car_sidestop.png'},
      {'name': 'Camion', 'prefix': 'truck_', 'id': '2', 'asset': 'assets/vehcileIcon/truck_sidestop.png'},
      {'name': 'Ambulance', 'prefix': 'ambulance_', 'id': '6', 'asset': 'assets/vehcileIcon/ambulance_sidestop.png'},
      {'name': 'Bus', 'prefix': 'bus_', 'id': '3', 'asset': 'assets/vehcileIcon/bus_sidestop.png'},
      {'name': 'Auto', 'prefix': 'erickshaw_', 'id': '8', 'asset': 'assets/vehcileIcon/erickshaw_sidestop.png'},
      {'name': 'Vélo', 'prefix': 'cycle_', 'id': '9', 'asset': 'assets/vehcileIcon/cycle_sidestop.png'},
      {'name': 'Scooter', 'prefix': 'scotty_', 'id': '10', 'asset': 'assets/vehcileIcon/scotty_sidestop.png'},
      {'name': 'Tracteur', 'prefix': 'tractor_', 'id': '5', 'asset': 'assets/vehcileIcon/tractor_sidestop.png'},
      {'name': 'Wagan', 'prefix': 'car1_', 'id': '11', 'asset': 'assets/vehcileIcon/car1_sidestop.png'},
      {'name': 'Voiture 2', 'prefix': 'car2_', 'id': '12', 'asset': 'assets/vehcileIcon/car2_sidestop.png'},
      {'name': 'Camion 2', 'prefix': 'car3_', 'id': '7', 'asset': 'assets/vehcileIcon/car3_sidestop.png'},
    ];

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E3A8A).withOpacity(0.4) : const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.directions_car_rounded,
                            color: Color(0xFF3B82F6),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "Choisir une icône".tr,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Icons Grid
                Flexible(
                  child: SingleChildScrollView(
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.9,
                      ),
                      itemCount: iconsList.length,
                      itemBuilder: (context, index) {
                        final item = iconsList[index];
                        return GestureDetector(
                          onTap: () async {
                            await _saveIconSelection(item['prefix']!, item['id']!);
                            if (mounted && Navigator.canPop(context)) {
                              Navigator.of(context).pop();
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  item['asset']!,
                                  height: 38,
                                  width: 38,
                                  errorBuilder: (context, error, stackTrace) => const Icon(
                                    Icons.directions_car_filled_rounded,
                                    color: Color(0xFF3B82F6),
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  item['name']!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Modern Popup for Text Edit (Name / Odometer)
  void _showEdit(BuildContext context, String changetype) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    changetext = "";

    String titleText = changetype.contains("Change Name")
        ? "Changer le nom"
        : changetype.contains("Change odometer")
            ? "Changer le kilométrage"
            : "Modifier le paramètre";

    IconData headerIcon = changetype.contains("Change Name") ? Icons.edit_note_rounded : Icons.speed_rounded;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E3A8A).withOpacity(0.4) : const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            headerIcon,
                            color: const Color(0xFF3B82F6),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          titleText.tr,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Field Label
                Text(
                  devicename.isNotEmpty ? "Véhicule: $devicename" : "Nouvelle valeur".tr,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 8),

                // Input Box
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
                        child: Icon(
                          headerIcon,
                          color: const Color(0xFF3B82F6),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          keyboardType: changetype.contains("Change odometer") ? TextInputType.number : TextInputType.text,
                          onChanged: (String value) {
                            changetext = value;
                          },
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                          decoration: InputDecoration(
                            hintText: changetype.contains("Change Name") ? "Entrez le nouveau nom".tr : "Entrez la nouvelle valeur".tr,
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

                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          "Annuler".tr,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          elevation: 4,
                          shadowColor: const Color(0xFF2563EB).withOpacity(0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () {
                          if (changetype.contains("Change Name")) {
                            editfnsettign(device_id, changetext, imei);
                          } else if (changetype.contains("Change odometer")) {
                            gpsapis.addsensors(device_id, changetext);
                          } else if (changetype.contains("Change mileage")) {
                            editfnsettign(name!, enginehour18!, changetext);
                          }
                          Fluttertoast.showToast(
                            msg: 'Mise à jour réussie!'.tr,
                            toastLength: Toast.LENGTH_LONG,
                            backgroundColor: Colors.green,
                          );
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          "Enregistrer".tr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> editfnsettign(String device_id, String name, String imei) async {
    try {
      await gpsapis.editdevice(device_id, name, imei);
      Fluttertoast.showToast(
        msg: 'Appareil mis à jour avec succès!',
        backgroundColor: Colors.green,
        toastLength: Toast.LENGTH_LONG,
      );
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    } catch (e) {}
  }

  Future<void> getfnsettign() async {
    try {} catch (e) {}
  }
}
