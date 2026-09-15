import 'dart:collection';

import 'package:maktrogps/config/static.dart';
import 'package:maktrogps/data/datasources.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/model/devices.dart';

class ObjectStore extends ChangeNotifier {
  List<deviceItems> _objects = [];

  int get count => _objects.length;
  List<deviceItems> get objects => _objects;
  bool isLoading = true;

  void clear() {
    _objects = [];
    isLoading = true;
    notifyListeners();
  }

  void setObjects(List<deviceItems> list) {
    if (list.isNotEmpty) {
      _objects = list;
      StaticVarMethod.devicelist = _objects;
      isLoading = false;
      notifyListeners();
    }
  }

  void getObjects({bool forceLoading = false}) async {
    if (_objects.isEmpty || forceLoading) {
      isLoading = true;
      notifyListeners();
    }
    try {
      String hash = StaticVarMethod.user_api_hash ?? '';
      if (hash.isEmpty) {
        final prefs = await SharedPreferences.getInstance();
        hash = prefs.getString('user_api_hash') ?? '';
        if (hash.isNotEmpty) {
          StaticVarMethod.user_api_hash = hash;
        }
      }
      var list = await gpsapis.getDevicesList(hash);
      if (list != null && list.isNotEmpty) {
        _objects = list;
        StaticVarMethod.devicelist = _objects;
      } else if (StaticVarMethod.devicelist.isNotEmpty) {
        _objects = List.from(StaticVarMethod.devicelist);
      }
    } catch (e) {
      print("ObjectStore error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}