import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:maktrogps/config/static.dart';
import 'package:maktrogps/screens/device_list_screen.dart';
import 'package:maktrogps/screens/notification_screen.dart';
import 'package:maktrogps/screens/settingscreens/setting_screen.dart';
import 'package:maktrogps/data/datasources.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/dashboard.dart';
import '../screens/mainmapscreen.dart';
import '../mvvm/view_model/objects.dart';
import '../theme/CustomColor.dart';

class BottomNavigation_01 extends StatefulWidget {
  const BottomNavigation_01({super.key});

  @override
  _BottomNavigation_01State createState() => _BottomNavigation_01State();
}

class _BottomNavigation_01State extends State<BottomNavigation_01> {
  late PageController _pageController;
  int _currentIndex = 0;
  int _eventsKey = 0;
  late List<Widget> _contentPages;

  bool loaded = false;
  bool _hasShownExpiryWarning = false;
  DateTime? currentBackPressTime;
  Timer? _timer;

  @override
  void initState() {
    _pageController = PageController(initialPage: 0);
    _contentPages = [
      DevicesListScreen(),
      mainmapscreen(),
      DashboardScreen(),
      NotificationsPage(key: ValueKey(_eventsKey)),
      SettingScreen()
    ];
    super.initState();
    _hasShownExpiryWarning = false;
    updateToken();
    getObjects();
  }

  void checkPreference() async {
    StaticVarMethod.pref_static = await SharedPreferences.getInstance();
  }

  void getObjects() {
    try {
      final store = Provider.of<ObjectStore>(context, listen: false);
      store.getObjects();
    } catch (_) {}

    _timer = Timer.periodic(const Duration(seconds: 8), (timer) {
      if (!mounted) return;
      try {
        Provider.of<ObjectStore>(context, listen: false).getObjects();
        if (!_hasShownExpiryWarning) {
          _checkExpiryWarning();
        }
      } catch (e) {
        print("Error in background timer: $e");
      }
    });

    Future.delayed(const Duration(seconds: 2)).then((value) {
      if (mounted) {
        setState(() {
          loaded = true;
        });
        _checkExpiryWarning();
      }
    });
  }

  void _checkExpiryWarning() {
    if (_hasShownExpiryWarning) return;

    List<String> warningMessages = [];
    for (var device in StaticVarMethod.devicelist) {
      String? expStr = device.deviceData?.expirationDate?.toString();
      if (expStr != null && expStr.isNotEmpty) {
        try {
          DateTime expDate = DateTime.parse(expStr);
          DateTime now = DateTime.now();
          DateTime expDateOnly = DateTime(expDate.year, expDate.month, expDate.day);
          DateTime nowOnly = DateTime(now.year, now.month, now.day);
          int diff = expDateOnly.difference(nowOnly).inDays;

          if (diff <= 10) {
            String name = device.deviceData?.name ?? device.name ?? "Véhicule";
            String imei = device.deviceData?.imei ?? "";
            String imeiStr = imei.isNotEmpty ? imei : "";
            String msg = "Le device $name $imeiStr va expirer bientot, veuillez nous contacter".replaceAll("  ", " ");
            warningMessages.add(msg);
          }
        } catch (_) {}
      }
    }

    if (warningMessages.isNotEmpty && mounted) {
      _hasShownExpiryWarning = true;
      _showExpiryWarningDialog(warningMessages);
    }
  }

  void _showExpiryWarningDialog(List<String> messages) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          padding: const EdgeInsets.all(22),
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xFFF59E0B),
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      "Avertissement d'expiration",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Warning Messages List
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 260),
                child: SingleChildScrollView(
                  child: Column(
                    children: messages
                        .map((msg) => Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFFFFBEB),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xFFF59E0B).withOpacity(0.4),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.info_outline_rounded,
                                    color: Color(0xFFD97706),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      msg,
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w600,
                                        height: 1.4,
                                        color: isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // OK Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    "Compris",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (_timer != null) {
      _timer!.cancel();
    }
    _pageController.dispose();
    super.dispose();
  }

  Future<void> updateToken() async {
    gpsapis.getUserData().then((value) =>
        {gpsapis.activateFCM(StaticVarMethod.notificationToken)});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final navItems = [
      {'icon': Icons.directions_car_filled_rounded, 'label': 'List'.tr},
      {'icon': Icons.map_outlined, 'label': 'Map'.tr},
      {'icon': Icons.grid_view_rounded, 'label': 'Dash'.tr},
      {'icon': Icons.notifications_outlined, 'label': 'Events'.tr, 'hasBadge': StaticVarMethod.hasUnreadNotifications},
      {'icon': Icons.tune_rounded, 'label': 'Settings'.tr},
    ];

    return Scaffold(
      backgroundColor: isDark ? CustomColor.primaryDark : const Color(0xFFF8FAFC),
      body: WillPopScope(
        onWillPop: onWillPop,
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: _contentPages,
        ),
      ),
      bottomNavigationBar: Container(
        color: const Color(0xFF091124),
        child: SafeArea(
          bottom: true,
          top: false,
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0F1E36),
                  Color(0xFF091124),
                ],
              ),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withOpacity(0.12),
                  width: 1,
                ),
              ),
            ),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final itemWidth = width / navItems.length;

                  return TweenAnimationBuilder<double>(
                    tween: Tween<double>(
                      begin: _currentIndex.toDouble(),
                      end: _currentIndex.toDouble(),
                    ),
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    builder: (context, animValue, child) {
                      final leftPos = animValue * itemWidth;
                      BorderRadius borderRadius = BorderRadius.circular(16);

                      return Stack(
                        children: [
                          // Animated Active Blue Background Pill
                          Positioned(
                            left: leftPos,
                            width: itemWidth,
                            top: 0,
                            bottom: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF2563EB),
                                    Color(0xFF1D4ED8),
                                  ],
                                ),
                                borderRadius: borderRadius,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF2563EB).withOpacity(0.4),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Navigation Items Row
                          Row(
                            children: List.generate(navItems.length, (index) {
                              final isSelected = _currentIndex == index;
                              final hasBadge = navItems[index]['hasBadge'] == true;

                              return Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    if (index == 3) {
                                      StaticVarMethod.notificationback = true;
                                      StaticVarMethod.hasUnreadNotifications = false;
                                      _eventsKey++;
                                    }
                                    _pageController.animateToPage(
                                      index,
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeOutCubic,
                                    );
                                    setState(() {
                                      _currentIndex = index;
                                    });
                                  },
                                  behavior: HitTestBehavior.opaque,
                                  child: Container(
                                    height: 66,
                                    alignment: Alignment.center,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        // Icon with Optional Red Badge Dot
                                        Stack(
                                          clipBehavior: Clip.none,
                                          children: [
                                            Icon(
                                              navItems[index]['icon'] as IconData,
                                              color: isSelected
                                                  ? Colors.white
                                                  : Colors.white.withOpacity(0.85),
                                              size: 22,
                                            ),
                                            if (hasBadge)
                                              Positioned(
                                                right: -2,
                                                top: -2,
                                                child: Container(
                                                  width: 7,
                                                  height: 7,
                                                  decoration: const BoxDecoration(
                                                    color: Color(0xFFEF4444),
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 3),

                                        // Label
                                        Text(
                                          navItems[index]['label'] as String,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.white.withOpacity(0.85),
                                          ),
                                        ),

                                        // Active Bottom White Dot
                                        if (isSelected) ...[
                                          const SizedBox(height: 3),
                                          Container(
                                            width: 4,
                                            height: 4,
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ] else
                                          const SizedBox(height: 7),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      showExitPopup();
      return Future.value(false);
    }
    return Future.value(true);
  }

  Future<bool> showExitPopup() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isDark ? const Color(0x3338BDF8) : const Color(0xFFE2E8F0),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: CustomColor.statusOffline.withOpacity(0.12),
                ),
                child: const Icon(
                  Icons.power_settings_new_rounded,
                  color: CustomColor.statusOffline,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Quitter l'application ?",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Voulez-vous vraiment fermer CapGPS ?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Non".tr,
                        style: TextStyle(
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => exit(0),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CustomColor.statusOffline,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Oui".tr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}