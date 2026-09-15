import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:maktrogps/config/static.dart';
import 'package:maktrogps/data/datasources.dart';
import 'package:maktrogps/mvvm/view_model/objects.dart';
import 'package:provider/provider.dart';
import 'package:maktrogps/screens/AlertList.dart';
import 'package:maktrogps/screens/serviceslist.dart';
import 'package:maktrogps/theme/CustomColor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/model/User.dart';
import '../addalert.dart';
import '../alerts/AlertList.dart';
import '../geofences/GeofenceList.dart';
import '../playback.dart';
import '../reports/reportselection.dart';
import '../sign_in.dart';
import 'changedevicesettings.dart';
import 'add_user_page.dart';


class SettingScreen extends StatefulWidget {
  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  late SharedPreferences prefs;
  bool isLoading = true;
  bool _val = true;
  String email = "";
  String expirationDate = "";

  final TextEditingController _newPassword = TextEditingController();
  final TextEditingController _retypePassword = TextEditingController();

  late User user;
  String expiration_date = "";

  @override
  void initState() {
    super.initState();
    getUser();
    checkPreference();
  }

  User? _user;

  bool get isDirecteur {
    if (_user == null) return false;
    final planStr = _user?.plan?.toString().toLowerCase() ?? "";
    return planStr.contains("directeur");
  }

  bool get isSuperviseur {
    if (_user == null) return false;
    final roleId = _user?.role_id;
    final groupId = _user?.group_id;
    final planStr = _user?.plan?.toString().toLowerCase() ?? "";
    return roleId == 5 ||
        groupId == 5 ||
        roleId?.toString() == "5" ||
        groupId?.toString() == "5" ||
        roleId == 6 ||
        groupId == 6 ||
        roleId?.toString() == "6" ||
        groupId?.toString() == "6" ||
        planStr.contains("opérateur") ||
        planStr.contains("operator") ||
        planStr.contains("superviseur") ||
        planStr.contains("supervisor");
  }

  getUser() async {
    prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString("user");
    if (userJson != null) {
      try {
        final parsed = json.decode(userJson);
        _user = User.fromJson(parsed);
        email = _user?.email.toString() ?? "";
        expiration_date = _user?.expiration_date.toString() ?? "";
        isLoading = false;
        if (mounted) setState(() {});
      } catch (e) {}
    }

    gpsapis.getUserData().then((value) {
      if (value != null) {
        isLoading = false;
        _user = value;
        user = value;
        email = value.email.toString();
        expiration_date = value.expiration_date.toString();
        if (mounted) setState(() {});
      }
    });
  }

  void checkPreference() async {
    prefs = await SharedPreferences.getInstance();
    _val = prefs.getBool("notival") ?? true;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
                children: [
                  Text(
                    'Paramètres'.tr,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 24.0,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildProfileSection(isDark),
                  const SizedBox(height: 16),
                  _buildSettingsOptions(isDark),
                  const SizedBox(height: 16),
                  _buildMenuItems(isDark),
                  const SizedBox(height: 90),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// **Profile Section with Avatar & User Info**
  Widget _buildProfileSection(bool isDark) {
    double profilePictureSize = 64;
    return Container(
      decoration: BoxDecoration(
        gradient: CustomColor.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: CustomColor.primaryAccent.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: profilePictureSize / 2,
                child: ClipOval(
                  child: Image.asset(
                    "assets/icon/user.png",
                    height: profilePictureSize - 12,
                    width: profilePictureSize - 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  (email.isNotEmpty)
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              email,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Compte actif',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        )
                      : const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// **Settings Section**
  Widget _buildSettingsOptions(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0x2638BDF8) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: CustomColor.primaryAccent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.tune_rounded,
                    color: CustomColor.primaryAccent,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Préférences',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
          _buildSettingItem(
            icon: Icons.notifications_active_rounded,
            text: "NotificationSetting".tr,
            isDark: isDark,
            trailing: Switch(
              value: _val,
              activeTrackColor: CustomColor.primaryAccent.withOpacity(0.4),
              activeColor: CustomColor.primaryAccent,
              onChanged: (value) {
                setState(() {
                  _val = value;
                  prefs.setBool("notival", _val);
                });
              },
            ),
            onTap: () {},
          ),
          _buildSettingItem(
            icon: Icons.language_rounded,
            text: "ChangeLanguage".tr,
            isDark: isDark,
            onTap: () => changeLanguageDialog(isDark),
          ),
          _buildSettingItem(
            icon: Icons.lock_outline_rounded,
            text: "ChangePassword".tr,
            isDark: isDark,
            onTap: () => changePasswordDialog(isDark),
          ),
          _buildSettingItem(
            icon: Icons.developer_mode_rounded,
            text: "ChangeDeviceSetting".tr,
            isDark: isDark,
            onTap: () => {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => changedevicesettings()))
            },
          ),
          _buildSettingItem(
            icon: Icons.notifications_rounded,
            text: 'AlertList'.tr,
            isDark: isDark,
            onTap: () => {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => AlertListPage()))
            },
          ),
          _buildSettingItem(
            icon: Icons.notification_add_rounded,
            text: 'ActivateAlert'.tr,
            isDark: isDark,
            onTap: () => {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ActivateAlert()))
            },
          ),
          _buildSettingItem(
            icon: Icons.fence_rounded,
            text: 'GeofenceSetting'.tr,
            isDark: isDark,
            onTap: () => {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => GeofenceListPage()))
            },
          ),

          _buildSettingItem(
            icon: Icons.speed_rounded,
            text: 'Overspeeding'.tr,
            isDark: isDark,
            onTap: () => {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const addalert(
                            defaultType: "Overspeed",
                            isTypeLocked: true,
                          )))
            },
          ),
          if (isSuperviseur)
            _buildSettingItem(
              icon: Icons.person_add_alt_1_rounded,
              text: "Ajouter Utilisateur".tr,
              isDark: isDark,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddUserPage()),
              ),
            ),
        ],
      ),
    );
  }

  /// **General Menu Items**
  Widget _buildMenuItems(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0x2638BDF8) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingItem(
            icon: Icons.bar_chart_rounded,
            text: "Reports".tr,
            isDark: isDark,
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => reportselection()));
            },
          ),
          _buildSettingItem(
            icon: Icons.logout_rounded,
            text: "SignOut".tr,
            isDark: isDark,
            textColor: CustomColor.statusOffline,
            onTap: () => _signOut(),
          ),
        ],
      ),
    );
  }

  /// **Reusable Setting Item**
  Widget _buildSettingItem({
    required IconData icon,
    required String text,
    required bool isDark,
    Color? textColor,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isDark ? const Color(0xFF334155).withOpacity(0.5) : const Color(0xFFF1F5F9),
              width: 1,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: textColor != null
                        ? textColor.withOpacity(0.12)
                        : CustomColor.primaryAccent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: textColor ?? CustomColor.primaryAccent,
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textColor ?? (isDark ? Colors.white : const Color(0xFF0F172A)),
                  ),
                ),
              ],
            ),
            trailing ??
                Icon(
                  Icons.chevron_right_rounded,
                  color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                  size: 20,
                ),
          ],
        ),
      ),
    );
  }

  /// **Handles Sign Out**
  void _signOut() async {
    StaticVarMethod.resetUserSession();
    try {
      Provider.of<ObjectStore>(context, listen: false).clear();
    } catch (_) {}
    await prefs.remove("email");
    await prefs.remove("password");
    await prefs.remove("user");
    await prefs.remove("user_api_hash");
    await prefs.remove("popup_notify");
    await prefs.setBool("notival", false);
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SignInWithBackground()),
      );
    }
  }

  /// **Opens External Browser**
  void _openBrowser(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Fluttertoast.showToast(msg: "Impossible d'ouvrir le lien");
    }
  }

  /// **Change Language Dialog**
  void changeLanguageDialog(bool isDark) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
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
              // Dialog Header
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
                          Icons.translate_rounded,
                          color: Color(0xFF3B82F6),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "Changer de langue".tr,
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

              Column(
                children: [
                  _languageTile("English", "en", "US", isDark),
                  const SizedBox(height: 10),
                  _languageTile("Français", "fr", "CA", isDark),
                  const SizedBox(height: 10),
                  _languageTile("العربية", "ar", "SA", isDark),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// **Reusable Language Tile**
  Widget _languageTile(String name, String lang, String country, bool isDark) {
    bool isSelected = Get.locale?.languageCode == lang;

    return InkWell(
      onTap: () async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('language_code', lang);
        await prefs.setString('country_code', country);
        Get.updateLocale(Locale(lang, country));
        Get.forceAppUpdate();
        if (mounted) {
          setState(() {});
          Navigator.pop(context);
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2563EB)
                : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            width: isSelected ? 1.5 : 1.0,
          ),
          color: isSelected
              ? const Color(0xFF2563EB).withOpacity(isDark ? 0.15 : 0.05)
              : Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF2563EB).withOpacity(0.2)
                        : (isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.language_rounded,
                    size: 18,
                    color: isSelected
                        ? const Color(0xFF2563EB)
                        : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? const Color(0xFF2563EB)
                        : (isDark ? Colors.white : const Color(0xFF0F172A)),
                  ),
                ),
              ],
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF2563EB),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  void changePasswordDialog(bool isDark) {
    bool isNewPasswordVisible = false;
    bool isRetypePasswordVisible = false;

    showDialog(
      context: context,
      builder: (BuildContext context) => Dialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: const EdgeInsets.all(20),
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dialog Header
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
                              Icons.lock_reset_rounded,
                              color: Color(0xFF3B82F6),
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Changer le mot de passe".tr,
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

                  // Field 1: Nouveau mot de passe
                  Text(
                    "Nouveau mot de passe".tr,
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
                            Icons.lock_outline_rounded,
                            color: Color(0xFF3B82F6),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _newPassword,
                            obscureText: !isNewPasswordVisible,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                            decoration: InputDecoration(
                              hintText: "Entrez le nouveau mot de passe".tr,
                              hintStyle: TextStyle(
                                fontSize: 14,
                                color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isNewPasswordVisible = !isNewPasswordVisible;
                            });
                          },
                          child: Icon(
                            isNewPasswordVisible ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                            color: const Color(0xFF94A3B8),
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Field 2: Retaper le mot de passe
                  Text(
                    "Retaper le mot de passe".tr,
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
                            Icons.lock_rounded,
                            color: Color(0xFF3B82F6),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _retypePassword,
                            obscureText: !isRetypePasswordVisible,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                            decoration: InputDecoration(
                              hintText: "Confirmez le nouveau mot de passe".tr,
                              hintStyle: TextStyle(
                                fontSize: 14,
                                color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isRetypePasswordVisible = !isRetypePasswordVisible;
                            });
                          },
                          child: Icon(
                            isRetypePasswordVisible ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                            color: const Color(0xFF94A3B8),
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Submit Button
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
                      onPressed: () {
                        updatePassword();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            "Mettre à jour".tr,
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
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> updatePassword() async {
    String pass = _newPassword.text.trim();
    String confirmPass = _retypePassword.text.trim();

    if (pass.isEmpty || confirmPass.isEmpty) {
      Fluttertoast.showToast(
        msg: "Veuillez remplir tous les champs".tr,
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.amber.shade800,
        textColor: Colors.white,
      );
      return;
    }

    if (pass.length < 4) {
      Fluttertoast.showToast(
        msg: "Le mot de passe doit contenir au moins 4 caractères".tr,
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.amber.shade800,
        textColor: Colors.white,
      );
      return;
    }

    if (pass != confirmPass) {
      Fluttertoast.showToast(
        msg: "Les mots de passe ne correspondent pas".tr,
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    try {
      EasyLoading.show(status: 'Mise à jour...'.tr);
      var result = await gpsapis.changePassword(pass);
      EasyLoading.dismiss();

      _newPassword.clear();
      _retypePassword.clear();

      if (mounted) {
        Navigator.of(context).pop();
      }

      Fluttertoast.showToast(
        msg: "Mot de passe mis à jour avec succès".tr,
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } catch (e) {
      EasyLoading.dismiss();
      Fluttertoast.showToast(
        msg: "Erreur lors de la modification du mot de passe".tr,
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  void _showAddUserDialog(bool isDark) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController confirmPasswordController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 10,
          child: Container(
            padding: const EdgeInsets.all(20),
            width: 340,
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.person_add_alt_1_rounded,
                              color: CustomColor.primaryAccent,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Ajouter Utilisateur".tr,
                              style: TextStyle(
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(dialogContext),
                          child: Icon(
                            Icons.close_rounded,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: nameController,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black),
                      decoration: InputDecoration(
                        labelText: "Nom complet".tr,
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? "Veuillez remplir tous les champs".tr : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black),
                      decoration: InputDecoration(
                        labelText: "Email".tr,
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty || !v.contains("@")) ? "Email invalide".tr : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black),
                      decoration: InputDecoration(
                        labelText: "Téléphone".tr,
                        prefixIcon: const Icon(Icons.phone_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? "Veuillez remplir tous les champs".tr : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black),
                      decoration: InputDecoration(
                        labelText: "Mot de passe".tr,
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (v) => (v == null || v.length < 4) ? "Le mot de passe doit contenir au moins 4 caractères".tr : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black),
                      decoration: InputDecoration(
                        labelText: "Confirmer le mot de passe".tr,
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (v) {
                        if (v != passwordController.text) {
                          return "Les mots de passe ne correspondent pas".tr;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CustomColor.primaryAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            Navigator.pop(dialogContext);
                            EasyLoading.show(status: "Création de l'utilisateur...".tr);

                            List<String> deviceIds = [];
                            try {
                              final objects = Provider.of<ObjectStore>(context, listen: false).objects;
                              for (var dev in objects) {
                                if (dev.id != null) {
                                  deviceIds.add(dev.id.toString());
                                }
                              }
                            } catch (_) {}

                            try {
                              final res = await gpsapis.addUserWithDevices(
                                nameController.text.trim(),
                                emailController.text.trim(),
                                phoneController.text.trim(),
                                passwordController.text,
                                deviceIds,
                              );
                              EasyLoading.dismiss();

                              if (res.statusCode == 200) {
                                Fluttertoast.showToast(
                                  msg: "Utilisateur créé avec succès".tr,
                                  backgroundColor: Colors.green,
                                  textColor: Colors.white,
                                );
                              } else {
                                Fluttertoast.showToast(
                                  msg: "Erreur lors de la création de l'utilisateur".tr,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                );
                              }
                            } catch (e) {
                              EasyLoading.dismiss();
                              Fluttertoast.showToast(
                                msg: "Erreur lors de la création de l'utilisateur".tr,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                              );
                            }
                          }
                        },
                        child: Text(
                          "Enregistrer".tr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}