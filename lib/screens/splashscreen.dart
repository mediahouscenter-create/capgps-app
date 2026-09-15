import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:maktrogps/bottom_navigation/bottom_navigation.dart';
import 'package:maktrogps/config/static.dart';
import 'package:maktrogps/data/datasources.dart';
import 'package:maktrogps/screens/sign_in.dart';
import 'package:maktrogps/theme/CustomColor.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../data/model/loginModel.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  SharedPreferences? prefs;
  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );

    _animController.forward();
    checkPreference();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F172A),
              Color(0xFF1E293B),
              Color(0xFF0F172A),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Decorative background glowing spheres
            Positioned(
              top: -80,
              right: -80,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: CustomColor.primaryAccent.withOpacity(0.12),
                ),
              ),
            ),
            Positioned(
              bottom: -100,
              left: -80,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: CustomColor.secondaryAccent.withOpacity(0.1),
                ),
              ),
            ),
            Center(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: ScaleTransition(
                  scale: _scaleAnim,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.06),
                          border: Border.all(
                            color: CustomColor.primaryAccent.withOpacity(0.3),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: CustomColor.primaryAccent.withOpacity(0.15),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Image.asset(
                          StaticVarMethod.splashimageurl,
                          scale: 2.2,
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        "CAP GPS",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Système de Géolocalisation Intelligente",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withOpacity(0.6),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 48),
                      SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            CustomColor.primaryAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void checkPreference() async {
    prefs = await SharedPreferences.getInstance();
    StaticVarMethod.pref_static = prefs;

    String? lang = prefs!.getString('language_code');
    String? country = prefs!.getString('country_code');
    if (lang != null && lang.isNotEmpty) {
      String cCode = country ?? (lang == 'ar' ? 'SA' : (lang == 'en' ? 'US' : 'CA'));
      Get.updateLocale(Locale(lang, cCode));
    }

    if (prefs!.get('baseurlall') != null) {
      StaticVarMethod.baseurlall = prefs!.get('baseurlall').toString();
    } else {
    }

    if (prefs!.get('email') != null) {
      if (prefs!.get("popup_notify") == null) {
        prefs!.setBool("popup_notify", true);
      }
      checkLogin();
    } else {
      prefs!.setBool("popup_notify", true);

      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SignInWithBackground()),
      );
    }
  }

  void checkLogin() {
    Future.delayed(const Duration(milliseconds: 1000), () {
      gpsapis api = new gpsapis();

      api
          .getlogin(
              prefs!.get('email').toString(), prefs!.get('password').toString())
          .then((response) {
        if (response != null) {
          if (response.statusCode == 200) {
            prefs!.setBool("popup_notify", true);
            prefs!.setString("user", response.body);
            final res = LoginModel.fromJson(json.decode(response.body));
            StaticVarMethod.user_api_hash = res.userApiHash;
            prefs!.setString('user_api_hash', res.userApiHash!);
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => BottomNavigation_01()),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SignInWithBackground()),
            );
          }
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SignInWithBackground()),
          );
        }
      });
    });
  }
}
