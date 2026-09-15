import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:maktrogps/data/datasources.dart';
import 'package:maktrogps/data/model/devices.dart';
import 'package:maktrogps/mvvm/view_model/objects.dart';
import 'package:provider/provider.dart';
import '../../config/static.dart';
import '../../services/cap_gps_admin_service.dart';

class AddUserPage extends StatefulWidget {
  const AddUserPage({Key? key}) : super(key: key);

  @override
  State<AddUserPage> createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _searchController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _searchQuery = "";
  List<String> _selectedDeviceIds = [];
  List<deviceItems> _devices = [];

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    List<deviceItems> objs = Provider.of<ObjectStore>(context, listen: false).objects;
    if (objs.isEmpty && StaticVarMethod.devicelist.isNotEmpty) {
      objs = StaticVarMethod.devicelist;
    }
    if (objs.isEmpty) {
      final fetched = await gpsapis.getDevicesList(StaticVarMethod.user_api_hash);
      if (fetched != null && fetched.isNotEmpty) {
        objs = fetched;
        StaticVarMethod.devicelist = fetched;
      }
    }
    if (mounted) {
      setState(() {
        _devices = objs;
        _selectedDeviceIds = objs
            .map((d) => (d.id?.toString() ?? d.deviceData?.id?.toString() ?? ""))
            .where((idStr) => idStr.isNotEmpty && idStr != "0" && idStr != "null")
            .toList();
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<deviceItems> get _filteredDevices {
    if (_searchQuery.isEmpty) return _devices;
    return _devices.where((device) {
      final name = (device.deviceData?.name ?? device.name ?? "").toLowerCase();
      final imei = (device.deviceData?.imei ?? "").toLowerCase();
      return name.contains(_searchQuery.toLowerCase()) ||
          imei.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    EasyLoading.show(status: "Création de l'utilisateur...".tr);

    try {
      // Primary: Create sub-user and bind selected devices via Laravel Web Form (/admin/clients)
      final webRes = await CapGpsAdminService().createSubUserWeb(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
        selectedDeviceIds: _selectedDeviceIds,
        roleId: '5',
        groupId: '5',
      );

      bool isSuccess = webRes['success'] == true;
      String errorMsg = webRes['message'] ?? "Erreur lors de la création de l'utilisateur".tr;

      // Fallback: If web session failed, try REST API endpoints
      if (!isSuccess) {
        final res = await gpsapis.addUserWithDevices(
          _nameController.text.trim(),
          _emailController.text.trim(),
          _phoneController.text.trim(),
          _passwordController.text,
          _selectedDeviceIds,
        );

        if (res.statusCode == 200) {
          try {
            final data = json.decode(res.body);
            if (data is Map) {
              if (data['status'] == 1 || data['status'] == '1' || data['success'] == true || data['id'] != null || data['user_id'] != null) {
                isSuccess = true;
              }
            } else {
              isSuccess = true;
            }
          } catch (_) {
            isSuccess = true;
          }
        }
      }

      EasyLoading.dismiss();

      if (isSuccess) {
        Fluttertoast.showToast(
          msg: "Utilisateur créé avec succès".tr,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        Fluttertoast.showToast(
          msg: errorMsg,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_LONG,
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
          "Ajouter Utilisateur".tr,
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF0F172A),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Card 1: User Information Form
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
                    // Field 1: Full Name
                    _buildFieldLabel("Nom complet".tr, isDark),
                    const SizedBox(height: 8),
                    _buildInputField(
                      controller: _nameController,
                      hintText: "Entrez le nom complet".tr,
                      icon: Icons.person_outline_rounded,
                      isDark: isDark,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? "Veuillez remplir tous les champs".tr
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // Field 2: Email
                    _buildFieldLabel("Email".tr, isDark),
                    const SizedBox(height: 8),
                    _buildInputField(
                      controller: _emailController,
                      hintText: "Entrez l'adresse email".tr,
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      isDark: isDark,
                      validator: (v) => (v == null || v.trim().isEmpty || !v.contains("@"))
                          ? "Email invalide".tr
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // Field 3: Phone
                    _buildFieldLabel("Téléphone".tr, isDark),
                    const SizedBox(height: 8),
                    _buildInputField(
                      controller: _phoneController,
                      hintText: "Entrez le numéro de téléphone".tr,
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      isDark: isDark,
                      validator: null,
                    ),
                    const SizedBox(height: 16),

                    // Field 4: Password
                    _buildFieldLabel("Mot de passe".tr, isDark),
                    const SizedBox(height: 8),
                    _buildInputField(
                      controller: _passwordController,
                      hintText: "Entrez le mot de passe".tr,
                      icon: Icons.lock_outline_rounded,
                      obscureText: _obscurePassword,
                      isDark: isDark,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          color: const Color(0xFF94A3B8),
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      validator: (v) => (v == null || v.length < 4)
                          ? "Le mot de passe doit contenir au moins 4 caractères".tr
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // Field 5: Confirm Password
                    _buildFieldLabel("Confirmer le mot de passe".tr, isDark),
                    const SizedBox(height: 8),
                    _buildInputField(
                      controller: _confirmPasswordController,
                      hintText: "Confirmez le mot de passe".tr,
                      icon: Icons.lock_reset_rounded,
                      obscureText: _obscureConfirmPassword,
                      isDark: isDark,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          color: const Color(0xFF94A3B8),
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                      validator: (v) {
                        if (v != _passwordController.text) {
                          return "Les mots de passe ne correspondent pas".tr;
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Card 2: Devices Selection Card (Same as AddAlerts)
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Vehicles".tr,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "${_selectedDeviceIds.length} ${_selectedDeviceIds.length == 1 ? 'sélectionné' : 'sélectionnés'}",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Search Input Bar
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
                              controller: _searchController,
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

                    // Devices List
                    if (_filteredDevices.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Center(
                          child: Text(
                            "Aucun véhicule trouvé".tr,
                            style: TextStyle(
                              color: isDark ? Colors.white54 : const Color(0xFF94A3B8),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _filteredDevices.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 20,
                          thickness: 1,
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFF8FAFC),
                        ),
                        itemBuilder: (context, index) {
                          final device = _filteredDevices[index];
                          final deviceIdStr = device.id?.toString() ?? device.deviceData?.id?.toString() ?? "";
                          final isSelected = _selectedDeviceIds.contains(deviceIdStr);

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedDeviceIds.remove(deviceIdStr);
                                } else {
                                  _selectedDeviceIds.add(deviceIdStr);
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
                                      device.deviceData?.name ?? device.name ?? "",
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
                  onPressed: _submitForm,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.person_add_rounded, color: Colors.white, size: 20),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label, bool isDark) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : const Color(0xFF0F172A),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required bool isDark,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Container(
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
              icon,
              color: const Color(0xFF3B82F6),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: controller,
              obscureText: obscureText,
              keyboardType: keyboardType,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                ),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
              ),
              validator: validator,
            ),
          ),
          if (suffixIcon != null) suffixIcon,
        ],
      ),
    );
  }
}
