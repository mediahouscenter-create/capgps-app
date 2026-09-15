import 'dart:async';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:maktrogps/config/static.dart';
import 'package:maktrogps/theme/CustomColor.dart';
import 'package:maktrogps/data/datasources.dart';
import 'package:maktrogps/data/model/devices.dart';
import 'package:maktrogps/data/model/history.dart';

import 'package:maktrogps/screens/playbackselection.dart';
import 'package:maktrogps/screens/reports/reportselection.dart';
import 'package:maktrogps/screens/reports/vehicle_info.dart';
import 'package:maktrogps/screens/trip/tripinfoselectionscreen.dart';
import 'package:maktrogps/mapconfig/CommonMethod.dart';
import 'package:maktrogps/ui/reusable/shimmer_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maktrogps/utils/MapUtils.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';
import '../../mvvm/view_model/objects.dart';
import 'LiveMapScreen/LiveMapScreen.dart';
import 'lockscreenNew.dart';
import 'playback.dart';
import 'reports/kmdetail.dart';

class DevicesListScreen extends StatefulWidget {
  @override
  _listscreencentereasytracking createState() =>
      _listscreencentereasytracking();
}

class _listscreencentereasytracking extends State<DevicesListScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  // initialize global function and global widget
  final _shimmerLoading = ShimmerLoading();
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  PersistentBottomSheetController? _bottomSheetController;

  // Animation controllers
  late AnimationController _listAnimationController;
  late AnimationController _appBarAnimationController;

  String filtertext = "All";
  bool _loading = true;

  final Completer<GoogleMapController> _mapController = Completer();
  Set<Marker> markers = new Set();

  List<deviceItems> _vehiclesData = [];
  List<deviceItems> _vehiclesData_sorted = [];
  List<deviceItems> _vehiclesData_duplicate = [];
  // _listKey is used for AnimatedList
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  TextEditingController _etSearch = TextEditingController();

  int _tabIndex = 0;

  GoogleMapController? _controller;
  bool _mapLoading = true;
  static Color primaryDark = const Color.fromARGB(255, 13, 61, 101);
  double _currentZoom = 14;

//  final LatLng _initialPosition = LatLng(-6.168033, 106.900467);

  Marker? _marker;

  late BitmapDescriptor _markerDirection;
  void _setSourceAndDestinationIcons() async {
    _markerDirection = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(devicePixelRatio: 2.5),
        'assets/images/direction.png');
  }

  List<String> carstatusList = [
    'All Vehicles'.tr,
    'Running'.tr,
    'Stopped'.tr,
    'Idle'.tr,
    'Expired'.tr
  ];
  int starIndex = 0;
  Color CHARCOAL = const Color(0xFF515151);
  bool _searchEnabled = false;
  List<deviceItems> _inactiveVehicles = [];
  List<deviceItems> _runningVehicles = [];
  List<deviceItems> _idleVehicles = [];
  List<deviceItems> _offlineVehicles = [];
  List<deviceItems> _stoppedVehicles = [];
  List<deviceItems> _expiredVehicles = [];
  late SharedPreferences prefs;
  late ObjectStore objectStore;

  final Map<int, Future<History>> _historyFutures = {};
  final Map<String, Future<String>> _addressFutures = {};

  // KmandfuelHistoryBloc kmhistorybloc = KmandfuelHistoryBloc();
  Timer? _syncTimer;

  @override
  void initState() {
    starIndex = 0;
    _tabIndex = 0;
    _etSearch.clear();
    _loading = false;

    final now = DateTime.now();
    final dateFormat = DateFormat('yyyy-MM-dd');
    final timeFormat = DateFormat('HH:mm:ss');

    StaticVarMethod.fromdate = dateFormat.format(now);
    StaticVarMethod.fromtime = "00:00:00";
    StaticVarMethod.todate = dateFormat.format(now);
    StaticVarMethod.totime = timeFormat.format(now);

    // Initialize animation controllers
    _listAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _appBarAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _appBarAnimationController.forward();
    _listAnimationController.forward();

    checkPreference();
    _setSourceAndDestinationIcons();

    _syncTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_vehiclesData.isEmpty && StaticVarMethod.devicelist.isNotEmpty) {
        setState(() {
          _vehiclesData = List.from(StaticVarMethod.devicelist);
          _updateFilteredList();
        });
        timer.cancel();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final store = Provider.of<ObjectStore>(context, listen: false);
        if (store.objects.isEmpty) {
          store.getObjects(forceLoading: true);
        }
      } catch (_) {}
    });

    super.initState();
  }

  void checkPreference() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    _etSearch.dispose();
    _listAnimationController.dispose();
    _appBarAnimationController.dispose();
    super.dispose();
  }

  bool _isVehicleExpired(deviceItems model) {
    if (model.time != null &&
        (model.time!.toLowerCase().contains("expired") ||
         model.time!.toLowerCase().contains("expiré") ||
         model.time!.toLowerCase().contains("expire"))) {
      return true;
    }
    if (model.online != null &&
        (model.online!.toLowerCase().contains("expired") ||
         model.online!.toLowerCase().contains("expiré") ||
         model.online!.toLowerCase().contains("expire"))) {
      return true;
    }
    if (model.deviceData != null) {
      var active = model.deviceData!.active;
      if (active == 0 || active == false || active == "0" || active == "false") {
        return true;
      }
    }
    String? expStr = model.deviceData?.expirationDate?.toString();
    if (expStr != null && expStr.isNotEmpty) {
      String lower = expStr.toLowerCase().trim();
      if (lower.contains("expire") || lower.contains("expiré") || lower.contains("0000-00-00")) {
        return true;
      }
      try {
        DateTime expDate = DateTime.parse(expStr);
        DateTime now = DateTime.now();
        DateTime expDateOnly = DateTime(expDate.year, expDate.month, expDate.day);
        DateTime nowOnly = DateTime(now.year, now.month, now.day);
        return expDateOnly.difference(nowOnly).inDays <= 0;
      } catch (_) {}
    }
    return false;
  }

  String _getIgnition(deviceItems model) {
    String other = "";
    if (model.deviceData != null && model.deviceData!.traccar != null) {
      other = model.deviceData!.traccar!.other?.toString() ?? "";
    }
    if (other.contains("<ignition>")) {
      const start = "<ignition>";
      const end = "</ignition>";
      final startIndex = other.indexOf(start);
      final endIndex = other.indexOf(end, startIndex + start.length);
      if (startIndex != -1 && endIndex != -1) {
        return other.substring(startIndex + start.length, endIndex);
      }
    }
    return "false";
  }

  double _getSpeed(deviceItems model) {
    if (model.speed == null) return 0.0;
    return double.tryParse(model.speed.toString()) ?? 0.0;
  }

  void _updateFilteredList() {
    _vehiclesData_duplicate.clear();
    String searchQuery = _etSearch.text.trim().toLowerCase();

    for (var model in _vehiclesData_sorted) {
      if (searchQuery.isNotEmpty) {
        String name = (model.deviceData?.name ?? model.name ?? "").toLowerCase();
        String imei = (model.deviceData?.imei ?? "").toLowerCase();
        if (!name.contains(searchQuery) && !imei.contains(searchQuery)) {
          continue;
        }
      }

      if (starIndex == 0) {
        _vehiclesData_duplicate.add(model);
      } else if (starIndex == 1) {
        if (!_isVehicleExpired(model) && _getSpeed(model) > 0) {
          _vehiclesData_duplicate.add(model);
        }
      } else if (starIndex == 2) {
        if (!_isVehicleExpired(model) && _getSpeed(model) <= 0 && !_getIgnition(model).contains("true")) {
          _vehiclesData_duplicate.add(model);
        }
      } else if (starIndex == 3) {
        if (!_isVehicleExpired(model) && _getSpeed(model) <= 0 && _getIgnition(model).contains("true")) {
          _vehiclesData_duplicate.add(model);
        }
      } else if (starIndex == 4) {
        if (_isVehicleExpired(model)) {
          _vehiclesData_duplicate.add(model);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    objectStore = Provider.of<ObjectStore>(context);
    _vehiclesData = objectStore.objects;
    if (_vehiclesData.isEmpty && StaticVarMethod.devicelist.isNotEmpty) {
      _vehiclesData = StaticVarMethod.devicelist;
    }
    StaticVarMethod.devicelist = _vehiclesData;

    _runningVehicles = [];
    _idleVehicles = [];
    _stoppedVehicles = [];
    _inactiveVehicles = [];
    _expiredVehicles = [];
    _offlineVehicles = [];

    if (_vehiclesData.isNotEmpty) {
      _vehiclesData_sorted.clear();
      _vehiclesData_sorted.addAll(_vehiclesData);

      for (var model in _vehiclesData) {
        if (_isVehicleExpired(model)) {
          _expiredVehicles.add(model);
        } else if (_getSpeed(model) > 0) {
          _runningVehicles.add(model);
        } else if (_getIgnition(model).contains("true")) {
          _idleVehicles.add(model);
        } else {
          _stoppedVehicles.add(model);
        }
      }

      _updateFilteredList();
      if (_vehiclesData_duplicate.isEmpty) {
        starIndex = 0;
        _tabIndex = 0;
        _etSearch.clear();
        _updateFilteredList();
      }
      _loading = false;
    } else {
      _vehiclesData_duplicate.clear();
      _vehiclesData_sorted.clear();
      _loading = false;
    }

    final double boxImageSize = (MediaQuery.of(context).size.width / 12);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    bool isStoreLoading = objectStore.isLoading;
    if (_vehiclesData.isNotEmpty) {
      isStoreLoading = false;
    }

    Widget _child;
    if (isStoreLoading && _vehiclesData.isEmpty) {
      _child = Center(
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
    } else if (_vehiclesData.isNotEmpty || _vehiclesData_duplicate.isNotEmpty) {
      if (_vehiclesData_duplicate.isEmpty && _vehiclesData.isNotEmpty) {
        _vehiclesData_duplicate.addAll(_vehiclesData);
      }
      _child = RefreshIndicator(
        onRefresh: refreshData,
        child: devicesListWidget(boxImageSize),
      );
    } else {
      _child = RefreshIndicator(
        onRefresh: refreshData,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.2),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.directions_car_filled_rounded,
                      size: 44,
                      color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    "Aucun véhicule trouvé".tr,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDark ? CustomColor.primaryDark : const Color(0xFFF5F7FA),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: isDark ? CustomColor.primaryDark : const Color(0xFF0F172A),
          ),
        ),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: (_searchEnabled)
            ? TextFormField(
              controller: _etSearch,
              style: const TextStyle(fontSize: 16, color: Colors.white),
              onChanged: (value) {
                setState(() {
                  if (value.isNotEmpty) {
                    filterSearchResults(value);
                  } else {
                    _vehiclesData.clear();
                    filtertext = "All";
                  }
                });
              },
              decoration: InputDecoration(
                fillColor: Colors.white.withOpacity(0.12),
                filled: true,
                hintText: 'Enter device name or IMEI'.tr,
                hintStyle: const TextStyle(fontSize: 14, color: Colors.white60),
                prefixIcon: Icon(Icons.search, color: CustomColor.primaryAccent, size: 20),
                suffixIcon: (_etSearch.text == '')
                    ? null
                    : GestureDetector(
                        onTap: () {
                          filtertext = "All";
                          _etSearch = TextEditingController(text: '');
                          _searchEnabled = !_searchEnabled;
                        },
                        child: const Icon(Icons.close, color: Colors.white70, size: 18)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            )
            : Text("Véhicules".tr,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? CustomColor.primaryDark : const Color(0xFFF5F7FA),
            ),
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
            height: 60,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: List.generate(carstatusList.length, (index) {
                return radioStar(carstatusList[index], index);
              }),
            ),
          ),
        ),
        actions: [
          IconButton(
              icon: Icon(
                (_searchEnabled) ? Icons.clear_rounded : Icons.search,
                color: Colors.white,
                size: 26,
              ),
              onPressed: () {
                setState(() {
                  filtertext = "All";
                  //setState(() {
                  // _getData();
                  _etSearch = TextEditingController(text: '');
                  _searchEnabled = _searchEnabled == false ? true : false;
                });
              }),
        ],
      ),
      body: _child,
    );
  }

  Widget radioStar(String txt, int index) {
    IconData tabIcon = Icons.directions_car_rounded;
    Color iconcolor = CustomColor.primaryAccent;
    var txt1 = "0";

    if (index == 0) {
      tabIcon = Icons.directions_car_rounded;
      txt1 = _vehiclesData.length.toString();
      iconcolor = CustomColor.primaryAccent;
    } else if (index == 1) {
      tabIcon = Icons.navigation_rounded;
      txt1 = _runningVehicles.length.toString();
      iconcolor = CustomColor.statusDriving;
    } else if (index == 2) {
      tabIcon = Icons.local_parking_rounded;
      txt1 = _stoppedVehicles.length.toString();
      iconcolor = CustomColor.statusOffline;
    } else if (index == 3) {
      tabIcon = Icons.pause_circle_rounded;
      txt1 = _idleVehicles.length.toString();
      iconcolor = CustomColor.statusIdle;
    } else if (index == 4) {
      tabIcon = Icons.timer_off_rounded;
      txt1 = _expiredVehicles.length.toString();
      iconcolor = CustomColor.statusExpired;
    }

    bool isSelected = starIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _appBarAnimationController,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (_appBarAnimationController.value * 0.2),
          child: Opacity(
            opacity: _appBarAnimationController.value,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: () {
          setState(() {
            starIndex = index;
            _tabIndex = index;
            _updateFilteredList();
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      iconcolor,
                      iconcolor.withOpacity(0.85),
                    ],
                  )
                : null,
            color: isSelected
                ? null
                : (isDark ? const Color(0xFF1E293B) : Colors.white),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? iconcolor.withOpacity(0.35)
                    : Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                blurRadius: isSelected ? 8 : 4,
                offset: Offset(0, isSelected ? 3 : 1),
              ),
            ],
            border: Border.all(
              color: isSelected ? Colors.transparent : iconcolor.withOpacity(0.3),
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                tabIcon,
                size: 18,
                color: isSelected ? Colors.white : iconcolor,
              ),
              const SizedBox(width: 6),
              Text(
                txt1,
                style: TextStyle(
                  color: isSelected ? Colors.white : (isDark ? Colors.white : const Color(0xFF0F172A)),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget devicesListWidget(double boxImageSize) {
    return ScrollablePositionedList.builder(
      key: _listKey,
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 160),
      itemCount: _vehiclesData_duplicate.length,
      itemBuilder: (context, index) =>
          _buildItem(_vehiclesData_duplicate[index], boxImageSize, index),
      itemScrollController: itemScrollController,
      itemPositionsListener: itemPositionsListener,
    );
  }

  void filterSearchResults(String query) {
    _updateFilteredList();
    if (mounted) {
      setState(() {});
    }
  }

  Color randomColor() =>
      Color((Random().nextDouble() * 0xFFFFFF).toInt() << 0).withOpacity(1.0);

  Widget _buildItem(deviceItems productData, boxImageSize, index) {
    double imageSize = MediaQuery.of(context).size.width / 25;
    double lat = productData.lat != null ? double.tryParse(productData.lat.toString()) ?? 0.0 : 0.0;
    double lng = productData.lng != null ? double.tryParse(productData.lng.toString()) ?? 0.0 : 0.0;
    double course = productData.course != null ? double.tryParse(productData.course.toString()) ?? 0.0 : 0.0;
    int speed = productData.speed != null ? double.tryParse(productData.speed.toString())?.toInt() ?? 0 : 0;
    
    String imei = "";
    if (productData.deviceData != null) {
      imei = productData.deviceData!.imei?.toString() ?? "";
    }
    
    String carstatus = productData.online?.toString() ?? "offline";
    String time = productData.time?.toString() ?? "";
    
    String drivername = "";
    if (productData.driverData != null) {
      drivername = productData.driverData!.name?.toString() ?? "";
    }
    
    var expirationdate;
    if (productData.deviceData != null && productData.deviceData!.expirationDate != null) {
      expirationdate =
          formatDateReport(productData.deviceData!.expirationDate.toString());
    } else {
      expirationdate = productData.deviceData?.expirationDate?.toString() ?? "";
    }

    Color statuscolor = const Color(0xffBBDEFA);

    // Extracting ignition, battery level, GSM, engine hours, etc.
    String other = "";
    if (productData.deviceData != null && productData.deviceData!.traccar != null) {
      other = productData.deviceData!.traccar!.other?.toString() ?? "";
    }
    
    String ignition = "false";
    int batterylevel = 0;
    int gsm = 0;
    String enginehours = "0h";
    String sat = "0";
    String totaldistance = "0";
    String distance = "0";
    String devicestatus = "0";
    String stopDuration = productData.stopDuration?.toString() ?? "0s";
    int hours = 0;

    if (other.contains("<ignition>")) {
      ignition = _extractValue(other, "<ignition>", "</ignition>");
    }
    if (other.contains("<batterylevel>")) {
      batterylevel = int.tryParse(_extractValue(other, "<batterylevel>", "</batterylevel>")) ?? 0;
    }
    if (other.contains("<rssi>")) {
      gsm = int.tryParse(_extractValue(other, "<rssi>", "</rssi>")) ?? 0;
    }
    if (other.contains("<enginehours>")) {
      int engineHrsRaw = int.tryParse(_extractValue(other, "<enginehours>", "</enginehours>")) ?? 0;
      enginehours = (engineHrsRaw / 3600).toStringAsFixed(2);
    }
    if (other.contains("<sat>")) {
      sat = _extractValue(other, "<sat>", "</sat>");
    }
    if (other.contains("<totaldistance>")) {
      double dis = double.tryParse(_extractValue(other, "<totaldistance>", "</totaldistance>")) ?? 0.0;
      totaldistance = (dis / 1000).toStringAsFixed(2);
    }
    if (other.contains("<distance>")) {
      distance = _extractValue(other, "<distance>", "</distance>");
    }

    if (productData.sensors != null) {
      for (var val in productData.sensors!) {
        if(val.type == "odometer"){
          totaldistance = val.value?.toString() ?? "0";
        }
      }
    }

    // Determining device status and icon
    String iconpath = _getDeviceIcon(productData, ignition, speed, stopDuration);
    devicestatus = _getDeviceStatus(productData, ignition, speed);
    statuscolor = _getStatusColor(productData, ignition, speed);

    return GestureDetector(
      onTap: () {
        _navigateToLiveTracking(productData, devicestatus, statuscolor);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey.shade50,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 15,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: statuscolor.withValues(alpha: 0.1),
              blurRadius: 20,
              spreadRadius: -5,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(
            color: statuscolor.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            // Device Name and Expiry Date
            _buildTopRow(productData),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildVehicleIcon(iconpath),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCircleIndicator(const Color(0xff7E3885), "TotalMI".tr + " " + '$totaldistance km'),
                      _buildDashedLine(),
                      _buildCircleIndicator(const Color(0xffE83F82), 'EngineHours'.tr + " " + '$enginehours h'),
                      _buildDashedLine(),
                      _buildCircleIndicator(const Color(0xff26C090), 'Stopped'.tr + " " + '${_formatStopDuration(productData.stopDuration.toString())}'),
                      _buildDashedLine(),
                      _buildCircleIndicator(const Color(0xff26C090), 'todayDistance'.tr + " " + (distance != "0" && distance.isNotEmpty ? "$distance km" : "0 km")),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSpeedIndicator(speed),
                    const SizedBox(height: 10),
                    _buildEngineButton(productData),
                    const SizedBox(height: 10),
                    _buildHistoryButton(productData),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildLocationRow(lat, lng, gsm),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }


  /// Function to build a filled circular indicator
  Widget _buildCircleIndicator(Color color, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color, // Dynamic color
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.5),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// Function to build a dashed line between indicators
  Widget _buildDashedLine() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 7),
          child: Column(
            children: List.generate(
              2,
              (index) => Container(
                margin: const EdgeInsets.symmetric(vertical: 1),
                height: 3,
                width: 3,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black26, // Dashed line color
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Extracts a value between two XML tags
  String _extractValue(String data, String startTag, String endTag) {
    final startIndex = data.indexOf(startTag);
    final endIndex = data.indexOf(endTag, startIndex + startTag.length);
    return data.substring(startIndex + startTag.length, endIndex);
  }

  /// Formats stop duration from hours to days format
  String _formatStopDuration(String stopDuration) {
    if (stopDuration.contains("h")) {
      try {
        // Extract hours from the string (e.g., "2238h 51min 5sec")
        final hourEnd = stopDuration.indexOf("h");
        final hoursStr = stopDuration.substring(0, hourEnd).trim();
        final hours = int.parse(hoursStr);

        // Extract minutes if available
        int minutes = 0;
        if (stopDuration.contains("min")) {
          final minStart = stopDuration.indexOf("h") + 1;
          final minEnd = stopDuration.indexOf("min");
          final minStr = stopDuration.substring(minStart, minEnd).trim();
          minutes = int.parse(minStr);
        }

        // Convert to days, hours, minutes
        final days = hours ~/ 24;
        final remainingHours = hours % 24;

        if (days > 0) {
          if (remainingHours > 0) {
            return "${days} jours ${remainingHours}h ${minutes}min";
          } else {
            return "${days} jours ${minutes}min";
          }
        } else {
          return "${remainingHours}h ${minutes}min";
        }
      } catch (e) {
        return stopDuration; // Return original if parsing fails
      }
    }
    return stopDuration;
  }

  String _getIconPrefix(deviceItems productData) {
    // 1. Check icon ID returned directly from server
    String iconId = (productData.icon?.id ?? productData.deviceData?.iconId ?? "").toString();
    switch (iconId) {
      case "1": return "car_";
      case "2": return "truck_";
      case "3": return "bus_";
      case "4": return "bike_";
      case "5": return "tractor_";
      case "6": return "ambulance_";
      case "7": return "car3_";
      case "8": return "erickshaw_";
      case "9": return "cycle_";
      case "10": return "scotty_";
      case "11": return "car1_";
      case "12": return "car2_";
    }

    // 2. Check category / icon type / icon path strings
    String iconType = (productData.category ?? productData.icon?.type ?? productData.icon?.path ?? "").toLowerCase();
    if (iconType.contains("truck") || iconType.contains("objects2a_04")) return "truck_";
    if (iconType.contains("bike") || iconType.contains("motorcycle") || iconType.contains("objects2a_07")) return "bike_";
    if (iconType.contains("bus")) return "bus_";
    if (iconType.contains("ambulance")) return "ambulance_";
    if (iconType.contains("tractor")) return "tractor_";
    if (iconType.contains("buldozer") || iconType.contains("bulldozer")) return "buldozer_";
    if (iconType.contains("pickup")) return "pickup_";
    if (iconType.contains("suv")) return "suv_";
    if (iconType.contains("scotty") || iconType.contains("scooter")) return "scotty_";
    if (iconType.contains("car3")) return "car3_";
    if (iconType.contains("car1")) return "car1_";
    if (iconType.contains("car2")) return "car2_";

    // 3. Check local SharedPreferences fallback
    String imei = productData.deviceData?.imei ?? "";
    String devId = productData.id?.toString() ?? "";
    try {
      String? prefIcon = prefs.getString(imei) ??
          prefs.getString(devId) ??
          prefs.getString("icon_$imei") ??
          prefs.getString("icon_$devId");

      if (prefIcon != null && prefIcon.isNotEmpty) {
        return prefIcon;
      }
    } catch (_) {}

    return "car_";
  }

  /// Determines the device icon based on status and selected vehicle icon
  String _getDeviceIcon(deviceItems productData, String ignition, int speed, String stopDuration) {
    String prefix = _getIconPrefix(productData);

    if (prefix == "car3_") {
      if (speed > 0) return 'assets/vehcileIcon/car3_toprunning.png';
      return 'assets/vehcileIcon/car3_sidestop.png';
    }

    if (productData.online.toString().contains("offline") &&
        !productData.time.toString().contains("Not connected") &&
        !productData.time.toString().contains("Expired")) {
      return 'assets/vehcileIcon/${prefix}sideinactive.png';
    } else if (productData.time!.contains('Not connected')) {
      return 'assets/vehcileIcon/${prefix}sidenodata.png';
    } else if (speed > 0) {
      return 'assets/vehcileIcon/${prefix}siderunning.png';
    } else if (ignition.contains("true") &&
        !productData.online.toString().contains("offline") &&
        speed < 1.0) {
      return 'assets/vehcileIcon/${prefix}sideidle.png';
    } else if (productData.online!.contains('online')) {
      return 'assets/vehcileIcon/${prefix}siderunning.png';
    } else {
      return 'assets/vehcileIcon/${prefix}sidestop.png';
    }
  }

  /// Determines the device status text
  String _getDeviceStatus(deviceItems productData, String ignition, int speed) {
    if (_isVehicleExpired(productData)) {
      return "Expiré";
    }
    if (speed > 0) {
      return "En mouvement";
    }
    if (ignition.contains("true") && speed == 0) {
      return "Au ralenti";
    }
    return "Stationnement";
  }

  /// Determines the status color based on state
  Color _getStatusColor(deviceItems productData, String ignition, int speed) {
    if (_isVehicleExpired(productData)) {
      return Colors.grey.withOpacity(0.2);
    }
    if (speed > 0) {
      return Colors.green.withOpacity(0.1);
    }
    if (ignition.contains("true") && speed == 0) {
      return const Color(0xFFFFB000).withValues(alpha: 0.15);
    }
    return Colors.red.withOpacity(0.2);
  }

  /// Builds the top row with device name and expiry date
  Widget _buildTopRow(deviceItems productData) {
    String name = productData.deviceData?.name ?? productData.name ?? "Véhicule";
    String? expirationDateStr = productData.deviceData?.expirationDate?.toString();
    
    bool isExpired = _isVehicleExpired(productData);
    String badgeText = isExpired ? "Expiré" : "Non défini";
    Color badgeColor = isExpired ? Colors.red : Colors.grey;
    IconData icon = isExpired ? Icons.cancel : Icons.event_note;
    
    if (expirationDateStr != null && expirationDateStr.isNotEmpty) {
      String lower = expirationDateStr.toLowerCase().trim();
      if (lower.contains("expire") || lower.contains("expiré") || lower.contains("0000-00-00")) {
        badgeText = "Expiré";
        badgeColor = Colors.red;
        icon = Icons.cancel;
      } else {
        try {
          DateTime expDate = DateTime.parse(expirationDateStr);
          DateTime now = DateTime.now();
          DateTime expDateOnly = DateTime(expDate.year, expDate.month, expDate.day);
          DateTime nowOnly = DateTime(now.year, now.month, now.day);
          
          int diff = expDateOnly.difference(nowOnly).inDays;
          
          if (diff <= 0) {
            badgeText = "Expired".tr;
            badgeColor = Colors.red;
            icon = Icons.cancel;
          } else if (diff == 1) {
            badgeText = "1 ${'dayRemaining'.tr}";
            badgeColor = Colors.orange;
            icon = Icons.hourglass_empty;
          } else if (diff <= 15) {
            badgeText = "$diff ${'daysRemaining'.tr}";
            badgeColor = Colors.orange;
            icon = Icons.hourglass_top;
          } else {
            badgeText = "$diff ${'daysRemaining'.tr}";
            badgeColor = const Color(0xff26C090); // Green
            icon = Icons.check_circle;
          }
        } catch (e) {
          if (isExpired) {
            badgeText = "Expiré";
            badgeColor = Colors.red;
            icon = Icons.cancel;
          }
        }
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xff0344a0),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: badgeColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: badgeColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 12, color: badgeColor),
              const SizedBox(width: 4),
              Text(
                badgeText,
                style: TextStyle(
                  fontSize: 11,
                  color: badgeColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


  /// Builds the vehicle image
  Widget _buildVehicleIcon(String iconpath) {
    return Image.asset(iconpath, height: 50, width: 50);
  }

  /// Builds vehicle information
  Widget _buildVehicleInfo(deviceItems productData, String time, String stopDuration) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text("Last Updated: $time", style: const TextStyle(fontSize: 12, color: Colors.black)),
        Text("Stopped: $stopDuration", style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  /// Builds the speed indicator
  Widget _buildSpeedIndicator(int speed) {
    double maxSpeed = 180; // Maximum speed range
    double angle = (speed / maxSpeed) * 180; // Calculate rotation angle

    // Define dynamic color based on speed range
    Color speedColor;
    if (speed == 0) {
      speedColor = Colors.grey;
    } else if (speed > 0 && speed <= 30) {
      speedColor = Colors.green;
    } else if (speed > 30 && speed <= 60) {
      speedColor = Colors.orange;
    } else {
      speedColor = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: speedColor.withOpacity(0.5),
            blurRadius: 6,
            spreadRadius: 1,
            offset: const Offset(2, 3),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Circular Progress Background (Smaller)
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              value: speed / maxSpeed,
              strokeWidth: 5, // Thinner stroke
              backgroundColor: Colors.grey.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation(speedColor),
            ),
          ),

          // Speed Text (Centered)
          Column(
            children: [
              Text(
                "$speed",
                style: TextStyle(
                  fontSize: 14, // Smaller text
                  fontWeight: FontWeight.bold,
                  color: speedColor,
                ),
              ),
              const Text(
                "Km/h",
                style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }


  /// Builds location row with GPS & GSM icons on the bottom left (without text)
  Widget _buildLocationRow(double lat, double lng, int gsm) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isGpsGsmActive = gsm >= 3;
    final iconStatusColor = isGpsGsmActive ? CustomColor.statusDriving : CustomColor.statusOffline;

    return Row(
      children: [
        // GPS Icon (Without text)
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: iconStatusColor.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Image.asset(
            "assets/icon/sattelite2.png",
            height: 14,
            width: 14,
            color: iconStatusColor,
          ),
        ),
        const SizedBox(width: 5),
        // GSM Icon (Without text)
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: iconStatusColor.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Image.asset(
            "assets/icon/signal.png",
            height: 14,
            width: 14,
            color: iconStatusColor,
          ),
        ),
        const SizedBox(width: 8),
        Icon(
          Icons.location_on_rounded,
          size: 15,
          color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0344a0),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: addressLoad(lat.toString(), lng.toString()),
        ),
      ],
    );
  }

  /// Builds Sensor Indicators Row
  Widget _buildSensorIndicators(String ignition, int gsm, int batterylevel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildSensorBadge(
            iconPath: "assets/images/engine.png",
            label: "Allumage",
            isActive: ignition.contains("true"),
          ),
          _buildSensorBadge(
            iconPath: "assets/icon/sattelite2.png",
            label: "GPS",
            isActive: gsm >= 3,
          ),
          _buildSensorBadge(
            iconPath: "assets/icon/battery1.png",
            label: "Batterie",
            isActive: batterylevel >= 3,
          ),
          _buildSensorBadge(
            iconPath: "assets/icon/signal.png",
            label: "GSM",
            isActive: gsm >= 3,
          ),
        ],
      ),
    );
  }

  /// Helper method to build a single sensor indicator
  Widget _buildSensorBadge({
    required String iconPath,
    required String label,
    required bool isActive,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isActive ? Colors.green : Colors.red, width: 1),
      ),
      child: Row(
        children: [
          Image.asset(
            iconPath,
            height: 15,
            width: 15,
            color: isActive ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  void _sendSMSCommand(String simNumber, String smsBody) async {
    final String bodyEncoded = Uri.encodeComponent(smsBody);
    String uriString = "sms:$simNumber?body=$bodyEncoded";
    
    bool isIOS = false;
    try {
      isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    } catch (_) {}

    if (isIOS) {
      uriString = "sms:$simNumber&body=$bodyEncoded";
    }

    final Uri smsUri = Uri.parse(uriString);
    try {
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Impossible d'ouvrir l'application SMS")),
        );
      }
    } catch (e) {
      print("SMS launch error: $e");
    }
  }

  void _showEngineControlDialog(deviceItems productData) {
    final String name = productData.name ?? "Véhicule";
    final String imei = productData.deviceData?.imei ?? "Inconnu";
    final String simNumber = productData.deviceData?.simNumber ?? "";
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 10,
          child: Container(
            padding: const EdgeInsets.all(20),
            width: 330,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header (Matricule, IMEI & Top Right Close button 'X')
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(width: 34),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            name,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "IMEI: $imei",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: isDark ? Colors.white70 : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                ),
                const SizedBox(height: 16),

                // Top Option Card: ARRÊTER (OFF)
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    if (simNumber.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Numéro SIM du véhicule introuvable".tr)),
                      );
                      return;
                    }
                    _sendSMSCommand(simNumber, "cap 2022 setdigout 1");
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF451A03).withOpacity(0.25) : const Color(0xFFFFF1F2),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFFFECDD3).withOpacity(isDark ? 0.2 : 0.6),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Power OFF Circle with glowing rings
                        Container(
                          width: 86,
                          height: 86,
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red.withOpacity(0.08),
                            border: Border.all(
                              color: const Color(0xFFEF4444).withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark ? const Color(0xFF0F172A) : Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFEF4444).withOpacity(0.2),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.power_settings_new_rounded,
                                  color: Color(0xFFEF4444),
                                  size: 34,
                                ),
                                SizedBox(height: 2),
                                Text(
                                  "OFF",
                                  style: TextStyle(
                                    color: Color(0xFFEF4444),
                                    fontWeight: FontWeight.w800,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "ARRÊTER".tr,
                          style: const TextStyle(
                            color: Color(0xFFEF4444),
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Éteindre le véhicule".tr,
                          style: TextStyle(
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Middle Divider line with center dot
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 1,
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark ? const Color(0xFF64748B) : const Color(0xFFCBD5E1),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 1,
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Bottom Option Card: DÉMARRER (ON)
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    if (simNumber.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Numéro SIM du véhicule introuvable".tr)),
                      );
                      return;
                    }
                    _sendSMSCommand(simNumber, "cap 2022 setdigout 0");
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF064E3B).withOpacity(0.25) : const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFBA7F3D0).withOpacity(isDark ? 0.2 : 0.6),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Power ON Circle with glowing rings
                        Container(
                          width: 86,
                          height: 86,
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.green.withOpacity(0.08),
                            border: Border.all(
                              color: const Color(0xFF10B981).withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark ? const Color(0xFF0F172A) : Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF10B981).withOpacity(0.2),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.power_settings_new_rounded,
                                  color: Color(0xFF10B981),
                                  size: 34,
                                ),
                                SizedBox(height: 2),
                                Text(
                                  "ON",
                                  style: TextStyle(
                                    color: Color(0xFF10B981),
                                    fontWeight: FontWeight.w800,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "DÉMARRER".tr,
                          style: const TextStyle(
                            color: Color(0xFF10B981),
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Démarrer le véhicule".tr,
                          style: TextStyle(
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Fermer Button (Full-width blue pill without icon)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1D4ED8),
                      elevation: 4,
                      shadowColor: const Color(0xFF1D4ED8).withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "Fermer".tr,
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
        );
      },
    );
  }

  /// Helper method to build engine control button
  Widget _buildEngineButton(deviceItems productData) {
    return GestureDetector(
      onTap: () {
        // Store device info and display popup dialog
        StaticVarMethod.deviceName = productData.name.toString();
        StaticVarMethod.deviceId = productData.id.toString();
        StaticVarMethod.imei = productData.deviceData!.imei.toString();
        StaticVarMethod.simno = productData.deviceData!.simNumber.toString();

        _showEngineControlDialog(productData);
      },
      child: Container(
        width: 58,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xff0344a0), Color(0xff0562d4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xff0344a0).withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            const Icon(Icons.lock, size: 18, color: Colors.white),
            const SizedBox(height: 4),
            Text(
              'Engine'.tr,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHistoryRangeDialog(deviceItems productData) {
    DateTime fromDate = DateTime.now();
    DateTime toDate = DateTime.now();
    final String name = productData.name ?? "Véhicule";
    final String imei = productData.deviceData?.imei ?? "Inconnu";
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            String fromStr = DateFormat('dd/MM/yyyy').format(fromDate);
            String toStr = DateFormat('dd/MM/yyyy').format(toDate);

            void launchPlayback(DateTime start, DateTime end) {
              StaticVarMethod.deviceName = productData.name.toString();
              StaticVarMethod.deviceId = productData.id.toString();
              StaticVarMethod.imei = productData.deviceData!.imei.toString();
              StaticVarMethod.simno = productData.deviceData!.simNumber.toString();
              StaticVarMethod.lat = productData.lat!.toDouble();
              StaticVarMethod.lng = productData.lng!.toDouble();

              StaticVarMethod.fromdate = DateFormat('yyyy-MM-dd').format(start);
              StaticVarMethod.todate = DateFormat('yyyy-MM-dd').format(end);
              StaticVarMethod.fromtime = "00:00";
              StaticVarMethod.totime = "23:59";

              Navigator.pop(context); // Close dialog
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PlaybackPage()),
              );
            }

            return Dialog(
              backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              elevation: 10,
              child: Container(
                padding: const EdgeInsets.all(20),
                width: 330,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header (Matricule, IMEI & Top Right Close button 'X')
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(width: 34),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                name,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "IMEI: $imei",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: isDark ? Colors.white70 : const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                    ),
                    const SizedBox(height: 18),

                    // Date Selectors: Du & Au
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // From Date
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Du", style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            GestureDetector(
                              onTap: () async {
                                final DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: fromDate,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime.now().add(const Duration(days: 365)),
                                );
                                if (picked != null) {
                                  setState(() {
                                    fromDate = picked;
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                                  borderRadius: BorderRadius.circular(12),
                                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.calendar_today_rounded, size: 16, color: Color(0xFF1D4ED8)),
                                    const SizedBox(width: 8),
                                    Text(fromStr, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F172A))),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        // To Date
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Au", style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            GestureDetector(
                              onTap: () async {
                                final DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: toDate,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime.now().add(const Duration(days: 365)),
                                );
                                if (picked != null) {
                                  setState(() {
                                    toDate = picked;
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                                  borderRadius: BorderRadius.circular(12),
                                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.calendar_today_rounded, size: 16, color: Color(0xFF1D4ED8)),
                                    const SizedBox(width: 8),
                                    Text(toStr, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F172A))),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Shortcuts title
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Raccourcis rapide",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    
                    // Shortcuts buttons
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        _shortcutButton(context, "Aujourd'hui", () {
                          launchPlayback(DateTime.now(), DateTime.now());
                        }),
                        _shortcutButton(context, "Hier", () {
                          launchPlayback(
                            DateTime.now().subtract(const Duration(days: 1)),
                            DateTime.now().subtract(const Duration(days: 1)),
                          );
                        }),
                        _shortcutButton(context, "Cette semaine", () {
                          launchPlayback(
                            DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1)),
                            DateTime.now(),
                          );
                        }),
                        _shortcutButton(context, "Ce mois", () {
                          launchPlayback(
                            DateTime(DateTime.now().year, DateTime.now().month, 1),
                            DateTime.now(),
                          );
                        }),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Full width Blue Pill Action Button (Rechercher l'historique)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1D4ED8),
                          elevation: 4,
                          shadowColor: const Color(0xFF1D4ED8).withOpacity(0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () {
                          launchPlayback(fromDate, toDate);
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text(
                              "Rechercher l'historique",
                              style: TextStyle(
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
              ),
            );
          },
        );
      },
    );
  }

  Widget _shortcutButton(BuildContext context, String label, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.grey.shade100,
        foregroundColor: CustomColor.primaryAccent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: isDark ? const Color(0x3338BDF8) : Colors.grey.shade300),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      ),
      onPressed: onTap,
      child: Text(
        label,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildHistoryButton(deviceItems productData) {
    return GestureDetector(
      onTap: () {
        _showHistoryRangeDialog(productData);
      },
      child: Container(
        width: 58,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE83F82), Color(0xFFFF6B8B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE83F82).withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            const Icon(Icons.history, size: 18, color: Colors.white),
            const SizedBox(height: 4),
            Text(
              'History'.tr,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Navigates to the Live Tracking screen with device details
  void _navigateToLiveTracking(deviceItems productData, String devicestatus, Color statuscolor) {
    // Store selected device details in StaticVarMethod for global access
    StaticVarMethod.deviceName = productData.name.toString();
    StaticVarMethod.deviceId = productData.id.toString();
    StaticVarMethod.imei = productData.deviceData!.imei.toString();
    StaticVarMethod.simno = productData.deviceData!.simNumber.toString();
    StaticVarMethod.lat = productData.lat!.toDouble();
    StaticVarMethod.lng = productData.lng!.toDouble();
    StaticVarMethod.devicestatus = devicestatus;
    StaticVarMethod.devicestatuscolor = statuscolor;

    // Navigate to Live Tracking Screen using GetX for smooth transitions
    Get.to(() => LiveMapScreen(), duration: const Duration(milliseconds: 300));
  }

  Widget _showbottomPopup() {
    double imageSize = MediaQuery.of(context).size.width / 17;
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter mystate) {
      return Container(
          margin: const EdgeInsets.only(left: 0, right: 0, bottom: 0),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /* Center(
            child: Container(
              margin: EdgeInsets.only(top: 12, bottom: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey[500],
                  borderRadius: BorderRadius.circular(10)
              ),
            ),
          ),*/
              Center(
                child: Container(
                  margin: const EdgeInsets.only(
                    top: 12,
                  ),
                  /* width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey[500],
                  borderRadius: BorderRadius.circular(10)
              ),*/
                  child: Text('${StaticVarMethod.deviceName}',
                      style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black,
                          fontWeight: FontWeight.bold)),
                ),
              ),

              Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: Column(
                          children: <Widget>[
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      //  builder: (context) => livetracknew()),
                                      builder: (context) => LiveMapScreen()),
                                );
                              },
                              child: Container(
                                  child: Column(children: <Widget>[
                                Image.asset(
                                    "assets/images/movingdurationicon.png",
                                    height: imageSize,
                                    width: imageSize),
                                Text('LiveMap'.tr,
                                    style: const TextStyle(fontSize: 12, height: 2))
                              ])),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: <Widget>[
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => kmdetail()),
                                );
                              },
                              child: Container(
                                  // padding: EdgeInsets.all(8),

                                  /*  decoration: new BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.rectangle,
                                    borderRadius:BorderRadius.all(Radius.circular(15)),
                                    // borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 1.0,
                                        //offset: const Offset(0.0, 10.0),
                                      ),
                                    ],
                                  ),*/
                                  // color: Colors.white,
                                  //color: Color(0x99FFFFFF),
                                  child: Column(children: <Widget>[
                                Image.asset(
                                    "assets/images/icons8-bar-chart-100.png",
                                    height: imageSize,
                                    width: imageSize),
                                Text('Mileage'.tr,
                                    style: const TextStyle(fontSize: 12, height: 2.0))
                              ])),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: <Widget>[
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          playbackselection()),
                                  //playbackwialonnew()),
                                );
                              },
                              child: Container(
                                  //    padding: EdgeInsets.all(8),

                                  /*     decoration: new BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.rectangle,
                                    borderRadius:BorderRadius.all(Radius.circular(15)),
                                    // borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 1.0,
                                        //offset: const Offset(0.0, 10.0),
                                      ),
                                    ],
                                  ),*/
                                  // color: Colors.white,
                                  //color: Color(0x99FFFFFF),
                                  child: Column(children: <Widget>[
                                Image.asset("assets/images/icons8-play-100.png",
                                    height: imageSize, width: imageSize),
                                Text('Playback'.tr,
                                    style: const TextStyle(fontSize: 12, height: 2.0))
                              ])),
                            ),
                          ],
                        ),
                      ),
                      // Expanded(
                      //   child: Column(
                      //     children: <Widget>[
                      //       GestureDetector(
                      //         onTap: () {
                      //           String url =
                      //               'http://maps.google.com/maps?q=${StaticVarMethod.lat},${StaticVarMethod.lng}';
                      //           launchWhatsApp("11111111111", url);
                      //         },
                      //         child: Container(
                      //           //  padding: EdgeInsets.all(8),
                      //
                      //           /*     decoration: new BoxDecoration(
                      //           color: Colors.white,
                      //           shape: BoxShape.rectangle,
                      //           borderRadius:BorderRadius.all(Radius.circular(15)),
                      //           // borderRadius: BorderRadius.circular(8),
                      //           boxShadow: [
                      //             BoxShadow(
                      //               color: Colors.black26,
                      //               blurRadius: 1.0,
                      //               //offset: const Offset(0.0, 10.0),
                      //             ),
                      //           ],
                      //         ),*/
                      //           // color: Colors.white,
                      //           //color: Color(0x99FFFFFF),
                      //             child: Column(children: <Widget>[
                      //               Image.asset(
                      //                   "assets/nepalicon/share-location.png",
                      //                   height: imageSize,
                      //                   width: imageSize),
                      //               Text('Share'.tr,
                      //                   style: TextStyle(fontSize: 12, height: 2.0))
                      //             ])),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                    ],
                  )),

              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => reportselection()),
                              );
                            },
                            child: Container(
                                //     padding: EdgeInsets.all(8),

                                /*   decoration: new BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.rectangle,
                                  borderRadius:BorderRadius.all(Radius.circular(15)),
                                  // borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 1.0,
                                      //offset: const Offset(0.0, 10.0),
                                    ),
                                  ],
                                ),*/
                                // color: Colors.white,
                                //color: Color(0x99FFFFFF),
                                child: Column(children: <Widget>[
                              Image.asset(
                                  "assets/images/icons8-bar-chart-100.png",
                                  height: imageSize,
                                  width: imageSize),
                              Text('Reports'.tr,
                                  style: const TextStyle(fontSize: 12, height: 2.0))
                            ])),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //       builder: (context) => CommandWindowPage()),
                              // );

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => lockscreenNew()),
                              );
                            },
                            child: Container(
                                // padding: EdgeInsets.all(8),

                                /*   decoration: new BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.rectangle,
                                  borderRadius:BorderRadius.all(Radius.circular(15)),
                                  // borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 1.0,
                                      //offset: const Offset(0.0, 10.0),
                                    ),
                                  ],
                                ),*/
                                // color: Colors.white,
                                //color: Color(0x99FFFFFF),
                                child: Column(children: <Widget>[
                              Image.asset("assets/images/icons8-play-100.png",
                                  height: imageSize, width: imageSize),
                              Text('Lock'.tr,
                                  style: const TextStyle(fontSize: 12, height: 2.0))
                            ])),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => vehicle_info()),
                                //builder: (context) => vehicle_dasboard()),
                              );

                              //_onMapTypeButtonPressed();
                            },
                            child: Container(
                                //   padding: EdgeInsets.all(8),

                                /*   decoration: new BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.rectangle,
                                  borderRadius:BorderRadius.all(Radius.circular(15)),
                                  // borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 1.0,
                                      //offset: const Offset(0.0, 10.0),
                                    ),
                                  ],
                                ),*/
                                // color: Colors.white,
                                //color: Color(0x99FFFFFF),
                                child: Column(children: <Widget>[
                              Image.asset(
                                  "assets/images/icons8-info-popup-100.png",
                                  height: imageSize,
                                  width: imageSize),
                              Text('VehicleInfo'.tr,
                                  style: const TextStyle(fontSize: 12, height: 2.0))
                            ])),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        tripinfoselectionscreen()),
                                //   builder: (context) => tasks()),
                              );
                            },
                            child: Container(
                                //  padding: EdgeInsets.all(8),

                                /*   decoration: new BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.rectangle,
                                  borderRadius:BorderRadius.all(Radius.circular(15)),
                                  // borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 1.0,
                                      //offset: const Offset(0.0, 10.0),
                                    ),
                                  ],
                                ),*/
                                // color: Colors.white,
                                //color: Color(0x99FFFFFF),
                                child: Column(children: <Widget>[
                              Image.asset(
                                  "assets/images/icons8-bar-chart-100.png",
                                  height: imageSize,
                                  width: imageSize),
                              Text('Trips'.tr,
                                  style: const TextStyle(fontSize: 12, height: 2.0))
                            ])),
                          ),
                        ],
                      ),
                    ),

                  ],
                ),
              ),
            ],
          ));
    });
  }

  // add marker
  Set<Marker> getmarkers(double lat, double lng, double course, String imei) {
    // void _addMarker(double lat, double lng,int index) {
    LatLng position = LatLng(lat, lng);

    // set initial marker
    markers.add(Marker(
      markerId: MarkerId(imei),
      anchor: const Offset(0.5, 0.5),
      position: position,
      rotation: course,
      /*  infoWindow: InfoWindow(title: 'This is marker 1'),
      onTap: () {
        Fluttertoast.showToast(msg: 'Click marker', toastLength: Toast.LENGTH_SHORT);
      },*/
      icon: _markerDirection,
    ));

    if (_controller != null) {
      _controller!
          .animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, lng), 15));
    }

    return markers;
  }


  Future refreshData() async {
    setState(() {
      _historyFutures.clear();
      _addressFutures.clear();
      objectStore.getObjects();
    });
  }


  Widget addressLoad(String lat, String lng) {
    if (lat == "0" || lng == "0" || lat == "0.0" || lng == "0.0" || lat.isEmpty || lng.isEmpty) {
      return const Text("N/A", style: TextStyle(color: Colors.grey, fontSize: 11));
    }
    String key = "$lat,$lng";
    final future = _addressFutures.putIfAbsent(key, () => gpsapis.geocode(lat, lng));
    return FutureBuilder<String>(
        future: future,
        builder: (context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData) {
            return Container(
              width: 305,
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
              child: Text(
                (snapshot.data!.replaceAll('"', '')),
                style: const TextStyle(
                    color: Colors.black, fontFamily: "Popins", fontSize: 11),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            );
          } else {
            return const Text("Chargement...", style: TextStyle(fontSize: 11, color: Colors.grey));
          }
        });
  }

  launchWhatsApp(num, text) async {
    final link = WhatsAppUnilink(
      //  phoneNumber: num,
      text: text,
    );
    await launch('$link');
  }

  void _poidialogPopup(BuildContext context) {
    double imageSize = MediaQuery.of(context).size.width / 15;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return SimpleDialog(
            backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isDark ? const Color(0x3338BDF8) : const Color(0xFFE2E8F0),
                width: 1.2,
              ),
            ),
            title: Center(
                child: Text('Points d\'intérêt proches',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ))),
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                    margin: const EdgeInsets.only(top: 1, bottom: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: Column(
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  final url =
                                      'https://maps.google.com/maps?q=atm&cbll=${StaticVarMethod.lat},${StaticVarMethod.lng}';
                                  MapUtils.openMap(url);
                                  Navigator.of(context).pop();
                                },
                                child: Container(
                                    child: Column(children: <Widget>[
                                  Image.asset(
                                      "assets/nepalicon/atm_machine.png",
                                      height: imageSize,
                                      width: imageSize),
                                  const Text('DAB',
                                      style:
                                          TextStyle(fontSize: 10, height: 2.0))
                                ])),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  final url =
                                      'https://maps.google.com/maps?q=Petrol Pump&cbll=${StaticVarMethod.lat},${StaticVarMethod.lng}';
                                  MapUtils.openMap(url);
                                  Navigator.of(context).pop();
                                },
                                child: Container(

                                    //color: Color(0x99FFFFFF),
                                    child: Column(children: <Widget>[
                                  Image.asset(
                                      "assets/nepalicon/petrol_pump.png",
                                      height: imageSize,
                                      width: imageSize),
                                  const Text('Station-service',
                                      style:
                                          TextStyle(fontSize: 10, height: 2.0))
                                ])),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  final url =
                                      'https://maps.google.com/maps?q=Gas Station&cbll=${StaticVarMethod.lat},${StaticVarMethod.lng}';
                                  MapUtils.openMap(url);
                                  Navigator.of(context).pop();
                                },
                                child: Container(
                                    child: Column(children: <Widget>[
                                  Image.asset("assets/nepalicon/gas_pump.png",
                                      height: imageSize, width: imageSize),
                                  const Text('Station de gaz',
                                      style:
                                          TextStyle(fontSize: 10, height: 2.0))
                                ])),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  final url =
                                      'https://maps.google.com/maps?q=Charge Station&cbll=${StaticVarMethod.lat},${StaticVarMethod.lng}';
                                  MapUtils.openMap(url);
                                  Navigator.of(context).pop();
                                },
                                child: Container(
                                    child: Column(children: <Widget>[
                                  Image.asset(
                                      "assets/nepalicon/battery_volt.png",
                                      height: imageSize,
                                      width: imageSize),
                                  const Text('Borne de recharge',
                                      style:
                                          TextStyle(fontSize: 10, height: 2.0))
                                ])),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )),
                Container(
                    margin: const EdgeInsets.only(/*top: 12,*/ bottom: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: Column(
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  final url =
                                      'https://maps.google.com/maps?q=Police Station&cbll=${StaticVarMethod.lat},${StaticVarMethod.lng}';
                                  MapUtils.openMap(url);
                                  Navigator.of(context).pop();
                                },
                                child: Container(
                                    child: Column(children: <Widget>[
                                  Image.asset(
                                      "assets/nepalicon/police_station.png",
                                      height: imageSize,
                                      width: imageSize),
                                  const Text('Poste de police',
                                      style:
                                          TextStyle(fontSize: 10, height: 2.0))
                                ])),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  final url =
                                      'https://maps.google.com/maps?q=Restaurant&cbll=${StaticVarMethod.lat},${StaticVarMethod.lng}';
                                  MapUtils.openMap(url);
                                  Navigator.of(context).pop();
                                },
                                child: Container(
                                    child: Column(children: <Widget>[
                                  Image.asset("assets/nepalicon/restaurant.png",
                                      height: imageSize, width: imageSize),
                                  const Text('Restaurant',
                                      style:
                                          TextStyle(fontSize: 10, height: 2.0))
                                ])),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  final url =
                                      'https://maps.google.com/maps?q=hospital&cbll=${StaticVarMethod.lat},${StaticVarMethod.lng}';
                                  MapUtils.openMap(url);
                                  Navigator.of(context).pop();
                                },
                                child: Container(
                                    child: Column(children: <Widget>[
                                  Image.asset("assets/nepalicon/hospital.png",
                                      height: imageSize, width: imageSize),
                                  const Text('Médical',
                                      style:
                                          TextStyle(fontSize: 10, height: 2.0))
                                ])),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  final url =
                                      'https://maps.google.com/maps?q=Restroom&cbll=${StaticVarMethod.lat},${StaticVarMethod.lng}';
                                  MapUtils.openMap(url);
                                  Navigator.of(context).pop();
                                },
                                child: Container(
                                    child: Column(children: <Widget>[
                                  Image.asset("assets/nepalicon/hotel.png",
                                      height: imageSize, width: imageSize),
                                  const Text('Toilettes',
                                      style:
                                          TextStyle(fontSize: 10, height: 2.0))
                                ])),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )),
              ]),
            ],
          );
        });
  }
}