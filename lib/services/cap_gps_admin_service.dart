import 'dart:async';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/static.dart';

class CapGpsDeviceModel {
  final int id;
  final String name;
  final String imei;

  CapGpsDeviceModel({required this.id, required this.name, required this.imei});

  factory CapGpsDeviceModel.fromJson(Map<String, dynamic> json) {
    return CapGpsDeviceModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? 'Appareil',
      imei: json['imei']?.toString() ?? 'N/A',
    );
  }
}

class CapGpsAdminService {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    followRedirects: false,
    validateStatus: (status) => true, // Handle status codes without throwing DioException
  ));

  final CookieJar _cookieJar = CookieJar();

  CapGpsAdminService() {
    _dio.interceptors.add(CookieManager(_cookieJar));
  }

  Future<String> _extractXsrfToken() async {
    try {
      final uri = Uri.parse(StaticVarMethod.baseurlall);
      final cookies = await _cookieJar.loadForRequest(uri);
      for (var cookie in cookies) {
        if (cookie.name == 'XSRF-TOKEN') {
          return Uri.decodeComponent(cookie.value);
        }
      }
    } catch (_) {}
    return '';
  }

  /// **1. Authenticate web session via Laravel Control Panel (/authentication/store)**
  Future<bool> loginWebAdmin({String? email, String? password}) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String userEmail = email ?? prefs.getString('email') ?? '';
      String userPassword = password ?? prefs.getString('password') ?? '';

      if (userEmail.isEmpty || userPassword.isEmpty) {
        return false;
      }

      // Step A: Initial GET /login to extract initial cookies and CSRF token
      final String loginUrl = '${StaticVarMethod.baseurlall}/login';
      final responseGet = await _dio.get(loginUrl);

      String csrfToken = '';
      if (responseGet.data is String) {
        final html = responseGet.data as String;
        final match = RegExp(r'name="_token"\s+type="hidden"\s+value="([^"]+)"').firstMatch(html) ??
                      RegExp(r'name="csrf-token"\s+content="([^"]+)"').firstMatch(html);
        if (match != null) {
          csrfToken = match.group(1) ?? '';
        }
      }

      String xsrfToken = await _extractXsrfToken();
      if (csrfToken.isEmpty) csrfToken = xsrfToken;

      // Step B: POST credentials to /authentication/store
      final String authUrl = '${StaticVarMethod.baseurlall}/authentication/store';
      Map<String, dynamic> loginData = {
        'email': userEmail,
        'password': userPassword,
      };
      if (csrfToken.isNotEmpty) {
        loginData['_token'] = csrfToken;
      }

      Map<String, String> headers = {
        'X-Requested-With': 'XMLHttpRequest',
      };
      if (xsrfToken.isNotEmpty) {
        headers['X-XSRF-TOKEN'] = xsrfToken;
      }

      final responsePost = await _dio.post(
        authUrl,
        data: loginData,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: headers,
        ),
      );

      // 302 Found redirect to /admin or 200 OK means web session authenticated successfully
      return responsePost.statusCode == 200 || responsePost.statusCode == 302;
    } catch (e) {
      print('CapGpsAdminService web login error: $e');
      return false;
    }
  }

  /// **2. Create sub-user and bind selected devices via Laravel Web Form & Assign Route**
  Future<Map<String, dynamic>> createSubUserWeb({
    required String name,
    required String email,
    String? phone,
    required String password,
    required List<String> selectedDeviceIds,
    String roleId = '5',
    String groupId = '5',
  }) async {
    try {
      // Step A: Ensure web session is active
      bool isLogged = await loginWebAdmin();
      if (!isLogged) {
        return {'success': false, 'message': 'Session web administrateur non disponible.'};
      }

      // Step B: GET /admin/clients/create to retrieve fresh CSRF token
      final String createUrl = '${StaticVarMethod.baseurlall}/admin/clients/create';
      final createGet = await _dio.get(createUrl);

      String csrfToken = '';
      if (createGet.data is String) {
        final html = createGet.data as String;
        final match = RegExp(r'name="_token"\s+type="hidden"\s+value="([^"]+)"').firstMatch(html) ??
                      RegExp(r'name="csrf-token"\s+content="([^"]+)"').firstMatch(html);
        if (match != null) {
          csrfToken = match.group(1) ?? '';
        }
      }

      String xsrfToken = await _extractXsrfToken();
      if (csrfToken.isEmpty) csrfToken = xsrfToken;

      // Step C: Build FormData for POST /admin/clients
      FormData formData = FormData.fromMap({
        'email': email,
        'password': password,
        'password_confirmation': password,
        'role_id': roleId,
        'group_id': groupId,
        'active': 1,
        'devices_limit': 0,
      });

      if (name.isNotEmpty) {
        formData.fields.add(MapEntry('client[first_name]', name));
      }
      if (phone != null && phone.isNotEmpty) {
        formData.fields.add(MapEntry('phone_number', phone));
      }
      if (csrfToken.isNotEmpty) {
        formData.fields.add(MapEntry('_token', csrfToken));
      }

      List<String> defaultMapIds = ['70', '53', '51', '54', '55', '52', '71', '2'];
      for (String mapId in defaultMapIds) {
        formData.fields.add(MapEntry('available_maps[]', mapId));
      }

      if (selectedDeviceIds.isNotEmpty) {
        for (String devId in selectedDeviceIds) {
          formData.fields.add(MapEntry('objects[]', devId));
        }
      }

      Map<String, String> headers = {
        'X-Requested-With': 'XMLHttpRequest',
        'Accept': 'application/json',
      };
      if (xsrfToken.isNotEmpty) {
        headers['X-XSRF-TOKEN'] = xsrfToken;
      }

      final String submitUrl = '${StaticVarMethod.baseurlall}/admin/clients';
      final responsePost = await _dio.post(
        submitUrl,
        data: formData,
        options: Options(headers: headers),
      );

      bool createdOk = false;
      if (responsePost.statusCode == 200 || responsePost.statusCode == 302) {
        createdOk = true;
      } else if (responsePost.data is Map) {
        final dataMap = responsePost.data as Map;
        if (dataMap['status'] == 1 || dataMap['status'] == '1' || dataMap['success'] == true) {
          createdOk = true;
        }
      }

      if (!createdOk) {
        String errorMsg = 'Impossible d\'ajouter l\'utilisateur (erreur serveur ${responsePost.statusCode}).';
        if (responsePost.data is Map) {
          final dataMap = responsePost.data as Map;
          if (dataMap['message'] != null && !dataMap['message'].toString().contains("Whoops")) {
            errorMsg = dataMap['message'].toString();
          } else if (dataMap['errors'] != null) {
            if (dataMap['errors'] is Map) {
              final errs = (dataMap['errors'] as Map).values.map((e) => e.toString()).join(", ");
              if (errs.isNotEmpty) errorMsg = errs;
            } else {
              errorMsg = dataMap['errors'].toString();
            }
          }
        }
        return {'success': false, 'message': errorMsg};
      }

      // Step D: Attach selected devices via POST /admin/objects/assign
      if (selectedDeviceIds.isNotEmpty) {
        try {
          // Get newly created user ID from /admin/users/clients
          final clientsGet = await _dio.get('${StaticVarMethod.baseurlall}/admin/users/clients');
          String newUserId = '';
          if (clientsGet.data is String) {
            final html = clientsGet.data as String;
            final idx = html.indexOf(email);
            if (idx != -1) {
              final snippet = html.substring(idx, (idx + 1500 < html.length) ? idx + 1500 : html.length);
              final matchId = RegExp(r'clients/(\d+)/edit').firstMatch(snippet);
              if (matchId != null) {
                newUserId = matchId.group(1) ?? '';
              }
            }
          }

          if (newUserId.isNotEmpty) {
            FormData assignData = FormData.fromMap({
              'action': 'attach',
              'user_id[0]': newUserId,
            });
            if (csrfToken.isNotEmpty) {
              assignData.fields.add(MapEntry('_token', csrfToken));
            }
            for (int i = 0; i < selectedDeviceIds.length; i++) {
              assignData.fields.add(MapEntry('device_id[$i]', selectedDeviceIds[i]));
            }

            await _dio.post(
              '${StaticVarMethod.baseurlall}/admin/objects/assign',
              data: assignData,
              options: Options(headers: headers),
            );
          }
        } catch (e) {
          print('Error assigning objects to sub-user: $e');
        }
      }

      return {'success': true, 'message': 'Utilisateur créé et véhicules affectés avec succès !'};
    } catch (e) {
      print('CapGpsAdminService createSubUserWeb error: $e');
      return {'success': false, 'message': 'Erreur lors de la création de l\'utilisateur.'};
    }
  }
}
