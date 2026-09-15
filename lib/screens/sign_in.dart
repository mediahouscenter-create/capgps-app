import 'dart:convert';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_io/io.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:maktrogps/bottom_navigation/bottom_navigation.dart';
import 'package:maktrogps/config/static.dart';
import 'package:maktrogps/data/datasources.dart';
import 'package:maktrogps/data/model/loginModel.dart';
import 'package:maktrogps/mvvm/view_model/objects.dart';
import 'package:provider/provider.dart';

import '../config/constant.dart';

class SignInWithBackground extends StatefulWidget {
  const SignInWithBackground({super.key});

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignInWithBackground>
    with TickerProviderStateMixin {
  final TextEditingController _usernameFieldController = TextEditingController();
  final TextEditingController _passwordFieldController = TextEditingController();
  final TextEditingController _customserverFieldController = TextEditingController();

  late SharedPreferences prefs;
  late AnimationController _animationController;
  late AnimationController _slideAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _logoSlideAnimation;
  late Animation<Offset> _cardSlideAnimation;
  late Animation<double> _scaleAnimation;

  final _obscureText = true.obs;
  final isBusy = true.obs;
  final isLoggedIn = false.obs;

  String _username = "", _password = "", _customserver = "";
  int _selectedserver = 0;

  @override
  void initState() {
    super.initState();
    checkPreference();
    configLoading();

    // Main fade animation
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _fadeAnimation = CurvedAnimation(
        parent: _animationController, curve: Curves.easeInOut);

    // Slide animations
    _slideAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));

    _logoSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideAnimationController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
    ));

    _cardSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideAnimationController,
      curve: const Interval(0.2, 0.7, curve: Curves.easeOutCubic),
    ));

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _slideAnimationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _animationController.forward();
    _slideAnimationController.forward();
  }

  @override
  void dispose() {
    _usernameFieldController.dispose();
    _passwordFieldController.dispose();
    _customserverFieldController.dispose();
    _animationController.dispose();
    _slideAnimationController.dispose();
    super.dispose();
  }

  void checkPreference() async {
    prefs = await SharedPreferences.getInstance();

    _selectedserver = prefs.getInt('selected_server') ?? 0;
    if (_selectedserver == 0) {
      StaticVarMethod.baseurlall = "http://195.26.241.183";
    } else if (_selectedserver == 1) {
      StaticVarMethod.baseurlall = "https://169-58-190-54.nip.io";
    } else {
      StaticVarMethod.baseurlall = prefs.getString('baseurlall') ?? "http://195.26.241.183";
    }

    if (prefs.getString('email') != null) {
      _usernameFieldController.text = prefs.getString('email')!;
      _passwordFieldController.text = prefs.getString('password')!;
      _customserverFieldController.text = prefs.getString('baseurlall') ?? "";
      _username = _usernameFieldController.text;
      _password = _passwordFieldController.text;

      login();
    } else {
      isBusy.value = false;
    }
  }

  void configLoading() {
    EasyLoading.instance
      ..displayDuration = const Duration(milliseconds: 2000)
      ..indicatorType = EasyLoadingIndicatorType.fadingCircle
      ..loadingStyle = EasyLoadingStyle.dark
      ..indicatorSize = 45.0
      ..radius = 10.0
      ..progressColor = const Color(0xFF2563EB)
      ..backgroundColor = const Color(0xFF0F172A)
      ..indicatorColor = const Color(0xFF38BDF8)
      ..textColor = Colors.white
      ..maskColor = Colors.black.withOpacity(0.6)
      ..userInteractions = true
      ..dismissOnTap = false;
  }

  void login() async {
    StaticVarMethod.resetUserSession();
    String inputUser = _usernameFieldController.text.trim();
    if (inputUser.isNotEmpty && !inputUser.contains('@')) {
      inputUser = '$inputUser@capgps.com';
    }
    _username = inputUser;
    _password = _passwordFieldController.text.trim();

    if (_selectedserver == 0) {
      StaticVarMethod.baseurlall = "http://195.26.241.183";
    } else if (_selectedserver == 1) {
      StaticVarMethod.baseurlall = "https://169-58-190-54.nip.io";
    } else if (_selectedserver == 3) {
      String custom = _customserverFieldController.text.trim();
      if (custom.isNotEmpty) {
        if (!custom.startsWith("http://") && !custom.startsWith("https://")) {
          custom = "http://$custom";
        }
        StaticVarMethod.baseurlall = custom;
      }
    }

    prefs.setInt('selected_server', _selectedserver);
    prefs.setString('baseurlall', StaticVarMethod.baseurlall);

    EasyLoading.show(status: 'Chargement...');
    gpsapis api = gpsapis();

    try {
      final response = await api.getlogin(_username, _password).timeout(
        const Duration(seconds: 8),
      );

      EasyLoading.dismiss();

      if (response.statusCode == 200) {
        try {
          final res = LoginModel.fromJson(json.decode(response.body));
          if (res.userApiHash != null && res.userApiHash!.isNotEmpty) {
            StaticVarMethod.resetUserSession();
            try {
              if (mounted) {
                Provider.of<ObjectStore>(context, listen: false).clear();
              }
            } catch (_) {}
            prefs.setBool("popup_notify", true);
            prefs.setString("user", response.body);
            prefs.setString("email", _username);
            prefs.setString("password", _password);
            isBusy.value = false;
            isLoggedIn.value = true;

            StaticVarMethod.user_api_hash = res.userApiHash;
            prefs.setString('user_api_hash', res.userApiHash!);

            Get.off(() => BottomNavigation_01());
            return;
          }
        } catch (_) {}

        isBusy.value = false;
        isLoggedIn.value = false;
        String errorMessage = "Réponse invalide du serveur.";

        Fluttertoast.showToast(
            msg: errorMessage,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.black87,
            textColor: Colors.white,
            fontSize: 15.0);
      } else {
        isBusy.value = false;
        isLoggedIn.value = false;
        String errorMessage;
        if (response.statusCode == 401 || response.statusCode == 403) {
          errorMessage = "Identifiants incorrects.";
        } else {
          errorMessage = "Impossible de se connecter au serveur (${response.statusCode}).";
        }

        Fluttertoast.showToast(
            msg: errorMessage,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.black87,
            textColor: Colors.white,
            fontSize: 15.0);
      }
    } catch (e) {
      EasyLoading.dismiss();
      isBusy.value = false;
      isLoggedIn.value = false;

      String errorMessage = "Impossible de contacter le serveur. Vérifiez votre connexion.";

      Fluttertoast.showToast(
          msg: errorMessage,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.black87,
          textColor: Colors.white,
          fontSize: 15.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: Platform.isIOS
            ? SystemUiOverlayStyle.light
            : const SystemUiOverlayStyle(statusBarIconBrightness: Brightness.light),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/appIcon/bg.jpeg"),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF0F172A).withOpacity(0.65),
                  const Color(0xFF0B132B).withOpacity(0.85),
                  const Color(0xFF030712).withOpacity(0.92),
                ],
              ),
            ),
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Top Right Language Selector Button
                        Align(
                          alignment: Alignment.topRight,
                          child: PopupMenuButton<String>(
                            onSelected: (String langCode) async {
                              SharedPreferences p = await SharedPreferences.getInstance();
                              String cCode = (langCode == 'ar') ? 'SA' : (langCode == 'en') ? 'US' : 'CA';
                              p.setString('language_code', langCode);
                              p.setString('country_code', cCode);
                              Get.updateLocale(Locale(langCode, cCode));
                              setState(() {});
                            },
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            color: const Color(0xFF0F172A),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withOpacity(0.2)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.language_rounded, color: Colors.white, size: 18),
                                  const SizedBox(width: 6),
                                  Text(
                                    Get.locale?.languageCode == 'ar'
                                        ? 'العربية'
                                        : Get.locale?.languageCode == 'en'
                                            ? 'English'
                                            : 'Français',
                                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white70, size: 16),
                                ],
                              ),
                            ),
                            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                              const PopupMenuItem<String>(
                                value: 'fr',
                                child: Text('Français', style: TextStyle(color: Colors.white)),
                              ),
                              const PopupMenuItem<String>(
                                value: 'en',
                                child: Text('English', style: TextStyle(color: Colors.white)),
                              ),
                              const PopupMenuItem<String>(
                                value: 'ar',
                                child: Text('العربية', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Logo Halo Header
                        SlideTransition(
                          position: _logoSlideAnimation,
                          child: ScaleTransition(
                            scale: _scaleAnimation,
                            child: Container(
                              width: 160,
                              height: 160,
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.35),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                "assets/images/app_logo.png",
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Main Glassmorphism Form Card
                        SlideTransition(
                          position: _cardSlideAnimation,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0B172E).withOpacity(0.82),
                              borderRadius: BorderRadius.circular(32),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.12),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.45),
                                  blurRadius: 30,
                                  offset: const Offset(0, 15),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Title & Subtitle
                                Text(
                                  'Bienvenue'.tr,
                                  style: const TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  width: 32,
                                  height: 3.5,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2563EB),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Connectez-vous pour continuer'.tr,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF94A3B8),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),

                                const SizedBox(height: 28),

                                // Username Input Field
                                _buildGlassTextField(
                                  controller: _usernameFieldController,
                                  hintText: "Nom d'utilisateur".tr,
                                  icon: Icons.mail_rounded,
                                  onChanged: (value) => _username = value,
                                ),

                                const SizedBox(height: 16),

                                // Password Input Field
                                Obx(() => _buildGlassTextField(
                                  controller: _passwordFieldController,
                                  hintText: "Mot de passe".tr,
                                  icon: Icons.lock_rounded,
                                  obscureText: _obscureText.value,
                                  onChanged: (value) => _password = value,
                                  suffixIcon: GestureDetector(
                                    onTap: () => _obscureText.toggle(),
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 14),
                                      child: Icon(
                                        _obscureText.value
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: const Color(0xFF94A3B8),
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                )),

                                const SizedBox(height: 20),

                                // Connection Button & S1/S2 Dropdown Row
                                _buildLoginAndServerRow(),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Centered Support Icon Button (Middle, No Text)
                        _buildCenteredSupportButton(),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    required Function(String) onChanged,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFF132238).withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF1E395A).withOpacity(0.8),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 6),
          // Left Icon Squircle
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF3B82F6),
                  Color(0xFF1D4ED8),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2563EB).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              onChanged: onChanged,
              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hintText,
                hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
              ),
            ),
          ),
          if (suffixIcon != null) suffixIcon,
        ],
      ),
    );
  }

  Widget _buildLoginAndServerRow() {
    return Row(
      children: [
        // Login / Connection Button
        Expanded(
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF3B82F6),
                  Color(0xFF1D4ED8),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2563EB).withOpacity(0.45),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  if (_username.isEmpty) {
                    Fluttertoast.showToast(msg: 'Veuillez fournir un nom d\'utilisateur!'.tr);
                  } else if (_password.isEmpty) {
                    Fluttertoast.showToast(msg: 'Veuillez fournir un mot de passe!'.tr);
                  } else {
                    login();
                  }
                },
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.logout_rounded, color: Colors.white, size: 22),
                      const SizedBox(width: 10),
                      Text(
                        'Login'.tr,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Small S1 / S2 Dropdown Selector
        Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF132238).withOpacity(0.85),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF1E395A).withOpacity(0.8),
              width: 1.5,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: (_selectedserver == 1) ? 1 : 0,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white70, size: 20),
              dropdownColor: const Color(0xFF0F172A),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
              onChanged: (int? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedserver = newValue;
                    if (_selectedserver == 0) {
                      StaticVarMethod.baseurlall = "http://195.26.241.183";
                    } else if (_selectedserver == 1) {
                      StaticVarMethod.baseurlall = "https://169-58-190-54.nip.io";
                    }
                    prefs.setInt('selected_server', _selectedserver);
                    prefs.setString('baseurlall', StaticVarMethod.baseurlall);
                  });
                }
              },
              items: const [
                DropdownMenuItem<int>(
                  value: 0,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.dns_rounded, size: 16, color: Color(0xFF38BDF8)),
                      SizedBox(width: 6),
                      Text('S1'),
                    ],
                  ),
                ),
                DropdownMenuItem<int>(
                  value: 1,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.dns_rounded, size: 16, color: Color(0xFF34D399)),
                      SizedBox(width: 6),
                      Text('S2'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCenteredSupportButton() {
    return Center(
      child: GestureDetector(
        onTap: launchWhatsApp,
        child: Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: const Color(0xFF0B172E).withOpacity(0.85),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(0.18),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.headset_mic_rounded,
            color: Colors.white,
            size: 26,
          ),
        ),
      ),
    );
  }

  void launchWhatsApp() async {
    await launchUrl(Uri.parse("mailto:otitsdi@gmail.com"));
  }

  bool _isValidServerFormat(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return false;
    
    String clean = trimmed.replaceAll(RegExp(r'^https?://'), '');
    if (clean.contains('/')) {
      clean = clean.split('/').first;
    }
    if (clean.contains(':')) {
      clean = clean.split(':').first;
    }

    final ipRegExp = RegExp(
      r'^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'
    );
    final domainRegExp = RegExp(
      r'^(?:[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}$'
    );

    return ipRegExp.hasMatch(clean) || domainRegExp.hasMatch(clean) || clean == "localhost";
  }

  void showServerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: const Color(0xFF0F172A),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: _selectedserver == 3 ? 320.0 : 250.0,
                width: 320.0,
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Sélectionner le serveur",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    RadioListTile<int>(
                      title: const Text("Serveur personnalisé", style: TextStyle(color: Colors.white)),
                      value: 3,
                      activeColor: const Color(0xFF2563EB),
                      groupValue: _selectedserver,
                      onChanged: (value) {
                        setState(() {
                          _selectedserver = value!;
                        });
                      },
                    ),
                    if (_selectedserver == 3)
                      TextField(
                        controller: _customserverFieldController,
                        keyboardType: TextInputType.url,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: "Adresse IP du serveur",
                          labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                          hintText: "ex: 195.26.241.183",
                          hintStyle: TextStyle(color: Color(0xFF64748B)),
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                        onChanged: (value) => _customserver = value,
                      ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Annuler", style: TextStyle(color: Colors.white)),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
                          onPressed: () {
                            if (_selectedserver == 3) {
                              String input = _customserverFieldController.text.trim();
                              if (!_isValidServerFormat(input)) {
                                Fluttertoast.showToast(
                                  msg: "Format IP invalide! (ex: 195.26.241.183)",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.CENTER,
                                  backgroundColor: Colors.redAccent,
                                  textColor: Colors.white,
                                  fontSize: 15.0,
                                );
                                return;
                              }

                              if (!input.startsWith("http://") && !input.startsWith("https://")) {
                                input = "http://$input";
                              }

                              StaticVarMethod.baseurlall = input;
                              _customserverFieldController.text = input;
                              prefs.setString('baseurlall', input);
                              prefs.setInt('selected_server', 3);
                            }

                            Fluttertoast.showToast(
                              msg: "Serveur enregistré",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                              backgroundColor: Colors.green,
                              textColor: Colors.white,
                            );

                            Navigator.pop(context);
                          },
                          child: const Text("Enregistrer", style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}